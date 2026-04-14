# copilot-workspace-setup

> **Template repo — set up once, use across every project.**
> Clone or copy `.github/`, `.context/`, `.vscode/` into any new project and you're ready to go.

Supports: **Laravel**, **Next.js**, **React (Vite)**, **Vue 3**, **NestJS**, **Django**, **FastAPI**

| Stack | Test Framework | E2E | Min Version |
|---|---|---|---|
| Laravel | PHPUnit | Playwright | PHP 8.2 / Laravel 11 |
| Next.js | Vitest | Playwright | Next.js 14 (App Router) |
| React (Vite) | Vitest | Playwright | React 18 / TypeScript 5 strict |
| Vue 3 | Vitest | Playwright | Vue 3.4 |
| NestJS | Jest + supertest | Playwright | NestJS 10 / Node 20 |
| Django | pytest-django | Playwright | Django 5 / Python 3.12 |
| FastAPI | pytest-asyncio | Playwright | FastAPI 0.111 / Pydantic v2 |

---

## Structure

```
copilot-workspace-setup/
│
├── .github/
│   ├── copilot-instructions.md        # Global rules (tech-agnostic)
│   ├── agents/                        # Custom agents (VS Code v1.100+)
│   │   ├── oryn-dev.agent.md          # Coordinator — orchestrates subagents automatically
│   │   ├── planner.agent.md           # Analysis sub-agent (user-invocable: false)
│   │   ├── implementer.agent.md       # Code-writing sub-agent (user-invocable: false)
│   │   ├── tc-writer.agent.md         # Test case sub-agent (user-invocable: false)
│   │   ├── qa-tester.agent.md         # Test-runner sub-agent (user-invocable: false)
│   │   ├── debugger.agent.md          # Bug fix + CI failure (user-invocable: true)
│   │   ├── security-auditor.agent.md  # OWASP Top 10 audit (user-invocable: true)
│   │   └── code-reviewer.agent.md     # Inline PR review (user-invocable: true)
│   ├── instructions/                  # File-scoped rules per stack
│   │   ├── laravel.instructions.md    # applyTo: **/*.php
│   │   ├── nextjs.instructions.md     # applyTo: app/**/*.{ts,tsx}
│   │   ├── react.instructions.md      # applyTo: src/**/*.{ts,tsx}
│   │   ├── vue.instructions.md        # applyTo: **/*.vue
│   │   ├── nestjs.instructions.md     # applyTo: src/**/*.ts
│   │   ├── django.instructions.md     # applyTo: **/serializers.py,...
│   │   ├── fastapi.instructions.md    # applyTo: **/routers/**/*.py,...
│   │   ├── database.instructions.md   # applyTo: **/migrations/**
│   │   └── testing.instructions.md    # applyTo: tests/**,**/*.test.*
│   ├── prompts/                       # Reusable prompt files (/slash-commands)
│   │   ├── new-feature.prompt.md
│   │   ├── create-migration.prompt.md
│   │   ├── create-module.prompt.md
│   │   ├── write-test-cases.prompt.md
│   │   ├── run-api-test.prompt.md
│   │   ├── run-e2e-test.prompt.md
│   │   ├── profile-performance.prompt.md
│   │   ├── commit-task.prompt.md
│   │   ├── log-decision.prompt.md
│   │   └── update-context.prompt.md
│   ├── skills/                        # Agent skills (explicit #file reference)
│   │   ├── test-case-writer/SKILL.md
│   │   ├── api-tester/SKILL.md
│   │   ├── e2e-tester/SKILL.md
│   │   └── context-updater/SKILL.md
│   └── hooks/                         # VS Code Agent hooks (auto-loaded)
│       ├── qa-workflow.json           # Hook config — SessionStart/PostToolUse/Stop
│       └── scripts/
│           ├── inject-session-ctx.sh  # SessionStart: inject .context/ into conversation
│           ├── check-task-done.sh     # UserPromptSubmit: verify context is ready
│           ├── post-edit-audit.sh     # PostToolUse: log file edits to session log
│           └── session-stop.sh        # Stop: block session if HISTORY.md not updated
│
├── .context/
│   ├── HISTORY.md                     # Chronological change log
│   ├── DECISIONS.md                   # Architectural decisions index (ADR)
│   ├── ERRORS.md                      # Known bugs index (avoid repeating)
│   ├── log.sh                         # Quick log helper script
│   ├── decisions/                     # Individual ADR files
│   ├── errors/                        # Individual error detail files
│   ├── sessions/                      # Per-session logs (auto-created by hooks)
│   └── test-cases/
│       └── TC-TEMPLATE.md
│
├── .vscode/
│   ├── mcp.json                       # MCP servers (context7, github, playwright, error-learning)
│   ├── settings.json                  # VS Code settings (agents, hooks, subagents)
│   └── extensions.json                # Recommended extensions
│
└── templates/                         # Stack-specific overrides
    ├── laravel/
    │   └── .github/copilot-instructions.md
    ├── nextjs/
    │   └── .github/copilot-instructions.md
    ├── nestjs/
    │   └── .github/copilot-instructions.md
    ├── django/
    │   └── .github/copilot-instructions.md
    └── fastapi/
        └── .github/copilot-instructions.md
```

---

## Getting Started on a New Project

### Option A — Manual Copy

```bash
# Clone the template repo
git clone https://github.com/orynvn/copilot-workspace-setup.git temp-setup

# Copy into your project
cp -r temp-setup/.github/ /path/to/your-project/
cp -r temp-setup/.context/ /path/to/your-project/
cp -r temp-setup/.vscode/ /path/to/your-project/

# Reset history
echo "# Project History" > /path/to/your-project/.context/HISTORY.md

# Remove temp clone
rm -rf temp-setup
```

