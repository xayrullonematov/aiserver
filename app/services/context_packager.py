import os
import logging
from typing import List, Dict, Any, Optional
from app.services.ssh_manager import ssh_manager

logger = logging.getLogger(__name__)

class ContextPackager:
    _instance: Optional['ContextPackager'] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ContextPackager, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        self.stack_files = [
            "package.json", "requirements.txt", "Dockerfile", 
            "docker-compose.yml", ".env.example", "go.mod", "Cargo.toml"
        ]
        self.log_files = ["app.log", "error.log"]
        self.max_chars = 32000  # Roughly 8000 tokens

    async def package(self, server_id: int, project_path: str) -> str:
        """
        Package project context into a token-efficient string.
        """
        context_parts = []
        
        # 1. Project Path
        context_parts.append(f"Project Path: {project_path}\n")

        # 2. Detect Stack
        detected_stack = await self._detect_stack(server_id, project_path)
        if detected_stack:
            context_parts.append(f"Detected Stack Files: {', '.join(detected_stack)}\n")

        # 3. Directory Tree (max 2 levels)
        tree = await self._get_directory_tree(server_id, project_path, depth=2)
        context_parts.append("Directory Structure (2 levels):\n" + tree + "\n")

        # 4. Recent Logs
        logs = await self._get_recent_logs(server_id, project_path)
        if logs:
            context_parts.append("Recent Logs (last 100 lines):\n" + logs + "\n")

        # 5. Docker Logs (if applicable)
        docker_logs = await self._get_docker_logs(server_id)
        if docker_logs:
            context_parts.append("Docker Logs:\n" + docker_logs + "\n")

        full_context = "\n".join(context_parts)
        
        # Enforce hard limit
        if len(full_context) > self.max_chars:
            return full_context[:self.max_chars] + "\n... [Context Truncated]"
        
        return full_context

    async def _detect_stack(self, server_id: int, project_path: str) -> List[str]:
        detected = []
        try:
            files = await ssh_manager.list_files(server_id, project_path)
            filenames = {f['name'] for f in files}
            for stack_file in self.stack_files:
                if stack_file in filenames:
                    detected.append(stack_file)
        except Exception as e:
            logger.error(f"Error detecting stack: {e}")
        return detected

    async def _get_directory_tree(self, server_id: int, path: str, depth: int, current_level: int = 0) -> str:
        if current_level > depth:
            return ""
        
        tree_lines = []
        try:
            files = await ssh_manager.list_files(server_id, path)
            for f in files:
                indent = "  " * current_level
                prefix = Indent = "  " * current_level
                if f['is_dir']:
                    tree_lines.append(f"{indent}📁 {f['name']}/")
                    if current_level < depth:
                        sub_tree = await self._get_directory_tree(
                            server_id, os.path.join(path, f['name']), depth, current_level + 1
                        )
                        if sub_tree:
                            tree_lines.append(sub_tree)
                else:
                    tree_lines.append(f"{indent}📄 {f['name']}")
        except Exception as e:
            tree_lines.append(f"{'  ' * current_level}[Error listing {os.path.basename(path)}: {e}]")
            
        return "\n".join(tree_lines)

    async def _get_recent_logs(self, server_id: int, project_path: str) -> str:
        log_contents = []
        for log_file in self.log_files:
            log_path = os.path.join(project_path, log_file)
            try:
                # Use tail to get last 100 lines efficiently
                command = f"tail -n 100 {log_path} 2>/dev/null"
                output = ""
                async for line in ssh_manager.execute(server_id, command):
                    output += line
                
                if output.strip():
                    log_contents.append(f"--- {log_file} ---\n{output}")
            except Exception:
                continue
        return "\n".join(log_contents)

    async def _get_docker_logs(self, server_id: int) -> str:
        try:
            # Try to get logs for running containers
            command = "docker ps --format '{{.Names}}' | xargs -I {} sh -c 'echo \"--- Container: {} ---\"; docker logs --tail 50 {} 2>&1'"
            output = ""
            async for line in ssh_manager.execute(server_id, command):
                output += line
            return output
        except Exception:
            return ""

# Global singleton instance
context_packager = ContextPackager()
