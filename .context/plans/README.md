# Plans

This directory contains pre-project design documents produced by the **Architect** or **Phase Writer** agent, and per-phase implementation plans consumed by **oryn-dev**.

## Workflow

```
Option A — Full design (greenfield / unknown arch):
[User] → #architect → system-design.md + phase-N.md
                                ↓
                  [User reviews Open Questions]
                                ↓
[User] → #oryn-dev "Implement phase 1" → reads phase-1.md → pipeline

Option B — Phases only (arch already known):
[User] → #phase-writer → phase-N.md (prioritized)
                                ↓
[User] → #oryn-dev "Implement phase 1" → reads phase-1.md → pipeline
```

## Files in this directory

| File | Created by | Purpose |
|---|---|---|
| `system-design.md` | Architect | Architecture, data model, API surface, open questions |
| `phase-1.md` | Architect or Phase Writer | Scope, tasks, acceptance criteria for Phase 1 |
| `phase-2.md` | Architect or Phase Writer | Scope, tasks, acceptance criteria for Phase 2 |
| `phase-N.md` | Architect or Phase Writer | Additional phases as needed |

## Notes

- `system-design.md` is the source of truth for all architectural decisions. Optional when using Phase Writer.
- Each `phase-N.md` is self-contained — oryn-dev should be able to implement it without reading other phases.
- After implementation, log decisions to `.context/DECISIONS.md` and update phase status from `draft` to `implemented`.
- Phase Writer appends new phases — it never overwrites existing `phase-N.md` files.
