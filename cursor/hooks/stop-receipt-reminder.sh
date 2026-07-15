#!/usr/bin/env bash
# Stop: remind agents to write receipts when SDLC workspace is active.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${HOOK_DIR}/.." && pwd)}"
# shellcheck source=lib/common.sh
source "${ROOT}/hooks/lib/common.sh"

PD="$(project_dir)"
if [[ ! -f "${PD}/.sdlc-automation-agent.yaml" ]]; then
  exit 0
fi

receipts_dir="${PD}/.sdlc-automation-agent/.orchestrator/receipts"
count=0
if [[ -d "$receipts_dir" ]]; then
  count="$(find "$receipts_dir" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l | tr -d ' ')"
fi

msg="## SDLC stop check
Before marking work complete:
1. Write a JSON receipt per receipt-protocol.md
2. Run verification_commands from tech-stack.yaml
3. Receipts in workspace: ${count}

Path: .sdlc-automation-agent/.orchestrator/receipts/{story-id}-{role}.json
"

emit_stop_context "$msg"
exit 0
