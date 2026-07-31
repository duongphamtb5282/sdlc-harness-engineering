#!/usr/bin/env bash
# ============================================================================
# sync-protocols.sh
# Syncs agent-v01/protocols/ from _shared/protocols/ (canonical source).
#
# The _shared/protocols/ directory under claude-code-production-grade-plugin is
# the authoritative, evolved version with full Rule/Detection/Examples sections.
# agent-v01/protocols/ is a consumer that must stay in sync.
#
# This script copies all protocol files *except* the receipts/ subdirectory,
# which contains methodology-specific state that does not belong in shared.
#
# Usage:
#   ./sync-protocols.sh              # dry-run (shows what would change)
#   ./sync-protocols.sh --apply      # actually copy files
#   ./sync-protocols.sh --check      # exit 1 if any file differs
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROTOCOLS_DIR="$SCRIPT_DIR/protocols"
SHARED_DIR="$SCRIPT_DIR/core-skills/claude-code-production-grade-plugin/skills/_shared/protocols"

# Files to sync (all .md except receipts/ which is local-only)
FILES=(
  boundary-safety.md
  conflict-resolution.md
  freshness-protocol.md
  input-validation.md
  loop-protocol.md
  receipt-protocol.md
  tool-efficiency.md
  ux-protocol.md
  visual-identity.md
)

MODE="${1:-dry-run}"

case "$MODE" in
  --dry-run|dry-run|"")
    echo "━━━ Sync Protocol Files ― dry run ━━━━━━━━━━━━━━━━━━━━━━━━━"
    any_different=false
    for f in "${FILES[@]}"; do
      src="$SHARED_DIR/$f"
      dst="$PROTOCOLS_DIR/$f"
      if [ ! -f "$src" ]; then
        echo "  ⚠  Source missing (will be skipped): $src"
        continue
      fi
      if [ ! -f "$dst" ]; then
        echo "  + Would create: $f"
        any_different=true
      elif ! diff -q "$src" "$dst" >/dev/null 2>&1; then
        echo "  ~ Would update: $f"
        any_different=true
      fi
    done
    if [ "$any_different" = false ]; then
      echo "  ✓ All files already in sync."
    fi
    echo ""
    echo "Run with --apply to apply changes."
    ;;

  --apply|apply)
    echo "━━━ Sync Protocol Files ― applying ━━━━━━━━━━━━━━━━━━━━━━━━"
    for f in "${FILES[@]}"; do
      src="$SHARED_DIR/$f"
      dst="$PROTOCOLS_DIR/$f"
      if [ ! -f "$src" ]; then
        echo "  ⚠  Source missing, skipping: $src"
        continue
      fi
      if [ ! -f "$dst" ]; then
        echo "  + Creating: $f"
      elif ! diff -q "$src" "$dst" >/dev/null 2>&1; then
        echo "  ~ Updating: $f"
      else
        echo "  ✓ Already same: $f"
        continue
      fi
      cp "$src" "$dst"
    done
    echo "━━━ Done ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Local receipts/ directory left untouched."
    ;;

  --check|check)
    exit_code=0
    for f in "${FILES[@]}"; do
      src="$SHARED_DIR/$f"
      dst="$PROTOCOLS_DIR/$f"
      if [ ! -f "$src" ]; then
        echo "  ⚠  Source missing: $src"
        exit_code=1
        continue
      fi
      if [ ! -f "$dst" ]; then
        echo "  ✗ Missing in protocols/: $f"
        exit_code=1
      elif ! diff -q "$src" "$dst" >/dev/null 2>&1; then
        echo "  ✗ Differs: $f"
        exit_code=1
      fi
    done
    if [ "$exit_code" -eq 0 ]; then
      echo "✓ All protocol files are in sync."
    fi
    exit "$exit_code"
    ;;

  *)
    echo "Usage: $0 [--dry-run|--apply|--check]"
    echo "  (default: --dry-run)"
    exit 1
    ;;
esac
