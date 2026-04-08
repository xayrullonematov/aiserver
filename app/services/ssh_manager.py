import asyncio
import logging
from typing import AsyncGenerator, Dict, List, Optional, Any
import asyncssh
from fastapi import WebSocket

from app.core.config import settings
from app.core.security import decrypt_credentials
from app.models.server import ServerProfile

logger = logging.getLogger(__name__)

class SSHManager:
    _instance: Optional['SSHManager'] = None
    _connections: Dict[int, asyncssh.SSHClientConnection] = {}
    _profiles: Dict[int, ServerProfile] = {}
    _reconnect_tasks: Dict[int, asyncio.Task] = {}

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SSHManager, cls).__new__(cls)
        return cls._instance

    async def _get_connection(self, server_id: int) -> asyncssh.SSHClientConnection:
        """Get an active connection or raise error."""
        conn = self._connections.get(server_id)
        if conn is None or conn.is_closing():
            if server_id in self._profiles:
                logger.info(f"Connection for server {server_id} lost, attempting immediate reconnect.")
                return await self.connect(self._profiles[server_id])
            raise RuntimeError(f"No active SSH connection for server {server_id}")
        return conn

    async def connect(self, profile: ServerProfile) -> asyncssh.SSHClientConnection:
        """Connect to a remote server and store in pool."""
        server_id = profile.id
        self._profiles[server_id] = profile
        
        # Decrypt credentials
        secret = decrypt_credentials(profile.encrypted_credentials)
        
        connect_kwargs: Dict[str, Any] = {
            "host": profile.host,
            "port": profile.port,
            "username": profile.username,
            # NOTE: In production, known_hosts should be set to a valid path
            # to enable host key verification and prevent MITM attacks.
            # Setting it to None disables this security feature.
            "known_hosts": settings.KNOWN_HOSTS_FILE,
        }
        
        if profile.auth_type == "password":
            connect_kwargs["password"] = secret
        else:
            # Assume secret is the private key string
            connect_kwargs["client_keys"] = [asyncssh.import_private_key(secret)]

        try:
            conn = await asyncssh.connect(**connect_kwargs)
            self._connections[server_id] = conn
            logger.info(f"Successfully connected to {profile.display_name} ({profile.host})")
            
            # Cancel any existing reconnect task if we connected manually
            if server_id in self._reconnect_tasks:
                self._reconnect_tasks[server_id].cancel()
                del self._reconnect_tasks[server_id]
                
            return conn
        except Exception as e:
            logger.error(f"Failed to connect to {profile.display_name}: {str(e)}")
            # Start background reconnection if not already running
            if server_id not in self._reconnect_tasks:
                self._reconnect_tasks[server_id] = asyncio.create_task(
                    self._reconnect_with_backoff(server_id)
                )
            raise

    async def disconnect(self, server_id: int):
        """Close connection and remove from pool."""
        if server_id in self._reconnect_tasks:
            self._reconnect_tasks[server_id].cancel()
            del self._reconnect_tasks[server_id]
            
        conn = self._connections.pop(server_id, None)
        if conn:
            conn.close()
            await conn.wait_closed()
            logger.info(f"Disconnected from server {server_id}")
        
        self._profiles.pop(server_id, None)

    async def _reconnect_with_backoff(self, server_id: int):
        """Background task to reconnect with exponential backoff."""
        delay = 1
        max_delay = 60
        profile = self._profiles.get(server_id)
        if not profile:
            return

        while True:
            try:
                logger.info(f"Attempting to reconnect to {profile.display_name} in {delay}s...")
                await asyncio.sleep(delay)
                await self.connect(profile)
                logger.info(f"Successfully reconnected to {profile.display_name}")
                break
            except Exception:
                delay = min(delay * 2, max_delay)

    async def execute(self, server_id: int, command: str) -> AsyncGenerator[str, None]:
        """Execute a command and yield output line by line."""
        conn = await self._get_connection(server_id)
        
        async with conn.create_process(command) as process:
            async for line in process.stdout:
                yield line
            
            # Also check stderr if needed, or handle exit status
            stderr = await process.stderr.read()
            if stderr:
                yield f"ERROR: {stderr}"

    async def stream_output(self, server_id: int, command: str, websocket: WebSocket):
        """Pipe command execution output to a WebSocket."""
        try:
            async for line in self.execute(server_id, command):
                await websocket.send_text(line)
        except Exception as e:
            await websocket.send_text(f"Connection Error: {str(e)}")

    async def list_files(self, server_id: int, path: str) -> List[Dict[str, Any]]:
        """List files in a directory via SFTP."""
        conn = await self._get_connection(server_id)
        async with conn.start_sftp_client() as sftp:
            entries = await sftp.readdir(path)
            return [
                {
                    "name": entry.filename,
                    "is_dir": entry.attrs.permissions & 0o40000 != 0,
                    "size": entry.attrs.size,
                    "mtime": entry.attrs.mtime,
                }
                for entry in entries if entry.filename not in ('.', '..')
            ]

    async def read_file(self, server_id: int, path: str) -> str:
        """Read file content via SFTP."""
        conn = await self._get_connection(server_id)
        async with conn.start_sftp_client() as sftp:
            async with sftp.open(path, 'r') as f:
                return await f.read()

    async def write_file(self, server_id: int, path: str, content: str):
        """Write file content via SFTP."""
        conn = await self._get_connection(server_id)
        async with conn.start_sftp_client() as sftp:
            async with sftp.open(path, 'w') as f:
                await f.write(content)

    async def remove(self, server_id: int, path: str):
        """Remove a file or directory via SFTP."""
        conn = await self._get_connection(server_id)
        async with conn.start_sftp_client() as sftp:
            await sftp.remove(path)

    async def stat(self, server_id: int, path: str) -> Any:
        """Get file attributes via SFTP."""
        conn = await self._get_connection(server_id)
        async with conn.start_sftp_client() as sftp:
            return await sftp.stat(path)

# Global singleton instance
ssh_manager = SSHManager()
