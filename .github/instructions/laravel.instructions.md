---
applyTo: "**/*.php"
---

# Laravel — Coding Instructions

> **PHP 8.2+ required.** Use typed properties, readonly properties, enums, fibers, and DNF types freely.

## Architecture — Modular Structure

- Organize code into self-contained **domain modules** under `app/Modules/<Name>/`.
- Each module owns its own Controllers, Services, Repositories, Models, Resources, Requests, Events.
- Follow **Service → Repository → Model** pattern within each module.
- Controllers must be thin — delegate business logic to Services.
- Use **Form Requests** for input validation, never validate in controllers directly.
- Use **API Resources** (`app/Http/Resources/`) for all JSON responses.

```
app/
├── Modules/
│   └── Users/
│       ├── Controllers/
│       ├── Services/
│       ├── Repositories/
│       ├── Models/
│       ├── Resources/
│       ├── Requests/
│       └── Routes/
│           └── api.php
└── Providers/
    └── ModuleServiceProvider.php
```

## Naming

| Entity | Convention | Example |
|---|---|---|
| Controller | PascalCase + `Controller` | `UserController` |
| Service | PascalCase + `Service` | `UserService` |
| Repository | PascalCase + `Repository` | `UserRepository` |
| Model | PascalCase, singular | `UserProfile` |
| Migration | snake_case, timestamped | `2024_01_01_create_users_table` |
| Job | PascalCase + verb | `SendWelcomeEmail` |
| Event | PascalCase, past tense | `UserRegistered` |
| Listener | PascalCase + `Listener` | `SendWelcomeEmailListener` |

## PHP 8.2+ Features — Use These

```php
// Readonly properties
class UserDto
{
    public function __construct(
        public readonly string $name,
        public readonly string $email,
    ) {}
}

// Native enums
enum UserStatus: string
{
    case Active   = 'active';
    case Inactive = 'inactive';
    case Banned   = 'banned';
}

// Typed properties on Models
class User extends Model
{
    protected string $table = 'users';
    protected $fillable = ['name', 'email', 'status'];

    protected $casts = [
        'status' => UserStatus::class,  // cast to enum
    ];
}
```

## Eloquent ORM

- Always define `$fillable` on every Model — never use `$guarded = []`.
- Use **scopes** for reusable query constraints: `scopeActive()`.
- Eager load relationships to avoid N+1: `with(['profile', 'roles'])`.
- Never use `DB::select()` with string interpolation — use query builder bindings.

```php
// ✅ Good
User::query()->where('active', true)->with('profile')->get();

// ❌ Bad
DB::select("SELECT * FROM users WHERE id = $id");
```

## API Structure

- Route prefix: `/api/v1/`
- Always return consistent response shape:

```php
return response()->json([
    'success' => true,
    'data'    => $resource,
    'message' => 'Operation successful',
], 200);
```

- Use `app/Exceptions/Handler.php` to centralize error formatting.

## Security

- Always use `$request->validated()` — never `$request->all()` in business logic.
- Sanitize file uploads: validate MIME type, size, store with `Storage::disk()`.
- Rate limit sensitive endpoints with `throttle` middleware.
- Use `Gate` and `Policy` for authorization — never check roles inline in controllers.

## Testing — PHPUnit

- Test files: `tests/Feature/<Module>/` and `tests/Unit/<Module>/`.
- Use **RefreshDatabase** trait for feature tests.
- Factory method convention: `User::factory()->create(['status' => UserStatus::Active])`.
- Assert HTTP status AND response structure:

```php
$response->assertStatus(201)
         ->assertJsonStructure(['success', 'data' => ['id', 'name', 'email']])
         ->assertJsonPath('data.status', UserStatus::Active->value);
```

## Artisan & Commands

- Custom commands: `app/Console/Commands/`, extend `Command`.
- Always use `$this->info()`, `$this->error()` — never `echo`.
- Register in `app/Console/Kernel.php` schedules if recurring.
