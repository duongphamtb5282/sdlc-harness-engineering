#!/usr/bin/env bash
# Propagate plugins/stack-spring skills to product repo .cursor/skills/ (file copies).
# Usage: ./scripts/sync-stack-spring.sh [seat-reservation-path] [--with-cursor]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ROOT}/plugins/stack-spring"
CATALOG="${ROOT}/plugins/claude-skills-catalog/skills/spring-boot-engineer"
SR=""
WITH_CURSOR=0

for arg in "$@"; do
  case "$arg" in
    --with-cursor) WITH_CURSOR=1 ;;
    *) SR="$arg" ;;
  esac
done

SR="${SR:-${ROOT}/../seat-reservation}"

if [[ ! -d "${SRC}/skills" ]]; then
  echo "Missing ${SRC}/skills — run merge-spring-boot-skills.sh first" >&2
  exit 1
fi

sync_skill_dir() {
  local name="$1"
  local from="$2"
  local base="$3"
  local dest="${base}/.cursor/skills/${name}"
  mkdir -p "$dest"
  rsync -a "${from}/" "$dest/"
  echo "  ✓ ${name} → ${dest}"
}

sync_product() {
  local product="$1"
  local label="$2"

  if [[ ! -d "$product" ]]; then
    echo "⚠ skip ${label}: ${product} not found" >&2
    return 0
  fi

  echo "Syncing stack-spring → ${label} (${product})..."

  for skill_path in "${SRC}/skills"/*; do
    [[ -d "$skill_path" ]] || continue
    sync_skill_dir "$(basename "$skill_path")" "$skill_path" "$product"
  done

  # Index skill with STACK-RULES + catalog
  mkdir -p "${product}/.cursor/skills/stack-spring"
  {
    echo "---"
    echo "name: stack-spring"
    echo "description: >"
    echo "  Spring Boot 3.x stack index. Load topic skills from .cursor/skills/ before"
    echo "  implementing Java backend work. Precedence rules in references/STACK-RULES.md."
    echo "---"
    echo ""
    echo "# stack-spring (index)"
    echo ""
    echo "Install source: \`agents/plugins/stack-spring\` (sync via \`scripts/sync-stack-spring.sh\`)."
    echo ""
    echo "## Topic skills (load on demand)"
    echo ""
    for skill_path in "${SRC}/skills"/*; do
      [[ -d "$skill_path" ]] || continue
      echo "- \`$(basename "$skill_path")\`"
    done
    echo ""
    echo "## Precedence"
    echo ""
    echo "Read [STACK-RULES.md](references/STACK-RULES.md) before mixing error formats, security, or architecture styles."
    echo ""
    echo "## Catalog"
    echo ""
    echo "General workflow: \`spring-boot-engineer\` (updated from claude-skills-catalog)."
  } > "${product}/.cursor/skills/stack-spring/SKILL.md"

  mkdir -p "${product}/.cursor/skills/stack-spring/references"
  cp "${SRC}/STACK-RULES.md" "${product}/.cursor/skills/stack-spring/references/STACK-RULES.md"
  cp "${SRC}/README.md" "${product}/.cursor/skills/stack-spring/references/README.md"
  echo "  ✓ stack-spring index → ${product}/.cursor/skills/stack-spring/"

  if [[ -d "$CATALOG" ]]; then
    sync_skill_dir "spring-boot-engineer" "$CATALOG" "$product"
  fi

  # Shared protocol copy (stack-spring path detection)
  PROTO="${ROOT}/skills/_shared/protocols/stack-skill-loading.md"
  if [[ -f "$PROTO" ]]; then
    mkdir -p "${product}/.cursor/skills/_shared/protocols"
    cp "$PROTO" "${product}/.cursor/skills/_shared/protocols/stack-skill-loading.md"
    echo "  ✓ stack-skill-loading.md"
  fi

  local count
  count="$(find "${SRC}/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
  echo "Done ${label}: ${count} topic skills + stack-spring index + spring-boot-engineer"
}

sync_product "$SR" "seat-reservation"

if [[ "$WITH_CURSOR" -eq 1 ]]; then
  sync_product "${ROOT}/cursor" "agents/cursor kit"
fi

echo ""
echo "All stack-spring sync targets complete."
