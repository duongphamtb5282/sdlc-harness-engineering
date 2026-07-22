#!/usr/bin/env bash
# Cost Controller Hook — classifies task complexity, gates model switches, checks budget
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "${HOOK_DIR}/../.." && pwd)}"

TASK_DESCRIPTION="${CLAUDE_PROMPT:-$*}"
COMPLEX_SIGNALS=("architecture" "design" "migrate" "strategy" "security" "performance" "scale" "multi-service" "cross-cutting" "trade-off" "decision" "evaluate" "compare" "alternative")

signal_count=0
for signal in "${COMPLEX_SIGNALS[@]}"; do
  if echo "$TASK_DESCRIPTION" | grep -qi "$signal"; then
    ((signal_count++))
  fi
done

word_count=$(echo "$TASK_DESCRIPTION" | wc -w | tr -d ' ')

if [ "$signal_count" -eq 0 ] && [ "$word_count" -lt 20 ]; then
  TIER="S1-S2"
  MODEL="claude-haiku"
elif [ "$signal_count" -le 2 ]; then
  TIER="S3"
  MODEL="claude-sonnet"
else
  TIER="S4-S5"
  MODEL="claude-opus"
fi

echo "cost_controller: classified as $TIER (signals=$signal_count, words=$word_count)"
echo "cost_controller: recommended model=$MODEL"

# Check budget limits
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_FILE="${PROJECT_DIR}/.sdlc-automation-agent/.orchestrator/cost-state.json"

if [ -f "$STATE_FILE" ]; then
  # Parse budget state with python
  PYTHON_OUT=$(python3 -c "
import json
try:
    with open('$STATE_FILE') as f:
        state = json.load(f)
    daily = state.get('daily', {}).get('spent', 0)
    total = state.get('total_spent', 0)
    print(f'DAILY_SPENT={daily:.2f}')
    print(f'TOTAL_SPENT={total:.2f}')
except:
    print('DAILY_SPENT=0')
    print('TOTAL_SPENT=0')
" 2>/dev/null || echo -e "DAILY_SPENT=0\nTOTAL_SPENT=0")

  eval "$PYTHON_OUT"

  # Warn at thresholds (10 daily, 50 hard stop defaults)
  if (( $(echo "$DAILY_SPENT >= 50" | bc -l 2>/dev/null || echo 0) )); then
    echo "cost_controller: 🔴 HARD STOP — daily spending limit exceeded (\$${DAILY_SPENT})"
    exit 1
  elif (( $(echo "$DAILY_SPENT >= 10" | bc -l 2>/dev/null || echo 0) )); then
    echo "cost_controller: ⚠ Daily budget reached (\$${DAILY_SPENT}) — premium tasks blocked"
  elif (( $(echo "$DAILY_SPENT >= 8" | bc -l 2>/dev/null || echo 0) )); then
    echo "cost_controller: ⚠ Daily budget at 80% (\$${DAILY_SPENT}/\$10) — approaching limit"
  fi
fi

if [ "$TIER" = "S4-S5" ]; then
  echo "cost_controller: ⚠ Premium model required — user gate must fire"
fi

exit 0
