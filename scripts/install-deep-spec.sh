#!/usr/bin/env bash
# =============================================================================
# Deep Spec — Single-Machine Install
# =============================================================================
# Installs the Deep Spec integration into an sdlc-automation-agent project.
# Run from the project root (where .sdlc-automation-agent.yaml lives).
#
# Usage:
#   bash scripts/install-deep-spec.sh
#
# What it does:
#   1. Creates spec folder structure if missing
#   2. Copies Deep Spec protocol to .sdlc-automation-agent/.protocols/
#   3. Copies spec templates (contracts.md, tests.md)
#   4. Updates .sdlc-automation-agent.yaml with deep_spec config
#   5. Generates steering docs if missing
#   6. Verifies installation
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Detect plugin root ─────────────────────────────────────────────────────
if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
elif [ -d "$PROJECT_DIR/claude/skills/_shared" ]; then
  PLUGIN_ROOT="$PROJECT_DIR/claude"
elif [ -d "$PROJECT_DIR/.claude/plugins/sdlc-automation-agent" ]; then
  PLUGIN_ROOT="$PROJECT_DIR/.claude/plugins/sdlc-automation-agent"
else
  # Assume this script lives in the plugin repo itself
  PLUGIN_ROOT="$PROJECT_DIR/claude"
  info "Using plugin root: $PLUGIN_ROOT"
fi

echo ""
echo -e "${BLUE}━━━ Deep Spec Install ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Step 1: Create spec folders ────────────────────────────────────────────
info "Step 1/6: Creating spec folder structure..."
mkdir -p ".sdlc-automation-agent/specs"
mkdir -p ".sdlc-automation-agent/.orchestrator"
mkdir -p ".sdlc-automation-agent/.protocols"
ok "Spec folder structure ready"

# ── Step 2: Install Deep Spec protocol ─────────────────────────────────────
info "Step 2/6: Installing Deep Spec protocol..."

PROTO_SRC="$PLUGIN_ROOT/skills/_shared/protocols/deep-spec.md"
PROTO_DST=".sdlc-automation-agent/.protocols/deep-spec.md"

if [ -f "$PROTO_SRC" ]; then
  cp "$PROTO_SRC" "$PROTO_DST"
  ok "deep-spec.md protocol installed"
else
  # Generate inline
  cat > "$PROTO_DST" << 'PROTO'
<!-- sdlc-automation-agent-id: deep-spec -->
# Deep Spec Protocol

The spec folder `.sdlc-automation-agent/specs/{spec-id}/` is the SINGLE source of truth for that feature's delivery. Every agent reads it on startup. Every agent writes back to it on completion.

## Traceability Chain
REQ-ID → Contracts (input/output/errors) → Design (component/API) → Tasks (checkboxes) → Code (files) → Tests (assertions) → Receipts (verification)

## Agent Responsibilities
| Agent | Reads | Writes | Validates |
|-------|-------|--------|-----------|
| PM | Source docs, BRD | requirements.md, contracts.md | Every REQ-ID has AC + behavioral contract |
| SA | requirements.md, contracts.md | design.md, ADRs | Every REQ-ID in traceability table; ADRs tagged with REQ-IDs |
| PM | requirements.md, design.md | tasks.md | Every REQ-ID referenced by ≥1 task |
| SE | requirements.md, contracts.md, tasks.md | coverage.json, code | Implementation covers assigned REQ-IDs only |
| QE | requirements.md, contracts.md, design.md | tests.md | Every REQ-ID has ≥1 test case |
| CR | requirements.md, tasks.md, coverage.json | Findings | Code implements exactly the spec'd REQ-IDs (no scope creep) |

## Enforcement Gates
| Gate | Blocks | Condition |
|------|--------|-----------|
| requirements_approved | Design start | All REQ-IDs have ACs + behavioral contracts |
| design_approved | Tasks creation | Traceability table complete + ADRs tagged |
| tasks_approved | Implementation | Every REQ-ID in ≥1 task |
| test_coverage_pass | Release sign-off | Every REQ-ID has ≥1 test |
| spec_compliance_pass | Merge | Changed files map to spec'd REQ-IDs only |
PROTO
  ok "deep-spec.md protocol generated (source not found)"
fi

# ── Step 3: Install spec templates ─────────────────────────────────────────
info "Step 3/6: Installing spec templates..."

TEMPLATES_SRC="$PLUGIN_ROOT/skills/_shared/templates/specs"
TEMPLATES_DST=".sdlc-automation-agent/templates/specs"
mkdir -p "$TEMPLATES_DST"

for tmpl in contracts.tmpl.md tests.tmpl.md requirements.tmpl.md design.tmpl.md tasks.tmpl.md; do
  if [ -f "$TEMPLATES_SRC/$tmpl" ]; then
    cp "$TEMPLATES_SRC/$tmpl" "$TEMPLATES_DST/$tmpl"
    ok "$tmpl installed"
  else
    warn "$tmpl not found at source — skipping"
  fi
