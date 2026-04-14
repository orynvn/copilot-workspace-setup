#!/usr/bin/env bash
# post-edit-audit.sh
# VS Code Agent Hook — PostToolUse event
# Ghi log mỗi file edit vào session log

set -euo pipefail

INPUT=$(cat)
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TODAY=$(date +%Y-%m-%d)
SESSION_LOG="$ROOT/.context/sessions/session-$TODAY.md"

# Tạo session log nếu chưa có
if [[ ! -f "$SESSION_LOG" ]]; then
  mkdir -p "$(dirname "$SESSION_LOG")"
  echo "# Session: $TODAY" > "$SESSION_LOG"
  echo "" >> "$SESSION_LOG"
  echo "## Changed Files" >> "$SESSION_LOG"
fi

# Đọc tool name từ input JSON (nếu có jq)
if command -v jq &>/dev/null; then
  TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
  FILE=$(echo "$INPUT" | jq -r '.tool_input.filePath // .tool_input.file_path // ""' 2>/dev/null || echo "")
  if [[ -n "$FILE" && "$TOOL" =~ (edit|create|replace|insert) ]]; then
    echo "- \`$FILE\` ($(date +%H:%M:%S))" >> "$SESSION_LOG"
  fi
fi

echo '{}'
