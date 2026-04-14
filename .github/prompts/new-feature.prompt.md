---
mode: agent
tools:
  - codebase
  - editFiles
  - readFile
  - runCommands
description: >
  Tạo một feature mới hoàn chỉnh theo pipeline Plan → Implement → Test → Commit → Log.
  Dùng khi cần implement một feature từ đầu, bao gồm cả test cases và commit chuẩn.
---

# New Feature Prompt

Tôi cần implement feature mới. Hãy chạy đúng pipeline:

## Thông tin feature

**Tên feature:** ${input:featureName:Tên feature (vd: User Authentication)}
**Mô tả:** ${input:description:Mô tả ngắn chức năng cần implement}
**Module:** ${input:module:Module liên quan (vd: AUTH, USER, PRODUCT)}

---

## Pipeline thực thi

### Bước 1 — PLAN

1. Đọc `.context/HISTORY.md`, `.context/DECISIONS.md`, `.context/ERRORS.md`.
2. Xác định tech stack từ project files.
3. Load instructions tương ứng từ `.github/instructions/`.
4. Tạo task breakdown đầy đủ:
   - Danh sách files cần tạo/sửa (theo thứ tự dependency)
   - Edge cases & rủi ro
   - Definition of Done
5. Hiển thị plan → **chờ user confirm** trước khi tiếp tục.

### Bước 2 — IMPLEMENT

Sau khi user confirm:
1. Implement từng task theo thứ tự.
2. Tuân thủ conventions của stack (`laravel.instructions.md`, `nextjs.instructions.md`, ...).
3. Không thêm scope ngoài plan.
4. Security checklist trước khi mark done:
   - [ ] Không hardcode secrets
   - [ ] Input validated
   - [ ] Authorization checked

### Bước 3 — TEST

1. Viết test cases cho toàn bộ feature (dùng skill `test-case-writer`).
2. Chạy tests.
3. Report kết quả.
4. Nếu fail → fix → chạy lại.

### Bước 4 — COMMIT

Sau khi tất cả tests pass, thực hiện commit:

1. Chạy `/commit-task` prompt để tạo commit chuẩn Conventional Commits.
2. Verify không có file nhạy cảm trong staged changes.
3. Commit với message: `feat(<scope>): <subject>`
4. **Không push** — user quyết định.

### Bước 5 — LOG

1. Append vào `.context/HISTORY.md`:
   ```
   [{{date}}] feat: ${input:featureName} — <files affected>
   ```
2. Nếu có architectural decision → chạy `log-decision` prompt.

---

Bắt đầu với **Bước 1 — PLAN**.
