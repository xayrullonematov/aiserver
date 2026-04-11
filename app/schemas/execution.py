from datetime import datetime
from typing import Optional
from pydantic import BaseModel, field_validator


class ExecutionLogPublic(BaseModel):
    id: str
    user_id: str
    server_id: str
    prompt: str
    proposed_command: str
    approved: bool
    output: Optional[str] = None
    risk_level: str
    executed_at: datetime

    class Config:
        from_attributes = True

    @field_validator("id", "user_id", "server_id", mode="before")
    @classmethod
    def coerce_id_to_str(cls, v: object) -> str:
        return str(v)

    @field_validator("prompt", mode="before")
    @classmethod
    def coerce_prompt(cls, v: object) -> str:
        return str(v) if v is not None else ""
