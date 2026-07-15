#!/usr/bin/env bash
# Move plugin-level agents/ out of Claude Code auto-discovery.
# Canonical SDLC delivery agents live at repo root agents/ only.
# See plugins/PLUGIN-AGENT-MAP.yaml and skills/_shared/protocols/agent-separation.md

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

absorb() {
  local src="$1" dest="$2"
  if [[ -f "$src" && ! -f "$dest" ]]; then
    mkdir -p "$(dirname "$dest")"
    {
      echo "<!-- absorbed-from: ${src#${ROOT}/} -->"
      echo "<!-- runtime: load via agents/*/references/ — not plugins/*/agents/ -->"
      echo ""
      cat "$src"
    } > "$dest"
    echo "  ✓ absorbed → ${dest#${ROOT}/}"
  fi
}

echo "Absorbing plugin agent content into canonical agents/*/references/..."

absorb "${ROOT}/plugins/sdlc-workflows/agents/code-reviewer.md" \
  "${ROOT}/agents/code-reviewer/references/general-review-framework.md"

absorb "${ROOT}/plugins/sdlc-workflows/agents/test-engineer.md" \
  "${ROOT}/agents/quality-engineer/references/test-engineer-perspective.md"

absorb "${ROOT}/plugins/sdlc-workflows/agents/security-auditor.md" \
  "${ROOT}/agents/security-engineer/references/security-auditor-perspective.md"

absorb "${ROOT}/plugins/sdlc-workflows/agents/web-performance-auditor.md" \
  "${ROOT}/agents/code-reviewer/references/web-performance-auditor.md"

absorb "${ROOT}/plugins/stack-frontend/agents/nextjs-reviewer.md" \
  "${ROOT}/agents/code-reviewer/references/nextjs-reviewer.md"

absorb "${ROOT}/plugins/stack-frontend/agents/e2e-tester.md" \
  "${ROOT}/agents/quality-engineer/references/e2e-tester-perspective.md"

echo ""
echo "Quarantining plugins/*/agents/ → plugins/*/reference/agents/..."

quarantine_plugin() {
  local plugin_dir="$1"
  local agents_dir="${plugin_dir}/agents"
  local ref_dir="${plugin_dir}/reference/agents"

  if [[ ! -d "$agents_dir" ]]; then
    return 0
  fi

  mkdir -p "$ref_dir"
  rsync -a "${agents_dir}/" "${ref_dir}/"
  rm -rf "$agents_dir"
  echo "  ✓ ${plugin_dir#${ROOT}/}/agents → reference/agents/"
}

for plugin_dir in \
  "${ROOT}/plugins/sdlc-workflows" \
  "${ROOT}/plugins/stack-frontend" \
  "${ROOT}/plugins/system-design" \
  "${ROOT}/plugins/staff-engineer" \
  "${ROOT}/plugins/delivery-toolkit/feature-dev" \
  "${ROOT}/plugins/delivery-toolkit/pr-review-toolkit" \
  "${ROOT}/plugins/delivery-toolkit/plugin-dev"; do
  quarantine_plugin "$plugin_dir"
done

echo ""
"${ROOT}/scripts/sync-claude-agents-stubs.sh"

echo "Done."
