# Test Case Template

> Copy this file to create a spec for a new module.
> Filename convention: `TC-<MODULE>-spec.md`

---

# Test Cases: <MODULE_NAME>

**Module:** `<MODULE_NAME>`
**Feature/File:** `<path/to/tested/file>`
**Stack:** Laravel | Next.js | React | Vue
**Test type:** unit | integration | e2e | mixed
**Last updated:** YYYY-MM-DD

---

## Summary

| TC ID | Description | Type | Priority | Status |
|-------|-------------|------|----------|--------|
| TC-MODULE-001 | Happy path description | integration | P0 | ✅ Pass |
| TC-MODULE-002 | Edge case description | unit | P1 | ✅ Pass |
| TC-MODULE-003 | Error case description | integration | P0 | ❌ Fail |

**Total:** 3 | **Pass:** 2 | **Fail:** 1 | **Skip:** 0

---

## TC-MODULE-001: <Happy path description>

**Type:** integration
**Priority:** P0 (blocker) | P1 (high) | P2 (low)
**Framework:** Pest PHP | Vitest | Playwright

### Arrange
- User is logged in with `admin` role
- Database has 5 records in the `products` table

### Act
```
GET /api/v1/products
Authorization: Bearer <valid-token>
```

### Assert
- HTTP status: `200`
- Response body:
  ```json
  {
    "success": true,
    "data": [{ "id": 1, "name": "..." }],
    "meta": { "total": 5 }
  }
  ```
- Response time < 500ms

**Status:** ✅ Pass
**Test file:** `tests/Feature/ProductControllerTest.php:42`

---

## TC-MODULE-002: <Edge case description>

**Type:** unit
**Priority:** P1

### Arrange
- Input: empty array `[]`

### Act
```ts
const result = processItems([])
```

### Assert
- Returns `[]` (does not throw exception)
- Log has no error entry

**Status:** ✅ Pass
**Test file:** `src/__tests__/product-service.test.ts:15`

---

## TC-MODULE-003: <Error case description>

**Type:** integration
**Priority:** P0

### Arrange
- Request has no Authorization header

### Act
```
GET /api/v1/products
```

### Assert
- HTTP status: `401`
- Response: `{ "message": "Unauthenticated" }`

**Status:** ❌ Fail — `500` instead of `401`
**Root cause:** Missing `auth:sanctum` middleware on route
**Fix:** Add middleware to `routes/api.php`
**Test file:** `tests/Feature/ProductControllerTest.php:68`

---

## Notes

<!-- Add notes about this module if any -->
