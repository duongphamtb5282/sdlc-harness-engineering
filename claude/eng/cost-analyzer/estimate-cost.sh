#!/usr/bin/env bash
# Cost Analyzer — estimates workflow cost based on model tiers
set -euo pipefail

WORKFLOW_FILE="${1:-workflows/default.yaml}"

if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "Workflow file not found: $WORKFLOW_FILE"
  exit 1
fi

echo "━━━ Cost Estimate ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Cost per 1K tokens by tier (approximate)
declare -A COST_PER_TIER
COST_PER_TIER[fast]="0.15-0.25"
COST_PER_TIER[standard]="1.50-3.00"
COST_PER_TIER[premium]="7.50-15.00"

# Average tokens per stage by tier
declare -A TOKENS_PER_STAGE
TOKENS_PER_STAGE[fast]="5000"
TOKENS_PER_STAGE[standard]="15000"
TOKENS_PER_STAGE[premium]="30000"

TOTAL_MIN=0
TOTAL_MAX=0
STAGES=0

while IFS= read -r line; do
  if echo "$line" | grep -q "model_tier:"; then
    tier=$(echo "$line" | awk '{print $2}')
    tokens="${TOKENS_PER_STAGE[$tier]:-10000}"

    cost_range="${COST_PER_TIER[$tier]:-0-0}"
    min=$(echo "$cost_range" | cut -d- -f1)
    max=$(echo "$cost_range" | cut -d- -f2)

    stage_min=$(echo "$tokens * $min / 1000" | bc -l 2>/dev/null || echo "0.00")
    stage_max=$(echo "$tokens * $max / 1000" | bc -l 2>/dev/null || echo "0.00")

    echo "  Stage $((++STAGES)) ($tier): \$$stage_min-$stage_max"
    TOTAL_MIN=$(echo "$TOTAL_MIN + $stage_min" | bc -l 2>/dev/null || echo "0")
    TOTAL_MAX=$(echo "$TOTAL_MAX + $stage_max" | bc -l 2>/dev/null || echo "0")
  fi
done < <(grep "model_tier:" "$WORKFLOW_FILE")

echo ""
echo "━━━ Total ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Estimated range: \$$TOTAL_MIN-$TOTAL_MAX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
