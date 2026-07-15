#!/usr/bin/env bash
# Copy agents/{role}/agent.md → claude-agents/{role}.md (real files, no symlinks).
# Usage: ./scripts/sync-claude-agents-stubs.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STUB_DIR="${ROOT}/claude-agents"
mkdir -p "$STUB_DIR"

ROLES=(
  product-manager
  solution-architect
  software-engineer
  frontend-engineer
  data-scientist
  quality-engineer
  devops
  sre
  platform-engineer
  security-engineer
  code-reviewer
  technical-writer
  research-advisor
  compliance-engineer
)

echo "Syncing claude-agents/ stubs (file copies, no symlinks)..."

for role in "${ROLES[@]}"; do
  src="${ROOT}/agents/${role}/agent.md"
  dest="${STUB_DIR}/${role}.md"
  if [[ ! -f "$src" ]]; then
    echo "  ⚠ missing agents/${role}/agent.md" >&2
    continue
  fi
  rm -f "$dest"
  cp "$src" "$dest"
  echo "  ✓ ${role}.md"
done

# Remove stale stubs not in ROLES list
for stub in "${STUB_DIR}"/*.md; do
  [[ -f "$stub" ]] || continue
  base="$(basename "$stub" .md)"
  found=0
  for role in "${ROLES[@]}"; do
    if [[ "$role" == "$base" ]]; then
      found=1
      break
    fi
  done
  if [[ "$found" -eq 0 ]]; then
    rm -f "$stub"
    echo "  ✗ removed stale ${base}.md"
  fi
done

echo "Done. ${#ROLES[@]} roles → claude-agents/"
