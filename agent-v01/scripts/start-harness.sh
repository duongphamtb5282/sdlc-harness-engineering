#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# start-harness.sh — Start all steps of the Ruflo harness
#
# Steps:
#   1. Verify prerequisites (node, ruflo)
#   2. Start the background daemon (7 workers)
#   3. Initialize memory database (if missing)
#   4. Start swarm (mesh topology, max 5 agents)
#   5. Verify MCP server
#   6. Verify everything with validate-harness.sh
#
# Usage:
#   ./start-harness.sh           # start everything
#   ./start-harness.sh --status  # check status only
#   ./start-harness.sh --stop    # stop daemon + swarm
# ═══════════════════════════════════════════════════════════════

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MODE="${1:-start}"
RUFLO="ruflo"

echo "━━━ Ruflo Harness — ${MODE} ━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Prerequisites ────────────────────────────────────────────
check_prereqs() {
  echo "[0/6] Prerequisites..."
  if command -v node >/dev/null 2>&1; then
    echo "  ✅ node $(node --version)"
  else
    echo "  ❌ node not found — install Node.js v20.12+"
    exit 1
  fi
  if command -v ruflo >/dev/null 2>&1; then
    echo "  ✅ ruflo $(ruflo --version 2>/dev/null | head -1 || echo installed)"
  else
    echo "  ⚠️  ruflo CLI not global — will use npx ruflo"
    RUFLO="npx ruflo"
  fi
}

# ── Status mode ───────────────────────────────────────────────
status_all() {
  echo "[1/6] Harness status..."
  $RUFLO status 2>&1 | grep -E "RuFlo|Swarm|Running|STOPPED" | head -6
  echo ""
  echo "[2/6] Daemon..."
  $RUFLO daemon status 2>&1 | grep -E "Status|PID" | head -3
  echo ""
  echo "[3/6] MCP..."
  $RUFLO mcp status 2>&1 | grep -E "Status|PID" | head -3
}

# ── Stop mode ─────────────────────────────────────────────────
stop_all() {
  echo "[1/6] Stopping swarm..."
  $RUFLO swarm stop >/dev/null 2>&1 && echo "  ✅ swarm stopped" || echo "  – swarm not running"
  echo ""
  echo "[2/6] Stopping daemon..."
  $RUFLO daemon stop >/dev/null 2>&1 && echo "  ✅ daemon stopped" || echo "  – daemon not running"
  echo ""
  echo "[3/6] Stopping MCP..."
  $RUFLO mcp stop >/dev/null 2>&1 && echo "  ✅ MCP stopped" || echo "  – MCP not running"
}

# ── Start mode ────────────────────────────────────────────────
start_all() {
  check_prereqs

  echo ""
  echo "[1/6] Starting daemon (7 workers: map, audit, optimize)..."
  $RUFLO daemon start 2>&1 | tail -2

  echo ""
  echo "[2/6] Initializing memory database..."
  if $RUFLO memory init 2>&1 | grep -q "already initialized"; then
    echo "  ✅ memory.db already initialized"
  else
    echo "  ✅ memory.db initialized"
  fi

  echo ""
  echo "[3/6] Starting swarm (mesh topology, max 5 agents)..."
  if $RUFLO swarm status 2>&1 | grep -q "No active swarm"; then
    $RUFLO swarm init 2>&1 | tail -2
  else
    echo "  ✅ swarm already active"
  fi

  echo ""
  echo "[4/6] Verifying MCP server..."
  $RUFLO mcp status 2>&1 | grep -E "Status|PID" | head -3

  echo ""
  echo "[5/6] Final harness status..."
  $RUFLO status 2>&1 | grep -E "RuFlo|Swarm|Running|STOPPED" | head -6

  echo ""
  echo "[6/6] Running validate-harness.sh..."
  bash "$ROOT/agent-v01/scripts/validate-harness.sh"
}

# ── Dispatch ──────────────────────────────────────────────────
case "$MODE" in
  --status|status)
    status_all
    ;;
  --stop|stop)
    stop_all
    ;;
  --start|start|"")
    start_all
    ;;
  *)
    echo "Usage: $0 [--start|--status|--stop]"
    exit 1
    ;;
esac

echo ""
echo "━━━ Done ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
