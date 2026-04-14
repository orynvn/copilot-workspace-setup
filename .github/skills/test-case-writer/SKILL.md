# SKILL: Test Case Writer

## Purpose

This skill guides Copilot to write comprehensive, structured, standards-compliant test cases.

## When to use

- When asked to write tests for a function, class, endpoint, or component.
- When running the `write-test-cases` prompt.
- After the Implementer completes a task.

## Workflow

### Step 1: Read and analyze code

1. Read the entire file to be tested.
2. List all:
   - Public methods / exported functions
   - API endpoints and HTTP methods
   - Input parameters and type constraints
   - Return values and error states
   - Business logic branches (if/else)

### Step 2: Design test matrix

For each unit to test, create a matrix:

```
| Test ID | Category | Input | Expected Output |
|---------|----------|-------|-----------------|
| TC-X-001 | happy path | valid payload | 200 + data |
| TC-X-002 | edge case | empty string | 422 + error |
| TC-X-003 | error | missing auth | 401 |
| TC-X-004 | security | SQL injection attempt | 422 |
```

### Step 3: Write test file

**ID Format:** `TC-<MODULE>-<NNN>` (3 digits, sequential)

**AAA Pattern obligatoire:**
```
// Arrange — set up data and mocks
// Act — execute the action being tested
// Assert — verify the result
```

**Naming:** Test description = system behavior, not implementation:
- ✅ `"returns 401 when Bearer token is missing"`
- ❌ `"test auth middleware check"`

### Step 4: Coverage checklist

Before marking done, verify:
- [ ] At least 1 happy path per function/endpoint
- [ ] At least 1 edge case (null, empty, boundary values)
- [ ] At least 1 error/rejection case
- [ ] Auth/authz cases if endpoint requires auth
- [ ] No test depends on execution order

### Step 5: Save spec document

Create `.context/test-cases/TC-<MODULE>-spec.md` with the full list of test IDs and descriptions.

## Framework Templates

### Laravel — Pest PHP

```php
<?php

use App\Models\User;

describe('UserController', function () {
    beforeEach(function () {
        $this->user = User::factory()->create();
    });

    it('TC-USER-001: returns user list for authenticated request', function () {
        // Arrange — user created in beforeEach

        // Act
        $response = $this->actingAs($this->user)
                         ->getJson('/api/v1/users');

        // Assert
        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => [['id', 'name', 'email']],
                 ]);
    });

    it('TC-USER-002: returns 401 when unauthenticated', function () {
        $response = $this->getJson('/api/v1/users');
        $response->assertStatus(401);
    });

    it('TC-USER-003: returns 422 when email is missing', function () {
        $response = $this->actingAs($this->user)
                         ->postJson('/api/v1/users', ['name' => 'Test']);
        $response->assertStatus(422)
                 ->assertJsonValidationErrors(['email']);
    });
});
```

### React/Next.js/Vue — Vitest + Testing Library

```ts
import { render, screen, fireEvent } from '@testing-library/react'
import { describe, it, expect, vi } from 'vitest'
import { UserForm } from './UserForm'

describe('UserForm', () => {
  it('TC-USER-001: submits form with valid data', async () => {
    // Arrange
    const onSubmit = vi.fn()
    render(<UserForm onSubmit={onSubmit} />)

    // Act
    await userEvent.type(screen.getByLabelText('Email'), 'test@example.com')
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }))

    // Assert
    expect(onSubmit).toHaveBeenCalledWith({ email: 'test@example.com' })
  })

  it('TC-USER-002: shows validation error for invalid email', async () => {
    render(<UserForm onSubmit={vi.fn()} />)
    await userEvent.type(screen.getByLabelText('Email'), 'not-an-email')
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }))
    expect(screen.getByText('Invalid email')).toBeInTheDocument()
  })
})
```

### Playwright — E2E

```ts
import { test, expect } from '@playwright/test'

test.describe('TC-E2E: User Authentication', () => {
  test('TC-E2E-001: user can log in with valid credentials', async ({ page }) => {
    // Arrange
    await page.goto('/login')

    // Act
    await page.getByLabel('Email').fill('admin@test.com')
    await page.getByLabel('Password').fill('password')
    await page.getByRole('button', { name: 'Login' }).click()

    // Assert
    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Welcome')).toBeVisible()
  })

  test('TC-E2E-002: shows error for wrong password', async ({ page }) => {
    await page.goto('/login')
    await page.getByLabel('Email').fill('admin@test.com')
    await page.getByLabel('Password').fill('wrong')
    await page.getByRole('button', { name: 'Login' }).click()
    await expect(page.getByText('Invalid credentials')).toBeVisible()
  })
})
```

## Anti-patterns to avoid

- ❌ Testing CSS classes: `expect(el.className).toContain('active')`
- ❌ Testing implementation details: `expect(component.state.isLoading).toBe(true)`
- ❌ Shared mutable state between tests
- ❌ Hardcoded IDs: `User::find(1)`
- ❌ `sleep()` / `setTimeout()` — use proper async waiters
- ❌ Tests that only test mocks (not testing real behavior)
