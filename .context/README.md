# .context — Hướng dẫn sử dụng

Thư mục `.context/` là **memory** của dự án dành cho Copilot agents. Mọi quyết định, lịch sử thay đổi, lỗi đã gặp và test cases đều được lưu tại đây.

## Cấu trúc

```
.context/
├── README.md          # File này — hướng dẫn sử dụng
├── HISTORY.md         # Chronological log mọi thay đổi
├── DECISIONS.md       # Index các architectural decisions (ADR)
├── ERRORS.md          # Index lỗi đã gặp & cách fix
├── log.sh             # Script log nhanh vào HISTORY.md
├── decisions/         # Chi tiết từng ADR: ADR-NNN-<slug>.md
├── errors/            # Chi tiết từng error report
├── sessions/          # Session logs theo ngày: session-YYYY-MM-DD.md
└── test-cases/        # Test case specs: TC-MODULE-spec.md
```

## Quy trình sử dụng

### Đầu mỗi session

Copilot sẽ tự động đọc:
1. `HISTORY.md` — 10 entries gần nhất
2. `DECISIONS.md` — tất cả decisions đang `Accepted`
3. `ERRORS.md` — open errors cần tránh

Hoặc chạy script: `source .context/inject-session-ctx.sh`

### Cuối mỗi session

Chạy prompt `update-context` — Copilot sẽ tự động cập nhật tất cả files.

## Lệnh nhanh

```bash
# Log nhanh một thay đổi
./.context/log.sh "feat: User auth module — AuthController.php"

# Xem 20 entries gần nhất
tail -20 .context/HISTORY.md

# Tìm decision theo keyword
grep -i "database" .context/DECISIONS.md

# Xem open errors
awk '/^## Open/,/^## Resolved/' .context/ERRORS.md
```

## Khi clone repo mới

```bash
# Copy toàn bộ .context/ vào project mới (reset history)
cp -r .context/ /path/to/new-project/

# Xóa history cũ, giữ structure
echo "# Project History" > /path/to/new-project/.context/HISTORY.md
echo "# Architectural Decisions" > /path/to/new-project/.context/DECISIONS.md
echo "# Known Errors" > /path/to/new-project/.context/ERRORS.md
```

## Không commit vào git (tùy chọn)

Nếu không muốn track context trong git, thêm vào `.gitignore`:
```
.context/sessions/
.context/test-cases/
```

Nhưng **nên commit** `HISTORY.md`, `DECISIONS.md`, `ERRORS.md` để team share context.
