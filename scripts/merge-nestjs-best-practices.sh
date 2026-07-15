#!/usr/bin/env bash
# Merge new-skills/agent-nestjs-skills rules into nestjs-expert (canonical catalog skill).
# Usage: ./scripts/merge-nestjs-best-practices.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ROOT}/new-skills/agent-nestjs-skills"
DEST="${ROOT}/plugins/claude-skills-catalog/skills/nestjs-expert"

if [[ ! -d "$SRC/rules" ]]; then
  echo "Missing ${SRC}/rules — add agent-nestjs-skills to new-skills/" >&2
  exit 1
fi

mkdir -p "${DEST}/references/rules"
rsync -a --delete \
  --exclude '_template.md' \
  --exclude '_sections.md' \
  "${SRC}/rules/" "${DEST}/references/rules/"
cp "${SRC}/rules/_sections.md" "${DEST}/references/rules-index.md"

count="$(find "${DEST}/references/rules" -name '*.md' | wc -l | tr -d ' ')"
echo "✓ nestjs-expert: merged ${count} rules from agent-nestjs-skills"
