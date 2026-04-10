import base64
import hashlib
import os
import secrets
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Optional

import jwt
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

ALGORITHM = "HS256"
ACCESS_TOKEN_TYPE = "access"
REFRESH_TOKEN_TYPE = "refresh"


def create_access_token(subject: str | Any, expires_delta: Optional[timedelta] = None) -> str:
    return create_token(subject=subject, token_type=ACCESS_TOKEN_TYPE, expires_delta=expires_delta)


def create_token(
    subject: str | Any,
    token_type: str,
    expires_delta: Optional[timedelta] = None,
    session_id: Optional[str] = None,
    token_id: Optional[str] = None,
) -> str:
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        if token_type == REFRESH_TOKEN_TYPE:
            expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        else:
            expire = datetime.now(timezone.utc) + timedelta(
                minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
            )
    to_encode = {"exp": expire, "sub": str(subject), "type": token_type}
    if session_id is not None:
        to_encode["sid"] = session_id
    if token_id is not None:
        to_encode["jti"] = token_id
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(subject: str | Any, session_id: str) -> str:
    return create_token(
        subject=subject,
        token_type=REFRESH_TOKEN_TYPE,
        session_id=session_id,
        token_id=str(uuid.uuid4()),
    )


def new_session_id() -> str:
    return str(uuid.uuid4())


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def compare_token_hash(token: str, expected_hash: str) -> bool:
    return secrets.compare_digest(hash_token(token), expected_hash)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def encrypt_credentials(plain_text: str) -> str:
    """
    Encrypt text using AES-256-GCM.
    Returns base64 encoded (IV + TAG + CIPHERTEXT).
    """
    try:
        # Key must be 32 bytes for AES-256
        key_bytes = base64.b64decode(settings.ENCRYPTION_KEY)
        if len(key_bytes) != 32:
            raise ValueError("ENCRYPTION_KEY must be a 32-byte base64 encoded string.")
            
        iv = os.urandom(12)  # Recommended 96-bit nonce for GCM
        cipher = Cipher(algorithms.AES(key_bytes), modes.GCM(iv), backend=default_backend())
        encryptor = cipher.encryptor()
        
        ciphertext = encryptor.update(plain_text.encode()) + encryptor.finalize()
        
        # Combine IV, Tag and Ciphertext
        return base64.b64encode(iv + encryptor.tag + ciphertext).decode()
    except Exception as e:
        # In production, logs should be carefully handled to not reveal secrets
        raise RuntimeError(f"Encryption failed: {str(e)}")


def decrypt_credentials(encrypted_text: str) -> str:
    """
    Decrypt text using AES-256-GCM.
    Expects base64 encoded (IV + TAG + CIPHERTEXT).
    """
    try:
        data = base64.b64decode(encrypted_text)
        iv = data[:12]
        tag = data[12:28]  # Tag is 16 bytes
        ciphertext = data[28:]
        
        key_bytes = base64.b64decode(settings.ENCRYPTION_KEY)
        if len(key_bytes) != 32:
            raise ValueError("ENCRYPTION_KEY must be a 32-byte base64 encoded string.")
            
        cipher = Cipher(algorithms.AES(key_bytes), modes.GCM(iv, tag), backend=default_backend())
        decryptor = cipher.decryptor()
        
        return (decryptor.update(ciphertext) + decryptor.finalize()).decode()
    except Exception as e:
        raise RuntimeError(f"Decryption failed: {str(e)}")
