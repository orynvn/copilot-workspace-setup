---
mode: agent
tools:
  - codebase
  - runCommands
  - readFile
description: >
  Chạy API/unit/integration tests, phân tích kết quả và báo cáo theo format chuẩn.
  Tự động detect stack để dùng đúng test runner.
---

# Run API Test Prompt

Chạy API và integration tests cho module chỉ định.

## Thông tin

**Module/Feature:** ${input:module:Module cần test (vd: UserController, AuthService, hoặc để trống để test all)}
**Test type:** ${input:testType:unit | integration | all}

---

## Thực thi

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

### 2. Chạy tests

Thực thi command phù hợp với stack.

### 3. Phân tích kết quả

Parse output để xác định:
- Tổng số tests: pass / fail / skip
- Chi tiết từng failing test: error message + stack trace
- Coverage % (nếu có)

### 4. Report

**Nếu tất cả PASS:**
```markdown
## ✅ API Test Report — ${input:module}

**Timestamp:** {{date}} {{time}}
**Tests:** X pass | 0 fail | 0 skip
**Coverage:** XX%

Tất cả tests đều pass. Ready to merge.
```

**Nếu có FAIL:**
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
**Root cause:** <phân tích>
**Gợi ý fix:** <hướng sửa>

---
**Action required:** Fix Y failing tests trước khi merge.
```

### 5. Append ERRORS.md nếu phát hiện bug mới

Nếu test reveal bug chưa biết:
```
[{{date}}] BUG: <mô tả> — <file>:<line> — Fixed: pending
```

---

**Bắt đầu: Detect stack → chạy tests → report.**
