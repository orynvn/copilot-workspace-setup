---
applyTo: "src/**/*.ts"
---

# NestJS — Coding Instructions

## Architecture

- Follow **Module → Controller → Service → Repository** pattern.
- Each feature is a self-contained **Module** (`UserModule`, `AuthModule`).
- Controllers handle HTTP routing only — delegate all logic to Services.
- Services contain business logic; use **Repository pattern** (TypeORM/Prisma) for data access.
- Use **Dependency Injection** exclusively — never instantiate services directly (`new UserService()`).

```
src/
├── modules/
│   └── user/
│       ├── user.module.ts
│       ├── user.controller.ts
│       ├── user.service.ts
│       ├── user.repository.ts
│       ├── dto/
│       │   ├── create-user.dto.ts
│       │   └── update-user.dto.ts
│       └── entities/
│           └── user.entity.ts
├── common/
│   ├── guards/
│   ├── interceptors/
│   ├── filters/
│   └── pipes/
└── config/
    └── configuration.ts
```

## DTOs (Data Transfer Objects)

- Every endpoint MUST have a DTO — never accept `any` or raw objects.
- Use `class-validator` decorators for validation.
- Use `class-transformer` for type coercion.
- Separate `CreateDto` and `UpdateDto` (use `PartialType` for updates).

```ts
import { IsString, IsEmail, MinLength, IsOptional } from 'class-validator'
import { PartialType } from '@nestjs/mapped-types'

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  name: string

  @IsEmail()
  email: string
}

export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

## Guards

- Implement `CanActivate` interface — never check auth inline in controllers.
- Use `@UseGuards()` decorator; apply globally sensitive guards in `app.module.ts`.
- JWT guard via `@nestjs/passport`; role guard via custom `RolesGuard`.

```ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ])
    if (!requiredRoles) return true
    const { user } = context.switchToHttp().getRequest()
    return requiredRoles.some(role => user.roles?.includes(role))
  }
}
```

## Controllers

- Use `@ApiTags()`, `@ApiOperation()`, `@ApiResponse()` for Swagger documentation.
- Always type the return value and response body.
- Use `@HttpCode()` for non-200 success responses.

```ts
@Controller('users')
@ApiTags('users')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create user' })
  create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.userService.create(dto)
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
    return this.userService.findOne(id)
  }
}
```

## Pipes & Validation

- Enable `ValidationPipe` globally with `transform: true` and `whitelist: true`.
- `whitelist: true` strips undeclared properties — prevents mass assignment attacks.

```ts
// main.ts
app.useGlobalPipes(
  new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }),
)
```

## Exception Filters

- Use built-in `HttpException` subclasses (`NotFoundException`, `BadRequestException`).
- Create a global `HttpExceptionFilter` for consistent error response shape.
- Never throw generic `Error` — always use NestJS HTTP exceptions.

```ts
// ✅ Good
throw new NotFoundException(`User #${id} not found`)

// ❌ Bad
throw new Error('not found')
```

## Configuration

- Use `@nestjs/config` with `ConfigService` — never read `process.env` directly in services.
- Define a typed config factory in `config/configuration.ts`.
- Validate env vars with Joi or `class-validator` schema at startup.

```ts
// ✅ Good
constructor(private config: ConfigService) {}
const dbUrl = this.config.get<string>('database.url')

// ❌ Bad
const dbUrl = process.env.DATABASE_URL
```

## Security

- Apply `helmet()` and `cors()` in `main.ts`.
- Rate-limit with `@nestjs/throttler` — apply the guard globally.
- Never expose internal stack traces — use the global exception filter.
- Validate all UUIDs with `ParseUUIDPipe`; validate enums with `ParseEnumPipe`.

## Testing

- Unit tests: `*.spec.ts` alongside source files.
- E2E tests: `test/*.e2e-spec.ts` using `supertest`.
- Mock dependencies with `jest.fn()` or NestJS `Test.createTestingModule()`.

```ts
const module = await Test.createTestingModule({
  providers: [
    UserService,
    { provide: UserRepository, useValue: mockUserRepository },
  ],
}).compile()
```

## Naming

| Entity | Convention | Example |
|---|---|---|
| Module | PascalCase + `Module` | `UserModule` |
| Controller | PascalCase + `Controller` | `UserController` |
| Service | PascalCase + `Service` | `UserService` |
| DTO (create) | PascalCase + `Dto` | `CreateUserDto` |
| Entity | PascalCase, singular | `User` |
| Guard | PascalCase + `Guard` | `JwtAuthGuard` |
| Interceptor | PascalCase + `Interceptor` | `TransformInterceptor` |
| Filter | PascalCase + `Filter` | `HttpExceptionFilter` |
