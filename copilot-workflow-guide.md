# Workflow Design cho GitHub Copilot Agent Mode — Chia sẻ từ thực tế

> *Đây là những gì tôi đã thử, những gì hoạt động với tôi. Không phải hướng dẫn duy nhất đúng.*

---

## Vấn đề thực tế

GitHub Copilot agent mode (VS Code 1.100+) đã khá mạnh: tự chạy tool, tự sửa lỗi compile, tích hợp subagents, hooks lifecycle. Không còn là "reactive chatbot" như một vài năm trước.

Vấn đề tôi gặp không phải là Copilot kém — mà là **mỗi session bắt đầu từ đầu**:

- Không biết convention của project này (naming, error handling, commit style)
- Không biết quyết định architecture đã làm tuần trước và lý do tại sao
- Không biết bug nào đã từng xảy ra và đã được fix như thế nào
- Mỗi task phức tạp cần nhắc lại context thủ công

So với Claude Code với `CLAUDE.md` được đọc mỗi session, Copilot không có gì tương đương theo mặc định. Nhưng đây là điều tôi nhận ra: **những thứ Claude Code có by design, Copilot có thể được build explicitly**.

---

## Giải pháp: 3 thành phần

**1. [`copilot-workspace-setup`](https://github.com/orynvn/copilot-workspace-setup)** — Template workspace với context injection, persistent memory, agent pipeline và lifecycle hooks.

**2. [`mcp-error-learning`](https://github.com/orynvn/mcp-error-learning)** — MCP server tích lũy kiến thức từ lịch sử bug và fix, giúp Debugger agent không "quên" giữa các session.

Repo này hoạt động với cả **VS Code extension** (agent mode) và **GitHub Copilot CLI**.

---

## Thành phần 1: Context System

**2-tier instruction system** — instructions được load tự động, không cần nhắc lại:

```
.github/
├── copilot-instructions.md        # Convention chung — naming, commits, security
└── instructions/
    ├── laravel.instructions.md    # applyTo: **/*.php
    ├── nextjs.instructions.md     # applyTo: app/**/*.{ts,tsx}
    ├── testing.instructions.md    # applyTo: tests/**,**/*.test.*
    └── database.instructions.md   # applyTo: **/migrations/**
```

Stack-specific rules chỉ load khi agent làm việc với file type tương ứng. Không pollute context với rules không liên quan.

---

## Thành phần 2: Persistent Memory

`.context/` directory là long-term memory của project. Được inject tự động vào mỗi session qua `SessionStart` hook:

```
.context/
├── HISTORY.md      # Change log — chỉ 15 entries gần nhất được inject
├── DECISIONS.md    # Architectural decisions — index → decisions/
├── ERRORS.md       # Known bugs — index → errors/
├── plans/          # System design + phase plans (xem bên dưới)
├── decisions/      # ADR files chi tiết
├── errors/         # Bug detail files
└── sessions/       # Per-session logs (auto-created bởi PostToolUse hook)
```

Ba file index **chỉ mô tả và link** — agent đọc index trước, rồi đọc file chi tiết khi cần. Context không bị overload khi project lớn lên.

---

## Thành phần 3: Agent Pipeline

**9 agents** được tổ chức thành 3 nhóm:

**Nhóm pipeline** (`user-invocable: false` — chỉ coordinator gọi):
- `planner` — phân tích task, tạo task breakdown
- `implementer` — viết code theo stack conventions
- `tc-writer` — viết test cases
- `qa-tester` — chạy test, phân tích lỗi, tự fix, chạy lại

**Coordinator** (`user-invocable: true`):
- `oryn-dev` — điều phối toàn bộ pipeline, enforce Plan→Implement→Test→Commit→Log

**On-demand** (`user-invocable: true`):
- `architect` — pre-project system design (xem bên dưới)
- `debugger` — bug fixing + MCP error learning
- `code-reviewer` — PR review + inline comments
- `security-auditor` — OWASP Top 10 scan
- `quick` — task đơn giản không cần pipeline

**Lifecycle hooks** (4 events):
```
SessionStart      → inject-session-ctx.sh  # Inject HISTORY/ERRORS/DECISIONS
UserPromptSubmit  → check-task-done.sh     # Nhắc update context nếu task đang dở
PostToolUse       → post-edit-audit.sh     # Log mọi file edit vào session log
Stop              → session-stop.sh        # Block close nếu HISTORY.md chưa update
```

---

## Workflow khi bắt đầu dự án mới

Đây là phần tôi thấy quan trọng nhất để phối hợp tốt với repo này.

**Trước khi dùng `oryn-dev`**, tôi chạy `architect` để tạo blueprint:

```
#architect "Tôi cần build hệ thống X với yêu cầu Y"
```

`architect` phân tích từ 4 góc nhìn, mỗi góc đọc output của góc trước:

```
1. Architecture lens → .context/plans/system-design.md (## Architecture)
      ↓ đọc
2. Data model lens   → append (## Data Model)
      ↓ đọc cả hai
3. API surface lens  → append (## API Surface)
      ↓ phát hiện conflict (ví dụ: endpoint trả full_name nhưng DB có first/last)
      → flag vào (## Open Questions), không tự resolve
      ↓ đọc toàn bộ
4. Risk & phase lens → .context/plans/phase-1.md, phase-2.md...
```

Kết quả: `system-design.md` có đầy đủ conflict được surface, `phase-N.md` là input cho `oryn-dev`.

**Tại sao conflict detection tự nhiên xuất hiện?** Vì mỗi lens *cần đọc output của lens trước* để làm việc của mình. API Surface lens không thể thiết kế endpoint đúng nếu không biết DB schema. Shared filesystem (`.context/plans/`) là "message bus" tự nhiên.

Sau khi review Open Questions và confirm:

```
#oryn-dev "Implement phase 1 từ .context/plans/phase-1.md"
  ↓
planner → task breakdown từ phase-1.md
  ↓
implementer → viết code
  ↓
tc-writer → viết tests
  ↓
qa-tester → chạy test → fix nếu fail → chạy lại
  ↓
oryn-dev → commit + update .context/HISTORY.md
```

Bạn không cần làm gì trong pipeline. Review khi có kết quả.

---

## Error Learning MCP

Mỗi bug fix là knowledge tạm thời — Debugger fix được hôm nay, session sau gặp bug tương tự không nhớ.

[`mcp-error-learning`](https://github.com/orynvn/mcp-error-learning) giải quyết điều này:

```
Bug mới → [MCP] search_similar → match? → suggest known fix
                                → không match → RCA → fix → [MCP] record_error
```

Phase 1 (hiện tại): SQLite local, single project. Đủ để validate concept, cần thêm thời gian accumulate data để đánh giá hiệu quả thực tế.

---

## Thêm agent chuyên môn cho từng dự án

Các agent trong template là general-purpose. Với dự án có workflow đặc thù, bạn có thể thêm agent riêng vào `.github/agents/` của project.

**Khi nào nên thêm agent mới vs. dùng `quick`:**

| Dùng `quick` | Tạo agent mới |
|---|---|
| Task đơn lẻ, không lặp lại | Task lặp lại nhiều lần |
| Không cần tool đặc biệt | Cần tool set hoặc MCP riêng |
| Không có workflow cố định | Có quy trình kiểm tra cụ thể |

**Template tối thiểu** — tạo file `.github/agents/<tên>.agent.md`:

```markdown
---
description: <Mô tả ngắn — hiện trong agent picker>
user-invocable: true
tools:
  - codebase
  - readFile
  - editFiles
  - runCommands
---

# <Tên Agent>

Bạn là <vai trò>. Nhiệm vụ: <mô tả>.

## Quy trình
1. ...
2. ...
```

**Ví dụ thực tế — `migration-reviewer` cho dự án Django:**

```markdown
---
description: Migration Reviewer — Kiểm tra Django migrations trước khi merge. Phát hiện missing indexes, breaking changes, và data loss risks.
user-invocable: true
tools:
  - codebase
  - readFile
  - runCommands
handoffs:
  - label: "🔧 Fix với Implementer"
    agent: implementer
    prompt: "Fix các migration issues sau: [danh sách findings]"
    send: false
---

# Migration Reviewer

Bạn là Migration Reviewer. Kiểm tra tất cả Django migrations chưa được apply.

## Checklist
- [ ] Missing index trên foreign key?
- [ ] Xóa column có data không?
- [ ] Thay đổi field type có backward compatible không?
- [ ] Migration có thể chạy zero-downtime không?
```

Agent này được gọi trực tiếp bằng `#migration-reviewer` — không cần khai báo trong `oryn-dev` vì người dùng gọi thủ công.

Nếu muốn `oryn-dev` tự động gọi agent này trong pipeline (ví dụ: sau mỗi lần implement xong), thêm vào `agents:` list và `handoffs:` của `oryn-dev.agent.md`.

---

## Cấu trúc file đầy đủ

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

## Yêu cầu

- VS Code 1.100+ với GitHub Copilot (bất kỳ plan nào)
- Python 3.12+ (chỉ nếu dùng Error Learning MCP)

---

## Thử nghiệm

```bash
git clone https://github.com/orynvn/copilot-workspace-setup.git temp-setup

cp -r temp-setup/.github/ your-project/
cp -r temp-setup/.context/ your-project/
cp -r temp-setup/.vscode/ your-project/

# Chọn stack template
cp temp-setup/templates/nextjs/.github/copilot-instructions.md \
   your-project/.github/copilot-instructions.md

# Optional: Error Learning MCP
cd your-project
git clone https://github.com/orynvn/mcp-error-learning.git
pip install -e mcp-error-learning/
```

---

## Những câu hỏi tôi chưa có câu trả lời

- `architect` agent có thực sự produce system design quality đủ tốt để làm blueprint, hay cần nhiều round edit thủ công không?
- Error Learning MCP có accumulate knowledge đủ nhanh để hữu ích trong dự án vừa (< 6 tháng) không?
- Hook friction ở bước nào khiến bạn tắt đi?

Feedback — dù tích cực hay tiêu cực — welcome.

---

*Repos:*
- *[github.com/orynvn/copilot-workspace-setup](https://github.com/orynvn/copilot-workspace-setup)*
- *[github.com/orynvn/mcp-error-learning](https://github.com/orynvn/mcp-error-learning)*
