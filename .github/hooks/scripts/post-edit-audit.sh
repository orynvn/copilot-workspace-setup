#!/usr/bin/env bash
# post-edit-audit.sh
# VS Code Agent Hook — PostToolUse event
# Logs each file edit to HISTORY.md (append-only, no session files)

set -euo pipefail

INPUT=$(cat)
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TODAY=$(date +%Y-%m-%d)
HISTORY="$ROOT/.context/HISTORY.md"

# Append edit to HISTORY.md if jq is available and file path is detected
if command -v jq &>/dev/null; then
  TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
  FILE=$(echo "$INPUT" | jq -r '.tool_input.filePath // .tool_input.file_path // ""' 2>/dev/null || echo "")
  if [[ -n "$FILE" && "$TOOL" =~ (edit|create|replace|insert) ]]; then
    # Only append if not already logged in the last 5 lines (avoid duplicate noise)
    LAST=$(tail -5 "$HISTORY" 2>/dev/null || echo "")
    if ! echo "$LAST" | grep -qF "$FILE"; then
      echo "[$TODAY] chore: edited \`$FILE\`" >> "$HISTORY"
    fi
  fi
fi

echo '{}'
