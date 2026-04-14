---
mode: agent
tools:
  - codebase
  - runCommands
  - readFile
description: >
  Chạy E2E tests với Playwright. Hỗ trợ headed/headless mode, specific test files,
  và tự động báo cáo kết quả theo format chuẩn.
---

# Run E2E Test Prompt

Chạy E2E tests với Playwright.

## Thông tin

**Test file/suite:** ${input:testFile:Tên file hoặc suite (để trống = chạy tất cả)}
**Mode:** ${input:mode:headless | headed | debug}
**Browser:** ${input:browser:chromium | firefox | webkit | all}

---

## Thực thi

### 1. Kiểm tra Playwright config

Đọc `playwright.config.ts` để hiểu:
- Base URL
- Test directory
- Browser targets
- Timeout settings

### 2. Chạy tests

```bash
# Tất cả tests (headless)
npx playwright test

# Specific file
npx playwright test ${input:testFile}

# Headed mode (thấy browser)
npx playwright test --headed

# Debug mode (breakpoints)
npx playwright test --debug

# Specific browser
npx playwright test --project=${input:browser}

# Với report
npx playwright test --reporter=html
```

### 3. Phân tích kết quả

Parse Playwright output:
- Pass / fail / flaky counts
- Screenshots và videos của failing tests (nếu có)
- Test duration và timeout warnings

### 4. Report

**Tất cả PASS:**
```markdown
## ✅ E2E Test Report

**Timestamp:** {{date}} {{time}}
**Mode:** ${input:mode} | **Browser:** ${input:browser}
**Tests:** X pass | 0 fail | 0 flaky
**Duration:** Xs

### Test Suites
| Suite | Tests | Status |
|---|---|---|
| auth.spec.ts | 5 | ✅ All pass |
| checkout.spec.ts | 8 | ✅ All pass |

**Playwright Report:** `npx playwright show-report`
```

**Có FAIL:**
```markdown
## ❌ E2E Test Report

**Timestamp:** {{date}} {{time}}
**Tests:** X pass | Y fail | Z flaky

### Failing Tests

#### TC-E2E-001: <test name>
**File:** `tests/e2e/auth.spec.ts:42`
**Browser:** chromium
**Error:**
\`\`\`
TimeoutError: Locator.click: Timeout 30000ms exceeded
  Call log: waiting for getByRole('button', { name: 'Login' })
\`\`\`
**Screenshot:** `test-results/auth-login-chromium/screenshot.png`
**Root cause:** Login button không có trong DOM — API response chậm.
**Gợi ý fix:** Tăng timeout selector hoặc thêm `waitForResponse` trước click.

---
**Action required:** Fix Y failing tests + check flaky tests.
```

### 5. Flaky test handling

Nếu phát hiện flaky tests (pass một lần, fail lần khác):
```bash
# Re-run lần 2 để confirm flakiness
npx playwright test --repeat-each=3
```
Nếu vẫn flaky → report và quarantine test đó (tag `@flaky`).

---

**Bắt đầu: Check config → chạy → report → show-report nếu có failures.**
