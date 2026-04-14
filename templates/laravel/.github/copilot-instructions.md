# Laravel — Project-specific Copilot Instructions

> **Override file cho dự án Laravel.**  
> Copy file này vào `.github/copilot-instructions.md` của project Laravel.  
> Các quy tắc trong file này kết hợp với global rules.

---

## Stack: Laravel + PHP

### Phiên bản tối thiểu
- PHP: 8.2+
- Laravel: 11.x
- MySQL: 8.0+ / PostgreSQL 15+
- Redis: 7.x (cho cache, queue, session)

---

## Architecture

```
app/
├── Console/Commands/          # Artisan commands
├── Events/                    # Domain events
├── Exceptions/                # Custom exceptions + Handler override
├── Http/
│   ├── Controllers/           # Thin controllers
│   ├── Middleware/            # Request middleware
│   ├── Requests/              # Form request classes (validation)
│   └── Resources/             # API resources (response transformers)
├── Jobs/                      # Queue jobs
├── Listeners/                 # Event listeners
├── Models/                    # Eloquent models
├── Policies/                  # Authorization policies
├── Providers/                 # Service providers
├── Repositories/              # Database access layer
└── Services/                  # Business logic layer
```

## Patterns

- **Controller → Service → Repository → Model**
- Controllers chỉ handle HTTP: validate request, call service, return response.
- Services chứa business logic — không directly query DB.
- Repositories chứa Eloquent queries — nhận/trả về Models hoặc Collections.
- API responses luôn dùng Resource classes.

## Route conventions

```php
// routes/api.php
Route::prefix('v1')->middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('users', UserController::class);
    Route::apiResource('products', ProductController::class);
});
```

## Response format chuẩn

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful",
  "meta": { "total": 100, "page": 1 }
}
```

## Queue & Jobs

- Luôn implement `ShouldQueue` cho time-consuming operations.
- Khai báo `$tries`, `$timeout`, `$backoff` cho mọi Job.
- Dùng `$job->fail()` thay vì throw exception khi cần dừng.

## Testing

- Framework: **Pest PHP**
- Feature tests: `tests/Feature/` — test HTTP endpoints.
- Unit tests: `tests/Unit/` — test Services, Repositories.
- Dùng `RefreshDatabase` hoặc `DatabaseTransactions` trait.
- Factories: tạo cho mọi Model.
- Không mock Eloquent — dùng test DB thật (SQLite in-memory hoặc MySQL test DB).

## Local development commands

```bash
# Start development
php artisan serve
php artisan queue:work --tries=3

# Testing
php artisan test -p    # parallel
php artisan test --coverage

# Code quality
./vendor/bin/pint      # Code style (Laravel Pint)
./vendor/bin/phpstan   # Static analysis

# Database
php artisan migrate:fresh --seed
```

## Forbidden patterns

- ❌ `$request->all()` trong business logic — dùng `$request->validated()`
- ❌ Logic trong Controller — move xuống Service
- ❌ DB query trong Controller hoặc View — move xuống Repository
- ❌ `Auth::user()` trong Service — inject qua parameter
- ❌ Hardcoded `env()` calls ngoài config files
