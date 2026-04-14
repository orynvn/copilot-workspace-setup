---
applyTo: "**/serializers.py,**/models.py,**/views.py,**/viewsets.py,**/apps.py,**/admin.py"
---

# Django — Coding Instructions

## Architecture

- Follow **URL → View/ViewSet → Serializer → Model** pattern.
- Use **Django REST Framework (DRF)** for all API endpoints.
- Group related code into Django **apps** (`users`, `products`, `orders`).
- Keep `views.py` thin — delegate business logic to a `services.py` layer.

```
project/
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   └── urls.py
└── apps/
    └── users/
        ├── apps.py
        ├── models.py
        ├── serializers.py
        ├── views.py          # or viewsets.py
        ├── services.py       # business logic
        ├── urls.py
        ├── admin.py
        └── tests/
            ├── test_models.py
            └── test_views.py
```

## Models

- Enable **type hints** on all model fields and methods (Python 3.10+).
- Use `class Meta` with `db_table`, `ordering`, `verbose_name`.
- Define `__str__` on every model.
- Use `select_related()` / `prefetch_related()` — never access related objects in loops (N+1).

```python
from django.db import models
from django.utils import timezone


class User(models.Model):
    name: str = models.CharField(max_length=255)
    email: str = models.EmailField(unique=True)
    is_active: bool = models.BooleanField(default=True)
    created_at: timezone.datetime = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "users"
        ordering = ["-created_at"]
        verbose_name = "user"

    def __str__(self) -> str:
        return self.email

    # ✅ Good — use select_related instead of lazy access
    @classmethod
    def active_with_profile(cls) -> models.QuerySet:
        return cls.objects.filter(is_active=True).select_related("profile")
```

## Serializers (DRF)

- Use `ModelSerializer` as the base; explicitly declare `fields` — never `fields = '__all__'`.
- Use `SerializerMethodField` for computed/derived values.
- Separate `read` and `write` serializers when shapes differ significantly.
- Validate at the serializer level with `validate_<field>()` and `validate()`.

```python
from rest_framework import serializers


class UserSerializer(serializers.ModelSerializer):
    full_name: str = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ["id", "email", "name", "full_name", "created_at"]
        read_only_fields = ["id", "created_at"]

    def get_full_name(self, obj: User) -> str:
        return f"{obj.first_name} {obj.last_name}".strip()

    def validate_email(self, value: str) -> str:
        if User.objects.filter(email=value).exclude(pk=self.instance.pk if self.instance else None).exists():
            raise serializers.ValidationError("Email already in use.")
        return value.lower()
```

## ViewSets & Views

- Prefer **ViewSets** with routers for CRUD resources.
- Use **APIView** or `@api_view` for non-resource endpoints.
- Apply permissions via `permission_classes` — never check `request.user` inline.
- Apply filtering via `django-filter` — never build raw query strings manually.

```python
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response


class UserViewSet(viewsets.ModelViewSet):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = UserSerializer
    filterset_fields = ["is_active"]

    def get_queryset(self):
        return User.objects.filter(is_active=True).select_related("profile")

    @action(detail=True, methods=["post"])
    def deactivate(self, request, pk=None) -> Response:
        user = self.get_object()
        user.is_active = False
        user.save(update_fields=["is_active"])
        return Response({"status": "deactivated"})
```

## Services Layer

- Business logic lives in `services.py`, not in views or models.
- Service functions are plain Python functions (or class methods) with full type hints.

```python
# apps/users/services.py
from typing import Optional
from .models import User


def create_user(email: str, name: str, password: str) -> User:
    user = User.objects.create_user(email=email, name=name, password=password)
    # send welcome email, etc.
    return user


def deactivate_user(user_id: int) -> Optional[User]:
    try:
        user = User.objects.get(pk=user_id)
        user.is_active = False
        user.save(update_fields=["is_active"])
        return user
    except User.DoesNotExist:
        return None
```

## Type Hints

- Use type hints on **all** function signatures and return types (Python 3.10+).
- Use `from __future__ import annotations` for forward references.
- Use `django-stubs` and `djangorestframework-stubs` for mypy compatibility.

```python
from __future__ import annotations
from typing import Optional
from django.http import HttpRequest
from rest_framework.response import Response


def get_active_user(user_id: int) -> Optional[User]:
    return User.objects.filter(pk=user_id, is_active=True).first()
```

## Settings

- Split settings: `base.py` + `development.py` + `production.py`.
- Never hardcode secrets — use `python-decouple` or `environ` to read from `.env`.
- Use `DJANGO_SETTINGS_MODULE` env var to select the correct settings file.

```python
# config/settings/base.py
from decouple import config

SECRET_KEY: str = config("SECRET_KEY")
DATABASE_URL: str = config("DATABASE_URL")
DEBUG: bool = config("DEBUG", cast=bool, default=False)
```

## Security

- Set `SECURE_SSL_REDIRECT`, `CSRF_COOKIE_SECURE`, `SESSION_COOKIE_SECURE` in production.
- Always use `get_object_or_404()` — never raw `get()` in views.
- Validate uploaded files: check content type, size, store with `default_storage`.
- Use DRF's `IsAuthenticated` + `IsAdminUser` permissions — never inline `if request.user.is_staff`.

## Testing

- Use `pytest` with `pytest-django` — not `TestCase` subclasses.
- Use `APIClient` from DRF for HTTP tests.
- Use `factory_boy` for creating test data — not raw `.create()` in tests.
- Mark tests with `@pytest.mark.django_db`.

```python
import pytest
from rest_framework.test import APIClient
from .factories import UserFactory


@pytest.mark.django_db
def test_user_list_requires_auth(client: APIClient) -> None:
    response = client.get("/api/users/")
    assert response.status_code == 401


@pytest.mark.django_db
def test_create_user(api_client: APIClient) -> None:
    payload = {"email": "test@example.com", "name": "Test User"}
    response = api_client.post("/api/users/", payload)
    assert response.status_code == 201
    assert response.data["email"] == payload["email"]
```

## Naming

| Entity | Convention | Example |
|---|---|---|
| Model | PascalCase, singular | `UserProfile` |
| ViewSet | PascalCase + `ViewSet` | `UserViewSet` |
| Serializer | PascalCase + `Serializer` | `UserSerializer` |
| Service function | snake_case | `create_user()` |
| URL pattern | kebab-case | `/api/user-profiles/` |
| Django app | snake_case | `user_profiles` |
| DB table | snake_case, plural | `user_profiles` |
