# Plans

This directory contains pre-project design documents produced by the **Architect** agent, and per-phase implementation plans consumed by **oryn-dev**.

## Workflow

```
[User] → #architect → system-design.md + phase-N.md
                                ↓
                  [User reviews Open Questions]
                                ↓
[User] → #oryn-dev "Implement phase 1" → reads phase-1.md → pipeline
```

## Files in this directory

| File | Created by | Purpose |
|---|---|---|
| `system-design.md` | Architect | Architecture, data model, API surface, open questions |
| `phase-1.md` | Architect | Scope, tasks, acceptance criteria for Phase 1 |
| `phase-2.md` | Architect | Scope, tasks, acceptance criteria for Phase 2 |
| `phase-N.md` | Architect | Additional phases as needed |

## Notes

- `system-design.md` is the source of truth for all architectural decisions made before coding starts.
- Each `phase-N.md` is self-contained — oryn-dev should be able to implement it without reading phases it did not produce.
- After implementation, log decisions to `.context/DECISIONS.md` and update `system-design.md` status from `draft` to `implemented`.
