from datetime import datetime
from typing import TYPE_CHECKING, Optional
from sqlalchemy import DateTime, ForeignKey, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.session import Base

if TYPE_CHECKING:
    from .user import User
    from .session import SSHSession
    from .execution import ExecutionLog


class ServerProfile(Base):
    __tablename__ = "server_profile"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("user.id", ondelete="CASCADE"), nullable=False)
    display_name: Mapped[str] = mapped_column(String(255), nullable=False)
    host: Mapped[str] = mapped_column(String(255), nullable=False)
    port: Mapped[int] = mapped_column(Integer, default=22, nullable=False)
    username: Mapped[str] = mapped_column(String(255), nullable=False)
    auth_type: Mapped[str] = mapped_column(String(50), nullable=False)  # "password" or "key"
    encrypted_credentials: Mapped[str] = mapped_column(String(1024), nullable=False)
    project_path: Mapped[Optional[str]] = mapped_column(String(1024), nullable=True)
    last_connected: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationships
    user: Mapped["User"] = relationship(back_populates="servers")
    sessions: Mapped[list["SSHSession"]] = relationship(back_populates="server", cascade="all, delete-orphan")
    executions: Mapped[list["ExecutionLog"]] = relationship(back_populates="server", cascade="all, delete-orphan")
