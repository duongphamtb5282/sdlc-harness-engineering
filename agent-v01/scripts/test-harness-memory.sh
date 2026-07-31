#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# test-harness-memory.sh — Verify Ruflo cross-session memory
#
# Proves: data written to memory survives a full harness restart
# (the equivalent of exiting and re-entering a Claude session).
#
# NOTE (Intel Mac): ruflo uses a sql.js fallback when better-sqlite3
# native is absent. The daemon opens the DB natively (WAL mode), and
# the read command auto-starts a daemon — so every memory op must
# ensure no daemon is alive first. This script handles that race
# with pkill + retry.
#
# Usage: ./agent-v01/test-harness-memory.sh
# ═══════════════════════════════════════════════════════════════

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

TEST_KEY="harness-test-$(date +%s)"
TEST_VALUE="persistence-verified-$(date +%s)"
RUFLO="ruflo"
# THE PROVEN PATTERN (Intel Mac + sql.js fallback):
#   CLAUDE_FLOW_DAEMON=0 prevents the op from racing a fresh daemon start
#   CLAUDE_FLOW_MEMORY_BACKEND=better-sqlite3 makes reads use the native
#     reader, which handles the WAL-mode DB that the daemon leaves behind
export CLAUDE_FLOW_DAEMON=0
export CLAUDE_FLOW_MEMORY_BACKEND=better-sqlite3

echo "━━━ Ruflo Cross-Session Memory Test ━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Helper: kill ALL daemons + drop WAL (race-free baseline) ──
# NOTE: sleep 3 is critical — the daemon releases the DB at variable
# speed, and WAL sidecars must be absent for the sql.js fallback read.
kill_daemons() {
  pkill -f "claude-flow.*daemon" 2>/dev/null
  sleep 3
  rm -f .swarm/memory.db-wal .swarm/memory.db-shm
}

# ── Helper: run a memory op with daemon race handling ──────────
# Pattern: pkill daemons → sleep 3 → rm WAL → op (with both env vars).
# Retry up to 8x — the daemon release timing is nondeterministic.
mem_op() {
  # $1 = op (store|get), rest = args
  # Store: succeeds even with daemon race (auto-start AFTER op). Success
  #   is detected by "[OK]" anywhere in full output.
  # Get: needs daemon dead + WAL cleared (the sql.js fallback refuses
  #   WAL-mode DBs). Retry until the value comes back or 8 attempts.
  local op="$1"; shift
  local result=""
  for attempt in 1 2 3 4 5 6 7 8; do
    kill_daemons
    result=$($RUFLO memory "$op" "$@" 2>&1 | grep -vE "INFO|DEBUG|Transformers|^\[WARN\]")
    if [[ "$op" == "store" ]] && echo "$result" | grep -qF "[OK]"; then
      echo "$result"
      return 0
    fi
    if [[ "$op" == "get" ]]; then
      # get success = the value line (no WAL/ERROR/not-found)
      if ! echo "$result" | grep -qE "WAL|ERROR|not found"; then
        echo "$result"
        return 0
      fi
    fi
    sleep 3
  done
  echo "$result"
  return 1
}

echo "[1/4] Storing test value..."
STORE_OUT=$(mem_op store -k "$TEST_KEY" -v "$TEST_VALUE")
if echo "$STORE_OUT" | grep -qF "[OK]"; then
  echo "  ✅ Stored: $TEST_KEY = $TEST_VALUE"
else
  echo "  ❌ Store failed:"
  echo "$STORE_OUT"
  kill_daemons
  exit 1
fi

echo ""
echo "[2/4] Restarting harness (simulates session exit + re-entry)..."
kill_daemons
echo "  ✅ all daemons stopped — memory now only on disk (.swarm/memory.db)"

echo ""
echo "[3/4] Retrieving in the 'new session'..."
RETRIEVED=$(mem_op get -k "$TEST_KEY" --value-only | grep -vE "^\+|^\|" | head -1)

echo ""
echo "[4/4] Verdict:"
if [ "$RETRIEVED" = "$TEST_VALUE" ]; then
  echo "  ✅ PASS — memory preserved across session boundary"
  echo "     key:   $TEST_KEY"
  echo "     value: $RETRIEVED"
  echo ""
  echo "  → Cross-session memory WORKS. Any future session can"
  echo "    run: ruflo memory get -k $TEST_KEY"
  PASS=0
else
  echo "  ❌ FAIL — retrieved: '${RETRIEVED:-empty}' (expected '$TEST_VALUE')"
  PASS=1
fi

# Cleanup test key
mem_op store -k "$TEST_KEY" -v "" --no-upsert >/dev/null 2>&1 || true

echo ""
echo "━━━ Result: $([ $PASS -eq 0 ] && echo PASS || echo FAIL) ━━━━━━━━━━━━━━━━━━━"
exit $PASS
