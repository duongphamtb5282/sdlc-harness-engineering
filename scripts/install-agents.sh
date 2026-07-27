#!/usr/bin/env bash
# =============================================================================
# sdlc-automation-agent — Full Install for 1 Machine
# =============================================================================
# Installs ALL agents, plugins, skills, hooks, rules, templates, and protocols.
# Run ONCE on the target machine. After install, agents are available in any
# project via /sdlc-automation-agent or by invoking individual agent names.
#
# Usage:
#   bash scripts/install-agents.sh                    # interactive install
#   bash scripts/install-agents.sh --auto             # non-interactive, default paths
#   bash scripts/install-agents.sh --plugin-dir <dir>  # custom plugin root
#
# What gets installed:
#   19 agent roles          → claude/agent-roles/*/
#   15 agent stubs          → ~/.claude/agents/*.md
#   24 stack/delivery plugins → claude/plugins/*/
#   7 hook scripts          → hooks/*.sh + hooks.json
#   13 protocols            → skills/_shared/protocols/
#   Deep Spec               → protocol + templates + config
#   Per-agent rules         → .claude/rules/agent-*.md
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/claude"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1"; }
header(){ echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

# ── Parse args ─────────────────────────────────────────────────────────────
AUTO=false
PLUGIN_DIR=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto) AUTO=true; shift ;;
    --plugin-dir) PLUGIN_DIR="$2"; shift 2 ;;
    --help) echo "Usage: bash install-agents.sh [--auto] [--plugin-dir <dir>]"; exit 0 ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

if [ -z "$PLUGIN_DIR" ]; then
  PLUGIN_DIR="$CLAUDE_HOME/plugins/sdlc-automation-agent"
fi

# ── Header ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}            ${GREEN}sdlc-automation-agent — Full Install${NC}            ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}19 agent roles · 24 plugins · 7 hooks · Deep Spec${NC}     ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$AUTO" = false ]; then
  echo "  Plugin directory: $PLUGIN_DIR"
  echo "  Claude home:      $CLAUDE_HOME"
  echo "  Source:           $CLAUDE_DIR"
  echo ""
  read -rp "  Proceed with install? [Y/n] " confirm
  confirm="${confirm:-Y}"
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "  Aborted."
    exit 0
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# STEP 1 — Install plugin files
# ═════════════════════════════════════════════════════════════════════════════
header "Step 1/6 — Installing plugin to $PLUGIN_DIR"

mkdir -p "$PLUGIN_DIR"
PLUGIN_PARENT="$(dirname "$PLUGIN_DIR")"

# Use rsync for efficient copy, fall back to cp
if command -v rsync &>/dev/null; then
  rsync -a --delete \
    --exclude='.git' --exclude='node_modules' --exclude='__pycache__' \
    --exclude='.DS_Store' --exclude='*.pyc' \
    "$CLAUDE_DIR/" "$PLUGIN_DIR/"
  ok "Plugin copied via rsync ($(du -sh "$PLUGIN_DIR" 2>/dev/null | cut -f1))"
