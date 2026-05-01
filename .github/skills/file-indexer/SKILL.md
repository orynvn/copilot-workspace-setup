# SKILL: File Indexer

## Purpose

This skill guides how to keep `.context/FILE-INDEX.md` accurate after every implementation task. An accurate index lets agents locate files in O(1) without scanning the codebase.

## When to use

- At the end of every `oryn-dev` LOG phase.
- After a phase is completed.
- When the `context-updater` skill runs.
- When files are created, moved, renamed, or deleted.

---

## Workflow

### Step 1: Determine what changed

Collect the list of files touched in the current task:

```bash
git diff --name-only HEAD
# or, if not yet committed:
git status --short | awk '{print $2}'
```

Categorize each file as: **created** | **modified** | **renamed** | **deleted**.

---

### Step 2: Map files to modules

Group files by their logical module (not by directory). A module = one row in the index.

Rules:
- One module = one business concept (`auth`, `user`, `order`, `payment`, ...).
- Infrastructure files (`Dockerfile`, `config/`, `.env.example`) belong to `infra` or `config` type.
- Migration files belong to the module they alter (e.g., `add_refresh_token` → `auth`).
- Test files are listed in the same row as their module under `Files` — no separate row.

---

### Step 3: Update FILE-INDEX.md

Open `.context/FILE-INDEX.md` and apply:

| Change type | Action |
|---|---|
| New file, new module | Add a new row |
| New file, existing module | Append path to `Files` column |
| File renamed / moved | Update path in `Files` column |
| File deleted | Remove path from `Files` column; remove row if `Files` becomes empty |
| New planned module (from phase-writer) | Add row with `Notes: planned` |

#### Row format

```
| <module> | <type> | <file1>, <file2> | <short note> |
```

- **Module:** kebab-case, matches directory/feature name
- **Type:** `feature` | `infra` | `migration` | `test` | `config` | `shared`
- **Files:** comma-separated relative paths from project root
- **Notes:** optional — key facts (e.g., `JWT + session`, `read-only`, `planned`)

#### Example

```markdown
| Module | Type | Files | Notes |
|---|---|---|---|
| auth | feature | src/auth/auth.service.ts, src/auth/auth.controller.ts, tests/auth.test.ts | JWT + refresh token |
| user | feature | src/users/users.service.ts, src/users/users.model.ts | CRUD only |
| config | infra | .env.example, config/app.ts | no secrets in source |
| add_refresh_token | migration | database/migrations/2026_01_01_add_refresh_token.php | belongs to auth |
```

---

### Step 4: Verify

After updating, do a quick sanity check:

1. Every file created in this task has a corresponding row.
2. No deleted files remain in the index.
3. No duplicate module rows exist.
4. All paths are relative from project root (no leading `/`).

---

## Anti-patterns to avoid

- **Do not** add every individual file as its own module row — group by feature.
- **Do not** list `node_modules/`, `vendor/`, `.git/`, or build output directories.
- **Do not** update FILE-INDEX before implementation is complete — only update after files exist on disk.
- **Do not** leave `planned` status rows after the module is implemented — update the note.
