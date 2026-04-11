from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select

from app.core import deps
from app.core import security
from app.models.server import ServerProfile
from app.models.execution import ExecutionLog
from app.schemas.server import (
    ServerProfileCreate, 
    ServerProfilePublic, 
    ServerTestRequest
)
from app.schemas.execution import ExecutionLogPublic
from app.services.ssh_manager import ssh_manager

router = APIRouter(prefix="/servers", tags=["servers"])

@router.get("/", response_model=List[ServerProfilePublic])
async def list_servers(
    session: deps.SessionDep,
    current_user: deps.CurrentUser,
    skip: int = 0,
    limit: int = 100
) -> Any:
    """
    List current user's servers.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.user_id == current_user.id)
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()

@router.post("/", response_model=ServerProfilePublic)
async def create_server(
    session: deps.SessionDep,
    current_user: deps.CurrentUser,
    server_in: ServerProfileCreate
) -> Any:
    """
    Add new server.
    """
    # Encrypt credentials before storing
    encrypted_creds = security.encrypt_credentials(server_in.credentials)
    
    db_server = ServerProfile(
        **server_in.model_dump(exclude={"credentials"}),
        user_id=current_user.id,
        encrypted_credentials=encrypted_creds
    )
    session.add(db_server)
    await session.commit()
    await session.refresh(db_server)
    return db_server

@router.get("/{id}", response_model=ServerProfilePublic)
async def get_server(
    id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
) -> Any:
    """
    Get single server.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    return server

@router.delete("/{id}")
async def delete_server(
    id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
) -> Any:
    """
    Remove server, disconnect SSH if active.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    # Disconnect if active
    await ssh_manager.disconnect(server.id)
    
    await session.delete(server)
    await session.commit()
    return {"detail": "Server deleted successfully"}

@router.post("/{id}/test")
async def test_server_existing(
    id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
) -> Any:
    """
    Test SSH connection for an existing server.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    try:
        await ssh_manager.connect(server)
        # If it didn't raise, it's successful. 
        # We can disconnect immediately if we just wanted a test.
        # But usually we might want to keep it in pool.
        return {"status": "success", "message": "Connection successful"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@router.post("/test")
async def test_server_new(
    server_in: ServerTestRequest,
    current_user: deps.CurrentUser
) -> Any:
    """
    Test SSH connection without saving.
    """
    # Create a temporary profile for testing
    # We need a dummy ID for the ssh_manager keyed storage if we use connect()
    # Or we can just use a specific test method in ssh_manager.
    
    # For simplicity, let's mock a ServerProfile object
    from app.models.server import ServerProfile
    temp_profile = ServerProfile(
        id=0, # special ID for transient tests
        host=server_in.host,
        port=server_in.port,
        username=server_in.username,
        auth_type=server_in.auth_type,
        # encrypt it because ssh_manager expects it to be encrypted
        encrypted_credentials=security.encrypt_credentials(server_in.credentials)
    )
    
    try:
        conn = await ssh_manager.connect(temp_profile)
        await ssh_manager.disconnect(0)
        return {"status": "success", "message": "Connection successful"}
    except Exception as e:
        return {"status": "error", "message": str(e)}


@router.get("/{id}/logs", response_model=List[ExecutionLogPublic])
async def get_server_logs(
    id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser,
    skip: int = 0,
    limit: int = 50,
) -> Any:
    """
    Get execution logs for a server (most recent first).
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == id, ServerProfile.user_id == current_user.id)
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Server not found")

    logs_result = await session.execute(
        select(ExecutionLog)
        .where(ExecutionLog.server_id == id, ExecutionLog.user_id == current_user.id)
        .order_by(ExecutionLog.executed_at.desc())
        .offset(skip)
        .limit(limit)
    )
    return logs_result.scalars().all()


@router.get("/{id}/metrics")
async def get_server_metrics(
    id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser,
) -> Any:
    """
    Get real-time CPU and RAM metrics via SSH.
    Returns zeros if server is not connected.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")

    try:
        command = "top -bn1 | grep 'Cpu(s)' | awk '{print $2}'; free -m | grep Mem | awk '{print $3/$2 * 100.0}'"
        lines = []
        async for line in ssh_manager.execute(id, command):
            stripped = line.strip()
            if stripped:
                lines.append(stripped)
        cpu = float(lines[0]) if len(lines) > 0 else 0.0
        ram = float(lines[1]) if len(lines) > 1 else 0.0
        return {"cpu": cpu, "ram": ram}
    except Exception:
        return {"cpu": 0.0, "ram": 0.0}
