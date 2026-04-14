# GitHub Copilot — Global Instructions

> **Scope:** Tech-agnostic rules applied to every project. Project-specific overrides live in `templates/<stack>/.github/copilot-instructions.md`.

---

## 1. Identity & Communication

- Respond in **English** by default.
- Be concise — no filler text, no unsolicited explanations.
- When uncertain, **ask one focused question** rather than guessing.
- Always cite the file path when referencing code: `src/services/UserService.ts:42`.

---

## 2. Stack Detection

Before implementing anything, identify the tech stack from project files:

| File present | Stack |
|---|---|
| `composer.json` + `artisan` | Laravel |
| `package.json` → `"next"` dep | Next.js |
| `package.json` → `"vite"` + `"react"` | React (Vite) |
| `package.json` → `"vue"` | Vue 3 |
| `package.json` → `"@nestjs/core"` | NestJS |
| `requirements.txt` / `pyproject.toml` → `django` | Django |
| `requirements.txt` / `pyproject.toml` → `fastapi` | FastAPI |

After detection, apply the matching `.github/instructions/<stack>.instructions.md` rules.

---

## 3. Context Memory Protocol

### 3.1 Read before acting
At the start of **every session**, silently read:
1. `.context/HISTORY.md` — recent decisions & changes
2. `.context/DECISIONS.md` — architectural decisions index
3. `.context/ERRORS.md` — known errors to avoid

### 3.2 Write after acting
After completing a task:
- Append a one-line entry to `.context/HISTORY.md`:
  ```
  [YYYY-MM-DD] <action> — <file/module affected>
  ```
- If an architectural decision was made → run `log-decision` prompt.
- If a bug/error was fixed → append to `.context/ERRORS.md`.

### 3.3 Session context
Use `.context/sessions/` to store per-session logs when working on multi-step tasks.

---

## 4. Workflow: Plan → Implement → Test

Every non-trivial task MUST follow this sequence:

```
PLAN  →  IMPLEMENT  →  TEST  →  LOG
```

### 4.1 PLAN phase
1. Understand the requirement — re-state it in 1-2 sentences.
2. List files to create/modify.
3. Identify edge cases & risks.
4. **Wait for user confirmation** before proceeding.

### 4.2 IMPLEMENT phase
- One logical change per commit scope.
- Never modify files outside the agreed plan without asking.
- Follow the naming conventions in §5.

### 4.3 TEST phase
- After implementation, suggest test cases or run existing ones.
- Use the `write-test-cases` or `run-api-test` prompts.

### 4.4 LOG phase
- Update `.context/HISTORY.md`.
- Log decisions if architectural choices were made.

---

## 5. Naming Conventions (Tech-Agnostic)

| Entity | Convention | Example |
|---|---|---|
| Files | kebab-case | `user-service.ts` |
| Classes | PascalCase | `UserService` |
| Functions/methods | camelCase | `getUserById()` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| DB tables | snake_case, plural | `user_profiles` |
| DB columns | snake_case | `created_at` |
| Env variables | UPPER_SNAKE_CASE | `DATABASE_URL` |
| Test files | `<subject>.test.<ext>` | `user-service.test.ts` |
| Test cases IDs | `TC-<MODULE>-<NNN>` | `TC-AUTH-001` |

---

## 6. Security Defaults

- **Never** hardcode secrets, API keys, passwords.
- Always use environment variables for sensitive config.
- Validate all external inputs at system boundaries.
- Follow OWASP Top 10 mitigations by default.
- SQL: use parameterized queries / ORM — never raw string interpolation.
- Auth: assume token-based (JWT/session); never roll custom crypto.

---

## 7. Code Quality Rules

- **DRY**: extract repeated logic into shared utilities after the 2nd occurrence.
- **YAGNI**: don't add features not explicitly requested.
- **Single Responsibility**: one file/class does one thing.
- Max function length: ~40 lines — split if longer.
- No commented-out dead code in final commits.
- All async operations must handle errors (try/catch or `.catch()`).

---

## 8. Git Conventions

Commit message format: `<type>(<scope>): <subject>`

| Type | When to use |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Restructuring without behavior change |
| `test` | Adding/updating tests |
| `docs` | Documentation only |
| `chore` | Build, deps, config |
| `perf` | Performance improvement |

Branch naming: `<type>/<short-description>` → `feat/user-auth`, `fix/login-redirect`

---

## 9. Agent Coordination

When using multi-agent mode (`oryn-dev` chatmode):
- **Planner** agent handles analysis → outputs a task breakdown.
- **Implementer** agent handles coding → one file/module at a time.
- **TC-Writer** agent writes test cases for each implementation.
- **QA-Tester** agent runs tests and reports results.

Never skip phases. Each agent's output feeds the next.
