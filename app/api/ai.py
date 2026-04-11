import json
import logging
import uuid
from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select

from app.core import deps
from app.models.server import ServerProfile
from app.models.execution import ExecutionLog
from app.schemas.ai import AIChatRequest, AIResponse, ApprovalRequest, ProposedCommand, FileEdit
from app.services.ai_proxy import ai_proxy
from app.services.context_packager import context_packager
from app.services.ssh_manager import ssh_manager
from app.services.command_safety import command_safety

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ai", tags=["ai"])

# In-memory storage for pending responses (in a real app, use Redis)
pending_responses: Dict[str, AIResponse] = {}

STRUCTURED_PROMPT_SUFFIX = """
IMPORTANT: You MUST respond with a valid JSON object matching this structure:
{
    "summary": "Short explanation of what you plan to do",
    "evidence": "Reasoning or logs supporting this action",
    "proposed_commands": [{"command": "shell command", "description": "why", "risk_level": "low|medium|high|critical"}],
    "file_edits": [{"path": "full/path/to/file", "old_content": "optional current content", "new_content": "entire new file content", "description": "why"}],
    "risk_level": "low|medium|high|critical",
    "needs_approval": true
}
Ensure all shell commands are checked against common safety standards.
"""

@router.post("/chat", response_model=AIResponse)
async def ai_chat(
    request: AIChatRequest,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    context = None
    if request.server_id:
        try:
            server_id_int = int(request.server_id)
        except (ValueError, TypeError):
            raise HTTPException(status_code=400, detail="Invalid server_id")
        result = await session.execute(
            select(ServerProfile)
            .where(ServerProfile.id == server_id_int, ServerProfile.user_id == current_user.id)
        )
        server = result.scalar_one_or_none()
        if not server:
            raise HTTPException(status_code=404, detail="Server not found")
        context = await context_packager.package(server.id, server.project_path or ".")

    full_prompt = f"{request.prompt}\n{STRUCTURED_PROMPT_SUFFIX}"
    
    try:
        # Get structured response from AI
        raw_response = ""
        async for chunk in ai_proxy.chat(
            provider=request.provider,
            api_key=request.api_key,
            messages=[{"role": "user", "content": full_prompt}],
            model=request.model,
            context=context,
            stream=True
        ):
            raw_response += chunk
        
        # Parse the JSON from AI
        # Handle cases where AI might wrap JSON in code blocks
        clean_json = raw_response.strip()
        if clean_json.startswith("```json"):
            clean_json = clean_json[7:]
        if clean_json.endswith("```"):
            clean_json = clean_json[:-3]
        clean_json = clean_json.strip()
        
        data = json.loads(clean_json)
        
        # Generate a unique ID for this proposal
        response_id = str(uuid.uuid4())
        ai_response = AIResponse(id=response_id, **data)
        
        # Store for approval step
        pending_responses[response_id] = ai_response
        
        return ai_response
        
    except json.JSONDecodeError as e:
        logger.error(f"AI returned invalid JSON: {raw_response}")
        raise HTTPException(
            status_code=500, 
            detail=f"AI failed to return a structured response. Raw: {raw_response[:200]}..."
        )
    except Exception as e:
        logger.error(f"AI Chat error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/approve")
async def approve_changes(
    request: ApprovalRequest,
    session: deps.SessionDep,
    current_user: deps.CurrentUser
):
    if request.ai_response_id not in pending_responses:
        raise HTTPException(status_code=404, detail="Proposal not found or expired")
    
    proposal = pending_responses.pop(request.ai_response_id)
    
    # Verify server access
    try:
        server_id_int = int(request.server_id)
    except (ValueError, TypeError):
        raise HTTPException(status_code=400, detail="Invalid server_id")
    result = await session.execute(
        select(ServerProfile)
        .where(ServerProfile.id == server_id_int, ServerProfile.user_id == current_user.id)
    )
    server = result.scalar_one_or_none()
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")

    results = []
    
    # 1. Execute Approved Commands
    for idx in request.approved_commands:
        if idx >= len(proposal.proposed_commands):
            continue
        
        cmd_obj = proposal.proposed_commands[idx]
        
        # Safety check again just in case
        safety = command_safety.check(cmd_obj.command)
        if safety["risk_level"] == "critical":
            results.append({"type": "command", "command": cmd_obj.command, "status": "blocked", "error": "Critical safety violation"})
            continue

        output_lines = []
        try:
            async for line in ssh_manager.execute(server.id, cmd_obj.command):
                output_lines.append(line)
            
            output = "".join(output_lines)
            results.append({"type": "command", "command": cmd_obj.command, "status": "success", "output": output})
            
            # Audit log
            log = ExecutionLog(
                user_id=current_user.id,
                server_id=server.id,
                prompt=proposal.summary,
                proposed_command=cmd_obj.command,
                approved=True,
                output=output,
                risk_level=cmd_obj.risk_level
            )
            session.add(log)
        except Exception as e:
            results.append({"type": "command", "command": cmd_obj.command, "status": "error", "error": str(e)})

    # 2. Execute Approved File Edits
    for idx in request.approved_edits:
        if idx >= len(proposal.file_edits):
            continue
        
        edit = proposal.file_edits[idx]
        try:
            await ssh_manager.write_file(server.id, edit.path, edit.new_content)
            results.append({"type": "file_edit", "path": edit.path, "status": "success"})
            
            # Audit log for file edit
            log = ExecutionLog(
                user_id=current_user.id,
                server_id=server.id,
                prompt=f"File Edit: {edit.description or edit.path}",
                proposed_command=f"WRITE {edit.path}",
                approved=True,
                output="Success",
                risk_level="medium"
            )
            session.add(log)
        except Exception as e:
            results.append({"type": "file_edit", "path": edit.path, "status": "error", "error": str(e)})

    await session.commit()
    return {"results": results}

@router.get("/providers")
async def list_ai_providers():
    providers = await ai_proxy.get_providers()
    return {"providers": providers}
