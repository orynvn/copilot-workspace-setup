# Known Errors & Anti-patterns

> Log tất cả bugs, errors, và anti-patterns đã gặp trong dự án.
> Copilot đọc file này trước khi implement để tránh lặp lại lỗi cũ.
>
> **MCP Integration:** Từ Phase 1 trở đi, file này được sync với `mcp-error-learning` SQLite DB.
> Dùng Debugger agent để tự động record — không cần edit thủ công.

---

## Open

*(Chưa có open errors — thêm khi phát hiện)*

---

## Resolved

*(Chưa có resolved errors)*

---

## Format chuẩn — BUG-NNN (manual hoặc auto qua Debugger)

```markdown
### BUG-NNN: <Tiêu đề ngắn, rõ ràng>
**Date:** YYYY-MM-DD
**Stack:** Laravel | Next.js | React | NestJS | Django | FastAPI
**Module:** AUTH | USER | PRODUCT | ORDER | ...
**Symptom:** <Triệu chứng user/dev quan sát được>
**Root cause:** <Nguyên nhân gốc rễ — không phải symptom>
**Fix:** `path/to/file.ts:line` — <mô tả thay đổi>
**Prevention:** <Pattern hoặc quy tắc để tránh tái diễn>
**Test added:** TC-MODULE-NNN
**MCP ID:** <error_id từ mcp-error-learning nếu đã record>
```

---

## Anti-patterns (project-level)

> Những pattern bị cấm trong dự án này và lý do:

*(Thêm khi phát hiện pattern xấu lặp lại)*


## Cách sử dụng

- Khi phát hiện bug mới → thêm vào **Open** section.
- Khi bug đã fix → move xuống **Resolved** section + thêm `**Fixed:** YYYY-MM-DD`.
- Copilot tự động append khi chạy `update-context` prompt.

## Anti-patterns thường gặp

> Những lỗi phổ biến cần tránh (tech-agnostic):

- **N+1 Query**: Luôn eager load relationships khi query.
- **Hardcoded credentials**: Dùng env vars, không bao giờ hardcode.
- **Missing input validation**: Validate tại system boundary, trước khi xử lý.
- **Raw SQL interpolation**: Dùng parameterized queries / ORM.
- **Swallowed errors**: Không bao giờ `catch(e) {}` rỗng — luôn log hoặc rethrow.
- **`any` type in TypeScript**: Định nghĩa type rõ ràng.
