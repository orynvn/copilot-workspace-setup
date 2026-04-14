# copilot-workspace-setup

> **Template repo — setup một lần, dùng cho mọi dự án.**
> Clone hoặc copy `.github/`, `.context/`, `.vscode/` vào project mới là xong.

> **Ngôn ngữ:** Đây là tài liệu tiếng Việt (phiên bản v1, lưu trữ).
> Tài liệu tiếng Anh (mặc định từ v2.0) xem tại [README.md](README.md).

Hỗ trợ: **Laravel**, **Next.js**, **React (Vite)**, **Vue 3**, **NestJS**, **Django**, **FastAPI**

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

## Cấu trúc

```
copilot-workspace-setup/
│
├── .github/
│   ├── copilot-instructions.md        # Global rules (tech-agnostic)
│   ├── agents/                        # Custom agents (VS Code v1.100+)
│   │   ├── oryn-dev.agent.md          # Coordinator — điều phối subagents tự động
│   │   ├── planner.agent.md           # Sub-agent phân tích (user-invocable: false)
│   │   ├── implementer.agent.md       # Sub-agent viết code (user-invocable: false)
│   │   ├── tc-writer.agent.md         # Sub-agent viết test cases (user-invocable: false)
│   │   ├── qa-tester.agent.md         # Sub-agent chạy tests (user-invocable: false)
│   │   ├── debugger.agent.md          # Bug fix + CI failure (user-invocable: true)
│   │   ├── security-auditor.agent.md  # OWASP Top 10 audit (user-invocable: true)
│   │   └── code-reviewer.agent.md     # PR review inline (user-invocable: true)
│   ├── instructions/                  # File-scoped rules theo stack
│   │   ├── laravel.instructions.md    # applyTo: **/*.php
│   │   ├── nextjs.instructions.md     # applyTo: app/**/*.{ts,tsx}
│   │   ├── react.instructions.md      # applyTo: src/**/*.{ts,tsx}
│   │   ├── vue.instructions.md        # applyTo: **/*.vue
│   │   ├── nestjs.instructions.md     # applyTo: src/**/*.ts
│   │   ├── django.instructions.md     # applyTo: **/serializers.py,...
│   │   ├── fastapi.instructions.md    # applyTo: **/routers/**/*.py,...
│   │   ├── database.instructions.md   # applyTo: **/migrations/**
│   │   └── testing.instructions.md    # applyTo: tests/**,**/*.test.*
│   ├── prompts/                       # Reusable prompt files (/slash-command)
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
│           ├── inject-session-ctx.sh  # SessionStart: inject .context/ vào conversation
│           ├── check-task-done.sh     # UserPromptSubmit: kiểm tra context sẵn sàng
│           ├── post-edit-audit.sh     # PostToolUse: ghi log file edits
│           └── session-stop.sh        # Stop: nhắc update HISTORY.md
│
├── .context/
│   ├── HISTORY.md                     # Log lịch sử thay đổi
│   ├── DECISIONS.md                   # Index architectural decisions
│   ├── ERRORS.md                      # Index errors đã gặp
│   ├── log.sh                         # Quick log script
│   ├── decisions/                     # Chi tiết từng ADR
│   ├── errors/                        # Chi tiết từng error
│   ├── sessions/                      # Per-session logs (auto-created by hooks)
│   └── test-cases/
│       └── TC-TEMPLATE.md
│
├── .vscode/
│   ├── mcp.json                       # MCP servers (context7, github, playwright, error-learning)
│   ├── settings.json                  # VS Code settings (agents, hooks, subagents)
│   └── extensions.json               # Recommended extensions
│
└── templates/                         # Project-specific overrides
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

## Cách dùng cho dự án mới

### Option A — Copy thủ công

```bash
# Clone template repo
git clone https://github.com/orynvn/copilot-workspace-setup.git temp-setup

# Copy vào project mới
cp -r temp-setup/.github/ /path/to/your-project/
cp -r temp-setup/.context/ /path/to/your-project/
cp -r temp-setup/.vscode/ /path/to/your-project/

# Reset history
echo "# Project History" > /path/to/your-project/.context/HISTORY.md

# Xoá temp
rm -rf temp-setup
```

### Option B — Use as template (GitHub)

1. Nhấn **"Use this template"** trên GitHub.
2. Clone repo mới về.
3. Copy template phù hợp với stack của bạn:

| Stack | Template path |
|---|---|
| Laravel | `templates/laravel/.github/copilot-instructions.md` |
| Next.js | `templates/nextjs/.github/copilot-instructions.md` |
| NestJS | `templates/nestjs/.github/copilot-instructions.md` |
| Django | `templates/django/.github/copilot-instructions.md` |
| FastAPI | `templates/fastapi/.github/copilot-instructions.md` |

```bash
# Ví dụ cho NestJS
cp templates/nestjs/.github/copilot-instructions.md .github/copilot-instructions.md
```

### Cài đặt Error Learning MCP (tùy chọn)

```bash
# Clone MCP server vào project (cùng cấp .github/)
cd /path/to/your-project
git clone https://github.com/orynvn/mcp-error-learning.git

# Install
python3 -m pip install -e mcp-error-learning/

