#!/usr/bin/env bash
# Smoke-test hooks/lib Python CLIs and hook script syntax.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export CLAUDE_PLUGIN_ROOT="$ROOT"
export CLAUDE_PROJECT_DIR="$TMP"

mkdir -p "${TMP}/.sdlc-automation-agent/.orchestrator/receipts"
cat > "${TMP}/.sdlc-automation-agent.yaml" <<EOF
project:
  name: hook-test
build_mode: scrum
EOF

echo "Testing scrum_state_machine..."
python3 "${ROOT}/hooks/lib/scrum_state_machine.py" init "$TMP" >/dev/null
python3 "${ROOT}/hooks/lib/scrum_state_machine.py" transition "$TMP" SPRINT_PLANNING >/dev/null
python3 "${ROOT}/hooks/lib/scrum_state_machine.py" read "$TMP" | grep -q SPRINT_PLANNING

echo "Testing kanban_state_machine..."
python3 "${ROOT}/hooks/lib/kanban_state_machine.py" init "$TMP" >/dev/null
python3 "${ROOT}/hooks/lib/kanban_state_machine.py" transition "$TMP" READY >/dev/null

echo "Testing story_pipeline..."
python3 "${ROOT}/hooks/lib/story_pipeline.py" transition "$TMP" US-001 in_progress >/dev/null
python3 "${ROOT}/hooks/lib/story_pipeline.py" list_stories "$TMP" in_progress | grep -q US-001

echo "Testing receipt_validator..."
cat > "${TMP}/.sdlc-automation-agent/.orchestrator/receipts/US-001-se.json" <<EOF
{
  "story_id": "US-001",
  "role": "software-engineer",
  "artifacts": [".sdlc-automation-agent.yaml"],
  "metrics": {"files_changed": 1},
  "verification_commands": ["test -f .sdlc-automation-agent.yaml"],
  "completed_at": "2026-07-10T12:00:00Z"
}
EOF
python3 "${ROOT}/hooks/lib/receipt_validator.py" \
  "${TMP}/.sdlc-automation-agent/.orchestrator/receipts/US-001-se.json" "$TMP" | grep -q '"valid": true'

echo "Testing update_claude_md..."
printf '%s\n' '## SDLC' | python3 "${ROOT}/hooks/lib/update_claude_md.py" "$TMP" >/dev/null
grep -q 'sdlc-automation-agent:begin' "${TMP}/CLAUDE.md"

echo "Testing hooks.json..."
python3 -c "import json; json.load(open('${ROOT}/hooks/hooks.json'))"

for script in "${ROOT}"/hooks/*.sh; do
  bash -n "$script"
done

echo "OK: hooks smoke test passed"
