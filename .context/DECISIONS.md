# Architectural Decisions

> Index tất cả architectural decisions của dự án.  
> Chi tiết từng ADR: xem `.context/decisions/ADR-NNN-<slug>.md`

## Index

| ADR | Title | Date | Status |
|-----|-------|------|--------|
| — | *(Chưa có decision nào — thêm khi có)* | — | — |

## Statuses

- `Proposed` — đang cân nhắc
- `Accepted` — đã quyết định và đang áp dụng
- `Deprecated` — không còn áp dụng (nhưng giữ lại để biết lý do)  
- `Superseded by ADR-NNN` — bị thay thế

## Hướng dẫn thêm ADR

1. Chạy prompt `log-decision` trong Copilot.
2. Hoặc thêm thủ công: tạo file `.context/decisions/ADR-NNN-<slug>.md` + update bảng trên.

## Mẫu ADR

```markdown
# ADR-001: <Title>

**Date:** YYYY-MM-DD
**Status:** Accepted
**Deciders:** <tên/team>

## Context
<Tại sao cần quyết định này?>

## Decision
<Quyết định gì?>

## Alternatives Considered
<Các phương án đã cân nhắc và lý do không chọn>

## Consequences
### Positive
- ...
### Negative / Trade-offs
- ...
```
