#!/usr/bin/env bash
# Merge new-skills/spring-boot-skills into plugins/stack-spring (canonical runtime).
# Default runtime: spring-boot-3 skills. spring-boot-4 kept under references/ (opt-in).
# Usage: ./scripts/merge-spring-boot-skills.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ROOT}/new-skills/spring-boot-skills"
DEST="${ROOT}/plugins/stack-spring"
SKILLS_SRC="${SRC}/skills/spring-boot-3"
SB4_REF="${SRC}/skills/spring-boot-4"

if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "Missing ${SKILLS_SRC} — add spring-boot-skills to new-skills/" >&2
  exit 1
fi

mkdir -p "${DEST}/skills" "${DEST}/references/spring-boot-4"

rsync -a --delete \
  --exclude='.git' \
  "${SKILLS_SRC}/" "${DEST}/skills/"

if [[ -d "$SB4_REF" ]]; then
  rsync -a --delete \
    --exclude='.git' \
    "${SB4_REF}/" "${DEST}/references/spring-boot-4/"
fi

count="$(find "${DEST}/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
sb4="$(find "${DEST}/references/spring-boot-4" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"

echo "✓ stack-spring: merged ${count} skills (Spring Boot 3.x default)"
echo "✓ stack-spring: ${sb4} reference skills (Spring Boot 4.x — opt-in)"
