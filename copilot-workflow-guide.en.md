# Workflow Design for GitHub Copilot Agent Mode — Lessons from Real Use

> *This is what I tried, what worked for me. Not the only right approach.*

---

## The Actual Problem

GitHub Copilot agent mode (VS Code 1.100+) is already capable: it runs tools autonomously, self-corrects compile errors, supports subagents and lifecycle hooks. It's not a "reactive chatbot" anymore.

The problem I ran into wasn't that Copilot was weak — it was that **every session starts from scratch**:

- No knowledge of this project's conventions (naming, error handling, commit style)
- No memory of architectural decisions made last week and why
- No record of bugs that were fixed and how
- Complex tasks required re-injecting context manually every time

Compared to Claude Code where `CLAUDE.md` is read every session, Copilot has no equivalent by default. But here's what I realized: **what Claude Code has by design, Copilot can be built explicitly**.

---

## The Solution: 2 Repos

**1. [`copilot-workspace-setup`](https://github.com/orynvn/copilot-workspace-setup)** — A workspace template with context injection, persistent memory, agent pipeline, and lifecycle hooks.

**2. [`mcp-error-learning`](https://github.com/orynvn/mcp-error-learning)** — An MCP server that accumulates knowledge from bug history and fixes, so the Debugger agent doesn't "forget" between sessions.

This works with both the **VS Code extension** (agent mode) and **GitHub Copilot CLI**.

---

## Component 1: Context System

**2-tier instruction system** — instructions load automatically, no manual prompting needed:

```
.github/
├── copilot-instructions.md        # Global convention — naming, commits, security
└── instructions/
    ├── laravel.instructions.md    # applyTo: **/*.php
    ├── nextjs.instructions.md     # applyTo: app/**/*.{ts,tsx}
    ├── testing.instructions.md    # applyTo: tests/**,**/*.test.*
    └── database.instructions.md   # applyTo: **/migrations/**
```

Stack-specific rules only load when the agent works with the matching file type. No context pollution with irrelevant rules.

---

## Component 2: Persistent Memory

`.context/` is the project's long-term memory. Auto-injected every session via the `SessionStart` hook:

```
.context/
├── HISTORY.md      # Change log — only last 15 entries injected
├── DECISIONS.md    # Architectural decisions — index → decisions/
├── ERRORS.md       # Known bugs — index → errors/
├── plans/          # System design + phase plans (see below)
├── decisions/      # Detailed ADR files
├── errors/         # Detailed bug files
└── sessions/       # Per-session logs (auto-created by PostToolUse hook)
```

The three index files **describe and link only** — the agent reads the index first, then loads detail files when needed. Context stays lean as the project grows.

---

## Component 3: Agent Pipeline

**9 agents** organized in 3 groups:

**Pipeline agents** (`user-invocable: false` — coordinator calls only):
- `planner` — analyze tasks, create task breakdown
- `implementer` — write code following stack conventions
- `tc-writer` — write test cases
- `qa-tester` — run tests, analyze failures, fix, re-run

**Coordinator** (`user-invocable: true`):
- `oryn-dev` — orchestrates the full pipeline, enforces Plan→Implement→Test→Commit→Log

**On-demand** (`user-invocable: true`):
- `architect` — pre-project system design (see below)
- `debugger` — bug fixing + MCP error learning
- `code-reviewer` — PR review + inline comments
- `security-auditor` — OWASP Top 10 scan
- `quick` — simple tasks that don't need the pipeline

**Lifecycle hooks** (4 events):
```
SessionStart      → inject-session-ctx.sh  # Inject HISTORY/ERRORS/DECISIONS
UserPromptSubmit  → check-task-done.sh     # Prompt to update context if task in progress
PostToolUse       → post-edit-audit.sh     # Log every file edit to session log
Stop              → session-stop.sh        # Block close if HISTORY.md not updated today
```

---

## Starting a New Project

This is the part I find most important for getting the most out of this repo.

**Before running `oryn-dev`**, I run `architect` to produce a blueprint:

```
#architect "I need to build system X with requirements Y"
```

`architect` analyzes from 4 lenses, each reading the output of the previous:

```
1. Architecture lens → .context/plans/system-design.md (## Architecture)
      ↓ reads
2. Data model lens   → appends (## Data Model)
      ↓ reads both
3. API surface lens  → appends (## API Surface)
      ↓ detects conflicts (e.g., endpoint returns full_name but DB has first/last)
      → flags to (## Open Questions), does NOT resolve silently
      ↓ reads full document
4. Risk & phase lens → .context/plans/phase-1.md, phase-2.md...
```

**Why does conflict detection emerge naturally?** Because each lens *must read the previous lens's output* to do its own job. The API Surface lens can't design correct endpoints without knowing the DB schema. The shared filesystem (`.context/plans/`) acts as a natural message bus.

After reviewing Open Questions and confirming:

```
#oryn-dev "Implement phase 1 from .context/plans/phase-1.md"
  ↓
planner → task breakdown from phase-1.md
  ↓
implementer → write code
  ↓
tc-writer → write tests
  ↓
qa-tester → run tests → fix if failing → re-run
  ↓
oryn-dev → commit + update .context/HISTORY.md
```

You don't need to do anything during the pipeline. Review when there's a result.

---

## Error Learning MCP

Every bug fix is temporary knowledge — Debugger fixes it today, encounters a similar bug next month in a different module, and has no memory of the previous solution.

[`mcp-error-learning`](https://github.com/orynvn/mcp-error-learning) addresses this:

```
New bug → [MCP] search_similar → match? → suggest known fix
                                → no match → RCA → fix → [MCP] record_error
```

Phase 1 (current): SQLite local, single project. Enough to validate the concept — needs more time to accumulate data to measure real-world effectiveness.

---

## Adding Project-Specific Agents

The agents in this template are general-purpose. For projects with specific workflows, you can add custom agents to `.github/agents/` in your project.

**When to create a new agent vs. use `quick`:**

| Use `quick` | Create a new agent |
|---|---|
| One-off task, won't repeat | Repeated task across the project lifecycle |
| No special toolset needed | Needs a specific tool set or MCP |
| No fixed workflow | Has a defined checklist or review process |

**Minimal template** — create `.github/agents/<name>.agent.md`:

```markdown
---
description: <Short description — shown in agent picker>
user-invocable: true
tools:
  - codebase
  - readFile
  - editFiles
  - runCommands
---

# <Agent Name>

You are <role>. Your job: <description>.

## Process
1. ...
2. ...
```

**Real example — `migration-reviewer` for a Django project:**

```markdown
---
description: Migration Reviewer — Checks Django migrations before merge. Detects missing indexes, breaking changes, and data loss risks.
user-invocable: true
tools:
  - codebase
  - readFile
  - runCommands
handoffs:
  - label: "🔧 Fix with Implementer"
    agent: implementer
    prompt: "Fix the following migration issues: [findings list]"
    send: false
---

# Migration Reviewer

You are Migration Reviewer. Check all unapplied Django migrations.

## Checklist
- [ ] Missing index on foreign key?
- [ ] Dropping a column that has data?
- [ ] Field type change — is it backward compatible?
- [ ] Can the migration run zero-downtime?
```

This agent is invoked directly with `#migration-reviewer` — no need to declare it in `oryn-dev` since users call it manually.

If you want `oryn-dev` to call it automatically in the pipeline (e.g., after every implementation), add it to the `agents:` list and `handoffs:` in `oryn-dev.agent.md`.

---

## Full File Structure

```
project/
├── .github/
│   ├── copilot-instructions.md    # Global convention
│   ├── agents/
│   │   ├── oryn-dev.agent.md      # Coordinator
│   │   ├── architect.agent.md     # Pre-project design
│   │   ├── planner.agent.md       # Pipeline — subagent only
│   │   ├── implementer.agent.md   # Pipeline — subagent only
│   │   ├── tc-writer.agent.md     # Pipeline — subagent only
│   │   ├── qa-tester.agent.md     # Pipeline — subagent only
│   │   ├── debugger.agent.md      # On-demand + MCP
│   │   ├── code-reviewer.agent.md # On-demand
│   │   ├── security-auditor.agent.md # On-demand
│   │   └── quick.agent.md         # Simple tasks
│   ├── instructions/              # Stack-specific rules
│   ├── prompts/                   # Slash commands
│   ├── skills/                    # Agent skills
│   └── hooks/
│       ├── qa-workflow.json       # Hook config
│       └── scripts/               # 4 hook scripts
├── .context/
│   ├── HISTORY.md
│   ├── DECISIONS.md
│   ├── ERRORS.md
│   ├── plans/                     # system-design.md + phase-N.md
│   ├── decisions/
│   ├── errors/
│   └── sessions/
├── .vscode/
│   └── mcp.json                   # context7, github, error-learning MCPs
└── templates/                     # laravel, nextjs, nestjs, django, fastapi, react
```

---

## Requirements

- VS Code 1.100+ with GitHub Copilot (any plan)
- Python 3.12+ (only if using Error Learning MCP)

---

## Getting Started

```bash
git clone https://github.com/orynvn/copilot-workspace-setup.git temp-setup

cp -r temp-setup/.github/ your-project/
cp -r temp-setup/.context/ your-project/
cp -r temp-setup/.vscode/ your-project/

# Pick your stack template
cp temp-setup/templates/nextjs/.github/copilot-instructions.md \
   your-project/.github/copilot-instructions.md

# Optional: Error Learning MCP
cd your-project
git clone https://github.com/orynvn/mcp-error-learning.git
pip install -e mcp-error-learning/
```

---

## Open Questions I Don't Have Answers To

- Does the `architect` agent produce system design quality good enough to use as a blueprint, or does it need significant manual editing?
- Does Error Learning MCP accumulate knowledge fast enough to be useful in a medium-length project (< 6 months)?
- Which hook causes enough friction to make you disable it?

Feedback — positive or negative — welcome.

---

*Repos:*
- *[github.com/orynvn/copilot-workspace-setup](https://github.com/orynvn/copilot-workspace-setup)*
- *[github.com/orynvn/mcp-error-learning](https://github.com/orynvn/mcp-error-learning)*
