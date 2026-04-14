---
mode: agent
tools:
  - codebase
  - editFiles
  - readFile
  - runCommands
description: >
  Viết test cases hoàn chỉnh cho một module hoặc feature. Output: file test thực tế
  + spec document trong .context/test-cases/.
---

# Write Test Cases Prompt

Viết test cases đầy đủ cho module/feature chỉ định.

## Thông tin

**Module:** ${input:module:Tên module (vd: AUTH, USER, PRODUCT)}
**Feature/File cần test:** ${input:target:File hoặc feature cần viết test (vd: UserController, useAuth hook)}
**Loại test:** ${input:testType:unit | integration | e2e | all}

---

## Thực thi

### 1. Đọc code cần test

Đọc file target để hiểu:
- Tất cả public methods / endpoints / exported functions
- Input types và validation rules
- Possible return values và error states
- Business logic paths (if/else, guard clauses)

### 2. Xác định test cases

Với mỗi function/endpoint, xác định:

| Category | Mô tả |
|---|---|
| Happy path | Input hợp lệ, output đúng kỳ vọng |
| Edge case | Giá trị biên (empty, null, max, min) |
| Error case | Input sai, not found, forbidden |
| Security case | Unauthorized, unauthenticated, injection attempt |

### 3. Assign Test IDs

Format: `TC-${input:module}-NNN`

Check `.context/test-cases/` để biết số thứ tự tiếp theo.

### 4. Viết test file

**Laravel (Pest PHP):**
```php
it('TC-${input:module}-001: returns 200 with valid payload', function () {
    // Arrange
    $user = User::factory()->create();
    
    // Act
    $response = $this->actingAs($user)
                     ->postJson('/api/v1/...', [...]);
    
    // Assert
    $response->assertStatus(200)
             ->assertJsonStructure(['success', 'data']);
});
```

**React/Next.js/Vue (Vitest + Testing Library):**
```ts
describe('TC-${input:module}', () => {
  it('TC-${input:module}-001: renders correctly with valid props', () => {
    // Arrange
    const props = { ... }
    
    // Act
    render(<Component {...props} />)
    
    // Assert
    expect(screen.getByRole('heading')).toHaveTextContent('...')
  })
})
```

**Playwright E2E:**
```ts
test('TC-E2E-001: user can complete flow', async ({ page }) => {
  await page.goto('/')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page.getByText('Success')).toBeVisible()
})
```

### 5. Lưu spec document

Tạo file `.context/test-cases/TC-${input:module}-spec.md`:
```markdown
# Test Cases: ${input:module}

## TC-${input:module}-001: <description>
**Type:** unit | integration | e2e
**Priority:** P0 | P1 | P2
**Arrange:** <setup>
**Act:** <action>
**Assert:** <expected outcome>
**Status:** ✅ Pass | ❌ Fail | ⏭️ Skip
```

### 6. Chạy tests

Sau khi viết xong, chạy `run-api-test` hoặc `run-e2e-test` prompt.

---

**Bắt đầu: Đọc file target → liệt kê test cases → viết → lưu spec.**
