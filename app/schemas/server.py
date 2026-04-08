from datetime import datetime
from typing import Optional
from pydantic import BaseModel

class ServerProfileBase(BaseModel):
    display_name: str
    host: str
    port: int = 22
    username: str
    auth_type: str  # "password" or "key"
    project_path: Optional[str] = None

class ServerProfileCreate(ServerProfileBase):
    credentials: str  # Plain password or private key, will be encrypted before storage

class ServerProfilePublic(ServerProfileBase):
    id: int
    user_id: int
    last_connected: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

class ServerTestRequest(BaseModel):
    host: str
    port: int = 22
    username: str
    auth_type: str
    credentials: str
