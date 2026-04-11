import asyncio
import json
import logging
from typing import Optional, Annotated
from fastapi import APIRouter, Depends, HTTPException, Query, Body, status
from fastapi.responses import StreamingResponse
from sqlalchemy import select

from app.core import deps
from app.models.server import ServerProfile
from app.models.execution import ExecutionLog
from app.schemas.ssh import CommandExecuteRequest, FileWriteRequest
from app.services.ssh_manager import ssh_manager
from app.services.command_safety import command_safety
from app.services.file_manager import file_manager
from app.core.config import settings
from app.db.session import AsyncSessionLocal

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ssh", tags=["ssh"])

async def get_server_for_user(
    server_id: int, 
    session: deps.SessionDep, 
    current_user: deps.CurrentUser
) -> ServerProfile:
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == server_id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    return server

@router.post("/{server_id}/connect")
async def connect_ssh(
    server_id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    """
    Connect to a server and store in pool.
    """
    server = await get_server_for_user(server_id, session, current_user)
    try:
        await ssh_manager.connect(server)
        return {"status": "connected"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{server_id}/disconnect")
async def disconnect_ssh(
    server_id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    """
    Disconnect from a server and remove from pool.
    """
    # Verify ownership
    await get_server_for_user(server_id, session, current_user)
    await ssh_manager.disconnect(server_id)
    return {"status": "disconnected"}

@router.post("/{server_id}/execute")
async def execute_command(
    server_id: int,
    request: CommandExecuteRequest,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    """
    Execute a command with safety check and logging.
    """
    server = await get_server_for_user(server_id, session, current_user)
    
    # Check safety
    safety_result = command_safety.check(request.command)
    risk_level = safety_result["risk_level"]
    
    # Log the attempt
    db_log = ExecutionLog(
        user_id=current_user.id,
        server_id=server_id,
        proposed_command=request.command,
        approved=request.approved,
        risk_level=risk_level
    )
    session.add(db_log)
    await session.commit()
    await session.refresh(db_log)

    # Block if risky and not approved
    if not request.approved and risk_level in ["high", "critical"]:
        return {
            "safe": False,
            "risk_level": risk_level,
            "warning": safety_result["warning"],
            "detail": "Command requires explicit approval=True"
        }

    async def generate_output():
        full_output = []
        try:
            async for line in ssh_manager.execute(server_id, request.command):
                full_output.append(line)
                yield f"data: {json.dumps({'output': line})}\n\n"
            
            # Final message
            yield "data: [DONE]\n\n"
            
            # Update log with output using a fresh session
            async with AsyncSessionLocal() as fresh_session:
                db_log.output = "".join(full_output)
                await fresh_session.merge(db_log)
                await fresh_session.commit()
            
        except Exception as e:
            error_msg = f"Execution error: {str(e)}"
            yield f"data: {json.dumps({'error': error_msg})}\n\n"
            async with AsyncSessionLocal() as fresh_session:
                db_log.output = "".join(full_output) + "\n" + error_msg
                await fresh_session.merge(db_log)
                await fresh_session.commit()

    return StreamingResponse(generate_output(), media_type="text/event-stream")

@router.get("/{server_id}/files")
async def list_files(
    server_id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser,
    path: Annotated[Optional[str], Query()] = None,
):
    """
    List directory contents.
    """
    server = await get_server_for_user(server_id, session, current_user)
    target_path = path
    if not target_path or target_path == ".":
        target_path = server.project_path or "/"
    try:
        files = await file_manager.list_directory(server_id, target_path)
        return files
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{server_id}/file")
async def read_file(
    server_id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser,
    path: Annotated[str, Query()]
):
    """
    Read file content.
    """
    await get_server_for_user(server_id, session, current_user)
    try:
        content = await file_manager.read_file(server_id, path)
        return {"content": content}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{server_id}/file")
async def write_file(
    server_id: int,
    request: FileWriteRequest,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    """
    Write file content.
    """
    await get_server_for_user(server_id, session, current_user)
    try:
        await file_manager.write_file(server_id, request.path, request.content)
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
