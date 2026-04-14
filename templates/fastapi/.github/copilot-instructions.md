# FastAPI — Project-specific Copilot Instructions

> **Override file cho dự án FastAPI.**
> Copy file này vào `.github/copilot-instructions.md` của project FastAPI.
> Các quy tắc trong file này kết hợp với global rules.

---

## Stack: FastAPI + Pydantic v2

### Phiên bản tối thiểu
- Python: 3.12+
- FastAPI: 0.111+
- Pydantic: 2.x
- SQLAlchemy: 2.x (async)
- PostgreSQL: 15+

---

## Architecture

```
app/
├── main.py                    # FastAPI app factory
├── dependencies.py            # Shared Depends() factories
├── config.py                  # pydantic-settings BaseSettings
├── database.py                # Async engine + session
├── routers/
│   ├── __init__.py
│   └── users.py               # APIRouter per domain
├── schemas/
│   ├── __init__.py
│   └── user.py                # Pydantic request/response schemas
├── models/
│   └── user.py                # SQLAlchemy ORM models
├── services/
│   └── user_service.py        # Business logic
└── repositories/
    └── user_repository.py     # DB queries
```

## Patterns

- **Router → Service → Repository → Model**
- All route handlers must be `async def`.
- Use `Depends()` for all dependency injection (auth, db session, services).
- Schemas (Pydantic) are separate from ORM Models (SQLAlchemy).

## Schemas (Pydantic v2)

```python
from pydantic import BaseModel, EmailStr, ConfigDict, field_validator


class UserBase(BaseModel):
    name: str
    email: EmailStr


class UserCreate(UserBase):
    password: str

    @field_validator("password")
    @classmethod
    def password_strong(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v


class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    is_active: bool
```

## Routers

```python
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies import get_db, get_current_user
from app.schemas.user import UserCreate, UserResponse
from app.services import user_service

router = APIRouter(prefix="/users", tags=["users"])


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    payload: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> UserResponse:
    return await user_service.create_user(db, payload)


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
) -> UserResponse:
    return await user_service.get_user_or_404(db, user_id)
```

## Dependencies

```python
# app/dependencies.py
from functools import lru_cache
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import async_session_factory
from app.config import Settings

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/token")


async def get_db() -> AsyncSession:
    async with async_session_factory() as session:
        yield session


@lru_cache
def get_settings() -> Settings:
    return Settings()


async def get_current_user(token: str = Depends(oauth2_scheme)):
    # verify JWT, return user
    ...
```

## Config (pydantic-settings)

```python
# app/config.py
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "My FastAPI App"
    database_url: str
    redis_url: str = "redis://localhost:6379"
    jwt_secret: str
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30


@lru_cache
def get_settings() -> Settings:
    return Settings()
```

## Error Handling

Add global exception handlers in `main.py`:

```python
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

app = FastAPI()

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"success": False, "errors": exc.errors()},
    )
```

## Testing (pytest-asyncio)

```python
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

```python
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.fixture
async def client():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac


async def test_create_user(client: AsyncClient) -> None:
    response = await client.post("/api/v1/users/", json={
        "name": "Alice",
        "email": "alice@example.com",
        "password": "secure12345",
    })
    assert response.status_code == 201
    assert response.json()["email"] == "alice@example.com"
```

## Environment Variables

```bash
# .env
APP_NAME=My FastAPI App
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/mydb
REDIS_URL=redis://localhost:6379
JWT_SECRET=change_me_in_production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```
