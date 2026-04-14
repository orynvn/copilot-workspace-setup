# SKILL: Context Updater

## Mục đích

Skill này hướng dẫn cách maintain `.context/` folder để luôn phản ánh trạng thái thực tế của dự án. Context chính xác giúp mọi agent (Planner, Implementer, QA) đưa ra quyết định tốt hơn.

## Khi nào dùng

- Khi chạy prompt `update-context`.
- Sau mỗi session làm việc (cuối ngày).
- Sau khi complete một milestone/sprint.
- Khi Copilot được yêu cầu "đọc context" trước khi làm task mới.

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

### Format chuẩn

```
[YYYY-MM-DD] <type>: <description> — <file/module>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `decision`, `migration`

### Ví dụ

```markdown
# Project History

[2024-01-15] feat: User authentication module — app/Http/Controllers/AuthController.php
[2024-01-15] test: Auth test cases TC-AUTH-001~005 — tests/Feature/AuthControllerTest.php
[2024-01-16] fix: JWT token expiry bug — app/Services/AuthService.php:87
[2024-01-16] decision: ADR-001 logged — Dùng Sanctum thay Passport
[2024-01-17] migration: add_refresh_token_to_personal_access_tokens — database/migrations/
```

### Rules

- One entry per logical change (không gộp nhiều changes vào 1 dòng).
- Reverse chronological order không bắt buộc — append ở cuối.
- Max 1 line per entry — không viết paragraph.

## DECISIONS.md

### Format

```markdown
# Architectural Decisions

| ADR | Title | Date | Status |
|-----|-------|------|--------|
| ADR-001 | Dùng Sanctum for API auth | 2024-01-16 | Accepted |
| ADR-002 | Zustand over Redux | 2024-01-20 | Accepted |
| ADR-003 | Monorepo structure | 2024-01-25 | Superseded by ADR-005 |
```

### ADR Statuses

- `Proposed` — đang cân nhắc
- `Accepted` — đã quyết định
- `Deprecated` — không còn áp dụng
- `Superseded by ADR-NNN` — bị thay thế bởi decision khác

## ERRORS.md

### Format

```markdown
# Known Errors & Anti-patterns

## Open

### ERR-001: N+1 Query trong UserService::getAllWithProfiles()
**Date:** 2024-01-18
**File:** `app/Services/UserService.php:42`
**Symptom:** Response time > 2s với 100+ users
**Root cause:** Missing eager load cho `profile` relationship
**Fix:** Add `->with('profile')` to query

---

## Resolved

### ERR-002: CORS error trên /api/v1/auth/refresh
**Date:** 2024-01-19 | **Fixed:** 2024-01-20
**Fix applied:** Added `/api/v1/auth/refresh` to CORS `allowed_paths`
```

## Session Log Format

```markdown
# Session: YYYY-MM-DD — <session title>

## Objective
<1-2 câu mục tiêu>

## Completed
- ✅ <task 1>
- ✅ <task 2>
- ❌ <task không xong — lý do>

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

## Workflow: Đọc context đầu session

```
1. Đọc HISTORY.md (10 entries gần nhất)
2. Đọc DECISIONS.md (tất cả Accepted decisions)
3. Đọc ERRORS.md (Open errors)
4. Check sessions/ cho ngày gần nhất
```

## Workflow: Ghi context cuối session

```
1. Append HISTORY.md với tất cả changes trong session
2. Check DECISIONS.md — có decision mới không? → log-decision prompt
3. Check ERRORS.md — có bug mới phát hiện? → append
   - Có bug cũ đã fix? → update status
4. Tạo session log trong sessions/session-YYYY-MM-DD.md
```

## Quick Log Script (log.sh)

```bash
#!/bin/bash
# Usage: ./log.sh "feat: User auth module — AuthController.php"
DATE=$(date +%Y-%m-%d)
echo "[$DATE] $1" >> .context/HISTORY.md
echo "✅ Logged: [$DATE] $1"
```
