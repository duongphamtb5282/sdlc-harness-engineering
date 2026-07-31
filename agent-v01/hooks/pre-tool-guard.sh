#!/usr/bin/env bash
# PreToolUse (Bash): block destructive or production-risk commands.
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${HOOK_DIR}/.." && pwd)}"
# shellcheck source=lib/common.sh
source "${ROOT}/hooks/lib/common.sh"

input="$(read_hook_input)"
command="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("command","") if isinstance(d.get("tool_input"),dict) else d.get("command",""))' 2>/dev/null || true)"

if [[ -z "$command" ]]; then
  exit 0
fi

deny_patterns=(
  'git push.*--force'
  'git push -f'
  'terraform apply.*-auto-approve'
  'kubectl delete '
  'DROP TABLE'
  'DROP DATABASE'
  'rm -rf /'
  'npm publish'
  'pnpm publish'
)

for pattern in "${deny_patterns[@]}"; do
  if [[ "$command" =~ $pattern ]]; then
    emit_permission_deny \
      "Blocked by SDLC hook: command matches risky pattern (${pattern})." \
      "This command was denied by pre-tool-guard.sh. Ask the user for explicit approval or use a safer alternative."
    exit 0
  fi
done

# Warn on prod deploy patterns (allow but inject context via deny ask - Claude uses ask if supported)
if [[ "$command" =~ (deploy.*prod|production.*deploy|aws.*--profile.*prod) ]]; then
  emit_permission_deny \
    "Production deploy detected — requires human gate per SDLC policy." \
    "Stop and confirm with the user before running production deployment commands."
  exit 0
fi

exit 0
