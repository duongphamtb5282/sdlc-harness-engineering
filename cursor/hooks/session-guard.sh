#!/usr/bin/env bash
# SessionStart (compact): re-inject critical rules after context compaction.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${HOOK_DIR}/.." && pwd)}"
# shellcheck source=lib/common.sh
source "${ROOT}/hooks/lib/common.sh"

RULES_FILE="${ROOT}/hooks/data/compacted-rules.md"
if [[ ! -f "$RULES_FILE" ]]; then
  exit 0
fi

context="## Post-compaction re-anchor
Context was compacted. Re-apply these SDLC rules before continuing:

$(cat "$RULES_FILE")
"

emit_additional_context "$context"
exit 0
