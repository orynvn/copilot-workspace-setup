# SKILL: E2E Tester (Playwright)

## Purpose

This skill guides writing, running, and debugging E2E tests with Playwright according to project standards.

## When to use

- When running the `run-e2e-test` prompt.
- When the QA-Tester agent executes the E2E suite.
- When critical user journeys need to be verified end-to-end.

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

### Step 1: Set up environment

```bash
# Install browsers (first time)
npx playwright install

# Start test server if needed
npm run dev &

# Or use webServer config in playwright.config.ts
```

### Step 2: Write tests

**Principles:**
- Use role-based locators: `getByRole`, `getByLabel`, `getByText` — not CSS selectors.
- Each test is independent — do not share state via `beforeAll`.
- Use `page.waitForURL()` / `expect(locator).toBeVisible()` instead of `sleep`.

**Page Object Model (for complex flows):**
```ts
// tests/e2e/pages/LoginPage.ts
export class LoginPage {
  readonly emailInput = this.page.getByLabel('Email')
  readonly passwordInput = this.page.getByLabel('Password')
  readonly submitButton = this.page.getByRole('button', { name: 'Login' })

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
    await page.getByLabel('Password').fill(process.env.TEST_USER_PASSWORD!)
    await page.getByRole('button', { name: 'Login' }).click()
    await page.waitForURL('/dashboard')
    await use(page)
  },
})
```

### Step 3: Run tests

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

### Step 4: Debug failures

```bash
# View HTML report
npx playwright show-report

# Trace viewer (step-by-step)
npx playwright show-trace test-results/.../trace.zip

# Record new test
npx playwright codegen http://localhost:3000
```

### Step 5: Report format

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
Waiting for: getByRole('button', { name: 'Pay' })
```
**Screenshot:** `test-results/checkout-chromium/screenshot.png`
**Root cause:** Button render blocked by loading skeleton that has not dismissed.
**Fix:** Add `await expect(page.getByTestId('loading-skeleton')).toBeHidden()` before click.

### Trace Links
Open trace with: `npx playwright show-report`
```

## Critical User Journeys (must have E2E coverage)

- [ ] Registration flow
- [ ] Login / Logout
- [ ] Password reset
- [ ] Core business flow (e.g. create order, payment)
- [ ] Role-based access (admin vs user)

## Locator Priority (highest to lowest)

1. `getByRole()` — semantic, accessible
2. `getByLabel()` — form inputs
3. `getByText()` — visible text
4. `getByTestId()` — custom `data-testid` attribute (use when no other option)
5. CSS selectors — **avoid** if possible
