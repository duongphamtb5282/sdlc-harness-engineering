#!/usr/bin/env bash
# Propagate nestjs-expert skill from canonical plugins/ to product repos.
# Does NOT modify cursor/ unless --with-cursor is passed.
# Usage: ./scripts/sync-nestjs-expert.sh [seat-reservation-path] [--with-cursor]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ROOT}/plugins/claude-skills-catalog/skills/nestjs-expert"
SR=""
WITH_CURSOR=0

for arg in "$@"; do
  case "$arg" in
    --with-cursor) WITH_CURSOR=1 ;;
    *) SR="$arg" ;;
  esac
done

SR="${SR:-${ROOT}/../seat-reservation}"

if [[ ! -d "$SRC/references/rules" ]]; then
  echo "Run merge-nestjs-best-practices.sh first" >&2
  exit 1
fi

TARGETS=()

if [[ "$WITH_CURSOR" -eq 1 ]]; then
  TARGETS+=(
    "${ROOT}/cursor/.cursor/skills/nestjs-expert"
    "${ROOT}/cursor/plugins/claude-skills-catalog/skills/nestjs-expert"
  )
fi

if [[ -d "$SR" ]]; then
  TARGETS+=(
    "${SR}/.cursor/skills/nestjs-expert"
    "${SR}/cursor/.cursor/skills/nestjs-expert"
  )
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "Canonical source is ${SRC} (no downstream targets)."
  echo "Pass a product repo path or --with-cursor to propagate copies."
  exit 0
fi

for dest in "${TARGETS[@]}"; do
  mkdir -p "$dest"
  rsync -a "$SRC/" "$dest/"
  echo "✓ synced → $dest"
done

echo "Done. Rules: $(find "$SRC/references/rules" -name '*.md' | wc -l | tr -d ' ')"
