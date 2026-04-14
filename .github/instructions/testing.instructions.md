---
applyTo: "tests/**,**/*.test.*,**/*.spec.*"
---

# Testing — Coding Instructions

## Test Philosophy

- Tests document **behavior**, not implementation details.
- Structure every test with **AAA**: Arrange → Act → Assert.
- One logical assertion group per test case.
- Test names describe what the system does, not how: `"returns 401 when token is missing"` not `"test auth"`.

## Test ID Convention

All test cases must have a structured ID in the description or comment:

```
TC-<MODULE>-<NNN>: <what it tests>

Examples:
TC-AUTH-001: returns 200 with valid credentials
TC-AUTH-002: returns 401 when token is missing
TC-USER-001: creates user with valid payload
```

## Unit Tests

- Test pure functions and classes in isolation.
- Mock all external dependencies (DB, HTTP, file system).
- Fast — no I/O, no network, no random state.
- File: `<subject>.test.ts` next to the source, or `tests/unit/`.

```ts
// Vitest example
describe('formatCurrency()', () => {
  it('TC-UTIL-001: formats integer amounts correctly', () => {
    expect(formatCurrency(1000, 'USD')).toBe('$1,000.00')
  })
})
```

## Integration / Feature Tests

- Test a slice of the system end-to-end through its public interface (HTTP, queue, etc.).
- Use a **test database** — never run against production or staging.
- Reset state between tests (transactions / truncate / factory reset).
- File: `tests/Feature/` or `tests/integration/`.

```php
// Laravel example
it('TC-USER-001: creates a user with valid payload', function () {
    $response = $this->postJson('/api/v1/users', [
        'name'  => 'Test User',
        'email' => 'test@example.com',
    ]);
    $response->assertStatus(201)
             ->assertJsonPath('data.email', 'test@example.com');
});
```

## E2E Tests

- Cover critical user journeys only — registration, login, checkout, key CRUD flows.
- Use **Playwright** (preferred) or Cypress.
- Never assert on CSS classes — use `getByRole`, `getByLabel`, `getByText`.
- Each test must be independent — no shared mutable state between tests.

```ts
// Playwright example
test('TC-E2E-001: user can log in with valid credentials', async ({ page }) => {
  await page.goto('/login')
  await page.getByLabel('Email').fill('admin@test.com')
  await page.getByLabel('Password').fill('secret')
  await page.getByRole('button', { name: 'Sign in' }).click()
  await expect(page).toHaveURL('/dashboard')
})
```

## Test Data

- Use **factories** for creating test data — never hardcode IDs or emails.
- Shared fixtures go in `tests/fixtures/` or `tests/factories/`.
- Use realistic but obviously fake data: `test@example.com`, `Test User`.

## Coverage Targets

| Layer | Minimum |
|---|---|
| Domain / Business logic | 90% |
| API endpoints | 80% |
| UI components (unit) | 70% |
| E2E critical paths | 100% of defined flows |

## CI Rules

- All tests must pass before merging to `main`.
- No `skip` or `todo` tests left in merged PRs without a linked issue.
- Flaky tests must be fixed or isolated within 48 hours of detection.
