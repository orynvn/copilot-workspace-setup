# Laravel — Project-specific Copilot Instructions

> **Override file for Laravel projects.**
> Copy this file to `.github/copilot-instructions.md` in your Laravel project.
> Rules in this file combine with the global rules.

---

## Stack: Laravel + PHP

### Minimum version
- PHP: 8.2+
- Laravel: 11.x
- MySQL: 8.0+ / PostgreSQL 15+
- Redis: 7.x (for cache, queue, session)

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
- Controllers only handle HTTP: validate request, call service, return response.
- Services contain business logic — do not directly query the DB.
- Repositories contain Eloquent queries — receive/return Models or Collections.
- API responses always use Resource classes.

## Route conventions

```php
// routes/api.php
Route::prefix('v1')->middleware(['auth:sanctum'])->group(function () {
    Route::apiResource('users', UserController::class);
    Route::apiResource('products', ProductController::class);
});
```

## Standard response format

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful",
  "meta": { "total": 100, "page": 1 }
}
```

## Queue & Jobs

- Always implement `ShouldQueue` for time-consuming operations.
- Declare `$tries`, `$timeout`, `$backoff` for every Job.
- Use `$job->fail()` instead of throwing an exception when stopping is needed.

## Testing

- Framework: **Pest PHP**
- Feature tests: `tests/Feature/` — test HTTP endpoints.
- Unit tests: `tests/Unit/` — test Services, Repositories.
- Use `RefreshDatabase` or `DatabaseTransactions` trait.
- Factories: create for every Model.
- Do not mock Eloquent — use a real test DB (SQLite in-memory or MySQL test DB).

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

- ❌ `$request->all()` in business logic — use `$request->validated()`
- ❌ Logic in Controller — move to Service
- ❌ DB query in Controller or View — move to Repository
- ❌ `Auth::user()` in Service — inject via parameter
- ❌ Hardcoded `env()` calls outside config files
