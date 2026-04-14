#!/usr/bin/env bash
# check-task-done.sh
# VS Code Agent Hook — UserPromptSubmit event
# Checks whether .context/ is ready before the agent starts

set -euo pipefail

# Read stdin (VS Code hook input JSON)
INPUT=$(cat)

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONTEXT_DIR="$ROOT/.context"

WARNINGS=""

# Check .context exists
if [[ ! -d "$CONTEXT_DIR" ]]; then
  WARNINGS="WARNING: .context/ has not been initialized. Run inject-session-ctx.sh first."
fi

# Check HISTORY.md
if [[ -d "$CONTEXT_DIR" && ! -f "$CONTEXT_DIR/HISTORY.md" ]]; then
  WARNINGS="$WARNINGS\nWARNING: .context/HISTORY.md does not exist."
fi

# Output
if [[ -n "$WARNINGS" ]]; then
  MSG=$(echo -e "$WARNINGS" | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}' | tr -d '\n')
  printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}' "$MSG"
else
  echo '{}'
fi
