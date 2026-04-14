# SKILL: Context Updater

## Purpose

This skill guides how to maintain the `.context/` folder so it always reflects the actual state of the project. Accurate context helps all agents (Planner, Implementer, QA) make better decisions.

## When to use

- When running the `update-context` prompt.
- After each working session (end of day).
- After completing a milestone/sprint.
- When Copilot is asked to "read context" before starting a new task.

## Context Directory Structure

```
.context/
├── HISTORY.md        # Chronological log of changes
├── DECISIONS.md      # Index of architectural decisions (ADR)
├── ERRORS.md         # Known bugs, errors, anti-patterns
├── log.sh            # Quick logging script
├── decisions/        # ADR detail files: ADR-001-*.md
├── errors/           # Detailed error reports
├── sessions/         # Per-session logs
└── test-cases/       # Test case specifications: TC-MODULE-spec.md
```

## HISTORY.md

### Standard format

```
[YYYY-MM-DD] <type>: <description> — <file/module>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `decision`, `migration`

### Examples

```markdown
# Project History

[2024-01-15] feat: User authentication module — app/Http/Controllers/AuthController.php
[2024-01-15] test: Auth test cases TC-AUTH-001~005 — tests/Feature/AuthControllerTest.php
[2024-01-16] fix: JWT token expiry bug — app/Services/AuthService.php:87
[2024-01-16] decision: ADR-001 logged — Use Sanctum instead of Passport
[2024-01-17] migration: add_refresh_token_to_personal_access_tokens — database/migrations/
```

### Rules

- One entry per logical change (do not combine multiple changes into one line).
- Reverse chronological order is not required — append at the end.
- Max 1 line per entry — do not write paragraphs.

## DECISIONS.md

### Format

```markdown
# Architectural Decisions

| ADR | Title | Date | Status |
|-----|-------|------|--------|
| ADR-001 | Use Sanctum for API auth | 2024-01-16 | Accepted |
| ADR-002 | Zustand over Redux | 2024-01-20 | Accepted |
| ADR-003 | Monorepo structure | 2024-01-25 | Superseded by ADR-005 |
```

### ADR Statuses

- `Proposed` — under consideration
- `Accepted` — decided
- `Deprecated` — no longer applicable
- `Superseded by ADR-NNN` — replaced by another decision

## ERRORS.md

### Format

```markdown
# Known Errors & Anti-patterns

## Open

### ERR-001: N+1 Query in UserService::getAllWithProfiles()
**Date:** 2024-01-18
**File:** `app/Services/UserService.php:42`
**Symptom:** Response time > 2s with 100+ users
**Root cause:** Missing eager load for `profile` relationship
**Fix:** Add `->with('profile')` to query

---

## Resolved

### ERR-002: CORS error on /api/v1/auth/refresh
**Date:** 2024-01-19 | **Fixed:** 2024-01-20
**Fix applied:** Added `/api/v1/auth/refresh` to CORS `allowed_paths`
```

## Session Log Format

```markdown
# Session: YYYY-MM-DD — <session title>

## Objective
<1-2 sentence goal>

## Completed
- ✅ <task 1>
- ✅ <task 2>
- ❌ <task not completed — reason>

## Decisions Made
- ADR-NNN: <title>

## Issues Encountered
- <issue> → <resolution>

## Next Session Priorities
1. <priority 1>
2. <priority 2>

## Changed Files
- `path/to/file.ts` — <why>
```

## Workflow: Read context at session start

```
1. Read HISTORY.md (last 10 entries)
2. Read DECISIONS.md (all Accepted decisions)
3. Read ERRORS.md (Open errors)
4. Check sessions/ for the most recent day
```

## Workflow: Write context at session end

```
1. Append HISTORY.md with all changes from the session
2. Check DECISIONS.md — any new decisions? → log-decision prompt
3. Check ERRORS.md — any newly discovered bugs? → append
   - Any old bugs fixed? → update status
4. Create session log in sessions/session-YYYY-MM-DD.md
```

## Quick Log Script (log.sh)

```bash
#!/bin/bash
# Usage: ./log.sh "feat: User auth module — AuthController.php"
DATE=$(date +%Y-%m-%d)
echo "[$DATE] $1" >> .context/HISTORY.md
echo "✅ Logged: [$DATE] $1"
```
