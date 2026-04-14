---
mode: agent
tools:
  - codebase
  - runCommands
description: >
  Create a Conventional Commits-compliant git commit for the task just completed.
  Auto-detects staged changes, generates an appropriate message, and commits.
  Does NOT push automatically — the user decides when to push to remote.
---

# Commit Task

Create a standardized git commit for the changes just implemented.

## Commit information

**Task/Feature:** ${input:taskName:Name of the task or feature just completed (e.g. JWT refresh token, Fix null check in UserService)}
**Type:** ${input:type:feat|fix|test|refactor|chore|docs|perf|ci}
**Scope:** ${input:scope:Module/feature scope (e.g. auth, user, payment, api) — leave blank if global}

---

## Execution

### Step 1 — Check status

```bash
git status
git diff --staged --stat
```

If **no staged changes** → run:
```bash
git add -A
git status
```

Display the list of files to be committed. If any file is unrelated to this task (e.g. `.env`, `node_modules`, personal files) → **do not commit** and ask the user.

### Step 2 — Safety check

Before committing, verify:

- [ ] No `.env`, `.env.local`, `*.pem`, `*.key` files in staged files.
- [ ] No `node_modules/`, `vendor/`, `__pycache__/` in staged files.
- [ ] No hardcoded secrets (quick scan with `git diff --staged | grep -i "password\|secret\|api_key\|token" | grep "^+"`).
- [ ] Tests have passed (if not — ask the user whether to commit anyway).

If a problem is found → **stop and report to user**, do not commit.

### Step 3 — Generate commit message

Apply **Conventional Commits** format:

```
<type>(<scope>): <subject>

[body — if extra explanation is needed]

[footer — if there is a breaking change or issue reference]
```

**Rules cho subject:**
- Use imperative present tense: `add`, `fix`, `update`, `remove`, `implement`, `refactor`
- Lowercase, no trailing period
- Maximum 72 characters
- English (git history is technical documentation)

**Rules cho body (optional):**
- Explain *why* the change was made, not *what* (the code already says that)
- Maximum 72 characters per line

**Footer (use when):**
- Breaking change: `BREAKING CHANGE: <description>`
- Closes issue: `Closes #123`
- Related to: `Refs #456`

**Example commit messages:**

```bash
# Simple feature
feat(auth): add JWT refresh token rotation

# Bug fix with context
fix(user): add null check after async getUserById

Previously the function would throw TypeError when user
was not found in Redis cache before DB fallback.

# Feature with breaking change
feat(api)!: change pagination format to cursor-based

BREAKING CHANGE: response now returns `cursor` instead of `page`.
Clients must update to use cursor parameter for next page.

# Test
test(payment): add edge cases for zero-amount transactions

# CI config
ci: add pytest-cov threshold check at 80%
```

### Step 4 — Execute commit

```bash
git commit -m "<generated message>"
```

If body/footer is needed:
```bash
git commit -m "<subject>" -m "<body>" -m "<footer>"
```

### Step 5 — Confirm and report

After a successful commit:

```bash
git log --oneline -3  # show last 3 commits to confirm
```

Output report:

```markdown
## ✅ Commit successful

**Hash:** `abc1234`
**Message:** `feat(auth): add JWT refresh token rotation`
**Files committed:** N files, +X insertions, -Y deletions

**Next steps (choose one):**
- Continue to the next task in the breakdown
- `git push origin <branch>` when ready to deploy
- Create a Pull Request on GitHub
```

---

## Important notes

- **DO NOT `git push`** — commit locally only. The user decides when to push.
- **DO NOT `git commit --amend`** if already pushed.
- **DO NOT `git commit -m "fix"` or `wip`** — messages must be meaningful.
- If a task is too large and requires multiple commits → each commit = one small logical change that can stand alone.
