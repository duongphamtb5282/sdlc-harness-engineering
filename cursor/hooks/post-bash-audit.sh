#!/usr/bin/env bash
# PostToolUse (Bash): log shell commands for audit trail.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${HOOK_DIR}/.." && pwd)}"
# shellcheck source=lib/common.sh
source "${ROOT}/hooks/lib/common.sh"

PD="$(project_dir)"
LOG_DIR="${PD}/.sdlc-automation-agent/.orchestrator/audit"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/shell.log"

input="$(read_hook_input)"
command="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); ti=d.get("tool_input",{}); print(ti.get("command","") if isinstance(ti,dict) else "")' 2>/dev/null || true)"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

printf '%s %s\n' "$ts" "${command:-<empty>}" >> "$LOG_FILE"
exit 0
