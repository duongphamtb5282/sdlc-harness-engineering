#!/usr/bin/env bash
# Copy the Cursor SDLC agents kit into a product repo as <product>/cursor/
#
# Usage:
#   ./scripts/sync-to-product.sh /path/to/seat-reservation
#   ./scripts/sync-to-product.sh /path/to/seat-reservation --full
#
# After sync, activate for Cursor IDE:
#   cd /path/to/seat-reservation && bash cursor/scripts/install-into-workspace.sh
#
set -euo pipefail

CURSOR_KIT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_REPO="${1:-}"
MODE="${2:-}"

if [[ -z "$TARGET_REPO" ]]; then
  echo "Usage: $0 /path/to/product-repo [--full]" >&2
  echo "" >&2
  echo "  Copies this cursor kit to <product>/cursor/" >&2
  echo "  Then run: <product>/cursor/scripts/install-into-workspace.sh" >&2
  exit 1
fi

if [[ ! -d "$CURSOR_KIT/.cursor/skills" ]]; then
  echo "Invalid cursor kit at $CURSOR_KIT" >&2
  exit 1
fi

TARGET_REPO="$(cd "$TARGET_REPO" && pwd)"
DEST="$TARGET_REPO/cursor"

mkdir -p "$DEST"

rsync -a --delete \
  --exclude '.DS_Store' \
  --exclude '.git/' \
  --exclude 'node_modules/' \
  "$CURSOR_KIT/" "$DEST/"

echo "Synced cursor kit → $DEST"
echo "Size: $(du -sh "$DEST" | cut -f1)"
echo ""
echo "Next: activate for Cursor (from product repo root):"
echo "  bash cursor/scripts/install-into-workspace.sh"
if [[ "$MODE" == "--full" ]]; then
  echo "  (install will use --full skills)"
fi
