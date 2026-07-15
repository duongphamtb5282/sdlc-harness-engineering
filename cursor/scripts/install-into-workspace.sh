#!/usr/bin/env bash
# Activate cursor/ kit into the parent product repo (.cursor/, packs/, config).
#
# Run from product repo:
#   bash cursor/scripts/install-into-workspace.sh
#   bash cursor/scripts/install-into-workspace.sh --full    # all ~500 skills
#   bash cursor/scripts/install-into-workspace.sh --curated # default ~35 skills
#
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$KIT/.." && pwd)"
MODE="curated"

for arg in "$@"; do
  case "$arg" in
    --full) MODE="full" ;;
    --curated) MODE="curated" ;;
  esac
done

if [[ ! -f "$ROOT/package.json" && ! -f "$ROOT/pom.xml" ]]; then
  echo "Expected product repo at $ROOT (parent of cursor/)" >&2
  exit 1
fi

mkdir -p "$ROOT/.cursor/rules" "$ROOT/.cursor/skills" "$ROOT/packs" "$ROOT/docs/architecture"

# Rules — SDLC kit + optional product overlay
rsync -a "$KIT/.cursor/rules/" "$ROOT/.cursor/rules/"
if [[ -d "$KIT/overlays/$(basename "$ROOT")/rules" ]]; then
  rsync -a "$KIT/overlays/$(basename "$ROOT")/rules/" "$ROOT/.cursor/rules/"
fi

# Packs
rsync -a "$KIT/packs/" "$ROOT/packs/"

# Project overlay (seat-reservation specific)
OVERLAY="$KIT/overlays/seat-reservation"
if [[ -d "$OVERLAY" ]]; then
  [[ -f "$OVERLAY/.sdlc-automation-agent.yaml" ]] && cp "$OVERLAY/.sdlc-automation-agent.yaml" "$ROOT/"
  [[ -f "$OVERLAY/docs/architecture/tech-stack.yaml" ]] && cp "$OVERLAY/docs/architecture/tech-stack.yaml" "$ROOT/docs/architecture/"
  [[ -f "$OVERLAY/.cursor/AGENTS.md" ]] && cp "$OVERLAY/.cursor/AGENTS.md" "$ROOT/.cursor/AGENTS.md"
  [[ -f "$OVERLAY/docs/cursor-agents-guide.md" ]] && cp "$OVERLAY/docs/cursor-agents-guide.md" "$ROOT/docs/"
fi

CURATED=(
  sdlc-automation-agent
  product-manager solution-architect software-engineer frontend-engineer
  quality-engineer code-reviewer devops platform-engineer security-engineer
  nestjs-expert react-best-practices test-driven-development
  code-review-and-quality incremental-implementation spec-driven-development
  debugging-and-error-recovery microservices-architect messaging-streaming
  consistency-coordination c4-architecture api-design application-patterns
  aws-containers aws-iam aws-cdk ci-cd-and-automation security-and-hardening
  typescript-pro _shared
  spring-boot-engineer stack-spring
  rest-api-conventions spring-data-jpa problem-details-rfc9457 layered-architecture
  java-code-review jpa-patterns security-audit
)

install_skill() {
  local name="$1"
  local src="$KIT/.cursor/skills/$name"
  local dest="$ROOT/.cursor/skills/$name"
  if [[ ! -d "$src" ]]; then
    echo "skip (missing in kit): $name" >&2
    return
  fi
  mkdir -p "$dest"
  rsync -a "$src/" "$dest/"
  echo "skill: $name"
}

if [[ "$MODE" == "full" ]]; then
  echo "Installing ALL skills from cursor kit..."
  rsync -a --delete "$KIT/.cursor/skills/" "$ROOT/.cursor/skills/"
else
  echo "Installing curated skills ($MODE)..."
  for skill in "${CURATED[@]}"; do
    install_skill "$skill"
  done
fi

for skill_dir in "$ROOT/.cursor/skills"/*; do
  [[ -d "$skill_dir" ]] || continue
  name=$(basename "$skill_dir")
  case "$name" in
    add-api-endpoint|add-entity|preflight-pr|understand-module|check-governance-impact)
      echo "kept project skill: $name"
      ;;
  esac
done

if [[ -d "$OVERLAY/.cursor/skills" ]]; then
  for skill_dir in "$OVERLAY/.cursor/skills"/*; do
    [[ -d "$skill_dir" ]] || continue
    name=$(basename "$skill_dir")
    if [[ ! -d "$ROOT/.cursor/skills/$name" ]]; then
      rsync -a "$skill_dir/" "$ROOT/.cursor/skills/$name/"
      echo "overlay skill: $name"
    fi
  done
fi

COUNT=$(find "$ROOT/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
echo ""
echo "Done ($MODE). Active skills: $COUNT"
echo "Rules: $(ls "$ROOT/.cursor/rules"/*.mdc 2>/dev/null | wc -l | tr -d ' ')"
echo "Open $ROOT in Cursor. Guide: docs/cursor-agents-guide.md"
