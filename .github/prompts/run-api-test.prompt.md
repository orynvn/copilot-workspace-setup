---
mode: agent
tools:
  - codebase
  - runCommands
  - readFile
description: >
  Run API/unit/integration tests, analyze results, and report in standard format.
  Auto-detects stack to use the correct test runner.
---

# Run API Test Prompt

Run API and integration tests for the specified module.

## Information

**Module/Feature:** ${input:module:Module to test (e.g. UserController, AuthService, or leave blank to test all)}
**Test type:** ${input:testType:unit | integration | all}

---

## Execution

### 1. Stack Detection → Test Command

**Laravel:**
```bash
# Specific module
php artisan test --filter=${input:module} --verbose

# All tests
php artisan test --verbose

# With coverage
php artisan test --coverage --min=80
```

**Next.js / React / Vue (Vitest):**
```bash
# Specific file
npx vitest run src/__tests__/${input:module}.test.ts --reporter=verbose

# All tests
npx vitest run --reporter=verbose

# With coverage
npx vitest run --coverage --reporter=verbose
```

**NestJS (Jest):**
```bash
npm run test -- --verbose --testPathPattern=${input:module}
npm run test:cov
```

### 2. Run tests

Execute the command appropriate for the stack.

### 3. Analyze results

Parse output to determine:
- Total test count: pass / fail / skip
- Details for each failing test: error message + stack trace
- Coverage % (if available)

### 4. Report

**If all PASS:**
```markdown
## ✅ API Test Report — ${input:module}

**Timestamp:** {{date}} {{time}}
**Tests:** X pass | 0 fail | 0 skip
**Coverage:** XX%

All tests passed. Ready to merge.
```

**If there are FAILs:**
```markdown
## ❌ API Test Report — ${input:module}

**Timestamp:** {{date}} {{time}}
**Tests:** X pass | Y fail | Z skip

### Failing Tests

#### [TC-ID] <test name>
**File:** `path/to/test.ts:42`
**Error:**
\`\`\`
<error message>
\`\`\`
**Root cause:** <analysis>
**Suggested fix:** <direction>

---
**Action required:** Fix Y failing tests before merging.
```

### 5. Append ERRORS.md if a new bug is found

If tests reveal a previously unknown bug:
```
[{{date}}] BUG: <description> — <file>:<line> — Fixed: pending
```

---

**Start: Detect stack → run tests → report.**
