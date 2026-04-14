#!/usr/bin/env bash
# check-task-done.sh
# VS Code Agent Hook — UserPromptSubmit event
# Kiểm tra xem .context/ có sẵn sàng không trước khi agent bắt đầu

set -euo pipefail

# Đọc stdin (VS Code hook input JSON)
INPUT=$(cat)

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONTEXT_DIR="$ROOT/.context"

WARNINGS=""

# Check .context tồn tại
if [[ ! -d "$CONTEXT_DIR" ]]; then
  WARNINGS="WARNING: .context/ chưa được khởi tạo. Chạy inject-session-ctx.sh trước."
fi

# Check HISTORY.md
if [[ -d "$CONTEXT_DIR" && ! -f "$CONTEXT_DIR/HISTORY.md" ]]; then
  WARNINGS="$WARNINGS\nWARNING: .context/HISTORY.md không tồn tại."
fi

# Output
if [[ -n "$WARNINGS" ]]; then
  MSG=$(echo -e "$WARNINGS" | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}' | tr -d '\n')
  printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}' "$MSG"
else
  echo '{}'
fi