### Option B — GitHub Template

1. Click **"Use this template"** on GitHub.
2. Clone your new repo.
3. Copy the template matching your stack:

| Stack | Template path |
|---|---|
| Laravel | `templates/laravel/.github/copilot-instructions.md` |
| Next.js | `templates/nextjs/.github/copilot-instructions.md` |
| NestJS | `templates/nestjs/.github/copilot-instructions.md` |
| Django | `templates/django/.github/copilot-instructions.md` |
| FastAPI | `templates/fastapi/.github/copilot-instructions.md` |

```bash
# Example for NestJS
cp templates/nestjs/.github/copilot-instructions.md .github/copilot-instructions.md
```

---

## Workflow — Automatic via Native Subagents

From VS Code 1.100+, the pipeline is **fully automatic** — no manual chatmode switching needed:

```
1. Select "Oryn Dev" agent in the Chat view
2. Set permission level to "Bypass Approvals" (optional, for speed)
3. Describe your task (or use /new-feature, /create-module...)

   Oryn Dev (Coordinator) automatically:
   ├── → Planner subagent      analyze + task breakdown
   ├── → User confirms plan
   ├── → Implementer subagent  implement files one by one
   ├── → TC-Writer subagent    write test cases
   ├── → QA-Tester subagent    run tests + report
   ├── → Commit (git add + commit — no push)
   └── → Update .context/HISTORY.md
```

After each phase, **handoff buttons** appear to advance to the next agent (or the coordinator calls subagents directly).

---

## Agents

| Agent | Role | Visibility |
|---|---|---|
| `oryn-dev` | Coordinator — orchestrates the full pipeline | Shown in dropdown |
| `planner` | Analysis, task breakdown | Subagent only |
| `implementer` | Write code per stack conventions | Subagent only |
| `tc-writer` | Write test cases TC-MODULE-NNN | Subagent only |
| `qa-tester` | Run tests, root cause analysis | Subagent only |
| `debugger` | Bug fix + CI/CD failure (GitHub MCP + Error Learning MCP) | Shown in dropdown |
| `security-auditor` | OWASP Top 10 audit, on-demand | Shown in dropdown |
| `code-reviewer` | Inline PR review comments via GitHub MCP | Shown in dropdown |

> Worker agents have `user-invocable: false` — hidden from the dropdown, only callable by the coordinator.

---

## Prompts (Slash Commands)

Type `/` in the Chat view to pick:

| Prompt | When to use |
|---|---|
| `/new-feature` | Implement a new feature end-to-end |
| `/create-module` | Generate a complete CRUD module |
| `/create-migration` | Create a DB migration (Laravel) |
| `/write-test-cases` | Write tests for existing code |
| `/run-api-test` | Run unit / integration tests |
| `/run-e2e-test` | Run Playwright E2E tests |
| `/profile-performance` | Analyze bottlenecks: N+1, bundle size, latency, memory |
| `/commit-task` | Generate a Conventional Commits message and commit |
| `/log-decision` | Record an architectural decision (ADR) |
| `/update-context` | Sync `.context/` at end of session |

---

## Hooks (Auto-loaded from `.github/hooks/`)

VS Code automatically loads and fires hooks at lifecycle events:

| Event | Script | Effect |
|---|---|---|
| `SessionStart` | `inject-session-ctx.sh` | Inject HISTORY / ERRORS / DECISIONS into context |
| `UserPromptSubmit` | `check-task-done.sh` | Warn if `.context/` is not ready |
| `PostToolUse` | `post-edit-audit.sh` | Log file edits to the session log |
| `Stop` | `session-stop.sh` | Block session exit if HISTORY.md was not updated |

---

## Context Memory

`.context/` acts as the project's long-term memory — auto-injected into every session via hooks:

- **HISTORY.md** — chronological change log
- **DECISIONS.md** — architectural decisions (ADR index)
- **ERRORS.md** — known bugs to avoid repeating
- **sessions/** — per-session logs (auto-created by hook)
- **test-cases/** — TC specs per module

```bash
# Quick log a change
./.context/log.sh "feat: User auth module — AuthController.php"
```

---

## MCP Servers (`.vscode/mcp.json`)

| Server | Purpose |
|---|---|
| `context7` | Fetch library docs (React, Next.js, Laravel…) |
| `github` | Issues, PRs, Actions workflow logs, CI check runs |
| `playwright` | Browser automation for E2E tests |
| `error-learning` | **Error Learning MCP** — local error knowledge base |

---

## Error Learning MCP

> **Concept:** Turns the Debugger agent from "smart but forgetful" into "smart and learning" — accumulating knowledge from error history over time.

Developed as an independent server at **[orynvn/mcp-error-learning](https://github.com/orynvn/mcp-error-learning)**. Once installed, VS Code auto-detects it via `.vscode/mcp.json` in this repo.

See installation instructions, tool API, and roadmap in that repo.

---

## Design Decisions

- **Native subagents**: Coordinator calls worker agents directly — no manual switching.
- **Handoffs**: Transition buttons between agents after each phase.
- **Hooks auto-loaded**: `.github/hooks/*.json` activates automatically, no extra config.
- **2-tier instructions**: Global (tech-agnostic) + stack-specific (`applyTo` frontmatter).
- **Context memory**: Persist AI memory across the entire project lifetime via `.context/`.
- **Structured test IDs**: `TC-MODULE-NNN` traceable from spec → code → report.

---

## Requirements

- **VS Code** v1.100+ (April 2025)
- **GitHub Copilot** extension (latest)
- Extension setting `chat.agent.enabled: true` (already included in `.vscode/settings.json`)
