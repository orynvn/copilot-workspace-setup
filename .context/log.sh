#!/usr/bin/env bash
# log.sh — Quick log script for .context/HISTORY.md
# Usage: ./log.sh "feat: User auth module — AuthController.php"
# or: ./log.sh feat "User auth module" "AuthController.php"

set -euo pipefail

CONTEXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HISTORY_FILE="$CONTEXT_DIR/HISTORY.md"
DATE=$(date +%Y-%m-%d)

# Parse arguments
if [[ $# -eq 0 ]]; then
  echo "Usage: ./log.sh \"<type>: <description> — <file>\""
  echo "       ./log.sh <type> <description> <file>"
  echo ""
  echo "Types: feat | fix | refactor | test | docs | chore | decision | migration | perf"
  echo ""
  echo "Examples:"
  echo "  ./log.sh \"feat: User auth module — AuthController.php\""
  echo "  ./log.sh feat \"User auth module\" \"AuthController.php\""
  exit 1
fi

if [[ $# -eq 1 ]]; then
  # Single argument: "type: description — file"
  LOG_ENTRY="[${DATE}] $1"
elif [[ $# -eq 3 ]]; then
  # Three arguments: type description file
  LOG_ENTRY="[${DATE}] $1: $2 — $3"
else
  echo "❌ Invalid arguments. Use 1 or 3 arguments."
  exit 1
fi

# Append to HISTORY.md
echo "$LOG_ENTRY" >> "$HISTORY_FILE"
echo "✅ Logged: $LOG_ENTRY"
