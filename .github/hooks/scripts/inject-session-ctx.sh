#!/usr/bin/env bash
# inject-session-ctx.sh
# VS Code Agent Hook — SessionStart event
# Đọc .context/ và inject vào conversation qua additionalContext
# Docs: https://code.visualstudio.com/docs/copilot/customization/hooks

set -euo pipefail

# Đọc stdin (VS Code hook input JSON)
INPUT=$(cat)

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONTEXT_DIR="$ROOT/.context"

# Khởi tạo .context/ nếu chưa có
if [[ ! -d "$CONTEXT_DIR" ]]; then
  mkdir -p "$CONTEXT_DIR"/{decisions,errors,sessions,test-cases}
  touch "$CONTEXT_DIR/HISTORY.md" "$CONTEXT_DIR/DECISIONS.md" "$CONTEXT_DIR/ERRORS.md"
fi

# Thu thập context
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

# Escape cho JSON
CTX_ESCAPED=$(echo "$CTX" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | awk '{printf "%s\\n", $0}' | tr -d '\n')

# Output VS Code hook JSON với additionalContext
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$CTX_ESCAPED"
