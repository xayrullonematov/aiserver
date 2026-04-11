import logging
from typing import Optional, Annotated
from fastapi import APIRouter, Depends, HTTPException, Query, status

from sqlalchemy import select

from app.core import deps
from app.models.server import ServerProfile
from app.services.file_manager import file_manager

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/files", tags=["files"])

@router.get("/{server_id}/tree")
async def get_file_tree(
    server_id: int,
    session: deps.SessionDep,
    current_user: deps.CurrentUser,
    path: Annotated[Optional[str], Query()] = None,
    depth: Annotated[int, Query()] = 2,
):
    """
    Get full file tree up to max_depth.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == server_id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    target_path = path
    if not target_path or target_path == ".":
        target_path = server.project_path or "/"
    try:
        tree = await file_manager.get_file_tree(server_id, target_path, max_depth=depth)
        return tree
    except Exception as e:
        logger.error(f"Error getting file tree: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{server_id}/exists")
async def check_file_exists(
    server_id: int,
    path: Annotated[str, Query()],
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    """
    Check if a remote file or directory exists.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == server_id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    exists = await file_manager.file_exists(server_id, path)
    return {"exists": exists}

@router.delete("/{server_id}/file")
async def delete_file(
    server_id: int,
    path: Annotated[str, Query()],
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    """
    Delete a remote file.
    """
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == server_id, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    try:
        await file_manager.delete_file(server_id, path)
        return {"status": "success"}
    except Exception as e:
        logger.error(f"Error deleting file: {e}")
        raise HTTPException(status_code=500, detail=str(e))
