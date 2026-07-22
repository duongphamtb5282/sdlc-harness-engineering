#!/usr/bin/env bash
# SessionStart (startup): inject SDLC context, git branch, lifecycle state.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${HOOK_DIR}/.." && pwd)}"
# shellcheck source=lib/common.sh
source "${ROOT}/hooks/lib/common.sh"

PD="$(project_dir)"
BRANCH="$(git -C "$PD" branch --show-current 2>/dev/null || echo unknown)"
RULES_FILE="${ROOT}/hooks/data/compacted-rules.md"

context="## SDLC session bootstrap
- Plugin: sdlc-automation-agent
- Project: ${PD}
- Git branch: ${BRANCH}
- Config: $(test -f "${PD}/.sdlc-automation-agent.yaml" && echo present || echo missing)
"

if [[ -f "$RULES_FILE" ]]; then
  context+="
### Compacted rules (always-on)
$(cat "$RULES_FILE")
"
fi

if [[ -f "${PD}/.sdlc-automation-agent.yaml" ]]; then
  lifecycle="$(python3 "${ROOT}/hooks/lib/scrum_state_machine.py" read "$PD" 2>/dev/null || true)"
  if [[ -z "$lifecycle" || "$lifecycle" == "{}" ]]; then
    lifecycle="$(python3 "${ROOT}/hooks/lib/kanban_state_machine.py" read "$PD" 2>/dev/null || echo '{}')"
  fi
  context+="
### Lifecycle state
\`\`\`json
${lifecycle}
\`\`\`
"
fi

emit_additional_context "$context"
exit 0
