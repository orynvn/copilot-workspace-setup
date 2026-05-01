# Project History

> **Format:** `[YYYY-MM-DD] <type>: <description> — <file/module>`
> **Types:** feat | fix | refactor | test | docs | chore | decision | migration | perf

<!-- Add new entries at the end of this file. Copilot will append automatically. -->

[YYYY-MM-DD] chore: Initial project setup from copilot-workspace-setup template
[2026-04-14] feat: add quick agent — solo executor for simple tasks, no pipeline — .github/agents/quick.agent.md
[2026-04-14] docs: add quick agent to README.md agent table and file tree — README.md
[2026-04-14] docs: add quick agent to README.vi.md (Vietnamese version) — README.vi.md
[2026-04-14] feat: publish branch v1 + tag v1.1 — quick agent (Vietnamese) backported to v1
[2026-04-14] chore: reset HISTORY.md to clean template state — .context/HISTORY.md
[2026-04-17] docs: review copilot-workflow-guide.md — identified 4 factual inaccuracies (missing agents, non-existent deliberative agents section, missing session-summary note, wrong .context/plans/ path) — copilot-workflow-guide.md
[2026-04-17] feat: add architect agent — pre-project system design, 4-lens analysis, outputs to .context/plans/ — .github/agents/architect.agent.md
[2026-04-17] feat: add .context/plans/ directory — holds system-design.md and phase-N.md produced by architect agent — .context/plans/README.md
[2026-04-17] docs: rewrite copilot-workflow-guide.md (VI) — shorter, factually accurate, removed non-existent features — copilot-workflow-guide.md
[2026-04-17] docs: add copilot-workflow-guide.en.md — English version of the workflow guide — copilot-workflow-guide.en.md
[2026-05-01] docs: research & analysis — GitHub Copilot usage-based billing (June 1, 2026): token pricing per model, impact on multi-agent pipeline, optimization recommendations — .context/HISTORY.md
[2026-05-01] perf: token optimization — conditional context reading (§3.1), routing table by complexity (§4), trim naming conventions table — .github/copilot-instructions.md
[2026-05-01] perf: token optimization — add complexity routing table to prevent unnecessary full-pipeline calls — .github/agents/oryn-dev.agent.md
[2026-05-01] perf: token optimization — add lightweight model recommendation (GPT-4.1/GPT-5 mini) — .github/agents/planner.agent.md, tc-writer.agent.md, qa-tester.agent.md
[2026-05-01] perf: phase-first pipeline — oryn-dev reads phase-N.md directly, skips planner when phase file exists — .github/agents/oryn-dev.agent.md
[2026-05-01] feat: add FILE-INDEX.md — module-to-file map for fast lookup without source scan — .context/FILE-INDEX.md
[2026-05-01] perf: inject FILE-INDEX into session start context via hook — .github/hooks/scripts/inject-session-ctx.sh
[2026-05-01] perf: add VI triggers to routing table §4, compress §7 git types, rewrite §8 agent table — .github/copilot-instructions.md
[2026-05-01] feat: add phase-writer agent — dedicated phase planning without full system design — .github/agents/phase-writer.agent.md
[2026-05-01] feat: add phase-writer to §4 routing table + §8 agent table — .github/copilot-instructions.md
[2026-05-01] feat: add phase-writer handoff to oryn-dev and architect agents — .github/agents/oryn-dev.agent.md, architect.agent.md
[2026-05-01] docs: update plans/README.md to include phase-writer workflow (Option A/B) — .context/plans/README.md
[2026-05-01] feat: add file-indexer skill — guides how to keep FILE-INDEX.md accurate after every task — .github/skills/file-indexer/SKILL.md
[2026-05-01] perf: remove sessions/ — redundant with HISTORY.md; repurpose post-edit-audit.sh to write HISTORY directly — .github/hooks/scripts/post-edit-audit.sh
[2026-05-01] perf: switch context reads to keyword search (grep) instead of full file reads — §3.1 copilot-instructions.md, context-updater/SKILL.md, .context/README.md
[2026-05-01] chore: remove sessions/ directory and all references across prompts/skills/hooks
[2026-05-01] chore: edited `/Volumes/DataStorage/oryn-project/copilot-workspace-setup/.github/prompts/update-context.prompt.md`
[2026-05-01] chore: edited `/Volumes/DataStorage/oryn-project/copilot-workspace-setup/.context/HISTORY.md`
[2026-05-01] chore: edited `/Volumes/DataStorage/oryn-project/copilot-workspace-setup/.context/README.md`
[2026-05-01] chore: edited `/Volumes/DataStorage/oryn-project/copilot-workspace-setup/.github/copilot-instructions.md`
