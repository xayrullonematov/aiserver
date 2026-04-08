from typing import Optional
from pydantic import BaseModel

class CommandExecuteRequest(BaseModel):
    command: str
    approved: bool = False

class FileWriteRequest(BaseModel):
    path: str
    content: str
