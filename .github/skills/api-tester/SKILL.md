# SKILL: API Tester

## Purpose

This skill guides how to run, analyze, and report API/integration test results consistently.

## When to use

- When running the `run-api-test` prompt.
- When the QA-Tester agent executes the test suite.
- After each implementation to verify correctness.

## Workflow

### Step 1: Pre-flight check

Before running tests, verify:
1. Test database exists and is accessible.
2. Env vars for test mode are set (`APP_ENV=testing`, `DATABASE_URL_TEST`, ...).
3. Migrations have run on the test DB.
4. Not running tests against the production database.

```bash
# Laravel
php artisan migrate --env=testing

# Node.js
NODE_ENV=test npx prisma migrate deploy
```

### Step 2: Run tests by stack

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

### Step 3: Parse output

Extract from output:
- Total: pass / fail / skip count
- Duration
- Coverage % (if available)
- Failing test names + error messages
- Stack traces for failures

### Step 4: Root cause analysis (when failures occur)

For each failing test, analyze using the checklist:

```
□ Type mismatch? (expected string, got undefined)
□ Missing mock? (function called but not mocked)
□ DB state issue? (data from previous test leaked)
□ Wrong assertion? (test logic incorrect)
□ Bug in implementation? (code logic incorrect)
□ Env issue? (missing env var, wrong config)
```

### Step 5: Report format

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
**Root cause:** <analysis>
**Recommended fix:** <specific direction>
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

If coverage is below threshold → report and require more tests before merging.

## Security Test Patterns

Always verify security cases in API tests:

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

If a test intermittently fails:
1. Run 3 times to confirm flakiness: `--retry=3`
2. Tag test with `@flaky` comment.
3. Create an issue to fix in the next sprint.
4. Do not block merge because of a flaky test — but track it.
