import base64
import os
import unittest

from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine
from sqlalchemy.pool import StaticPool

os.environ.setdefault("SECRET_KEY", "test-secret-key")
os.environ.setdefault("ENCRYPTION_KEY", base64.b64encode(b"0123456789abcdef0123456789abcdef").decode())
os.environ.setdefault("DATABASE_URL", "postgresql+asyncpg://test:test@localhost/test_db")
os.environ.setdefault("ENVIRONMENT", "local")

from app.core import deps  # noqa: E402
from app.db.session import Base  # noqa: E402
from app.main import app  # noqa: E402


class AuthApiTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self) -> None:
        self.engine = create_async_engine(
            "sqlite+aiosqlite://",
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
        self.session_maker = async_sessionmaker(self.engine, expire_on_commit=False)

        async with self.engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

        async def override_get_db():
            async with self.session_maker() as session:
                yield session

        app.dependency_overrides[deps.get_db] = override_get_db
        self.client = AsyncClient(
            transport=ASGITransport(app=app),
            base_url="http://testserver",
            follow_redirects=False,
        )

    async def asyncTearDown(self) -> None:
        await self.client.aclose()
        app.dependency_overrides.clear()
        async with self.engine.begin() as conn:
            await conn.run_sync(Base.metadata.drop_all)
        await self.engine.dispose()

    async def signup(self, email: str = "user@example.com", password: str = "password123"):
        return await self.client.post(
            "/api/v1/auth/register",
            json={"email": email, "password": password},
        )

    async def login(self, email: str = "user@example.com", password: str = "password123"):
        return await self.client.post(
            "/api/v1/auth/login",
            json={"email": email, "password": password},
        )

    async def test_signup_success(self):
        response = await self.signup()

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("access_token", data)
        self.assertIn("refresh_token", data)
        self.assertEqual(data["token_type"], "bearer")
        self.assertEqual(data["user"]["email"], "user@example.com")

    async def test_signup_duplicate_email(self):
        await self.signup()
        response = await self.signup()

        self.assertEqual(response.status_code, 400)
        self.assertEqual(
            response.json()["detail"],
            "The user with this email already exists in the system.",
        )

    async def test_login_success(self):
        await self.signup()
        response = await self.login()

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("access_token", data)
        self.assertIn("refresh_token", data)
        self.assertEqual(data["user"]["email"], "user@example.com")

    async def test_login_invalid_credentials(self):
        await self.signup()
        response = await self.login(password="wrong-password")

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json()["detail"], "Incorrect email or password")

    async def test_me_success(self):
        signup_response = await self.signup()
        access_token = signup_response.json()["access_token"]

        response = await self.client.get(
            "/api/v1/auth/me",
            headers={"Authorization": f"Bearer {access_token}"},
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["email"], "user@example.com")

    async def test_me_unauthorized(self):
        response = await self.client.get("/api/v1/auth/me")

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json()["detail"], "Not authenticated")

    async def test_refresh_success(self):
        signup_response = await self.signup()
        refresh_token = signup_response.json()["refresh_token"]

        response = await self.client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh_token},
        )

        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("access_token", data)
        self.assertIn("refresh_token", data)
        self.assertNotEqual(data["refresh_token"], refresh_token)

    async def test_refresh_failure(self):
        response = await self.client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": "invalid-token"},
        )

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.json()["detail"], "Invalid or expired token")

    async def test_logout(self):
        signup_response = await self.signup()
        refresh_token = signup_response.json()["refresh_token"]

        logout_response = await self.client.post(
            "/api/v1/auth/logout",
            json={"refresh_token": refresh_token},
        )
        refresh_response = await self.client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh_token},
        )

        self.assertEqual(logout_response.status_code, 200)
        self.assertEqual(logout_response.json()["detail"], "Logged out")
        self.assertEqual(refresh_response.status_code, 401)

    async def test_auth_endpoints_do_not_redirect(self):
        response_specs = [
            ("post", "/api/v1/auth/register", {"email": "slashless@example.com", "password": "password123"}),
            ("post", "/api/v1/auth/register/", {"email": "slash@example.com", "password": "password123"}),
            ("post", "/api/v1/auth/login", {"email": "slashless@example.com", "password": "password123"}),
            ("post", "/api/v1/auth/login/", {"email": "slash@example.com", "password": "password123"}),
            ("get", "/api/v1/auth/me", None),
            ("get", "/api/v1/auth/me/", None),
            ("post", "/api/v1/auth/refresh", {"refresh_token": "invalid-token"}),
            ("post", "/api/v1/auth/refresh/", {"refresh_token": "invalid-token"}),
            ("post", "/api/v1/auth/logout", {"refresh_token": "invalid-token"}),
            ("post", "/api/v1/auth/logout/", {"refresh_token": "invalid-token"}),
        ]

        for method, path, payload in response_specs:
            if method == "get":
                response = await self.client.get(path)
            else:
                response = await self.client.post(path, json=payload)
            self.assertNotIn(response.status_code, {301, 302, 307, 308}, msg=path)


if __name__ == "__main__":
    unittest.main()
