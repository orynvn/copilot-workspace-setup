---
applyTo: "**/routers/**/*.py,**/schemas/**/*.py,**/dependencies.py,**/main.py"
---

# FastAPI — Coding Instructions

## Architecture

- Follow **Router → Service → Repository** pattern.
- Split the app into **feature modules** — each in its own package.
- Use `APIRouter` per feature; aggregate in `main.py`.
- Keep route handlers thin — delegate to async service layer.

```
app/
├── main.py                  # FastAPI instance, include routers
├── core/
│   ├── config.py            # Pydantic Settings
│   ├── database.py          # Async SQLAlchemy engine
│   └── dependencies.py      # Shared FastAPI Depends
├── routers/
│   └── users.py             # APIRouter for /users
└── modules/
    └── users/
        ├── router.py
        ├── service.py
        ├── repository.py
        ├── schemas.py       # Pydantic v2 models
        └── models.py        # SQLAlchemy ORM models
```

## Pydantic v2 Schemas

- Use Pydantic v2 with `model_config = ConfigDict(...)` — not `class Config`.
- Define separate schemas for **request** (`CreateUserRequest`), **response** (`UserResponse`), and **DB** (`UserInDB`).
- Use `model_validator` and `field_validator` for cross-field validation.
- Always set `from_attributes = True` in response models (ORM mode).

```python
from pydantic import BaseModel, EmailStr, ConfigDict, field_validator, model_validator
from datetime import datetime
from uuid import UUID


class CreateUserRequest(BaseModel):
    name: str
    email: EmailStr
    password: str

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    email: EmailStr
    created_at: datetime
```

## Async Route Handlers

- All route handlers MUST be `async def`.
- Service methods MUST be `async def` — use `await` for all I/O operations.
- Use `async with` for database sessions — never keep sessionsopen across requests.
- Prefer `asyncpg` / async SQLAlchemy over sync drivers.

```python
from fastapi import APIRouter, Depends, HTTPException, status
from .schemas import CreateUserRequest, UserResponse
from .service import UserService
from core.dependencies import get_user_service

router = APIRouter(prefix="/users", tags=["users"])


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    body: CreateUserRequest,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    return await service.create(body)


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: UUID,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = await service.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user
```

## Dependencies (Depends)

- Use `Depends()` for DI — database sessions, auth, services.
- Auth dependency must raise `HTTPException(401)` or `HTTPException(403)`.
- Never access `request.state` directly for auth — use typed dependencies.

```python
# core/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from .database import AsyncSession, get_db

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> User:
    token = credentials.credentials
    user = await verify_jwt_and_get_user(token, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )
    return user
```

## Configuration (Pydantic Settings)

- Use `pydantic-settings` `BaseSettings` — never read `os.environ` directly.
- Load `.env` file automatically.
- Use a singleton pattern with `@lru_cache`.

```python
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False
    allowed_origins: list[str] = []

    model_config = ConfigDict(env_file=".env")


@lru_cache
def get_settings() -> Settings:
    return Settings()
```

## Error Handling

- Use `HTTPException` with structured `detail` objects — not bare strings for API errors.
- Register global exception handlers in `main.py` for `RequestValidationError` and custom domain errors.
- Return consistent error shape: `{"error": "...", "detail": [...]}`.

```python
from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


@app.exception_handler(RequestValidationError)
async def validation_error_handler(req: Request, exc: RequestValidationError) -> JSONResponse:
    return JSONResponse(
        status_code=422,
        content={"error": "Validation failed", "detail": exc.errors()},
    )
```

## Type Hints

- Full type annotations on **all** functions, methods, and class attributes.
- Use `from __future__ import annotations` for forward references.
- Use `TypeAlias` and `TypeVar` where appropriate.
- Run `mypy` with `strict` mode in CI.

```python
from __future__ import annotations
from typing import Optional, Sequence
from uuid import UUID


async def get_users(
    skip: int = 0,
    limit: int = 100,
    is_active: Optional[bool] = None,
) -> Sequence[UserResponse]:
    ...
```

## Security

- Always validate JWT in a `Depends` chain — never in route handlers directly.
- Use `secrets.compare_digest()` for token comparison (timing-safe).
- Set `CORS` origins explicitly — never `allow_origins=["*"]` in production.
- Validate file uploads: check content type, size, use `aiofiles` for disk writes.
- Use parameterized queries — never f-strings in SQLAlchemy `text()` calls.

## Testing

- Use `pytest` + `pytest-asyncio` for async tests.
- Use `httpx.AsyncClient` with `ASGITransport` — not `TestClient` for async apps.
- Use an in-memory SQLite or test database with `pytest` fixtures.

```python
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest_asyncio.fixture
async def client() -> AsyncClient:
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


@pytest.mark.asyncio
async def test_create_user(client: AsyncClient) -> None:
    response = await client.post("/users/", json={"name": "Alice", "email": "alice@example.com", "password": "secret123"})
    assert response.status_code == 201
    assert response.json()["email"] == "alice@example.com"
```

## Naming

| Entity | Convention | Example |
|---|---|---|
| Router file | snake_case | `users.py` |
| Schema (request) | PascalCase + `Request` | `CreateUserRequest` |
| Schema (response) | PascalCase + `Response` | `UserResponse` |
| Service | PascalCase + `Service` | `UserService` |
| Repository | PascalCase + `Repository` | `UserRepository` |
| Dependency | `get_` prefix, snake_case | `get_current_user()` |
| URL route | kebab-case | `/user-profiles/` |
