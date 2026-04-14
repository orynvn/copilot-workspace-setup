---
mode: agent
tools:
  - codebase
  - readFile
  - runCommands
  - search
description: >
  Phân tích và tìm bottleneck hiệu năng: DB queries (N+1), API latency, bundle size, Memory leaks.
  Output report với các điểm cần cải thiện, ưu tiên theo impact.
---

# Profile Performance

Phân tích hiệu năng của code/feature được chỉ định. Tìm bottlenecks, đề xuất cải thiện có đo lường cụ thể.

## Phạm vi phân tích

**Target:** ${input:target:File, module, hoặc endpoint cần phân tích (vd: UserController, /api/products)}
**Stack:** ${input:stack:Laravel | Next.js | React | NestJS | Django | FastAPI}
**Loại vấn đề nghi ngờ:** ${input:concern:N+1 queries | Slow API | Large bundle | Memory leak | Slow render | Tất cả}

---

## Checklist phân tích theo stack

### Database / ORM

**N+1 Query Detection:**

```bash
# Laravel — bật query log
DB::enableQueryLog();
// ... code
dd(DB::getQueryLog()); // xem số queries

# Django — Django Debug Toolbar hoặc:
from django.db import connection
print(len(connection.queries))

# NestJS TypeORM — bật logging
{ type: 'postgres', logging: true }
```

Dấu hiệu N+1: vòng lặp `foreach` mà bên trong gọi DB, hoặc relationship access mà không eager load.

**Index check:**
```sql
-- Xem query plan
EXPLAIN ANALYZE SELECT ...;

-- Tìm sequential scans (không dùng index)
-- Nếu "Seq Scan" trên bảng lớn → cần index
```

**Các pattern cần fix:**
- [ ] `where` clause trên column không có index.
- [ ] `SELECT *` thay vì chọn columns cần thiết.
- [ ] Pagination thiếu (`LIMIT/OFFSET` lớn chậm → dùng cursor-based).
- [ ] Missing `select_related`/`with()` trên relationships.

### API Latency

```bash
# Đo thời gian response
curl -w "\nTime: %{time_total}s\n" -o /dev/null -s http://localhost:8000/api/endpoint

# Laravel Telescope — xem slow queries
# Next.js — Server Components timing trong browser DevTools
# FastAPI — thêm middleware đo thời gian
```

Patterns cần check:
- [ ] External API calls trong request cycle (nên async/queue).
- [ ] File I/O đồng bộ trong handler (nên stream hoặc background job).
- [ ] Large payload không được paginated.
- [ ] Missing cache cho data ít thay đổi.

### Frontend Bundle Size

```bash
# Vite / React / Next.js
npx vite-bundle-visualizer        # React (Vite)
npx @next/bundle-analyzer         # Next.js (cần ANALYZE=true)

# Kiểm tra chunk sizes
npm run build -- --report
```

Patterns cần check:
- [ ] Import cả thư viện thay vì tree-shake (`import _ from 'lodash'` → `import debounce from 'lodash/debounce'`).
- [ ] Large images không optimize (dùng `next/image` hoặc WebP).
- [ ] Component không lazy-load dù chỉ dùng ở một route.
- [ ] Polyfills không cần thiết cho target browser.

### Memory Leaks

```bash
# Node.js (NestJS / Next.js)
node --inspect server.js
# Mở Chrome DevTools → Memory tab → Heap snapshot

# Python
pip install memory-profiler
python -m memory_profiler script.py
```

Patterns cần check:
- [ ] Event listener thêm liên tục mà không remove.
- [ ] Cache không có TTL / eviction policy.
- [ ] WebSocket connections không được cleanup khi disconnect.
- [ ] Closure giữ reference đến large object.

---

## Output Template

```markdown
## ⚡ Performance Report — <target>

**Analyzed:** <date>
**Severity:** 🔴 Critical | 🟡 Medium | 🟢 Minor

### Findings

#### [CRITICAL] PERF-001: N+1 query trong UserService.getAll()
**File:** `app/Services/UserService.php:34`
**Impact:** 1 request → ~150 queries với 50 users → 2.3s response time
**Fix:**
```php
// Before
$users = User::all();
foreach ($users as $user) { $user->profile; } // N+1

// After
$users = User::with('profile')->get(); // 2 queries
```
**Estimated improvement:** ~2s → ~50ms

#### [MEDIUM] PERF-002: Bundle size — lodash imported toàn bộ
...

### Không phát hiện vấn đề
- ✅ DB indexes đầy đủ cho WHERE clauses thường dùng
- ✅ Pagination đã implement

### Recommended actions (theo priority)
1. Fix N+1 trong UserService (impact cao nhất)
2. ...
```
