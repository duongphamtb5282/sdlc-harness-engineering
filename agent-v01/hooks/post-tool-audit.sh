#!/usr/bin/env bash
# PostToolUse (Edit/Write): append lightweight audit log in product workspace.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${HOOK_DIR}/.." && pwd)}"
# shellcheck source=lib/common.sh
source "${ROOT}/hooks/lib/common.sh"

PD="$(project_dir)"
LOG_DIR="${PD}/.sdlc-automation-agent/.orchestrator/audit"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/file-edits.log"

input="$(read_hook_input)"
tool="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null || echo unknown)"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

printf '%s tool=%s\n' "$ts" "$tool" >> "$LOG_FILE"
exit 0
