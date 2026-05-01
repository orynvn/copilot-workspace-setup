# GitHub Copilot — Global Instructions

> **Scope:** Tech-agnostic rules applied to every project. Project-specific overrides live in `templates/<stack>/.github/copilot-instructions.md`.

---

## 1. Identity & Communication

- Respond in **English** by default.
- Be concise — no filler text, no unsolicited explanations.
- When uncertain, **ask one focused question** rather than guessing.
- Always cite the file path when referencing code: `src/services/UserService.ts:42`.

---

## 2. Stack Detection

Before implementing anything, identify the tech stack from project files:

| File present | Stack |
|---|---|
| `composer.json` + `artisan` | Laravel |
| `package.json` → `"next"` dep | Next.js |
| `package.json` → `"vite"` + `"react"` | React (Vite) |
| `package.json` → `"vue"` | Vue 3 |
| `package.json` → `"@nestjs/core"` | NestJS |
| `requirements.txt` / `pyproject.toml` → `django` | Django |
| `requirements.txt` / `pyproject.toml` → `fastapi` | FastAPI |

After detection, apply the matching `.github/instructions/<stack>.instructions.md` rules.

---

## 3. Context Memory Protocol

### 3.1 Read before acting
Only for **complex or multi-step tasks** (full pipeline, architecture, refactor):
1. **HISTORY** — already injected at session start (last 15 entries). Do not re-read the full file.
2. **DECISIONS** — search by task keyword: `grep -i "<keyword>" .context/DECISIONS.md`
3. **ERRORS** — search by task keyword: `grep -i "<keyword>" .context/ERRORS.md`
4. **FILE-INDEX** — already injected at session start. Search by module name if needed.

> Skip context reads entirely for: single-file edits, documentation, config changes, quick fixes.

### 3.2 Write after acting
After completing a task:
- Append a one-line entry to `.context/HISTORY.md`:
  ```
  [YYYY-MM-DD] <action> — <file/module affected>
  ```
- If an architectural decision was made → run `log-decision` prompt.
- If a bug/error was fixed → append to `.context/ERRORS.md`.

### 3.3 Session context
Session context (HISTORY tail + FILE-INDEX) is injected automatically at session start via the VS Code hook. No manual session logs needed.

---

## 4. Workflow: Route by Complexity

Choose the workflow tier based on task scope — this is the primary token optimization gate:

| Task type | VI triggers | Route | Pipeline |
|---|---|---|---|
| Docs, config, single-file fix | sửa nhanh, chỉnh, cập nhật docs, fix config | `quick` agent | Direct implement → LOG |
| Small feature, 1-2 files | thêm tính năng, tạo API, viết service | `planner` + `implementer` | PLAN → IMPLEMENT → LOG |
| Feature with tests required | viết test, thêm unit test, cần coverage | + `tc-writer` + `qa-tester` | + TEST |
| Phase file exists (`.context/plans/phase-N.md`) | implement phase, chạy phase | `oryn-dev` phase-first | Read phase → IMPLEMENT → TEST (if required) → COMMIT → LOG |
| Need phases, arch already known | lên phases, viết kế hoạch, phân phase, tạo plan | `phase-writer` | Analyze → Write phase-N.md → oryn-dev |
| Complex / multi-module / arch | thiết kế, refactor toàn bộ, kiến trúc, tái cấu trúc | `architect` → `oryn-dev` | DESIGN → PLAN → IMPLEMENT → TEST → COMMIT → LOG |

> **Default to the lightest sufficient tier.** Only escalate if the current tier is insufficient.

### 4.1 PLAN phase
1. Re-state requirement in 1-2 sentences.
2. List files to create/modify.
3. Identify edge cases & risks.
4. **Wait for user confirmation** before proceeding.

### 4.2 IMPLEMENT phase
- One logical change per commit scope.
- Never modify files outside the agreed plan without asking.
- Follow naming conventions: files=kebab-case, classes=PascalCase, functions=camelCase, constants=UPPER_SNAKE_CASE, DB=snake_case.

### 4.3 TEST phase
- After implementation, suggest test cases or run existing ones.
- Use the `write-test-cases` or `run-api-test` prompts.

### 4.4 LOG phase
- Update `.context/HISTORY.md`.
- Update `.context/FILE-INDEX.md` using the `file-indexer` skill.
- Log decisions if architectural choices were made.

---

## 5. Security Defaults

- **Never** hardcode secrets, API keys, passwords.
- Always use environment variables for sensitive config.
- Validate all external inputs at system boundaries.
- Follow OWASP Top 10 mitigations by default.
- SQL: use parameterized queries / ORM — never raw string interpolation.
- Auth: assume token-based (JWT/session); never roll custom crypto.

---

## 6. Code Quality Rules

- **DRY**: extract repeated logic into shared utilities after the 2nd occurrence.
- **YAGNI**: don't add features not explicitly requested.
- **Single Responsibility**: one file/class does one thing.
- Max function length: ~40 lines — split if longer.
- No commented-out dead code in final commits.
- All async operations must handle errors (try/catch or `.catch()`).

---

## 7. Git Conventions

Commit message format: `<type>(<scope>): <subject>`

Types: `feat` | `fix` | `refactor` | `test` | `docs` | `chore` | `perf` | `ci`

Branch naming: `<type>/<short-description>` → `feat/user-auth`, `fix/login-redirect`

---

## 8. Agent Coordination

| Agent | Role |
|---|---|
| `architect` | Greenfield design → produces `system-design.md` + `phase-N.md` |
| `phase-writer` | Produces prioritized `phase-N.md` files when arch is already known |
| `oryn-dev` | Coordinator — phase-first execution, orchestrates subagents |
| `implementer` | Writes code per task spec |
| `tc-writer` | Writes test cases (lightweight model) |
| `qa-tester` | Runs tests, reports failures (lightweight model) |
| `debugger` | Bug reports and CI failures |
| `quick` | Single-agent, no pipeline — for simple tasks |

Detailed workflow logic lives in `.github/agents/oryn-dev.agent.md`.
