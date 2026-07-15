#!/usr/bin/env bash
# Shared helpers for SDLC hook scripts.
set -euo pipefail

plugin_root() {
  if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    printf '%s' "$CLAUDE_PLUGIN_ROOT"
    return 0
  fi
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
  printf '%s' "$(cd "${script_dir}/.." && pwd)"
}

project_dir() {
  printf '%s' "${CLAUDE_PROJECT_DIR:-${PWD}}"
}

read_hook_input() {
  cat
}

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

emit_additional_context() {
  local text="$1"
  local escaped
  escaped="$(printf '%s' "$text" | json_escape)"
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$escaped"
}

emit_permission_deny() {
  local user_msg="$1"
  local agent_msg="${2:-$1}"
  local u a
  u="$(printf '%s' "$user_msg" | json_escape)"
  a="$(printf '%s' "$agent_msg" | json_escape)"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s,"additionalContext":%s}}\n' "$u" "$a"
}

emit_stop_context() {
  local text="$1"
  local escaped
  escaped="$(printf '%s' "$text" | json_escape)"
  printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":%s}}\n' "$escaped"
}
