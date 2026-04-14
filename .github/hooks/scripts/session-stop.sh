#!/usr/bin/env bash
# session-stop.sh
# VS Code Agent Hook — Stop event
# Reminds user to update .context/HISTORY.md when the session ends

set -euo pipefail

INPUT=$(cat)

# Check if stop_hook_active to avoid infinite loops
if command -v jq &>/dev/null; then
  ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null || echo "false")
  if [[ "$ACTIVE" == "true" ]]; then
    echo '{}'
    exit 0
  fi
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
HISTORY="$ROOT/.context/HISTORY.md"

# Only remind if HISTORY.md has not been updated today
TODAY=$(date +%Y-%m-%d)
if [[ -f "$HISTORY" ]] && grep -q "^\[$TODAY\]" "$HISTORY" 2>/dev/null; then
  echo '{}'
else
  MSG="Session ended. Please update .context/HISTORY.md with the changes from this session before closing."
  printf '{"hookSpecificOutput":{"hookEventName":"Stop","decision":"block","reason":"%s"}}' "$MSG"
fi
