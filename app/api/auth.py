from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select

from app.core import deps
from app.core import security
from app.models.user import User
from app.schemas.token import Token
from app.schemas.user import UserCreate, UserLogin, UserPublic

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=UserPublic)
async def register(
    session: deps.SessionDep, 
    user_in: UserCreate
) -> Any:
    """
    Create new user.
    """
    result = await session.execute(select(User).where(User.email == user_in.email))
    user = result.scalar_one_or_none()
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this email already exists in the system.",
        )
    
    db_user = User(
        email=user_in.email,
        hashed_password=security.get_password_hash(user_in.password),
        is_active=user_in.is_active,
    )
    session.add(db_user)
    await session.commit()
    await session.refresh(db_user)
    return db_user

@router.post("/login", response_model=Token)
async def login(
    session: deps.SessionDep,
    user_in: UserLogin
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests.
    """
    result = await session.execute(select(User).where(User.email == user_in.email))
    user = result.scalar_one_or_none()
    
    if not user or not security.verify_password(user_in.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    elif not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    
    return Token(
        access_token=security.create_access_token(user.id),
        token_type="bearer",
    )

@router.get("/me", response_model=UserPublic)
async def read_user_me(current_user: deps.CurrentUser) -> Any:
    """
    Get current user.
    """
    return current_user
