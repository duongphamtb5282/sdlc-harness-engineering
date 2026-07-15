#!/usr/bin/env bash
# Maintainer pipeline for Claude Code runtime (does not modify cursor/).
# Usage: ./scripts/sync-all.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== sync-from-new-skills ==="
"${ROOT}/scripts/sync-from-new-skills.sh"

echo ""
echo "=== materialize-symlinks ==="
"${ROOT}/scripts/materialize-symlinks.sh"

echo ""
echo "=== sync-claude-agents-stubs ==="
"${ROOT}/scripts/sync-claude-agents-stubs.sh"

echo ""
echo "=== validate-skills-frontmatter ==="
"${ROOT}/scripts/validate-skills-frontmatter.sh"

echo ""
echo "=== validate-hooks ==="
"${ROOT}/scripts/validate-hooks.sh"

echo ""
echo "Claude Code sync complete (cursor/ untouched — run scripts/sync-to-cursor.sh for Cursor kit)."

# Propagate stack-spring to seat-reservation when present
if [[ -d "${ROOT}/../seat-reservation" ]]; then
  echo ""
  echo "=== sync-stack-spring (seat-reservation) ==="
  "${ROOT}/scripts/sync-stack-spring.sh"
fi
