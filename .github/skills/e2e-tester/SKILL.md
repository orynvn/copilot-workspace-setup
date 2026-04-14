# SKILL: E2E Tester (Playwright)

## Mục đích

Skill này hướng dẫn viết, chạy và debug E2E tests với Playwright theo standard của dự án.

## Khi nào dùng

- Khi chạy prompt `run-e2e-test`.
- Khi QA-Tester agent thực thi E2E suite.
- Khi cần verify critical user journeys end-to-end.

## Test Organization

```
tests/e2e/
├── auth/
│   ├── login.spec.ts
│   └── registration.spec.ts
├── checkout/
│   └── checkout-flow.spec.ts
├── fixtures/
│   ├── auth.ts         # reusable auth setup
│   └── test-data.ts    # shared test data
└── playwright.config.ts
```

## Playwright Config Best Practices

```ts
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html', { open: 'never' }], ['line']],
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'mobile', use: { ...devices['iPhone 14'] } },
  ],
})
```

## Workflow

### Bước 1: Setup môi trường

```bash
# Install browsers (lần đầu)
npx playwright install

# Start test server nếu cần
npm run dev &

# Hoặc dùng webServer config trong playwright.config.ts
```

### Bước 2: Viết tests

**Principles:**
- Dùng role-based locators: `getByRole`, `getByLabel`, `getByText` — không dùng CSS selectors.
- Mỗi test độc lập — không share state qua `beforeAll`.
- Dùng `page.waitForURL()` / `expect(locator).toBeVisible()` thay vì `sleep`.

**Page Object Model (cho flows phức tạp):**
```ts
// tests/e2e/pages/LoginPage.ts
export class LoginPage {
  readonly emailInput = this.page.getByLabel('Email')
  readonly passwordInput = this.page.getByLabel('Mật khẩu')
  readonly submitButton = this.page.getByRole('button', { name: 'Đăng nhập' })

  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }
}
```

**Reusable auth fixture:**
```ts
// tests/e2e/fixtures/auth.ts
import { test as base } from '@playwright/test'

export const test = base.extend({
  authenticatedPage: async ({ page }, use) => {
    await page.goto('/login')
    await page.getByLabel('Email').fill(process.env.TEST_USER_EMAIL!)
    await page.getByLabel('Mật khẩu').fill(process.env.TEST_USER_PASSWORD!)
    await page.getByRole('button', { name: 'Đăng nhập' }).click()
    await page.waitForURL('/dashboard')
    await use(page)
  },
})
```

### Bước 3: Chạy tests

```bash
# All tests (headless)
npx playwright test

# Single file
npx playwright test tests/e2e/auth/login.spec.ts

# With UI (headed)
npx playwright test --headed

# Debug mode (pause on failure)
npx playwright test --debug

# Update snapshots
npx playwright test --update-snapshots

# Specific browser
npx playwright test --project=chromium

# CI mode
CI=true npx playwright test
```

### Bước 4: Debug failures

```bash
# Xem HTML report
npx playwright show-report

# Trace viewer (xem từng step)
npx playwright show-trace test-results/.../trace.zip

# Record new test
npx playwright codegen http://localhost:3000
```

### Bước 5: Report format

```markdown
## E2E Test Report

**Date:** YYYY-MM-DD HH:MM
**Base URL:** http://localhost:3000
**Browsers:** chromium, firefox, mobile

### Summary
| Browser | Pass | Fail | Flaky |
|---------|------|------|-------|
| Chromium | 24 | 1 | 0 |
| Firefox | 24 | 1 | 0 |
| Mobile | 22 | 3 | 0 |

### Failed Tests

#### TC-E2E-003: Checkout flow completes successfully
**Browser:** chromium
**File:** `tests/e2e/checkout/checkout-flow.spec.ts:87`
**Error:**
```
TimeoutError: locator.click: Timeout 30000ms exceeded
Waiting for: getByRole('button', { name: 'Thanh toán' })
```
**Screenshot:** `test-results/checkout-chromium/screenshot.png`
**Root cause:** Button render bị block bởi loading skeleton chưa dismiss.
**Fix:** Thêm `await expect(page.getByTestId('loading-skeleton')).toBeHidden()` trước click.

### Trace Links
Mở trace với: `npx playwright show-report`
```

## Critical User Journeys (phải có E2E coverage)

- [ ] Registration flow
- [ ] Login / Logout
- [ ] Password reset
- [ ] Core business flow (vd: tạo order, thanh toán)
- [ ] Role-based access (admin vs user)

## Locator Priority (từ ưu tiên cao đến thấp)

1. `getByRole()` — semantic, accessible
2. `getByLabel()` — form inputs
3. `getByText()` — visible text
4. `getByTestId()` — custom `data-testid` attribute (dùng khi không có cách khác)
5. CSS selectors — **tránh dùng** nếu có thể