# VS Code tự độc config từ .vscode/mcp.json — không cần config thêm
```

> MCP server sẽ lưu knowledge base tại `mcp-error-learning/data/errors.db`.
> Thư mục `mcp-error-learning/` có repo riêng, đã được thêm vào `.gitignore` của project.

---

## Workflow — Tự động qua Native Subagents

Kể từ VS Code 1.100+, pipeline **hoàn toàn tự động** — không cần switch chatmode thủ công:

```
1. Chọn agent "Oryn Dev" trong Chat view
2. Đặt permission level: "Bypass Approvals" (optional, cho tốc độ)
3. Mô tả task (hoặc dùng /new-feature, /create-module...)

   Oryn Dev (Coordinator) tự động:
   ├── → Planner subagent    phân tích + task breakdown
   ├── → User confirm
   ├── → Implementer subagent  implement từng file
   ├── → TC-Writer subagent   viết test cases
   ├── → QA-Tester subagent   chạy tests + báo cáo
   ├── → Commit (git add + commit — không push)
   └── → Cập nhật .context/HISTORY.md
```

Sau mỗi phase, **handoff buttons** xuất hiện để chuyển tiếp sang agent tiếp theo (hoặc agent tự gọi subagent).

---

## Agents

| Agent | Vai trò | Visibility |
|-------|---------|-----------|
| `oryn-dev` | Coordinator — điều phối pipeline | Hiện trong dropdown |
| `planner` | Phân tích, task breakdown | Subagent only |
| `implementer` | Viết code theo stack conventions | Subagent only |
| `tc-writer` | Viết test cases TC-MODULE-NNN | Subagent only |
| `qa-tester` | Chạy tests, root cause analysis | Subagent only || `debugger` | Bug fix + CI/CD failure (GitHub MCP + Error Learning MCP) | Hiện trong dropdown |
| `security-auditor` | OWASP Top 10 audit, on-demand | Hiện trong dropdown |
| `code-reviewer` | PR review inline comments qua GitHub MCP | Hiện trong dropdown |
> Worker agents có `user-invocable: false` — ẩn khỏi dropdown, chỉ được gọi bởi coordinator.

---

## Prompts (Slash Commands)

Gõ `/` trong Chat view để chọn:

| Prompt | Dùng khi |
|--------|----------|
| `/new-feature` | Implement feature mới từ đầu |
| `/create-module` | Tạo module CRUD hoàn chỉnh |
| `/create-migration` | Tạo DB migration (Laravel) |
| `/write-test-cases` | Viết tests cho code hiện có |
| `/run-api-test` | Chạy unit/integration tests |
| `/run-e2e-test` | Chạy Playwright E2E tests |
| `/profile-performance` | Phân tích bottleneck: N+1, bundle size, latency, memory || `/commit-task` | Tạo git commit chuẩn Conventional Commits sau mỗi task || `/log-decision` | Ghi architectural decision (ADR) |
| `/update-context` | Sync `.context/` cuối session |

---

## Hooks (Auto-loaded từ `.github/hooks/`)

VS Code tự động load và chạy hooks tại các lifecycle events:

| Event | Script | Tác dụng |
|-------|--------|----------|
| `SessionStart` | `inject-session-ctx.sh` | Inject HISTORY/ERRORS/DECISIONS vào context |
| `UserPromptSubmit` | `check-task-done.sh` | Cảnh báo nếu `.context/` chưa sẵn sàng |
| `PostToolUse` | `post-edit-audit.sh` | Ghi log file edits vào session log |
| `Stop` | `session-stop.sh` | Chặn session nếu HISTORY.md chưa được update |

---

## Context Memory

`.context/` là "memory" của dự án — tự động được inject vào mỗi session qua hooks:

- **HISTORY.md** — log mọi thay đổi theo thời gian
- **DECISIONS.md** — architectural decisions (ADR index)
- **ERRORS.md** — bugs đã gặp để tránh lặp lại
- **sessions/** — per-session logs (tự tạo bởi hook)
- **test-cases/** — TC specs theo module

```bash
# Log nhanh một thay đổi
./.context/log.sh "feat: User auth module — AuthController.php"
```

---

## MCP Servers (`.vscode/mcp.json`)

| Server | Dùng cho |
|--------|---------|
| `context7` | Fetch docs thư viện (React, Next.js, Laravel...) |
| `github` | Issues, PRs, Actions workflow logs, CI check runs |
| `playwright` | Browser automation cho E2E tests |
| `error-learning` | **Error Learning MCP** — knowledge base lỗi local (xem bên dưới) |

---

## Error Learning MCP

> **Concept:** Biến Debugger agent từ "thông minh nhưng hay quên" thành "thông minh và học được" — tích lũy kiến thức từ lịch sử lỗi theo thời gian.

MCP server này được phát triển độc lập tại **[orynvn/mcp-error-learning](https://github.com/orynvn/mcp-error-learning)**. Sau khi cài đặt, VS Code tự detect qua `.vscode/mcp.json` trong repo này.

Xem hướng dẫn cài đặt, tool API, và roadmap tại repo trên.

---

## Design Decisions

- **Native subagents**: Coordinator tự gọi worker agents — không cần switch thủ công.
- **Handoffs**: Button chuyển tiếp giữa agents sau mỗi phase.
- **Hooks auto-loaded**: `.github/hooks/*.json` tự động active, không cần config thêm.
- **2-tier instructions**: Global (tech-agnostic) + Stack-specific (`applyTo` frontmatter).
- **Context memory**: Persist "AI memory" xuyên suốt dự án qua `.context/`.
- **Structured test IDs**: `TC-MODULE-NNN` trace từ spec → code → report.

---

## Yêu cầu

- **VS Code** v1.100+ (April 2025)
- **GitHub Copilot** extension (latest)
- Extension setting `chat.agent.enabled: true` (đã có trong `.vscode/settings.json`)