else
  mkdir -p "$PLUGIN_DIR"
  cp -R "$CLAUDE_DIR"/* "$PLUGIN_DIR/" 2>/dev/null || true
  ok "Plugin copied via cp"
fi

# ═════════════════════════════════════════════════════════════════════════════
# STEP 2 — Create agent stubs
# ═════════════════════════════════════════════════════════════════════════════
header "Step 2/6 — Installing agent stubs to $CLAUDE_HOME/agents/"

mkdir -p "$CLAUDE_HOME/agents"

STUBS_SRC="$CLAUDE_DIR/agents"
if [ -d "$STUBS_SRC" ]; then
  cp "$STUBS_SRC"/*.md "$CLAUDE_HOME/agents/" 2>/dev/null || true
  AGENT_COUNT=$(ls "$CLAUDE_HOME/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
  ok "$AGENT_COUNT agent stubs installed"

  # Update CLAUDE_PLUGIN_ROOT in stubs if plugin dir differs from default
  if [ "$PLUGIN_DIR" != "\${CLAUDE_PLUGIN_ROOT}" ]; then
    info "Updating CLAUDE_PLUGIN_ROOT references in stubs..."
    for stub in "$CLAUDE_HOME/agents"/*.md; do
      if grep -q 'CLAUDE_PLUGIN_ROOT' "$stub" 2>/dev/null; then
        # Replace the generic reference with explicit path
        sed -i '' "s|\${CLAUDE_PLUGIN_ROOT}|$PLUGIN_DIR|g" "$stub" 2>/dev/null || true
      fi
    done
    ok "Plugin root references updated"
  fi
else
  warn "No agent stubs found at $STUBS_SRC"
fi

# ═════════════════════════════════════════════════════════════════════════════
# STEP 3 — Register plugin in Claude Code settings
# ═════════════════════════════════════════════════════════════════════════════
header "Step 3/6 — Registering plugin in Claude Code settings"

SETTINGS_FILE="$CLAUDE_HOME/settings.json"

# Create or update settings.json
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{"enabledPlugins":{}}' > "$SETTINGS_FILE"
fi

# Add env var for CLAUDE_PLUGIN_ROOT
python3 -c "
import json, os

path = '$SETTINGS_FILE'
with open(path) as f:
    cfg = json.load(f)

if 'env' not in cfg:
    cfg['env'] = {}
cfg['env']['CLAUDE_PLUGIN_ROOT'] = '$PLUGIN_DIR'

if 'enabledPlugins' not in cfg:
    cfg['enabledPlugins'] = {}
cfg['enabledPlugins']['sdlc-automation-agent'] = True

# Add agent stubs path so Claude can find them
if 'agentPaths' not in cfg:
    cfg['agentPaths'] = []
agent_path = '$CLAUDE_HOME/agents'
if agent_path not in cfg['agentPaths']:
    cfg['agentPaths'].append(agent_path)

with open(path, 'w') as f:
    json.dump(cfg, f, indent=2)
print('OK')
" 2>/dev/null && ok "Plugin registered in settings.json" || err "Failed to update settings.json"

# ── Also register in installed_plugins.json ────────────────────────────────
INSTALLED_PLUGINS="$CLAUDE_HOME/plugins/installed_plugins.json"
mkdir -p "$(dirname "$INSTALLED_PLUGINS")"

python3 -c "
import json, os, datetime

path = '$INSTALLED_PLUGINS'
ts = datetime.datetime.utcnow().isoformat() + 'Z'

if os.path.exists(path):
    with open(path) as f:
        reg = json.load(f)
else:
    reg = {'version': 2, 'plugins': {}}

# Add or update the plugin entry
plugin_key = 'sdlc-automation-agent'
now = datetime.datetime.utcnow().isoformat() + 'Z'
entry = {
    'scope': 'user',
    'installPath': '$PLUGIN_DIR',
    'version': '2.0.0',
    'installedAt': now,
    'lastUpdated': now
}

if plugin_key not in reg['plugins']:
    reg['plugins'][plugin_key] = []

# Check if this install path already exists
existing = [e for e in reg['plugins'][plugin_key] if e.get('installPath') == '$PLUGIN_DIR']
if not existing:
    reg['plugins'][plugin_key].append(entry)
    print('Added to registry')
else:
    print('Already registered')

with open(path, 'w') as f:
    json.dump(reg, f, indent=2)
" 2>/dev/null && ok "Plugin registered in installed_plugins.json" || warn "installed_plugins.json update skipped"

# ═════════════════════════════════════════════════════════════════════════════
# STEP 4 — Create .claude/rules/ for project-level agent rules
# ═════════════════════════════════════════════════════════════════════════════
header "Step 4/6 — Creating agent rule files"

PROJECT_RULES="$PROJECT_ROOT/.claude/rules"
mkdir -p "$PROJECT_RULES"

RULE_COUNT=$(ls "$PROJECT_RULES"/agent-*.md 2>/dev/null | wc -l)
if [ "$RULE_COUNT" -lt 19 ]; then
  info "Scaffolding missing agent rules..."
  bash "$SCRIPT_DIR/install-deep-spec.sh" 2>/dev/null || true
fi

ok "Agent rules ready at $PROJECT_RULES"

# ═════════════════════════════════════════════════════════════════════════════
# STEP 5 — Install hooks
# ═════════════════════════════════════════════════════════════════════════════
header "Step 5/6 — Installing hooks"

HOOKS_SRC="$PLUGIN_DIR/hooks"
HOOKS_JSON="$HOOKS_SRC/hooks.json"

if [ -f "$HOOKS_JSON" ]; then
  # Create project-level hooks config link
  PROJECT_HOOKS="$PROJECT_ROOT/.claude/hooks.json"
  if [ ! -f "$PROJECT_HOOKS" ]; then
    mkdir -p "$PROJECT_ROOT/.claude"
    ln -sf "$HOOKS_JSON" "$PROJECT_HOOKS" 2>/dev/null && \
      ok "Hooks linked to project" || \
      warn "Could not symlink hooks — copy instead"
  fi

  # Make hook scripts executable
  chmod +x "$HOOKS_SRC"/*.sh 2>/dev/null || true
  ok "Hook scripts made executable ($(ls "$HOOKS_SRC"/*.sh 2>/dev/null | wc -l) scripts)"
else
  warn "No hooks.json found at $HOOKS_JSON"
fi

# ═════════════════════════════════════════════════════════════════════════════
# STEP 6 — Create orchestrator workspace + verify
# ═════════════════════════════════════════════════════════════════════════════
header "Step 6/6 — Creating orchestrator workspace"

mkdir -p ".sdlc-automation-agent/.orchestrator"
mkdir -p ".sdlc-automation-agent/.protocols"
mkdir -p ".sdlc-automation-agent/specs"

# Copy Deep Spec protocol if present
if [ -f "$PLUGIN_DIR/skills/_shared/protocols/deep-spec.md" ]; then
  cp "$PLUGIN_DIR/skills/_shared/protocols/deep-spec.md" \
     ".sdlc-automation-agent/.protocols/deep-spec.md"
  ok "Deep Spec protocol installed"
fi

# ── Verify installation ─────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Verification ───────────────────────────────────────────────${NC}"
echo ""

PASS=0
FAIL=0
WARN=0

verify() {
  local desc="$1" path="$2"
  if [ -e "$path" ]; then
    echo -e "  ${GREEN}✓${NC} $desc"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗${NC} $desc"
    FAIL=$((FAIL + 1))
  fi
}

verify_contains() {
  local desc="$1" file="$2" pattern="$3"
  if [ -f "$file" ] && grep -q "$pattern" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $desc"
    PASS=$((PASS + 1))
  else
    echo -e "  ${YELLOW}○${NC} $desc (not found — may need manual config)"
    WARN=$((WARN + 1))
  fi
}

verify "Plugin directory"            "$PLUGIN_DIR"
verify "Agent roles"                 "$PLUGIN_DIR/agent-roles"
verify "Agent stubs (software-engineer)" "$CLAUDE_HOME/agents/software-engineer.md"
verify "Agent stubs (product-manager)"   "$CLAUDE_HOME/agents/product-manager.md"
verify "Agent stubs (quality-engineer)"  "$CLAUDE_HOME/agents/quality-engineer.md"
verify "Agent stubs (code-reviewer)"     "$CLAUDE_HOME/agents/code-reviewer.md"
verify "Agent stubs (solution-architect)" "$CLAUDE_HOME/agents/solution-architect.md"
verify "Plugins directory"           "$PLUGIN_DIR/plugins"
verify "Skills directory"            "$PLUGIN_DIR/skills"
verify "SDLC workflows plugin"       "$PLUGIN_DIR/plugins/sdlc-workflows"
verify "Stack frontend plugin"       "$PLUGIN_DIR/plugins/stack-frontend"
verify "System design plugin"        "$PLUGIN_DIR/plugins/system-design"
verify "Agent toolkit plugin"        "$PLUGIN_DIR/plugins/agent-toolkit"
verify "Hooks"                       "$PLUGIN_DIR/hooks/hooks.json"
verify "Session start hook"          "$PLUGIN_DIR/hooks/session-start.sh"
verify "Pre-tool guard"              "$PLUGIN_DIR/hooks/pre-tool-guard.sh"
verify "Protocols"                   "$PLUGIN_DIR/skills/_shared/protocols"
verify "Spec templates"              "$PLUGIN_DIR/skills/_shared/templates/specs"
verify "Packs directory"             "$PLUGIN_DIR/packs"
verify "Agent-skill map"             "$PLUGIN_DIR/plugins/AGENT-SKILL-MAP.yaml"
verify "Orchestrator workspace"      ".sdlc-automation-agent/.orchestrator"
verify "Project rules"               "$PROJECT_RULES/sdlc-agent-development.md"
verify_contains "Plugin env in settings.json" "$SETTINGS_FILE" "CLAUDE_PLUGIN_ROOT"
verify_contains "Plugin enabled in settings.json" "$SETTINGS_FILE" "sdlc-automation-agent"
verify_contains "Plugin in registry" "$INSTALLED_PLUGINS" "sdlc-automation-agent"

echo ""
echo -e "${BLUE}━━━ Summary ──────────────────────────────────────────────────────${NC}"
echo ""
echo -e "  ${GREEN}${PASS} passed${NC} · ${RED}${FAIL} failed${NC} · ${YELLOW}${WARN} warnings${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "  ${RED}Some verifications failed. Check output above.${NC}"
else
  echo -e "  ${GREEN}── Installation complete ──${NC}"
  echo ""
  echo "  What's installed:"
  echo "    • 19 agent roles at $PLUGIN_DIR/agent-roles/"
  echo "    • $AGENT_COUNT agent stubs at $CLAUDE_HOME/agents/"
  echo "    • 24 stack/delivery plugins"
  echo "    • 7 hooks (session start, guards, audit)"
  echo "    • 13+ shared protocols"
  echo "    • Deep Spec (traceability chain + gates)"
  echo "    • Per-agent .claude/rules/"
  echo ""
  echo -e "  ${YELLOW}To activate in a project:${NC}"
  echo "    1. cd your-project"
  echo "    2. Describe what you want to build"
  echo "    3. Or run:  /sdlc-automation-agent"
  echo ""
  echo -e "  ${YELLOW}For existing projects:${NC}"
  echo "    bash $SCRIPT_DIR/install-deep-spec.sh"
  echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
