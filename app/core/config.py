import base64
import warnings
from typing import Annotated, Any, Literal, Optional

from pydantic import (
    AnyHttpUrl,
    BeforeValidator,
    PostgresDsn,
    computed_field,
    model_validator,
)
from pydantic_settings import BaseSettings, SettingsConfigDict


def parse_cors(v: Any) -> list[str] | str:
    if isinstance(v, str) and not v.startswith("["):
        return [i.strip() for i in v.split(",") if i.strip()]
    elif isinstance(v, list | str):
        return v
    raise ValueError(v)


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        # Use .env file
        env_file=".env",
        env_ignore_empty=True,
        extra="ignore",
    )
    
    API_V1_STR: str = "/api/v1"
    
    # Auth
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    # SSH Encryption
    ENCRYPTION_KEY: str  # Must be 32 bytes (base64 encoded) for AES-256
    KNOWN_HOSTS_FILE: Optional[str] = None
    
    # Environment
    ENVIRONMENT: Literal["local", "staging", "production"] = "local"
    DEBUG: bool = False

    # Database
    DATABASE_URL: PostgresDsn
    
    # CORS
    ALLOWED_ORIGINS: Annotated[
        list[AnyHttpUrl] | str, BeforeValidator(parse_cors)
    ] = []

    @computed_field
    @property
    def all_cors_origins(self) -> list[str]:
        return [str(origin).rstrip("/") for origin in self.ALLOWED_ORIGINS]

    PROJECT_NAME: str = "AI Server Copilot"

    @model_validator(mode="after")
    def _enforce_non_default_secrets(self) -> "Settings":
        self._check_default_secret("SECRET_KEY", self.SECRET_KEY)
        # Check ENCRYPTION_KEY is valid base64 and 32 bytes
        try:
            key_bytes = base64.b64decode(self.ENCRYPTION_KEY)
            if len(key_bytes) != 32:
                raise ValueError("ENCRYPTION_KEY must be a 32-byte base64 encoded string.")
        except Exception:
            if self.ENVIRONMENT != "local":
                 raise ValueError("ENCRYPTION_KEY must be a valid 32-byte base64 encoded string.")
            else:
                 warnings.warn("ENCRYPTION_KEY is missing or invalid. Use a 32-byte base64 string.", stacklevel=1)
        return self

    def _check_default_secret(self, var_name: str, value: str | None) -> None:
        if value == "changethis" or value == "secret":
            message = (
                f'The value of {var_name} is "{value}", '
                "for security, please change it, at least for deployments."
            )
            if self.ENVIRONMENT == "local":
                warnings.warn(message, stacklevel=1)
            else:
                raise ValueError(message)


settings = Settings()  # type: ignore
