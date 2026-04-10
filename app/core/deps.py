from datetime import datetime, timezone
import logging
from typing import Annotated, AsyncGenerator

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt.exceptions import InvalidTokenError
from pydantic import ValidationError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core import security
from app.core.config import settings
from app.db.session import AsyncSessionLocal
from app.models.auth_session import AuthSession
from app.models.user import User
from app.schemas.token import TokenPayload

reusable_bearer = HTTPBearer(auto_error=False)
logger = logging.getLogger(__name__)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session

SessionDep = Annotated[AsyncSession, Depends(get_db)]
CredentialsDep = Annotated[HTTPAuthorizationCredentials | None, Depends(reusable_bearer)]


def decode_token(token: str, expected_type: str = security.ACCESS_TOKEN_TYPE) -> TokenPayload:
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[security.ALGORITHM]
        )
        token_data = TokenPayload(**payload)
    except (InvalidTokenError, ValidationError):
        logger.warning("Token decode failed", extra={"expected_type": expected_type})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token")

    if token_data.type != expected_type:
        logger.warning("Token type mismatch", extra={"expected_type": expected_type, "token_type": token_data.type})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token type")
    if token_data.sub is None:
        logger.warning("Token missing subject", extra={"expected_type": expected_type})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token subject")
    return token_data


async def get_current_user(session: SessionDep, credentials: CredentialsDep) -> User:
    if credentials is None:
        logger.info("Authenticated endpoint requested without bearer token")
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    return await get_user_from_access_token(session, credentials.credentials)


async def get_user_from_access_token(session: SessionDep, token: str) -> User:
    token_data = decode_token(token, expected_type=security.ACCESS_TOKEN_TYPE)

    result = await session.execute(select(User).where(User.id == token_data.sub))
    user = result.scalar_one_or_none()

    if not user:
        logger.warning("Access token user not found", extra={"user_id": token_data.sub})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    if not user.is_active:
        logger.warning("Inactive user attempted authenticated access", extra={"user_id": user.id})
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Inactive user")
    return user


async def get_auth_session(session: SessionDep, refresh_token: str) -> tuple[AuthSession, User, TokenPayload]:
    token_data = decode_token(refresh_token, expected_type=security.REFRESH_TOKEN_TYPE)
    if token_data.sid is None:
        logger.warning("Refresh token missing session id", extra={"user_id": token_data.sub})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid session token")

    result = await session.execute(select(AuthSession).where(AuthSession.id == token_data.sid))
    auth_session = result.scalar_one_or_none()
    if not auth_session or auth_session.is_revoked:
        logger.warning("Refresh requested for inactive session", extra={"session_id": token_data.sid})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh session is not active")
    expires_at = auth_session.expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at <= datetime.now(timezone.utc):
        logger.info("Refresh token expired", extra={"session_id": auth_session.id, "user_id": auth_session.user_id})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token has expired")
    if not security.compare_token_hash(refresh_token, auth_session.refresh_token_hash):
        auth_session.is_revoked = True
        await session.commit()
        logger.warning("Refresh token hash mismatch; session revoked", extra={"session_id": auth_session.id})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Refresh token is invalid")

    result = await session.execute(select(User).where(User.id == auth_session.user_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        auth_session.is_revoked = True
        await session.commit()
        logger.warning("Refresh session user is not authorized; session revoked", extra={"session_id": auth_session.id})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User is not authorized")

    return auth_session, user, token_data

CurrentUser = Annotated[User, Depends(get_current_user)]
