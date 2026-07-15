#!/usr/bin/env bash
# Refresh cursor/ kit from parent monorepo and propagate stack skills (file copies, no symlinks).
#
# Usage:
#   ./scripts/sync-to-cursor.sh
#   ./scripts/sync-to-cursor.sh /path/to/seat-reservation
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SR="${1:-${ROOT}/../seat-reservation}"

echo "=== refresh-from-parent (cursor kit mirror) ==="
"${ROOT}/cursor/scripts/refresh-from-parent.sh"

if [[ -d "${ROOT}/new-skills/claude-code-java" ]]; then
  echo ""
  echo "=== merge-claude-code-java ==="
  "${ROOT}/scripts/merge-claude-code-java.sh"
fi

echo ""
echo "=== sync-nestjs-expert (--with-cursor) ==="
"${ROOT}/scripts/sync-nestjs-expert.sh" "$SR" --with-cursor

echo ""
echo "=== sync-stack-spring (--with-cursor) ==="
"${ROOT}/scripts/sync-stack-spring.sh" "$SR" --with-cursor

if [[ -d "$SR" ]]; then
  echo ""
  echo "=== sync-to-product (cursor kit → ${SR}/cursor/) ==="
  "${ROOT}/cursor/scripts/sync-to-product.sh" "$SR"

  if [[ -f "${ROOT}/docs/sdlc-workflow-proposal.md" ]]; then
    mkdir -p "${SR}/docs"
    cp "${ROOT}/docs/sdlc-workflow-proposal.md" "${SR}/docs/sdlc-workflow-proposal.md"
    echo "  ✓ docs/sdlc-workflow-proposal.md → ${SR}/docs/"
  fi

  echo ""
  echo "=== install-into-workspace (curated) ==="
  (cd "$SR" && bash cursor/scripts/install-into-workspace.sh --curated)
fi

echo ""
echo "Cursor kit + product sync complete."
