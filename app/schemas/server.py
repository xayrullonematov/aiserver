from datetime import datetime
from typing import Optional
from pydantic import BaseModel, field_validator

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
    id: str
    user_id: str
    last_connected: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

    @field_validator("id", "user_id", mode="before")
    @classmethod
    def coerce_id_to_str(cls, v: object) -> str:
        return str(v)

    @field_validator("project_path", mode="before")
    @classmethod
    def coerce_project_path(cls, v: object) -> str:
        return str(v) if v is not None else ""

class ServerTestRequest(BaseModel):
    host: str
    port: int = 22
    username: str
    auth_type: str
    credentials: str
