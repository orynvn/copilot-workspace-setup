# SKILL: API Tester

## Mục đích

Skill này hướng dẫn cách chạy, phân tích và báo cáo kết quả API/integration tests một cách nhất quán.

## Khi nào dùng

- Khi chạy prompt `run-api-test`.
- Khi QA-Tester agent thực thi test suite.
- Sau mỗi implementation để verify correctness.

## Workflow

### Bước 1: Pre-flight check

Trước khi chạy tests, verify:
1. Test database tồn tại và accessible.
2. Env vars cho test mode được set (`APP_ENV=testing`, `DATABASE_URL_TEST`, ...).
3. Migrations đã chạy trên test DB.
4. Không chạy tests trên production database.

```bash
# Laravel
php artisan migrate --env=testing

# Node.js
NODE_ENV=test npx prisma migrate deploy
```

### Bước 2: Chạy tests theo stack

**Laravel (Pest/PHPUnit):**
```bash
# Run specific filter
php artisan test --filter=UserControllerTest --verbose

# Run specific directory
php artisan test tests/Feature/Auth/ --verbose

# Run all with coverage
php artisan test --coverage --min=80 2>&1 | tee test-output.log
```

**Vitest (React/Next.js/Vue):**
```bash
# Single file
npx vitest run src/__tests__/user.test.ts --reporter=verbose

# Directory
npx vitest run src/__tests__/ --reporter=verbose

# Coverage
npx vitest run --coverage --reporter=verbose 2>&1 | tee test-output.log
```

**NestJS (Jest):**
```bash
npm run test -- --verbose --forceExit 2>&1 | tee test-output.log
npm run test:cov
```

### Bước 3: Parse output

Extract từ output:
- Total: pass / fail / skip count
- Duration
- Coverage % (nếu có)
- Failing test names + error messages
- Stack traces cho failures

### Bước 4: Root cause analysis (khi có failures)

Với mỗi failing test, phân tích theo checklist:

```
□ Type mismatch? (expected string, got undefined)
□ Missing mock? (function called but not mocked)
□ DB state issue? (data from previous test leaked)
□ Wrong assertion? (test logic incorrect)
□ Bug in implementation? (code logic incorrect)
□ Env issue? (missing env var, wrong config)
```

### Bước 5: Report format

```markdown
## API Test Report

**Date:** YYYY-MM-DD HH:MM
**Stack:** <Laravel|Next.js|Vue|NestJS>
**Scope:** <module or "all">

### Summary
| Metric | Value |
|--------|-------|
| Total tests | N |
| ✅ Pass | N |
| ❌ Fail | N |
| ⏭️ Skip | N |
| Coverage | XX% |
| Duration | Xs |

### Failed Tests

#### [TC-ID] <test name>
**File:** `tests/path/file.php:42`
**Error type:** AssertionError | TypeError | TimeoutError
**Message:**
```
<actual error message>
```
**Root cause:** <phân tích>
**Recommended fix:** <hướng sửa cụ thể>
**Priority:** P0 (blocker) | P1 (high) | P2 (low)

### Coverage Report

| Module | Statements | Branches | Functions | Lines |
|--------|-----------|----------|-----------|-------|
| UserService | 92% | 88% | 100% | 91% |

### Next Actions
- [ ] Fix failing tests (assign to Implementer)
- [ ] Increase coverage for <module>
- [ ] Update .context/ERRORS.md
```

## Coverage Thresholds

| Layer | Min coverage |
|-------|-------------|
| Business logic / Services | 90% |
| Controllers / Route handlers | 80% |
| Utilities/helpers | 85% |
| Overall project | 75% |

Nếu coverage dưới threshold → báo cáo và yêu cầu thêm tests trước khi merge.

## Security Test Patterns

Luôn verify các security cases trong API tests:

```php
// Laravel — check auth required
it('requires authentication', function () {
    $this->getJson('/api/v1/users')->assertStatus(401);
});

// Check authorization
it('forbids access to other users data', function () {
    $otherUser = User::factory()->create();
    $this->actingAs($this->user)
         ->getJson("/api/v1/users/{$otherUser->id}/private")
         ->assertStatus(403);
});
```

## Flaky Test Detection

Nếu một test intermittently fails:
1. Chạy 3 lần để confirm flakiness: `--retry=3`
2. Tag test với `@flaky` comment.
3. Tạo issue để fix trong sprint tiếp theo.
4. Không block merge vì flaky test — nhưng track nó.
