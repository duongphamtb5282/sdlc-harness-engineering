#!/usr/bin/env bash
# UserPromptSubmit: flag likely secrets in user prompts.
set -euo pipefail

input="$(cat)"
prompt="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("prompt",""))' 2>/dev/null || true)"

if [[ -z "$prompt" ]]; then
  exit 0
fi

if printf '%s' "$prompt" | grep -qE '(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,}|-----BEGIN (RSA |OPENSSH )?PRIVATE KEY-----|api[_-]?key\s*[:=]\s*["\x27][^"\x27]{8,})'; then
  escaped="$(printf '%s' "⚠ SDLC hook: prompt may contain secrets. Redact credentials before continuing." | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":%s}}\n' "$escaped"
fi

exit 0
