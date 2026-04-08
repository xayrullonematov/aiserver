import re
from typing import Dict, TypedDict

class SafetyResult(TypedDict):
    safe: bool
    risk_level: str
    warning: str

class CommandSafety:
    def __init__(self):
        # Patterns for different risk levels
        self.critical_patterns = [
            r'\bformat\b',
            r'\bmkfs\b',
            r'\bdd\s+if=',
            r'\bshutdown\b',
            r'\breboot\b',
            r'\bfdisk\b',
        ]
        
        self.high_patterns = [
            r'rm\s+-rf',
            r'chmod\s+777',
            r'>\s*/dev/',
            r'\btruncate\b',
            r'drop\s+table',
        ]
        
        self.medium_patterns = [
            r'pip\s+install\s+.*(--extra-index-url|--index-url|https?://|git\+|ssh\+)',
            r'curl\s+.*\|\s*(bash|sh|zsh|dash)',
            r'wget\s+.*\|\s*(bash|sh|zsh|dash)',
        ]

    def check(self, command: str) -> SafetyResult:
        """
        Evaluate the risk level of a given shell command.
        Returns a dict with safety status and warnings.
        """
        # Critical risk check
        for pattern in self.critical_patterns:
            if re.search(pattern, command, re.IGNORECASE):
                return {
                    "safe": False,
                    "risk_level": "critical",
                    "warning": f"CRITICAL: This command uses a highly destructive operation: '{pattern}'"
                }

        # High risk check
        for pattern in self.high_patterns:
            if re.search(pattern, command, re.IGNORECASE):
                return {
                    "safe": False,
                    "risk_level": "high",
                    "warning": f"HIGH RISK: This command is potentially dangerous: '{pattern}'"
                }

        # Medium risk check
        for pattern in self.medium_patterns:
            if re.search(pattern, command, re.IGNORECASE):
                return {
                    "safe": True,  # Medium is technically allowed but warned
                    "risk_level": "medium",
                    "warning": "MEDIUM RISK: Be cautious when installing packages or piping remote scripts."
                }

        # Default low risk
        return {
            "safe": True,
            "risk_level": "low",
            "warning": ""
        }

# Global singleton instance
command_safety = CommandSafety()
