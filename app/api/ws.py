import json
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException, status
from sqlalchemy import select

from app.core import deps
from app.models.server import ServerProfile
from app.models.execution import ExecutionLog
from app.services.ssh_manager import ssh_manager
from app.services.command_safety import command_safety
from app.services.context_packager import context_packager
from app.services.ai_proxy import ai_proxy
from app.db.session import AsyncSessionLocal

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ws", tags=["websocket"])

@router.websocket("/{server_id}/terminal")
async def terminal_websocket(
    websocket: WebSocket,
    server_id: int,
):
    """
    Live terminal stream.
    Authentication is handled via token in query param or first message.
    For simplicity here, we'll assume token is in query param 'token'.
    """
    await websocket.accept()
    
    token = websocket.query_params.get("token")
    if not token:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    async with AsyncSessionLocal() as session:
        try:
            # Manually validate user from token
            current_user = await deps.get_current_user(session, token)
            
            # Verify server ownership
            result = await session.execute(
                select(ServerProfile)
                .where(ServerProfile.id == server_id, ServerProfile.user_id == current_user.id)
            )
            server = result.scalar_one_or_none()
            if not server:
                await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
                return

            while True:
                data = await websocket.receive_text()
                try:
                    payload = json.loads(data)
                    command = payload.get("command")
                    approved = payload.get("approved", False)
                except ValueError:
                    command = data
                    approved = False

                if not command:
                    continue

                # Safety check
                safety_result = command_safety.check(command)
                risk_level = safety_result["risk_level"]

                # Log
                db_log = ExecutionLog(
                    user_id=current_user.id,
                    server_id=server_id,
                    proposed_command=command,
                    approved=approved,
                    risk_level=risk_level
                )
                session.add(db_log)
                await session.commit()
                await session.refresh(db_log)

                if not approved and risk_level in ["high", "critical"]:
                    await websocket.send_json({
                        "type": "safety_warning",
                        "risk_level": risk_level,
                        "warning": safety_result["warning"]
                    })
                    continue

                # Execute and stream
                full_output = []
                try:
                    async for line in ssh_manager.execute(server_id, command):
                        full_output.append(line)
                        await websocket.send_json({"type": "output", "data": line})
                    
                    await websocket.send_json({"type": "exit", "data": "Command finished"})
                    
                    # Update log
                    db_log.output = "".join(full_output)
                    await session.commit()
                except Exception as e:
                    await websocket.send_json({"type": "error", "data": str(e)})

        except WebSocketDisconnect:
            logger.info(f"Terminal websocket disconnected for server {server_id}")
        except Exception as e:
            logger.error(f"WebSocket error: {e}")
            await websocket.close(code=status.WS_1011_INTERNAL_ERROR)

@router.websocket("/{server_id}/ai")
async def ai_websocket(
    websocket: WebSocket,
    server_id: int,
):
    """
    Streaming AI responses.
    """
    await websocket.accept()
    
    token = websocket.query_params.get("token")
    if not token:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    async with AsyncSessionLocal() as session:
        try:
            current_user = await deps.get_current_user(session, token)
            
            result = await session.execute(
                select(ServerProfile)
                .where(ServerProfile.id == server_id, ServerProfile.user_id == current_user.id)
            )
            server = result.scalar_one_or_none()
            if not server:
                await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
                return

            while True:
                data = await websocket.receive_text()
                payload = json.loads(data)
                
                prompt = payload.get("prompt")
                provider = payload.get("provider")
                api_key = payload.get("api_key")
                model = payload.get("model")

                if not all([prompt, provider, api_key]):
                    await websocket.send_json({"error": "Missing prompt, provider, or api_key"})
                    continue

                # 1. Package context
                context = await context_packager.package(server_id, server.project_path or ".")
                
                # 2. Stream AI response
                messages = [{"role": "user", "content": prompt}]
                
                try:
                    async for chunk in ai_proxy.chat(
                        provider=provider,
                        api_key=api_key,
                        messages=messages,
                        model=model,
                        context=context
                    ):
                        await websocket.send_json({"type": "chunk", "data": chunk})
                    
                    await websocket.send_json({"type": "done"})
                except Exception as e:
                    await websocket.send_json({"type": "error", "data": str(e)})

        except WebSocketDisconnect:
            logger.info(f"AI websocket disconnected for server {server_id}")
        except Exception as e:
            logger.error(f"WebSocket error: {e}")
            await websocket.close(code=status.WS_1011_INTERNAL_ERROR)
