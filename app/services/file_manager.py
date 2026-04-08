import os
import logging
from typing import List, Dict, Any, Optional
from app.services.ssh_manager import ssh_manager

logger = logging.getLogger(__name__)

class FileManager:
    _instance: Optional['FileManager'] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(FileManager, cls).__new__(cls)
        return cls._instance

    def _validate_path(self, path: str):
        """
        Basic path validation to prevent directory traversal.
        """
        normalized = os.path.normpath(path)
        if ".." in normalized.split(os.sep):
            raise ValueError(f"Invalid path: {path}. Directory traversal not allowed.")
        return normalized

    async def list_directory(self, server_id: int, path: str) -> List[Dict[str, Any]]:
        """List contents of a directory."""
        path = self._validate_path(path)
        return await ssh_manager.list_files(server_id, path)

    async def read_file(self, server_id: int, path: str) -> str:
        """Read a remote file."""
        path = self._validate_path(path)
        return await ssh_manager.read_file(server_id, path)

    async def write_file(self, server_id: int, path: str, content: str):
        """Write to a remote file."""
        path = self._validate_path(path)
        await ssh_manager.write_file(server_id, path, content)

    async def delete_file(self, server_id: int, path: str):
        """Delete a remote file."""
        path = self._validate_path(path)
        await ssh_manager.remove(server_id, path)

    async def file_exists(self, server_id: int, path: str) -> bool:
        """Check if a remote file exists."""
        try:
            path = self._validate_path(path)
            await ssh_manager.stat(server_id, path)
            return True
        except Exception:
            return False

    async def get_file_tree(self, server_id: int, path: str, max_depth: int = 2, current_depth: int = 0) -> Dict[str, Any]:
        """
        Recursively get a directory tree up to max_depth.
        """
        path = self._validate_path(path)
        name = os.path.basename(path) or path
        
        node = {
            "name": name,
            "path": path,
            "type": "directory",
            "children": []
        }

        if current_depth >= max_depth:
            return node

        try:
            items = await self.list_directory(server_id, path)
            for item in items:
                item_path = os.path.join(path, item['name'])
                if item['is_dir']:
                    child_node = await self.get_file_tree(
                        server_id, item_path, max_depth, current_depth + 1
                    )
                    node['children'].append(child_node)
                else:
                    node['children'].append({
                        "name": item['name'],
                        "path": item_path,
                        "type": "file",
                        "size": item.get('size'),
                        "mtime": item.get('mtime')
                    })
        except Exception as e:
            logger.error(f"Error building file tree for {path}: {e}")
            node['error'] = str(e)

        return node

# Global singleton instance
file_manager = FileManager()
