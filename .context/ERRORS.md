# Known Errors & Anti-patterns

> Log all bugs, errors, and anti-patterns encountered in the project.
> Copilot reads this file before implementing to avoid repeating old mistakes.
>
> **MCP Integration:** From Phase 1 onwards, this file is synced with the `mcp-error-learning` SQLite DB.
> Use the Debugger agent to auto-record — no need to edit manually.

---

## Open

*(No open errors yet — add when discovered)*

---

## Resolved

*(No resolved errors yet)*

---

## Standard format — BUG-NNN (manual or auto via Debugger)

```markdown
### BUG-NNN: <Short, clear title>
**Date:** YYYY-MM-DD
**Stack:** Laravel | Next.js | React | NestJS | Django | FastAPI
**Module:** AUTH | USER | PRODUCT | ORDER | ...
**Symptom:** <Symptom observed by user/dev>
**Root cause:** <Root cause — not the symptom>
**Fix:** `path/to/file.ts:line` — <description of change>
**Prevention:** <Pattern or rule to avoid recurrence>
**Test added:** TC-MODULE-NNN
**MCP ID:** <error_id from mcp-error-learning if recorded>
```

---

## Anti-patterns (project-level)

> Patterns that are prohibited in this project and why:

*(Add when a bad pattern is repeatedly observed)*


## How to use

- When a new bug is found → add to the **Open** section.
- When a bug is fixed → move to the **Resolved** section + add `**Fixed:** YYYY-MM-DD`.
- Copilot automatically appends when running the `update-context` prompt.

## Common anti-patterns to avoid

> Common mistakes to avoid (tech-agnostic):

- **N+1 Query**: Always eager load relationships when querying.
- **Hardcoded credentials**: Use env vars, never hardcode.
- **Missing input validation**: Validate at system boundary, before processing.
- **Raw SQL interpolation**: Use parameterized queries / ORM.
- **Swallowed errors**: Never `catch(e) {}` empty — always log or rethrow.
- **`any` type in TypeScript**: Define types explicitly.
