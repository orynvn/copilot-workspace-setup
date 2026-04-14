# SKILL: Test Case Writer

## Mục đích

Skill này hướng dẫn Copilot viết test cases đầy đủ, có cấu trúc, và đúng format chuẩn dự án.

## Khi nào dùng

- Khi được yêu cầu viết test cho một function, class, endpoint, hoặc component.
- Khi chạy prompt `write-test-cases`.
- Sau khi Implementer hoàn thành một task.

## Workflow

### Bước 1: Đọc và phân tích code

1. Đọc toàn bộ file cần test.
2. Lập danh sách tất cả:
   - Public methods / exported functions
   - API endpoints và HTTP methods
   - Input parameters và type constraints
   - Return values và error states
   - Business logic branches (if/else)

### Bước 2: Thiết kế test matrix

Với mỗi unit cần test, tạo matrix:

```
| Test ID | Category | Input | Expected Output |
|---------|----------|-------|-----------------|
| TC-X-001 | happy path | valid payload | 200 + data |
| TC-X-002 | edge case | empty string | 422 + error |
| TC-X-003 | error | missing auth | 401 |
| TC-X-004 | security | SQL injection attempt | 422 |
```

### Bước 3: Viết test file

**Format ID:** `TC-<MODULE>-<NNN>` (3 digits, sequential)

**AAA Pattern obligatoire:**
```
// Arrange — setup dữ liệu và mocks
// Act — thực thi action cần test
// Assert — kiểm tra kết quả
```

**Naming:** Test description = hành vi hệ thống, không phải implementation:
- ✅ `"returns 401 when Bearer token is missing"`
- ❌ `"test auth middleware check"`

### Bước 4: Coverage checklist

Trước khi báo done, verify:
- [ ] Ít nhất 1 happy path per function/endpoint
- [ ] Ít nhất 1 edge case (null, empty, boundary values)
- [ ] Ít nhất 1 error/rejection case
- [ ] Auth/authz cases nếu endpoint requires auth
- [ ] Không có test phụ thuộc vào thứ tự chạy

### Bước 5: Lưu spec document

Tạo `.context/test-cases/TC-<MODULE>-spec.md` với danh sách đầy đủ test IDs và descriptions.

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
        // Arrange — user đã được tạo ở beforeEach

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
    expect(screen.getByText('Email không hợp lệ')).toBeInTheDocument()
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
    await page.getByRole('button', { name: 'Đăng nhập' }).click()

    // Assert
    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Chào mừng')).toBeVisible()
  })

  test('TC-E2E-002: shows error for wrong password', async ({ page }) => {
    await page.goto('/login')
    await page.getByLabel('Email').fill('admin@test.com')
    await page.getByLabel('Password').fill('wrong')
    await page.getByRole('button', { name: 'Đăng nhập' }).click()
    await expect(page.getByText('Thông tin đăng nhập không đúng')).toBeVisible()
  })
})
```

## Anti-patterns to avoid

- ❌ Testing CSS classes: `expect(el.className).toContain('active')`
- ❌ Testing implementation details: `expect(component.state.isLoading).toBe(true)`
- ❌ Shared mutable state between tests
- ❌ Hardcoded IDs: `User::find(1)`
- ❌ `sleep()` / `setTimeout()` — dùng proper async waiters
- ❌ Tests that only test mocks (không test behavior thực)
