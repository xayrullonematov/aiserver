from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, servers, ssh, ws, ai, files
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Set all CORS enabled origins
if settings.all_cors_origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.all_cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(servers.router, prefix=settings.API_V1_STR)
app.include_router(ssh.router, prefix=settings.API_V1_STR)
app.include_router(ws.router, prefix=settings.API_V1_STR)
app.include_router(ai.router, prefix=settings.API_V1_STR)
app.include_router(files.router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {"message": "AI Server Copilot API is running"}