done

# ── Step 4: Update .sdlc-automation-agent.yaml ─────────────────────────────
info "Step 4/6: Updating configuration..."

CONFIG_FILE=".sdlc-automation-agent.yaml"
DEEP_SPEC_BLOCK="

# Deep Spec — spec-driven traceability from requirements through delivery
deep_spec:
  enabled: true
  gates:
    test_coverage: true
    spec_compliance: true
  artifacts:
    contracts: true
    coverage_report: true
"

if [ -f "$CONFIG_FILE" ]; then
  if grep -q "deep_spec:" "$CONFIG_FILE" 2>/dev/null; then
    info "deep_spec already in config — skipping"
  else
    echo "$DEEP_SPEC_BLOCK" >> "$CONFIG_FILE"
    ok "deep_spec config added to $CONFIG_FILE"
  fi
else
  warn "$CONFIG_FILE not found — creating..."
  cat > "$CONFIG_FILE" << 'YAML'
# sdlc-automation-agent configuration
project:
  name: "my-project"
  language: ""
  build_mode: "scrum"

deep_spec:
  enabled: true
  gates:
    test_coverage: true
    spec_compliance: true
  artifacts:
    contracts: true
    coverage_report: true
YAML
  ok "$CONFIG_FILE created with deep_spec enabled"
fi

# ── Step 5: Create steering docs ───────────────────────────────────────────
info "Step 5/6: Creating steering docs..."

mkdir -p .sdlc-automation-agent/steering

for name in product.md tech.md structure.md workflow.md; do
  path=".sdlc-automation-agent/steering/$name"
  if [ ! -f "$path" ]; then
    case "$name" in
      product.md)
        cat > "$path" << 'EOF'
# Product steering

Domain language, personas, compliance requirements.
Populate during Inception with BRD context.
EOF
        ;;
      tech.md)
        cat > "$path" << 'EOF'
# Tech steering

Pointer: docs/architecture/tech-stack.yaml
Stack conventions, deploy targets, infrastructure constraints.
EOF
        ;;
      structure.md)
        cat > "$path" << 'EOF'
# Repo structure rules

Directory conventions, naming, module boundaries.
EOF
        ;;
      workflow.md)
        cat > "$path" << 'EOF'
# Branch, PR, review rules

Git workflow, PR conventions, review requirements.
EOF
        ;;
    esac
    ok "steering/$name created"
  else
    info "steering/$name already exists"
  fi
done

# ── Step 6: Verify installation ────────────────────────────────────────────
info "Step 6/6: Verifying installation..."

PASS=0
FAIL=0

verify() {
  local desc="$1" path="$2"
  if [ -f "$path" ] || [ -d "$path" ]; then
    ok "$desc — $path"
    PASS=$((PASS + 1))
  else
    err "$desc — $path NOT FOUND"
    FAIL=$((FAIL + 1))
  fi
}

verify "Deep Spec protocol"      ".sdlc-automation-agent/.protocols/deep-spec.md"
verify "Spec folder"             ".sdlc-automation-agent/specs"
verify "Steering folder"         ".sdlc-automation-agent/steering"
verify "Contracts template"      ".sdlc-automation-agent/templates/specs/contracts.tmpl.md"
verify "Tests template"          ".sdlc-automation-agent/templates/specs/tests.tmpl.md"

if [ -f "$CONFIG_FILE" ] && grep -q "deep_spec:" "$CONFIG_FILE" 2>/dev/null; then
  ok "deep_spec enabled in config"
  PASS=$((PASS + 1))
else
  err "deep_spec NOT in config"
  FAIL=$((FAIL + 1))
fi

echo ""
echo -e "${BLUE}━━━ Summary ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}  Deep Spec installed successfully!${NC}"
  echo ""
  echo "  Next steps:"
  echo "  1. Run \`/sdlc-automation-agent\` — agents will auto-load the deep spec protocol"
  echo "  2. PM creates specs with:  \`/sdlc-automation-agent init\`"
  echo "  3. Or manually:            mkdir -p .sdlc-automation-agent/specs/{feature-name}/"
  echo "  4. PM writes:              requirements.md + contracts.md (from templates)"
  echo "  5. SA writes:              design.md with REQ traceability"
  echo "  6. PM writes:              tasks.md"
  echo "  7. SE implements + writes: coverage.json"
  echo "  8. QE writes:              tests.md + validates REQ-ID coverage"
  echo "  9. CR verifies:            spec compliance against REQ-IDs"
  echo ""
  echo -e "  ${YELLOW}Note:${NC} Agent SKILL.md files already include the deep-spec protocol"
  echo "  reference. No additional agent configuration needed."
else
  echo -e "${RED}  $FAIL verification(s) failed. Check output above.${NC}"
  exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
