#!/usr/bin/env bash
# post-edit-audit.sh
# VS Code Agent Hook — PostToolUse event
# Logs each file edit to the session log

set -euo pipefail

INPUT=$(cat)
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TODAY=$(date +%Y-%m-%d)
SESSION_LOG="$ROOT/.context/sessions/session-$TODAY.md"

# Create session log if it does not exist
if [[ ! -f "$SESSION_LOG" ]]; then
  mkdir -p "$(dirname "$SESSION_LOG")"
  echo "# Session: $TODAY" > "$SESSION_LOG"
  echo "" >> "$SESSION_LOG"
  echo "## Changed Files" >> "$SESSION_LOG"
fi

# Read tool name from input JSON (if jq is available)
if command -v jq &>/dev/null; then
  TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
  FILE=$(echo "$INPUT" | jq -r '.tool_input.filePath // .tool_input.file_path // ""' 2>/dev/null || echo "")
  if [[ -n "$FILE" && "$TOOL" =~ (edit|create|replace|insert) ]]; then
    echo "- \`$FILE\` ($(date +%H:%M:%S))" >> "$SESSION_LOG"
  fi
fi

echo '{}'
