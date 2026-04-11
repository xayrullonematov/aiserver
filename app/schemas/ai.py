from pydantic import BaseModel, Field
from typing import List, Optional, Dict

class AIChatRequest(BaseModel):
    prompt: str
    server_id: Optional[str] = None
    provider: str = "openai"
    api_key: str
    model: Optional[str] = None

class FileEdit(BaseModel):
    path: str
    old_content: Optional[str] = None
    new_content: str
    description: Optional[str] = None

class ProposedCommand(BaseModel):
    command: str
    description: str
    risk_level: str = Field(..., pattern="^(low|medium|high|critical)$")

class AIResponse(BaseModel):
    id: str
    summary: str
    evidence: Optional[str] = None
    proposed_commands: List[ProposedCommand] = []
    file_edits: List[FileEdit] = []
    risk_level: str
    needs_approval: bool = True

class ApprovalRequest(BaseModel):
    server_id: str
    ai_response_id: str
    approved_commands: List[int] = []  # Indices of approved commands
    approved_edits: List[int] = []     # Indices of approved edits
