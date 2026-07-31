#!/usr/bin/env bash
# Smoke-test agent-v01/hooks — validate JSON, referenced scripts, and syntax.
# Usage: ./agent-v01/validate-hooks.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HOOKS_DIR="${ROOT}/agent-v01/hooks"
FAILURES=0

echo "━━━ agent-v01 Hooks Validation ━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. hooks.json is valid JSON ──────────────────────────────
echo "[1/4] hooks.json..."
if python3 -c "import json; json.load(open('${HOOKS_DIR}/hooks.json'))" 2>/dev/null; then
  echo "  ✅ hooks.json valid JSON"
else
  echo "  ❌ hooks.json invalid"
  FAILURES=$((FAILURES+1))
fi

# ── 2. Every script referenced in hooks.json exists ───────────
echo ""
echo "[2/4] Referenced hook scripts..."
MISSING=0
for ref in $(grep -oE "hooks/[a-z_-]+\.(sh|py)" "${HOOKS_DIR}/hooks.json" | sort -u); do
  script="${HOOKS_DIR}/$(basename "$ref")"
  if [ -f "$script" ]; then
    echo "  ✅ $(basename "$ref")"
  else
    echo "  ❌ $(basename "$ref") MISSING"
    MISSING=1
  fi
done
[ $MISSING -eq 0 ] || FAILURES=$((FAILURES+1))

# ── 3. Syntax check all hook scripts ──────────────────────────
echo ""
echo "[3/4] Script syntax..."
SYNTAX_FAIL=0
for script in "${HOOKS_DIR}"/*.sh; do
  [[ -f "$script" ]] || continue
  if bash -n "$script" 2>/dev/null; then
    echo "  ✅ $(basename "$script")"
  else
    echo "  ❌ $(basename "$script") syntax error"
    SYNTAX_FAIL=1
  fi
done
[ $SYNTAX_FAIL -eq 0 ] || FAILURES=$((FAILURES+1))

# ── 4. Plugin root convention (hooks use ${CLAUDE_PLUGIN_ROOT}) ─
echo ""
echo "[4/4] Plugin-root convention..."
if grep -q "CLAUDE_PLUGIN_ROOT" "${HOOKS_DIR}/hooks.json"; then
  echo "  ✅ hooks.json uses CLAUDE_PLUGIN_ROOT convention"
else
  echo "  ⚠️  hooks.json does not reference CLAUDE_PLUGIN_ROOT — verify path resolution"
fi

echo ""
echo "━━━ Result: $FAILURES failure(s) ━━━━━━━━━━━━━━━━━━━━━━━"
exit $FAILURES
