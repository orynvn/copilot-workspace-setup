---
mode: agent
tools:
  - editFiles
  - readFile
description: >
  Record an architectural decision in .context/DECISIONS.md and create
  a decision detail file in .context/decisions/.
---

# Log Decision Prompt

Record an architectural decision as documentation for the project.

## Decision information

**Title:** ${input:title:Short title (e.g. Use Zustand instead of Redux for state management)}
**Context:** ${input:context:Why does this decision need to be made?}
**Decision:** ${input:decision:What is the final decision?}
**Alternatives:** ${input:alternatives:Alternatives considered}
**Consequences:** ${input:consequences:Consequences / trade-offs}

---

## Execution

### 1. Read DECISIONS.md

Read `.context/DECISIONS.md` to get the next ADR sequence number.

### 2. Create decision file

Create file `.context/decisions/ADR-NNN-<slug>.md`:

```markdown
# ADR-NNN: ${input:title}

**Date:** {{date}}
**Status:** Accepted
**Deciders:** <team / decision makers>

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
- ADR-XXX: <if any>
```

### 3. Update index

Append to `.context/DECISIONS.md`:
```markdown
| ADR-NNN | ${input:title} | {{date}} | Accepted |
```

### 4. Update HISTORY.md

Append to `.context/HISTORY.md`:
```
[{{date}}] decision: ADR-NNN logged — ${input:title}
```

---

**Execute immediately — no confirmation needed.**
