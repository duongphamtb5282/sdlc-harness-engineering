#!/usr/bin/env bash
# Sync upstream reference repos (new-skills/) into canonical runtime paths.
# Usage: ./scripts/sync-from-new-skills.sh
# Agents must NEVER load new-skills/ at runtime — see skills/_shared/protocols/reference-sources.md

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REF="${ROOT}/new-skills"
RSYNC=(rsync -a --delete --exclude='.git')

if [[ ! -d "$REF" ]]; then
  echo "Missing ${REF} — add upstream repos for reference, or sync manually."
  exit 1
fi

echo "Syncing from ${REF} → canonical paths..."

# Specialist skills (claude-software-skills categories)
if [[ -d "${REF}/claude-software-skills" ]]; then
  for cat in software-design software-engineering development-stacks programming-languages tools-integrations domain-applications; do
    src="${REF}/claude-software-skills/${cat}"
    if [[ -d "$src" ]]; then
      mkdir -p "${ROOT}/skills/_shared/specialist-skills/${cat}"
      "${RSYNC[@]}" "${src}/" "${ROOT}/skills/_shared/specialist-skills/${cat}/"
      echo "  ✓ specialist-skills/${cat}"
    fi
  done
  # Maintainer mirror (full tree, no .git)
  "${RSYNC[@]}" --exclude='.git' "${REF}/claude-software-skills/" "${ROOT}/skills/_shared/specialist-skills-source/"
  echo "  ✓ specialist-skills-source/"
fi

# Stack plugins
[[ -d "${REF}/cc-skills-golang/skills" ]] && \
  "${RSYNC[@]}" "${REF}/cc-skills-golang/skills/" "${ROOT}/plugins/stack-golang/skills/" && echo "  ✓ stack-golang"

if [[ -d "${REF}/claude-code-nextjs-skills/skills" ]]; then
  "${RSYNC[@]}" "${REF}/claude-code-nextjs-skills/skills/" "${ROOT}/plugins/stack-frontend/skills/"
  echo "  ✓ stack-frontend (claude-code-nextjs-skills)"
fi

# Vercel Labs frontend skills — merge overlay (do not --delete; keeps Next.js-only skills above)
if [[ -d "${REF}/agent-skills-frontend/skills" ]]; then
  rsync -a \
    --exclude='*.zip' \
    "${REF}/agent-skills-frontend/skills/" \
    "${ROOT}/plugins/stack-frontend/skills/"
  count="$(find "${ROOT}/plugins/stack-frontend/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
  echo "  ✓ stack-frontend (agent-skills-frontend merge, ${count} skills)"
fi

[[ -d "${REF}/agent-toolkit-for-aws/skills" ]] && \
  "${RSYNC[@]}" "${REF}/agent-toolkit-for-aws/skills/" "${ROOT}/plugins/stack-aws/skills/" && \
  echo "  ✓ stack-aws"

[[ -d "${REF}/Agent-Skills" ]] && \
  "${RSYNC[@]}" "${REF}/Agent-Skills/skills/" "${ROOT}/plugins/stack-azure/skills/" 2>/dev/null || true
echo "  ✓ stack-azure (if Agent-Skills/skills exists)"

[[ -d "${REF}/agent-skills1/skills" ]] && \
  "${RSYNC[@]}" "${REF}/agent-skills1/skills/" "${ROOT}/plugins/sdlc-workflows/skills/" && echo "  ✓ sdlc-workflows"

[[ -d "${REF}/agent-toolkit/skills" ]] && \
  "${RSYNC[@]}" "${REF}/agent-toolkit/skills/" "${ROOT}/plugins/agent-toolkit/skills/" && echo "  ✓ agent-toolkit"

if [[ -d "${REF}/system-design-skills/skills" ]]; then
  "${RSYNC[@]}" --exclude='site' --exclude='meta/evals' \
    "${REF}/system-design-skills/skills/" "${ROOT}/plugins/system-design/skills/"
  echo "  ✓ system-design"
fi

# Delivery sub-plugins
for sub in feature-dev pr-review-toolkit code-review security-guidance commit-commands; do
  if [[ -d "${REF}/claude-code/plugins/${sub}" ]]; then
    "${RSYNC[@]}" "${REF}/claude-code/plugins/${sub}/" "${ROOT}/plugins/delivery-toolkit/${sub}/"
    echo "  ✓ delivery-toolkit/${sub}"
  fi
done

# Staff engineer (optional alternative workflow)
if [[ -d "${REF}/claude-code-staff-engineer" ]]; then
  "${RSYNC[@]}" --exclude='README.md' \
    "${REF}/claude-code-staff-engineer/" "${ROOT}/plugins/staff-engineer/"
  echo "  ✓ staff-engineer"
fi

# Extended skill catalog (claude-skills → always synced for full coverage)
if [[ -d "${REF}/claude-skills/skills" ]]; then
  mkdir -p "${ROOT}/plugins/claude-skills-catalog"
  "${RSYNC[@]}" "${REF}/claude-skills/skills/" "${ROOT}/plugins/claude-skills-catalog/skills/"
  count="$(ls -1 "${ROOT}/plugins/claude-skills-catalog/skills" | wc -l | tr -d ' ')"
  echo "  ✓ claude-skills-catalog (${count} skills)"
  src_count="$(find "${REF}/claude-skills/skills" -name 'SKILL.md' | wc -l | tr -d ' ')"
  if [[ "${count}" != "${src_count}" ]]; then
    echo "  ⚠ claude-skills-catalog count mismatch: source=${src_count} dest=${count}" >&2
    exit 1
  fi
  # Apply catalog deprecations (stack plugin supersedes catalog skill)
  if [[ -f "${ROOT}/plugins/claude-skills-catalog/overrides/golang-pro.SKILL.md" ]]; then
    cp "${ROOT}/plugins/claude-skills-catalog/overrides/golang-pro.SKILL.md" \
      "${ROOT}/plugins/claude-skills-catalog/skills/golang-pro/SKILL.md"
    echo "  ✓ claude-skills-catalog/golang-pro deprecated → stack-golang"
  fi
fi

# NestJS best practices (Kadajett/agent-nestjs-skills) → nestjs-expert rules
if [[ -d "${REF}/agent-nestjs-skills/rules" ]]; then
  "${ROOT}/scripts/merge-nestjs-best-practices.sh"
fi

# Spring Boot skills (rrezartprebreza/spring-boot-skills) → stack-spring plugin
if [[ -d "${REF}/spring-boot-skills/skills/spring-boot-3" ]]; then
  "${ROOT}/scripts/merge-spring-boot-skills.sh"
fi

echo ""
echo "Quarantining plugin agents (skills-only plugins at runtime)..."
"${ROOT}/scripts/quarantine-plugin-agents.sh"

echo ""
echo "Materializing symlinks in Claude Code runtime paths..."
"${ROOT}/scripts/materialize-symlinks.sh"

echo ""
echo "Done. Commit changes under plugins/ and skills/_shared/ — not new-skills/."
echo "Map: plugins/REFERENCE-MAP.yaml | Agent separation: plugins/PLUGIN-AGENT-MAP.yaml"
echo "Full pipeline: ./scripts/sync-all.sh"
