#!/usr/bin/env bash
# Merge new-skills/claude-code-java into plugins/stack-spring/skills/ (additive file copies).
# Upstream: claude-code-java (.claude/skills/)
# Usage: ./scripts/merge-claude-code-java.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ROOT}/new-skills/claude-code-java/.claude/skills"
DEST="${ROOT}/plugins/stack-spring/skills"
DOCS_SRC="${ROOT}/new-skills/claude-code-java/docs"
DOCS_DEST="${ROOT}/plugins/stack-spring/references/claude-code-java"

if [[ ! -d "$SRC" ]]; then
  echo "Missing ${SRC} — add claude-code-java to new-skills/" >&2
  exit 1
fi

merged=0
for skill_path in "${SRC}"/*; do
  [[ -d "$skill_path" ]] || continue
  name="$(basename "$skill_path")"
  rsync -a "${skill_path}/" "${DEST}/${name}/"
  echo "  ✓ ${name}"
  merged=$((merged + 1))
done

if [[ -d "$DOCS_SRC" ]]; then
  mkdir -p "$DOCS_DEST"
  rsync -a "${DOCS_SRC}/" "${DOCS_DEST}/"
  echo "  ✓ docs → references/claude-code-java/"
fi

total="$(find "${DEST}" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo ""
echo "✓ stack-spring: merged ${merged} claude-code-java skills (${total} total topic skills)"
