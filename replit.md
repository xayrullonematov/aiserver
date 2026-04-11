# AI Server Copilot

## Overview
A FastAPI backend for an AI-assisted server management application. It allows developers to manage remote servers with AI assistance via SSH command execution, file management (SFTP), and an AI-driven chat interface.

The companion mobile app is built with Flutter (not in this Replit environment - Flutter/Dart doesn't run here). The API serves as the backend for that mobile app.

## Tech Stack
- **Backend**: FastAPI (Python 3.12) with async SQLAlchemy and asyncpg
- **Database**: PostgreSQL (Replit built-in)
- **Migrations**: Alembic
- **Security**: passlib (bcrypt), PyJWT, AES-256 encryption for SSH credentials
- **SSH**: asyncssh for async SSH/SFTP connections
- **AI**: OpenAI and Anthropic SDKs
- **Frontend**: Flutter (mobile app, separate from this repo)

## Project Structure
```
app/
  api/         - FastAPI routers (auth, ai, servers, ssh, websocket, files)
  core/        - Configuration, security, dependency injection
  db/          - Database session management
  models/      - SQLAlchemy ORM models
  schemas/     - Pydantic models
  services/    - Core business logic
migrations/    - Alembic migrations
flutter-app/   - Mobile frontend (Flutter/Dart, not runnable in Replit)
```

## Running the App
The backend runs via uvicorn on port 5000:
```
uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload
```

## Environment Variables
- `DATABASE_URL` - PostgreSQL connection string (set by Replit)
- `SECRET_KEY` - JWT signing key
- `ENCRYPTION_KEY` - 32-byte base64 AES key for SSH credential encryption
- `ALLOWED_ORIGINS` - Comma-separated CORS origins
- `ENVIRONMENT` - "local", "staging", or "production"
- `DEBUG` - Enable debug mode

## Database
Uses Replit's built-in PostgreSQL database. Migrations run with:
```
python -m alembic upgrade head
```

## Key Configuration Notes
- The `parse_database_url()` function in `app/core/config.py` automatically converts `postgresql://` URLs to `postgresql+asyncpg://` and removes the `sslmode` parameter (incompatible with asyncpg)
- CORS allows all origins when `ALLOWED_ORIGINS` is not set (development mode)

## API Endpoints
- `GET /` - Health check
- `POST /api/v1/auth/*` - Authentication (login, register, refresh, me)
- `GET/POST/DELETE /api/v1/servers/` - Server CRUD
- `GET /api/v1/servers/{id}/logs` - Execution log history for a server
- `GET /api/v1/servers/{id}/metrics` - Real-time CPU/RAM metrics via SSH (returns zeros if not connected)
- `GET /api/v1/ssh/*` - SSH connect/disconnect/execute/files
- `WS /api/v1/ws/{server_id}/terminal` - WebSocket live terminal
- `WS /api/v1/ws/{server_id}/ai` - WebSocket streaming AI
- `POST /api/v1/ai/chat` - AI chat (non-streaming REST)
- `POST /api/v1/ai/approve` - Approve AI-proposed commands/edits
- `GET /api/v1/files/*` - File management (SFTP)

## Flutter–Backend Contract (Resolved Issues)
All ID fields (`user.id`, `server.id`, `execution_log.id`, etc.) are returned as **strings** in JSON to match Flutter's `String` type. Validators in Pydantic schemas coerce ints to strings on serialization.

- `project_path` always returns `""` (never `null`) to avoid Dart non-nullable cast crash
- `execution_log.prompt` always returns `""` (never `null`)  
- `AIChatRequest.server_id` accepts `Optional[str]` — Flutter can send int or null; Pydantic coerces to string
- WebSocket auth via `?token=` query param (not HTTP Authorization header)

## Deployment
Configured for VM deployment (required for WebSocket support).
