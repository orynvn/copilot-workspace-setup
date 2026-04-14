# NestJS — Project-specific Copilot Instructions

> **Override file for NestJS projects.**
> Copy this file to `.github/copilot-instructions.md` in your NestJS project.
> Rules in this file combine with the global rules.

---

## Stack: NestJS + TypeScript

### Minimum version
- Node.js: 20.x LTS
- NestJS: 10.x
- TypeScript: 5.x (strict mode)
- PostgreSQL 15+ / MongoDB 6+

---

## Architecture

```
src/
├── app.module.ts              # Root module
├── main.ts                    # Bootstrap
├── common/
│   ├── decorators/            # Custom decorators (@Public, @Roles)
│   ├── exceptions/            # Custom exception subclasses
│   ├── filters/               # Global exception filters
│   ├── guards/                # Auth guards (JwtAuthGuard, RolesGuard)
│   ├── interceptors/          # Response transform, logging
│   └── pipes/                 # Validation pipes
├── config/                    # ConfigModule setup
└── modules/
    └── users/
        ├── users.module.ts
        ├── users.controller.ts
        ├── users.service.ts
        ├── users.repository.ts
        ├── dto/
        │   ├── create-user.dto.ts
        │   └── update-user.dto.ts
        └── entities/
            └── user.entity.ts
```

## Patterns

- **Controller → Service → Repository → Entity** architecture.
- Controllers handle HTTP only — route, validate input (via DTOs + Pipes), return response.
- Services contain all business logic — injected via constructor DI.
- Repositories handle DB queries only (TypeORM/Prisma) — injected into Services.
- Each module is self-contained and registered in the root AppModule.

## DTOs

```ts
import { IsEmail, IsString, MinLength } from 'class-validator'

export class CreateUserDto {
  @IsString()
  name: string

  @IsEmail()
  email: string

  @IsString()
  @MinLength(8)
  password: string
}

// Update DTO inherits all as optional via PartialType
export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

## Global ValidationPipe

In `main.ts`, always configure:
```ts
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,          // strip unknown properties
    forbidNonWhitelisted: true,
    transform: true,          // auto-transform payloads to DTO types
    transformOptions: { enableImplicitConversion: true },
  }),
)
```

## Guards & Auth

```ts
// JWT guard applied globally — use @Public() to opt out
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.get<boolean>('isPublic', context.getHandler())
    if (isPublic) return true
    return super.canActivate(context)
  }
}

// Roles guard
@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ])
    const { user } = context.switchToHttp().getRequest()
    return requiredRoles.some((role) => user.roles.includes(role))
  }
}
```

## Exception Handling

- Throw typed exceptions: `NotFoundException`, `UnauthorizedException`, `ConflictException`.
- Create custom exceptions in `common/exceptions/`:

```ts
export class EmailAlreadyExistsException extends ConflictException {
  constructor() {
    super('Email already exists')
  }
}
```

## Config

Use `@nestjs/config` with `ConfigService` — never use `process.env` directly:

```ts
constructor(private readonly config: ConfigService) {}

getDatabaseUrl(): string {
  return this.config.getOrThrow<string>('DATABASE_URL')
}
```

## Response Format

Use a response interceptor to normalize all responses:

```json
{
  "success": true,
  "data": { ... },
  "meta": { "total": 100, "page": 1, "limit": 20 }
}
```

## Testing

- **Unit**: `Test.createTestingModule()` with mocked providers.
- **Integration**: `supertest` against the full NestJS app.
- **E2E**: Playwright.

```ts
const module = await Test.createTestingModule({
  providers: [UsersService, { provide: UsersRepository, useValue: mockRepo }],
}).compile()
```

## Environment Variables

```bash
# .env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
JWT_SECRET=change_me_in_production
JWT_EXPIRES_IN=7d
REDIS_URL=redis://localhost:6379
```
