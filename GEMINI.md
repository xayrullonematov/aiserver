# AI Server Copilot

## Project Overview
A mobile-first developer tool that lets users connect their own VPS/servers via SSH,
select an AI coding agent (Claude/GPT/Gemini/Grok) using their own API keys,
and manage real project folders from a Flutter mobile app — without needing a laptop.

Think: Replit but on your own server, with your own AI.

## Architecture
```
Flutter App (mobile)
      ↓ WebSocket / REST
FastAPI Backend (this repo)
      ↓ asyncssh
User's Remote Server
      ↓
Project folder + AI provider of user's choice
```

## Stack
- **Runtime**: Python 3.11+
- **Framework**: FastAPI with async throughout
- **SSH**: asyncssh — all connections async, no blocking
- **Database**: PostgreSQL via SQLAlchemy 2.0 async + alembic migrations
- **Realtime**: WebSocket for streaming terminal output and AI responses
- **Auth**: JWT tokens, SSH credentials AES-256 encrypted at rest
- **Infra**: Docker Compose, nginx reverse proxy

## Project Structure
```
app/
├── api/
│   ├── __init__.py
│   ├── auth.py          # JWT login/register
│   ├── servers.py       # Server profile CRUD
│   ├── ssh.py           # SSH connect/execute/stream
│   ├── ai.py            # AI chat proxy endpoints
│   ├── files.py         # File read/write/browse
│   └── ws.py            # WebSocket handlers
├── core/
│   ├── __init__.py
│   ├── config.py        # Settings from env vars only
│   ├── security.py      # JWT, encryption, hashing
│   └── deps.py          # FastAPI dependencies
├── db/
│   ├── __init__.py
│   └── session.py       # Async DB session
├── models/
│   ├── __init__.py
│   ├── user.py          # User model
│   ├── server.py        # Server profile model
│   ├── session.py       # SSH session model
│   └── execution.py     # Command execution audit log
└── services/
    ├── __init__.py
    ├── ssh_manager.py       # SSH connection pool + execution
    ├── ai_proxy.py          # Multi-provider AI routing
    ├── file_manager.py      # Remote file operations via SSH
    ├── command_safety.py    # Dangerous command detection
    └── context_packager.py  # Package project context for AI
```

## Reference Code
Study these before implementing — do not modify:
- `refs/lunel/cli/` — WebSocket bridge and session patterns
- `refs/lunel/manager/` — session relay and pairing architecture
- `refs/lunel/pty/` — PTY terminal rendering approach
- `refs/asyncssh/examples/` — SSH connection and execution patterns
- `refs/full-stack-fastapi-template/backend/` — FastAPI project structure

## Database Models

### User
```python
id, email, hashed_password, is_active, created_at
```

### ServerProfile
```python
id, user_id, display_name, host, port,
username, auth_type (password|key),
encrypted_credentials, project_path,
last_connected, created_at
```

### ExecutionLog
```python
id, user_id, server_id, prompt,
proposed_command, approved (bool),
output, risk_level, executed_at
```

## Services Specification

### ssh_manager.py
```python
class SSHManager:
    # Connection pool keyed by server_id
    # async connect(server_profile) -> connection
    # async disconnect(server_id)
    # async execute(server_id, command) -> AsyncGenerator[str, None]
    # async stream_output(server_id, command, websocket)
    # async list_files(server_id, path) -> list
    # async read_file(server_id, path) -> str
    # async write_file(server_id, path, content)
    # handle reconnection with exponential backoff
```

### ai_proxy.py
```python
class AIProxy:
    # Route to correct provider based on user config
    # Supported: openai, anthropic, gemini, grok, custom
    # Grok uses OpenAI-compatible client with base_url=https://api.x.ai/v1
    # Gemini uses base_url=https://generativelanguage.googleapis.com/v1beta/openai/
    # async chat(provider, api_key, messages) -> AsyncGenerator[str, None]
    # async package_context(server_id, project_path) -> str
    # NEVER store user API keys in DB — use only in memory per request
```

### command_safety.py
```python
class CommandSafety:
    # risk_level: low | medium | high | critical
    # HIGH: rm -rf, drop table, truncate, chmod 777, > /dev/
    # CRITICAL: format, mkfs, dd if=, shutdown, reboot
    # Returns: {safe: bool, risk_level: str, warning: str}
    # All high/critical commands require explicit approval=True flag
```

### context_packager.py
```python
class ContextPackager:
    # Read project structure via SSH
    # Detect stack: package.json, requirements.txt,
    #   Dockerfile, docker-compose.yml, .env.example
    # Read recent logs (last 100 lines)
    # Summarize into token-efficient context string
    # Max context: 8000 tokens to leave room for AI response
```

## API Endpoints

### Auth
```
POST /auth/register
POST /auth/login
GET  /auth/me
```

### Servers
```
GET    /servers              # list user's servers
POST   /servers              # add new server
GET    /servers/{id}         # get server details
DELETE /servers/{id}         # remove server
POST   /servers/{id}/test    # test SSH connection
```

### SSH
```
POST /ssh/{server_id}/connect
POST /ssh/{server_id}/disconnect
POST /ssh/{server_id}/execute     # requires approved=true for risky commands
GET  /ssh/{server_id}/files       # browse directory
GET  /ssh/{server_id}/file        # read file content
PUT  /ssh/{server_id}/file        # write file content
```

### AI
```
POST /ai/chat                # send message, returns streamed response
POST /ai/context/{server_id} # package project context
GET  /ai/providers           # list supported providers
```

### WebSocket
```
WS /ws/{server_id}/terminal  # live terminal stream
WS /ws/{server_id}/ai        # streaming AI responses
```

## Coding Rules — Follow Strictly

1. **Async everywhere** — every function touching I/O must be async
2. **No hardcoded values** — all config via environment variables in core/config.py
3. **Encrypt SSH credentials** — AES-256 before writing to DB, decrypt only in memory
4. **Never store AI API keys** — pass through per request only, never persist
5. **Approval gate** — command_safety.check() must run before every execution
6. **Stream everything** — never wait for full output, always use AsyncGenerator
7. **One responsibility per service** — ssh_manager only does SSH, ai_proxy only does AI
8. **Log every execution** — insert into ExecutionLog regardless of approval outcome
9. **Handle disconnections** — SSH connections drop, always implement reconnect logic
10. **Token efficiency** — context sent to AI must be summarized, never raw file dumps

## Environment Variables
```
DATABASE_URL=postgresql+asyncpg://user:pass@db:5432/ai_server_copilot
SECRET_KEY=
ENCRYPTION_KEY=
ALLOWED_ORIGINS=
DEBUG=false
```

## Build Order
Implement strictly in this order — each depends on the previous:
1. core/config.py + core/security.py
2. models/ — all four models + alembic migration
3. services/ssh_manager.py
4. services/command_safety.py
5. services/context_packager.py
6. services/ai_proxy.py
7. api/auth.py
8. api/servers.py
9. api/ssh.py + api/ws.py
10. api/ai.py
11. api/files.py
12. docker-compose.yml finalization + .env.example

## Current Status
- [x] Project scaffolded
- [x] core/config.py complete
- [x] Models defined
- [x] SSH manager built
- [x] AI proxy built
- [x] API endpoints complete
- [x] Docker Compose finalized
- [ ] Flutter app (separate repo — not started)
