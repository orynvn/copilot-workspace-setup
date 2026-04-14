#!/usr/bin/env bash
# inject-session-ctx.sh
# VS Code Agent Hook — SessionStart event
# Reads .context/ and injects it into the conversation via additionalContext
# Docs: https://code.visualstudio.com/docs/copilot/customization/hooks

set -euo pipefail

# Read stdin (VS Code hook input JSON)
INPUT=$(cat)

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONTEXT_DIR="$ROOT/.context"

# Initialize .context/ if it does not exist
if [[ ! -d "$CONTEXT_DIR" ]]; then
  mkdir -p "$CONTEXT_DIR"/{decisions,errors,sessions,test-cases}
  touch "$CONTEXT_DIR/HISTORY.md" "$CONTEXT_DIR/DECISIONS.md" "$CONTEXT_DIR/ERRORS.md"
fi

# Collect context
HISTORY=$(tail -15 "$CONTEXT_DIR/HISTORY.md" 2>/dev/null || echo "(no history)")
OPEN_ERRORS=$(grep "^###" "$CONTEXT_DIR/ERRORS.md" 2>/dev/null | head -5 || echo "(no open errors)")
LAST_DECISION=$(tail -5 "$CONTEXT_DIR/DECISIONS.md" 2>/dev/null || echo "(no decisions)")

# Build context message
CTX="=== PROJECT CONTEXT ===
[HISTORY - last 15 entries]
$HISTORY

[OPEN ERRORS]
$OPEN_ERRORS

[RECENT DECISIONS]
$LAST_DECISION
=== END CONTEXT ==="

# Escape for JSON
CTX_ESCAPED=$(echo "$CTX" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}' | tr -d '\n')

# Output VS Code hook JSON with additionalContext
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$CTX_ESCAPED"
