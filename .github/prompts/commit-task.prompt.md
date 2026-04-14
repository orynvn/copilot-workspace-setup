---
mode: agent
tools:
  - codebase
  - runCommands
description: >
  Tạo git commit chuẩn Conventional Commits cho task vừa hoàn thành.
  Tự động detect staged changes, generate message phù hợp, và commit.
  KHÔNG tự push — user quyết định khi nào push lên remote.
---

# Commit Task

Tạo git commit chuẩn hóa cho những thay đổi vừa implement.

## Thông tin commit

**Task/Feature:** ${input:taskName:Tên task hoặc feature vừa làm (vd: JWT refresh token, Fix null check in UserService)}
**Type:** ${input:type:feat|fix|test|refactor|chore|docs|perf|ci}
**Scope:** ${input:scope:Module/feature scope (vd: auth, user, payment, api) — để trống nếu global}

---

## Thực thi

### Bước 1 — Kiểm tra trạng thái

```bash
git status
git diff --staged --stat
```

Nếu **không có staged changes** → chạy:
```bash
git add -A
git status
```

Hiển thị danh sách files sẽ được commit. Nếu có file không liên quan đến task này (ví dụ: `.env`, `node_modules`, file cá nhân) → **không commit** và hỏi user.

### Bước 2 — Kiểm tra safety

Trước khi commit, verify:

- [ ] Không có file `.env`, `.env.local`, `*.pem`, `*.key` trong staged files.
- [ ] Không có `node_modules/`, `vendor/`, `__pycache__/` trong staged files.
- [ ] Không có file chứa hardcoded secrets (scan nhanh với `git diff --staged | grep -i "password\|secret\|api_key\|token" | grep "^+"`).
- [ ] Tests đã pass (nếu chưa chạy → hỏi user có muốn commit không).

Nếu phát hiện vấn đề → **dừng và báo user**, không commit.

### Bước 3 — Generate commit message

Áp dụng format **Conventional Commits**:

```
<type>(<scope>): <subject>

[body — nếu cần giải thích thêm]

[footer — nếu có breaking change hoặc issue reference]
```

**Rules cho subject:**
- Động từ ở hiện tại: `add`, `fix`, `update`, `remove`, `implement`, `refactor`
- Viết thường, không dấu chấm cuối
- Tối đa 72 ký tự
- Tiếng Anh (git history là tài liệu kỹ thuật)

**Rules cho body (optional):**
- Giải thích *tại sao* thay đổi, không phải *làm gì* (code đã nói điều đó)
- Mỗi dòng tối đa 72 ký tự

**Footer (dùng khi):**
- Breaking change: `BREAKING CHANGE: <mô tả>`
- Closes issue: `Closes #123`
- Related to: `Refs #456`

**Ví dụ commit messages:**

```bash
# Feature đơn giản
feat(auth): add JWT refresh token rotation

# Bug fix với context
fix(user): add null check after async getUserById

Previously the function would throw TypeError when user
was not found in Redis cache before DB fallback.

# Feature với breaking change
feat(api)!: change pagination format to cursor-based

BREAKING CHANGE: response now returns `cursor` instead of `page`.
Clients must update to use cursor parameter for next page.

# Test
test(payment): add edge cases for zero-amount transactions

# CI config
ci: add pytest-cov threshold check at 80%
```

### Bước 4 — Thực hiện commit

```bash
git commit -m "<generated message>"
```

Nếu có body/footer:
```bash
git commit -m "<subject>" -m "<body>" -m "<footer>"
```

### Bước 5 — Xác nhận và report

Sau khi commit thành công:

```bash
git log --oneline -3  # hiển thị 3 commits gần nhất để confirm
```

Output report:

```markdown
## ✅ Commit thành công

**Hash:** `abc1234`
**Message:** `feat(auth): add JWT refresh token rotation`
**Files committed:** N files, +X insertions, -Y deletions

**Next steps (chọn 1):**
- Tiếp tục task tiếp theo trong breakdown
- `git push origin <branch>` khi sẵn sàng deploy
- Tạo Pull Request trên GitHub
```

---

## Lưu ý quan trọng

- **KHÔNG `git push`** — chỉ commit local. User tự quyết định push.
- **KHÔNG `git commit --amend`** nếu đã push trước đó.
- **KHÔNG `git commit -m "fix"` hay `wip`** — message phải có ý nghĩa.
- Nếu task quá lớn và cần nhiều commits → mỗi commit = một logical change nhỏ, có thể đứng độc lập.
