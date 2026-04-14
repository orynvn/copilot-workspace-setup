# .context — Usage Guide

The `.context/` directory is the project's **memory** for Copilot agents. All decisions, change history, encountered errors, and test cases are stored here.

## Structure

```
.context/
├── README.md          # This file — usage guide
├── HISTORY.md         # Chronological log of all changes
├── DECISIONS.md       # Index of architectural decisions (ADR)
├── ERRORS.md          # Index of known errors & fixes
├── log.sh             # Quick log script for HISTORY.md
├── decisions/         # ADR details: ADR-NNN-<slug>.md
├── errors/            # Detailed error reports
├── sessions/          # Session logs by date: session-YYYY-MM-DD.md
└── test-cases/        # Test case specs: TC-MODULE-spec.md
```

## Workflow

### At the start of each session

Copilot will automatically read:
1. `HISTORY.md` — last 10 entries
2. `DECISIONS.md` — all `Accepted` decisions
3. `ERRORS.md` — open errors to avoid

Or run the script: `source .context/inject-session-ctx.sh`

### At the end of each session

Run the `update-context` prompt — Copilot will automatically update all files.

## Quick commands

```bash
# Quickly log a change
./.context/log.sh "feat: User auth module — AuthController.php"

# View last 20 entries
tail -20 .context/HISTORY.md

# Find decision by keyword
grep -i "database" .context/DECISIONS.md

# View open errors
awk '/^## Open/,/^## Resolved/' .context/ERRORS.md
```

## When cloning a new repo

```bash
# Copy entire .context/ into new project (reset history)
cp -r .context/ /path/to/new-project/

# Clear old history, keep structure
echo "# Project History" > /path/to/new-project/.context/HISTORY.md
echo "# Architectural Decisions" > /path/to/new-project/.context/DECISIONS.md
echo "# Known Errors" > /path/to/new-project/.context/ERRORS.md
```

## Optionally, do not commit to git

If you do not want to track context in git, add to `.gitignore`:
```
.context/sessions/
.context/test-cases/
```

However, it is **recommended to commit** `HISTORY.md`, `DECISIONS.md`, `ERRORS.md` so the team can share context.
