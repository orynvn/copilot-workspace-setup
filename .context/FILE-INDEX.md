# File Index

> **Purpose:** Maps modules/features to their source files. Agents read this instead of scanning the full codebase.
> **Updated by:** oryn-dev after every task that creates or modifies files.

---

## How to use

When an agent needs to locate files for a module, read this file first.
Only open source files when you need to read/edit their content — not to discover paths.

---

## Format

```
| Module | Type | Files | Notes |
|---|---|---|---|
| auth | feature | src/auth/auth.service.ts, src/auth/auth.controller.ts | JWT + session |
| user | feature | src/users/users.service.ts, src/users/users.model.ts | CRUD only |
| config | infra | .env.example, config/app.ts | no secrets in source |
```

**Type values:** `feature` | `infra` | `migration` | `test` | `config` | `shared`

---

## Index

| Module | Type | Files | Notes |
|---|---|---|---|
| _(empty — populate after first implementation phase)_ | | | |

---

## Update rules

1. After every task that **creates** a new file → add a row.
2. After every task that **moves or renames** a file → update the path.
3. After every task that **deletes** a file → remove the row.
4. Do **not** add test files here — they live in the same module row under `Files`.
