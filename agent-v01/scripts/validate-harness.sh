#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# validate-harness.sh — Verifies the Ruflo execution harness
# Checks: daemon, MCP, memory, config, .gitignore hygiene
# Usage: ./validate-harness.sh
# ═══════════════════════════════════════════════════════════════

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FAILURES=0

echo "━━━ Ruflo Harness Validation ━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. Daemon ────────────────────────────────────────────────
echo "[1/6] Daemon..."
if [ -d "$ROOT/.claude-flow" ]; then
  echo "  ✅ .claude-flow/ present"
else
  echo "  ❌ .claude-flow/ missing — run: npx ruflo init --minimal"
  FAILURES=$((FAILURES+1))
fi

# ── 2. Config ────────────────────────────────────────────────
echo ""
echo "[2/6] Config..."
if [ -f "$ROOT/.claude-flow/config.yaml" ]; then
  echo "  ✅ config.yaml present"
else
  echo "  ❌ config.yaml missing"
  FAILURES=$((FAILURES+1))
fi

# ── 3. Memory DB ─────────────────────────────────────────────
echo ""
echo "[3/6] Memory database..."
if [ -f "$ROOT/.swarm/memory.db" ]; then
  echo "  ✅ .swarm/memory.db present ($(du -sh "$ROOT/.swarm/memory.db" | cut -f1))"
else
  echo "  ⚠️  memory.db missing — run: ruflo memory init"
  FAILURES=$((FAILURES+1))
fi

# ── 4. MCP ───────────────────────────────────────────────────
echo ""
echo "[4/6] MCP server..."
if [ -f "$ROOT/.mcp.json" ]; then
  echo "  ✅ .mcp.json present"
  grep -q "claude-flow" "$ROOT/.mcp.json" && echo "  ✅ claude-flow MCP registered" || echo "  ⚠️  claude-flow not in .mcp.json"
else
  echo "  ❌ .mcp.json missing"
  FAILURES=$((FAILURES+1))
fi

# ── 5. Skills + helpers ──────────────────────────────────────
echo ""
echo "[5/6] Skills & helpers..."
if [ -d "$ROOT/.agents/skills/ruflo" ]; then
  echo "  ✅ .agents/skills/ruflo present"
else
  echo "  ⚠️  ruflo skill not materialized"
fi

# ── 6. Git hygiene (runtime state not committed) ─────────────
echo ""
echo "[6/6] Git hygiene..."
if grep -q ".claude-flow" "$ROOT/.gitignore" 2>/dev/null; then
  echo "  ✅ .claude-flow/ in .gitignore"
else
  echo "  ⚠️  .claude-flow/ NOT in .gitignore"
  FAILURES=$((FAILURES+1))
fi
if grep -q ".swarm" "$ROOT/.gitignore" 2>/dev/null; then
  echo "  ✅ .swarm/ in .gitignore"
else
  echo "  ⚠️  .swarm/ NOT in .gitignore — memory.db should not be committed"
  FAILURES=$((FAILURES+1))
fi

echo ""
echo "━━━ Result: $FAILURES failure(s) ━━━━━━━━━━━━━━━━━━━━━━━"
exit $FAILURES
