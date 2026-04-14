---
mode: agent
tools:
  - editFiles
  - readFile
description: >
  Ghi lại một architectural decision vào .context/DECISIONS.md và tạo
  decision detail file trong .context/decisions/.
---

# Log Decision Prompt

Ghi lại architectural decision để làm tài liệu cho dự án.

## Thông tin decision

**Tiêu đề:** ${input:title:Tiêu đề ngắn (vd: Dùng Zustand thay Redux cho state management)}
**Context:** ${input:context:Tại sao cần đưa ra quyết định này?}
**Decision:** ${input:decision:Quyết định cuối cùng là gì?}
**Alternatives:** ${input:alternatives:Các phương án đã cân nhắc}
**Consequences:** ${input:consequences:Hệ quả / trade-offs}

---

## Thực thi

### 1. Đọc DECISIONS.md

Đọc `.context/DECISIONS.md` để lấy số thứ tự ADR tiếp theo.

### 2. Tạo decision file

Tạo file `.context/decisions/ADR-NNN-<slug>.md`:

```markdown
# ADR-NNN: ${input:title}

**Date:** {{date}}
**Status:** Accepted
**Deciders:** <team/người quyết định>

## Context

${input:context}

## Decision

${input:decision}

## Alternatives Considered

${input:alternatives}

## Consequences

### Positive
- ...

### Negative / Trade-offs
- ...

## Related decisions
- ADR-XXX: <nếu có>
```

### 3. Cập nhật index

Append vào `.context/DECISIONS.md`:
```markdown
| ADR-NNN | ${input:title} | {{date}} | Accepted |
```

### 4. Cập nhật HISTORY.md

Append vào `.context/HISTORY.md`:
```
[{{date}}] decision: ADR-NNN logged — ${input:title}
```

---

**Thực thi ngay — không cần confirm.**
