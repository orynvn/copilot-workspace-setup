---
mode: agent
tools:
  - editFiles
  - readFile
  - codebase
description: >
  Update all context files (.context/) to reflect the current state
  of the project. Use at the end of a session or after completing a milestone.
---

# Update Context Prompt

Sync `.context/` to reflect the actual state of the project.

## Information

**Session/milestone:** ${input:session:Brief description of what this session did (e.g. Sprint 3 - Auth module)}
**Changes made:** ${input:changes:What changed in this session}

---

## Execution

### 1. Update HISTORY.md

Read the git log or list of changed files, append any missing entries:
```
[{{date}}] ${input:changes}
```

Format for each entry:
```
[YYYY-MM-DD] <type>: <description> — <file/module>
```
Types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`

### 2. Check DECISIONS.md

Review any decisions made this session:
- Any new architectural choices not yet logged?
- If yes → run the `log-decision` prompt for each one.

### 3. Check ERRORS.md

Review bugs/issues encountered this session:
- Append new errors in the format:
  ```
  [{{date}}] ERROR: <description> | Root cause: <cause> | Fix: <solution> | File: <path>
  ```
- Update status of old errors that were fixed: `Fixed: {{date}}`

### 4. Session log summary

Create or update `.context/sessions/session-<date>.md`:

```markdown
# Session Log: {{date}}

## Goal
${input:session}

## Completed
- [ ] <task 1>
- [ ] <task 2>

## Decisions in this session
- ADR-NNN: <decision title> (if any)

## Issues encountered
- <issue 1> → <resolution>

## Next steps
- <next task 1>
- <next task 2>

## Changed files
${input:changes}
```

### 5. Verify context integrity

Check:
- [ ] Does `HISTORY.md` have an entry for today?
- [ ] Does `DECISIONS.md` include all major decisions?
- [ ] Are there any resolved errors in `ERRORS.md` that need a status update?
- [ ] Are test cases in sync with `.context/test-cases/`?

---

**Execute all steps — report a summary when done.**
