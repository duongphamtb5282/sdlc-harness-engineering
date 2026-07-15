#!/usr/bin/env bash
# Refresh this Cursor project from the parent agents monorepo (excludes new-skills + Claude-only).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(cd "$HERE/.." && pwd)"
if [[ ! -d "$PARENT/agents" || ! -d "$PARENT/plugins" ]]; then
  echo "Expected parent agents monorepo at $PARENT" >&2
  exit 1
fi
rsync -a --delete \
  --exclude 'new-skills/' \
  --exclude 'cursor/' \
  --exclude '.claude-plugin/' \
  --exclude 'claude-agents/' \
  --exclude 'scripts/' \
  --exclude 'overlays/' \
  --exclude '.DS_Store' \
  --exclude '.git/' \
  --exclude 'node_modules/' \
  --exclude 'AGENTS.md' \
  --exclude 'README.md' \
  --exclude '.gitignore' \
  --exclude '.cursor/' \
  --exclude '.cursorignore' \
  "$PARENT/" "$HERE/"
echo "Mirrored content. Re-run Cursor skill/rule wiring if needed (see README)."
