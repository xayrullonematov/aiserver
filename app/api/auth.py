from typing import Any
from datetime import datetime, timedelta, timezone
import logging

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from app.core import deps
from app.core import security
from app.models.auth_session import AuthSession
from app.models.user import User
from app.schemas.auth import (
    AuthLoginRequest,
    AuthResponse,
    AuthSignupRequest,
    ErrorResponse,
    LogoutRequest,
    TokenPair,
    TokenRefreshRequest,
)
from app.schemas.user import UserPublic

router = APIRouter(prefix="/auth", tags=["auth"])
logger = logging.getLogger(__name__)


def build_auth_response(user: User, access_token: str, refresh_token: str) -> AuthResponse:
    return AuthResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=UserPublic.model_validate(user),
    )


async def issue_token_pair(session: deps.SessionDep, user: User) -> tuple[str, str]:
    session_id = security.new_session_id()
    refresh_token = security.create_refresh_token(user.id, session_id=session_id)
    auth_session = AuthSession(
        id=session_id,
        user_id=user.id,
        refresh_token_hash=security.hash_token(refresh_token),
        expires_at=datetime.now(timezone.utc) + timedelta(days=deps.settings.REFRESH_TOKEN_EXPIRE_DAYS),
    )
    session.add(auth_session)
    await session.commit()
    return security.create_access_token(user.id), refresh_token


async def rotate_refresh_token(
    session: deps.SessionDep,
    auth_session: AuthSession,
    user: User,
) -> TokenPair:
    refresh_token = security.create_refresh_token(user.id, session_id=auth_session.id)
    auth_session.refresh_token_hash = security.hash_token(refresh_token)
    auth_session.last_used_at = datetime.now(timezone.utc)
    auth_session.expires_at = datetime.now(timezone.utc) + timedelta(days=deps.settings.REFRESH_TOKEN_EXPIRE_DAYS)
    await session.commit()
    return TokenPair(
        access_token=security.create_access_token(user.id),
        refresh_token=refresh_token,
        token_type="bearer",
    )


@router.post(
    "/register",
    response_model=AuthResponse,
    responses={400: {"model": ErrorResponse}},
)
@router.post(
    "/register/",
    response_model=AuthResponse,
    include_in_schema=False,
    responses={400: {"model": ErrorResponse}},
)
async def register(
    session: deps.SessionDep,
    user_in: AuthSignupRequest,
) -> Any:
    """
    Create new user.
    """
    result = await session.execute(select(User).where(User.email == user_in.email))
    user = result.scalar_one_or_none()
    if user:
        logger.info("Registration rejected for existing email", extra={"email": user_in.email})
        raise HTTPException(
            status_code=400,
            detail="The user with this email already exists in the system.",
        )
    
    db_user = User(
        email=user_in.email,
        hashed_password=security.get_password_hash(user_in.password),
        is_active=True,
    )
    session.add(db_user)
    await session.commit()
    await session.refresh(db_user)
    access_token, refresh_token = await issue_token_pair(session, db_user)
    return build_auth_response(db_user, access_token, refresh_token)


@router.post(
    "/login",
    response_model=AuthResponse,
    responses={401: {"model": ErrorResponse}, 403: {"model": ErrorResponse}},
)
@router.post(
    "/login/",
    response_model=AuthResponse,
    include_in_schema=False,
    responses={401: {"model": ErrorResponse}, 403: {"model": ErrorResponse}},
)
async def login(
    session: deps.SessionDep,
    user_in: AuthLoginRequest,
) -> Any:
    """
    Email/password login returning first-party access and refresh tokens.
    """
    result = await session.execute(select(User).where(User.email == user_in.email))
    user = result.scalar_one_or_none()

    if not user or not security.verify_password(user_in.password, user.hashed_password):
        logger.warning("Login failed due to invalid credentials", extra={"email": user_in.email})
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    elif not user.is_active:
        logger.warning("Login rejected for inactive user", extra={"user_id": user.id, "email": user.email})
        raise HTTPException(status_code=403, detail="Inactive user")

    access_token, refresh_token = await issue_token_pair(session, user)
    return build_auth_response(user, access_token, refresh_token)


@router.post(
    "/refresh",
    response_model=TokenPair,
    responses={401: {"model": ErrorResponse}},
)
@router.post(
    "/refresh/",
    response_model=TokenPair,
    include_in_schema=False,
    responses={401: {"model": ErrorResponse}},
)
async def refresh_token(
    session: deps.SessionDep,
    payload: TokenRefreshRequest,
) -> Any:
    auth_session, user, _ = await deps.get_auth_session(session, payload.refresh_token)
    logger.info("Refresh token rotated", extra={"user_id": user.id, "session_id": auth_session.id})
    return await rotate_refresh_token(session, auth_session, user)


@router.post(
    "/logout",
    responses={200: {"model": ErrorResponse}},
)
@router.post(
    "/logout/",
    include_in_schema=False,
    responses={200: {"model": ErrorResponse}},
)
async def logout(
    session: deps.SessionDep,
    payload: LogoutRequest,
) -> Any:
    try:
        auth_session, _, _ = await deps.get_auth_session(session, payload.refresh_token)
    except HTTPException:
        logger.info("Logout requested for non-active refresh token")
        return {"detail": "Logged out"}

    auth_session.is_revoked = True
    auth_session.last_used_at = datetime.now(timezone.utc)
    await session.commit()
    logger.info("Refresh session revoked on logout", extra={"session_id": auth_session.id, "user_id": auth_session.user_id})
    return {"detail": "Logged out"}


@router.get(
    "/me",
    response_model=UserPublic,
    responses={401: {"model": ErrorResponse}, 403: {"model": ErrorResponse}},
)
@router.get(
    "/me/",
    response_model=UserPublic,
    include_in_schema=False,
    responses={401: {"model": ErrorResponse}, 403: {"model": ErrorResponse}},
)
async def read_user_me(current_user: deps.CurrentUser) -> Any:
    """
    Get current user.
    """
    return current_user
