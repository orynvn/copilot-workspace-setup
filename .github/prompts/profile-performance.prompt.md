---
mode: agent
tools:
  - codebase
  - readFile
  - runCommands
  - search
description: >
  Analyze and find performance bottlenecks: DB queries (N+1), API latency, bundle size, Memory leaks.
  Output report with areas for improvement, prioritized by impact.
---

# Profile Performance

Analyze the performance of the specified code/feature. Find bottlenecks and suggest measurable improvements.

## Scope of analysis

**Target:** ${input:target:File, module, or endpoint to analyze (e.g. UserController, /api/products)}
**Stack:** ${input:stack:Laravel | Next.js | React | NestJS | Django | FastAPI}
**Suspected issue type:** ${input:concern:N+1 queries | Slow API | Large bundle | Memory leak | Slow render | All}

---

## Analysis checklist by stack

### Database / ORM

**N+1 Query Detection:**

```bash
# Laravel — enable query log
DB::enableQueryLog();
// ... code
dd(DB::getQueryLog()); // view query count

# Django — Django Debug Toolbar or:
from django.db import connection
print(len(connection.queries))

# NestJS TypeORM — enable logging
{ type: 'postgres', logging: true }
```

Sign of N+1: a `foreach` loop that queries the DB inside, or relationship access without eager loading.

**Index check:**
```sql
-- View query plan
EXPLAIN ANALYZE SELECT ...;

-- Find sequential scans (not using index)
-- If "Seq Scan" on a large table → needs an index
```

**Patterns to fix:**
- [ ] `where` clause on a column with no index.
- [ ] `SELECT *` instead of selecting only needed columns.
- [ ] Missing pagination (large `LIMIT/OFFSET` is slow → use cursor-based).
- [ ] Missing `select_related`/`with()` on relationships.

### API Latency

```bash
# Measure response time
curl -w "\nTime: %{time_total}s\n" -o /dev/null -s http://localhost:8000/api/endpoint

# Laravel Telescope — view slow queries
# Next.js — Server Components timing in browser DevTools
# FastAPI — add timing middleware
```

Patterns to check:
- [ ] External API calls inside the request cycle (should be async/queued).
- [ ] Synchronous file I/O in handler (should stream or use background job).
- [ ] Large payload not paginated.
- [ ] Missing cache for rarely-changing data.

### Frontend Bundle Size

```bash
# Vite / React / Next.js
npx vite-bundle-visualizer        # React (Vite)
npx @next/bundle-analyzer         # Next.js (requires ANALYZE=true)

# Check chunk sizes
npm run build -- --report
```

Patterns to check:
- [ ] Importing entire libraries instead of tree-shaking (`import _ from 'lodash'` → `import debounce from 'lodash/debounce'`).
- [ ] Large images not optimized (use `next/image` or WebP).
- [ ] Components not lazy-loaded despite only being used on one route.
- [ ] Unnecessary polyfills for target browser.

### Memory Leaks

```bash
# Node.js (NestJS / Next.js)
node --inspect server.js
# Open Chrome DevTools → Memory tab → Heap snapshot

# Python
pip install memory-profiler
python -m memory_profiler script.py
```

Patterns to check:
- [ ] Event listeners added repeatedly without removal.
- [ ] Cache with no TTL / eviction policy.
- [ ] WebSocket connections not cleaned up on disconnect.
- [ ] Closure holding reference to a large object.

---

## Output Template

```markdown
## ⚡ Performance Report — <target>

**Analyzed:** <date>
**Severity:** 🔴 Critical | 🟡 Medium | 🟢 Minor

### Findings

#### [CRITICAL] PERF-001: N+1 query in UserService.getAll()
**File:** `app/Services/UserService.php:34`
**Impact:** 1 request → ~150 queries with 50 users → 2.3s response time
**Fix:**
```php
// Before
$users = User::all();
foreach ($users as $user) { $user->profile; } // N+1

// After
$users = User::with('profile')->get(); // 2 queries
```
**Estimated improvement:** ~2s → ~50ms

#### [MEDIUM] PERF-002: Bundle size — entire lodash imported
...

### No issues found
- ✅ DB indexes sufficient for commonly used WHERE clauses
- ✅ Pagination already implemented

### Recommended actions (by priority)
1. Fix N+1 in UserService (highest impact)
2. ...
```
