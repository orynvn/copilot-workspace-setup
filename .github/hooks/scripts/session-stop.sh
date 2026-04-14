#!/usr/bin/env bash
# session-stop.sh
# VS Code Agent Hook — Stop event
# Nhắc nhở update .context/HISTORY.md khi session kết thúc

set -euo pipefail

INPUT=$(cat)

# Kiểm tra xem có phải stop_hook_active không (tránh vòng lặp vô tận)
if command -v jq &>/dev/null; then
  ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")
  if [[ "$ACTIVE" == "true" ]]; then
    echo '{}'
    exit 0
  fi
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
HISTORY="$ROOT/.context/HISTORY.md"

# Chỉ nhắc nếu HISTORY.md chưa được cập nhật hôm nay
TODAY=$(date +%Y-%m-%d)
if [[ -f "$HISTORY" ]] && grep -q "^\[$TODAY\]" "$HISTORY" 2>/dev/null; then
  echo '{}'
else
  MSG="Session đã kết thúc. Hãy cập nhật .context/HISTORY.md với những thay đổi trong session này trước khi đóng."
  printf '{"hookSpecificOutput":{"hookEventName":"Stop","decision":"block","reason":"%s"}}' "$MSG"
fi
