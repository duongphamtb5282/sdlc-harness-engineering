#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# validate-structure.sh — Validates the complete agent-v01 structure
# Checks: agent references, symlinks, stacks, supplements, protocols
# Usage: ./validate-structure.sh
# ═══════════════════════════════════════════════════════════════

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FAILURES=0

echo "━━━ agent-v01 Structure Validation ━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. Agent file references ──────────────────────────────────
echo "[1/6] Agent file references..."
for agent in "$ROOT"/agent-v01/agents/*.md; do
  name=$(basename "$agent")
  while IFS= read -r ref; do
    # Skip empty
    [ -z "$ref" ] && continue
    # Skip template placeholders ({tech}, {name}, {category}) — intentional lookup conventions
    case "$ref" in
      *'{'*|*'}'*) continue ;;
    esac
    # Resolve relative to project root
    full="$ROOT/$ref"
    if [ ! -e "$full" ]; then
      echo "  ❌ $name → BROKEN: $ref"
      FAILURES=$((FAILURES+1))
    fi
  done < <(grep -oE '(agent-v01|core-skills|stacks|supplements|protocols|references|agent-skills)/[a-zA-Z0-9_./{}-]+' "$agent" 2>/dev/null | sort -u)
done
[ $FAILURES -eq 0 ] && echo "  ✅ No broken references"

# ── 2. Symlink check (structure uses direct copies, not symlinks) ─
echo ""
echo "[2/6] Symlink check (direct-copy structure)..."
SYMLINKS=$(find "$ROOT/agent-v01" -type l 2>/dev/null | wc -l | tr -d ' ')
if [ "$SYMLINKS" -eq 0 ]; then
  echo "  ✅ No symlinks — all content copied directly"
elif [ "$SYMLINKS" -gt 0 ]; then
  # Only warn for symlinks outside core-skills and BMAD-METHOD (upstream content may contain them)
  OUTSIDE=$(find "$ROOT/agent-v01" -type l -not -path "*/core-skills/*" -not -path "*/BMAD-METHOD/*" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$OUTSIDE" -gt 0 ]; then
    echo "  ⚠️  $OUTSIDE symlinks outside core-skills/BMAD-METHOD (expected 0 — copy directly)"
    FAILURES=$((FAILURES+1))
  else
    echo "  ✅ No symlinks outside upstream content dirs"
  fi
fi

# ── 3. Stacks coverage ────────────────────────────────────────
echo ""
echo "[3/6] Stack coverage..."
EXPECTED=("backend/nestjs" "backend/spring-boot" "backend/java" "backend/golang" "backend/dot-net" "frontend/react" "frontend/nextjs" "frontend/vue" "frontend/nuxt" "frontend/ui-ux" "mobile/swift-ui" "mobile/android" "mobile/kotlin-compose" "mobile/flutter" "mobile/react-native" "cloud/aws" "cloud/azure" "ai/langchain" "ai/mlflow" "ai/ml-agents" "ai/context-engineering")
for stack in "${EXPECTED[@]}"; do
  if [ ! -e "$ROOT/agent-v01/stacks/$stack" ]; then
    echo "  ⚠️  MISSING: $stack"
    FAILURES=$((FAILURES+1))
  fi
done
present=0
for d in "$ROOT"/agent-v01/stacks/*/*; do
  [ -e "$d" ] && present=$((present+1))
done
echo "  ✅ $present/21 stacks present"

# ── 4. Supplements, references, methodologies coverage ────────
echo ""
echo "[4/6] Supplements, references & methodologies..."
echo "  -- supplements --"
for s in "$ROOT"/agent-v01/supplements/*; do
  name=$(basename "$s")
  if [ -e "$s" ]; then
    echo "    ✅ $name"
  else
    echo "    ❌ $name"
    FAILURES=$((FAILURES+1))
  fi
done
echo "  -- references --"
for s in "$ROOT"/agent-v01/references/*; do
  name=$(basename "$s")
  if [ -e "$s" ]; then
    echo "    ✅ $name"
  else
    echo "    ❌ $name"
    FAILURES=$((FAILURES+1))
  fi
done
echo "  -- methodologies --"
for s in "$ROOT"/agent-v01/methodologies/*; do
  name=$(basename "$s")
  if [ -e "$s" ]; then
    echo "    ✅ $name"
  else
    echo "    ❌ $name"
    FAILURES=$((FAILURES+1))
  fi
done

# ── 5. Commands coverage ──────────────────────────────────────
echo ""
echo "[5/6] Slash commands..."
for cmd in discover spec arch-design plan qa build review; do
  if [ -f "$ROOT/.claude/commands/$cmd.md" ] && [ -f "$ROOT/agent-v01/.claude/commands/$cmd.md" ]; then
    echo "  ✅ /$cmd (root + agent-v01)"
  else
    echo "  ❌ /$cmd"
    FAILURES=$((FAILURES+1))
  fi
done

# ── 6. Protocol sync ──────────────────────────────────────────
echo ""
echo "[6/6] Protocol sync..."
if bash "$ROOT/agent-v01/scripts/sync-protocols.sh" --check >/dev/null 2>&1; then
  echo "  ✅ All protocols in sync"
else
  echo "  ⚠️  Protocols out of sync — run ./sync-protocols.sh --apply"
  FAILURES=$((FAILURES+1))
fi

# ── 7. Plugin manifest ────────────────────────────────────────
echo ""
echo "[7/7] Plugin manifest..."
if [ -f "$ROOT/agent-v01/.claude-plugin/plugin.json" ] && [ -f "$ROOT/agent-v01/.claude-plugin/marketplace.json" ]; then
  if python3 -c "
import json, sys
json.load(open('$ROOT/agent-v01/.claude-plugin/plugin.json'))
json.load(open('$ROOT/agent-v01/.claude-plugin/marketplace.json'))
" 2>/dev/null; then
    echo "  ✅ plugin.json + marketplace.json valid"
  else
    echo "  ❌ Invalid plugin JSON"
    FAILURES=$((FAILURES+1))
  fi
else
  echo "  ❌ Missing .claude-plugin/ manifests"
  FAILURES=$((FAILURES+1))
fi

# ── 8. Skill router + profiles (Tier 2/3) ────────────────────
echo ""
echo "[8/8] Skill router (Tier 2/3)..."
if [ -f "$ROOT/agent-v01/SKILL-ROUTER.yaml" ]; then
  echo "  ✅ SKILL-ROUTER.yaml present"
  if ruby -ryaml -e "YAML.load_file('$ROOT/agent-v01/SKILL-ROUTER.yaml')" 2>/dev/null; then
    echo "  ✅ SKILL-ROUTER.yaml valid YAML"
  else
    echo "  ❌ SKILL-ROUTER.yaml invalid"
    FAILURES=$((FAILURES+1))
  fi
else
  echo "  ⚠️  SKILL-ROUTER.yaml missing (Tier 2)"
  FAILURES=$((FAILURES+1))
fi

PROFILE_COUNT=$(ls "$ROOT/agent-v01/skills/profiles/"*.yaml 2>/dev/null | wc -l | tr -d ' ')
if [ "$PROFILE_COUNT" -ge 8 ]; then
  echo "  ✅ $PROFILE_COUNT per-agent profiles present (Tier 3)"
else
  echo "  ⚠️  Expected 8 profiles, found $PROFILE_COUNT — run generate-skill-profiles.rb"
  FAILURES=$((FAILURES+1))
fi

echo ""
echo "━━━ Result: $FAILURES failure(s) ━━━━━━━━━━━━━━━━━━━━━━━━"
exit $FAILURES
