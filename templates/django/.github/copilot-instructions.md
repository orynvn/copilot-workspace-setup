# Django — Project-specific Copilot Instructions

> **Override file cho dự án Django + DRF.**
> Copy file này vào `.github/copilot-instructions.md` của project Django.
> Các quy tắc trong file này kết hợp với global rules.

---

## Stack: Django + Django REST Framework

### Phiên bản tối thiểu
- Python: 3.12+
- Django: 5.x
- Django REST Framework: 3.15+
- PostgreSQL: 15+
- Redis: 7.x (cache, Celery broker)

---

## Architecture

```
project/
├── manage.py
├── config/
│   ├── settings/
│   │   ├── base.py          # Common settings
│   │   ├── development.py   # Dev overrides
│   │   └── production.py    # Prod overrides
│   ├── urls.py
│   └── wsgi.py
└── apps/
    └── users/
        ├── apps.py
        ├── admin.py
        ├── models.py
        ├── serializers.py
        ├── views.py          # ViewSets
        ├── services.py       # Business logic
        ├── urls.py
        └── tests/
            ├── test_models.py
            ├── test_views.py
            └── test_services.py
```

## Patterns

- **URL → ViewSet → Serializer → Service → Model**
- ViewSets handle HTTP; delegate business logic to `services.py`.
- `services.py` functions are plain Python — no HTTP concepts.
- Models use type annotations on all fields.

## Models

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

    def __str__(self) -> str:
        return self.email
```

## Serializers (DRF)

- Always declare `fields` explicitly — never use `fields = '__all__'`.
- Add `read_only_fields` for auto-managed fields.

```python
from rest_framework import serializers
from .models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "name", "email", "is_active", "created_at"]
        read_only_fields = ["id", "created_at"]
```

## ViewSets

```python
from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from .serializers import UserSerializer
from . import services


class UserViewSet(viewsets.ModelViewSet):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return services.get_users()

    def perform_create(self, serializer: UserSerializer) -> None:
        services.create_user(serializer.validated_data)
```

## Services Layer

```python
# apps/users/services.py
from django.db.models import QuerySet
from .models import User


def get_users() -> QuerySet[User]:
    return User.objects.filter(is_active=True).select_related("profile")


def create_user(data: dict) -> User:
    return User.objects.create(**data)
```

## URL Registration

```python
# apps/users/urls.py
from rest_framework.routers import DefaultRouter
from .views import UserViewSet

router = DefaultRouter()
router.register(r"users", UserViewSet, basename="user")
urlpatterns = router.urls
```

## Settings Split

```python
# config/settings/base.py — never put secrets here
INSTALLED_APPS = [
    "django.contrib.auth",
    "rest_framework",
    "apps.users",
]

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": ["rest_framework_simplejwt.authentication.JWTAuthentication"],
    "DEFAULT_PERMISSION_CLASSES": ["rest_framework.permissions.IsAuthenticated"],
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 20,
}
```

## Testing (pytest + pytest-django)

```python
# pytest.ini or pyproject.toml
[pytest]
DJANGO_SETTINGS_MODULE = config.settings.development
python_files = tests/test_*.py
```

```python
import pytest
from django.test import Client


@pytest.mark.django_db
def test_list_users(client: Client, user_factory) -> None:
    user_factory(n=3)
    response = client.get("/api/v1/users/")
    assert response.status_code == 200
    assert len(response.json()["results"]) == 3
```

## Environment Variables

```bash
# .env
SECRET_KEY=change_me_in_production
DEBUG=True
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
ALLOWED_HOSTS=localhost,127.0.0.1
REDIS_URL=redis://localhost:6379/0
```
