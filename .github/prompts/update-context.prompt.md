---
mode: agent
tools:
  - editFiles
  - readFile
  - codebase
description: >
  Cập nhật toàn bộ context files (.context/) để phản ánh trạng thái hiện tại
  của dự án. Dùng cuối session hoặc sau khi hoàn thành một milestone.
---

# Update Context Prompt

Đồng bộ `.context/` để phản ánh trạng thái thực tế của dự án.

## Thông tin

**Session/milestone:** ${input:session:Mô tả ngắn session này làm gì (vd: Sprint 3 - Auth module)}
**Changes made:** ${input:changes:Những gì đã thay đổi trong session này}

---

## Thực thi

### 1. Cập nhật HISTORY.md

Đọc git log hoặc danh sách files đã thay đổi, append các entries còn thiếu:
```
[{{date}}] ${input:changes}
```

Format mỗi entry:
```
[YYYY-MM-DD] <type>: <description> — <file/module>
```
Types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`

### 2. Kiểm tra DECISIONS.md

Review các decisions trong session vừa rồi:
- Có architectural choice mới nào chưa được log?
- Nếu có → chạy `log-decision` prompt cho từng decision.

### 3. Kiểm tra ERRORS.md

Review bugs/issues gặp phải trong session:
- Append errors mới theo format:
  ```
  [{{date}}] ERROR: <mô tả> | Root cause: <nguyên nhân> | Fix: <cách sửa> | File: <path>
  ```
- Update status của errors cũ đã fix: `Fixed: {{date}}`

### 4. Tổng kết session log

Tạo hoặc cập nhật `.context/sessions/session-<date>.md`:

```markdown
# Session Log: {{date}}

## Mục tiêu
${input:session}

## Đã hoàn thành
- [ ] <task 1>
- [ ] <task 2>

## Quyết định trong session
- ADR-NNN: <decision title> (if any)

## Vấn đề gặp phải
- <issue 1> → <cách giải quyết>

## Việc cần làm tiếp theo
- <next task 1>
- <next task 2>

## Files đã thay đổi
${input:changes}
```

### 5. Verify context integrity

Kiểm tra:
- [ ] `HISTORY.md` có entry cho ngày hôm nay chưa?
- [ ] `DECISIONS.md` có đủ tất cả major decisions chưa?
- [ ] `ERRORS.md` có resolved errors nào cần update status không?
- [ ] Test cases có sync với `.context/test-cases/` không?

---

**Thực thi tất cả steps — báo cáo summary sau khi xong.**
