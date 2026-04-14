# Project History

> **Format:** `[YYYY-MM-DD] <type>: <description> — <file/module>`
> **Types:** feat | fix | refactor | test | docs | chore | decision | migration | perf

<!-- Thêm entries mới ở cuối file. Copilot sẽ append tự động. -->

[2024-01-01] chore: Initial template setup — copilot-workspace-setup
[2025-07-09] feat: Add NestJS stack support — .github/instructions/nestjs.instructions.md
[2025-07-09] feat: Add Django stack support — .github/instructions/django.instructions.md
[2025-07-09] feat: Add FastAPI stack support — .github/instructions/fastapi.instructions.md
[2025-07-09] feat: Add PHP 8.2+ features and Modular domain structure — .github/instructions/laravel.instructions.md
[2025-07-09] feat: Add TypeScript strict rules section — .github/instructions/react.instructions.md
[2025-07-09] chore: Update stack detection table (NestJS/Django/FastAPI) — .github/agents/oryn-dev.agent.md
[2025-07-09] chore: Update stack table (NestJS/Django/FastAPI) — .github/agents/implementer.agent.md
[2025-07-09] chore: Add Django/FastAPI to framework table — .github/agents/tc-writer.agent.md
[2025-07-09] chore: Add Django/FastAPI test commands — .github/agents/qa-tester.agent.md
[2025-07-09] feat: Create NestJS project template — templates/nestjs/.github/copilot-instructions.md
[2025-07-09] feat: Create Django project template — templates/django/.github/copilot-instructions.md
[2025-07-09] feat: Create FastAPI project template — templates/fastapi/.github/copilot-instructions.md
[2026-04-14] decision: Evaluate agent gaps — proposed debugger agent (RCA flow) + security-auditor agent + /profile-performance prompt — .github/agents/
[2026-04-14] feat: Create debugger agent (Reproduce→RCA→Fix→Regression flow) — .github/agents/debugger.agent.md
[2026-04-14] feat: Create security-auditor agent (OWASP Top 10 checklist, stack-specific commands) — .github/agents/security-auditor.agent.md
[2026-04-14] chore: Update oryn-dev coordinator (add debugger/security-auditor to agents list, handoffs, bug+audit flows) — .github/agents/oryn-dev.agent.md
[2026-04-14] feat: Add CI/CD failure flow to debugger agent (GitHub MCP list_workflow_runs/get_workflow_run_logs) — .github/agents/debugger.agent.md
[2026-04-14] chore: Add CI failure handoff + routing flow to oryn-dev — .github/agents/oryn-dev.agent.md
[2026-04-14] chore: Update GitHub MCP description to reflect CI/CD capabilities — .vscode/mcp.json
[2026-04-14] feat: Create code-reviewer agent (PR review inline via GitHub MCP) — .github/agents/code-reviewer.agent.md
[2026-04-14] feat: Create /profile-performance prompt (N+1, bundle, latency, memory) — .github/prompts/profile-performance.prompt.md
[2026-04-14] refactor: Restructure ERRORS.md with BUG-NNN format + MCP ID field + anti-patterns section — .context/ERRORS.md
[2026-04-14] feat: Create mcp-error-learning system design (Phase 1 SQLite → Phase 2 pgvector → Phase 3 AI) — mcp-error-learning/DESIGN.md
[2026-04-14] chore: Add .gitignore (exclude mcp-error-learning/, venv, .env, .DS_Store) — .gitignore
[2026-04-14] feat: Add error-learning MCP server config (stdio, Phase 1) — .vscode/mcp.json
[2026-04-14] feat: Integrate Error Learning MCP into debugger flow (search_similar→record_error) — .github/agents/debugger.agent.md
[2026-04-14] docs: Update README (new agents, /profile-performance prompt, Error Learning MCP section with roadmap) — README.md
[2026-04-14] feat: Add COMMIT phase to oryn-dev pipeline (Conventional Commits, no-push rule) — .github/agents/oryn-dev.agent.md
[2026-04-14] feat: Create /commit-task prompt (safety checks, Conventional Commits, report) — .github/prompts/commit-task.prompt.md
[2026-04-14] chore: Update /new-feature prompt to include COMMIT phase — .github/prompts/new-feature.prompt.md
[2026-04-14] docs: Update README pipeline diagram and prompts table with /commit-task — README.md
[2025-07-09] docs: Update README with 6-stack table and template copy instructions — README.md
