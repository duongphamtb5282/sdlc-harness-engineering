#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# install-to-project.sh — Install agent-v01 into a new project's .claude/
#
# Everything lands inside the target project's .claude/ folder:
#
#   your-project/
#   └── .claude/
#       ├── commands/          ← 7 slash commands (auto-discovered)
#       ├── agents/            ← 8 BMAD personas (auto-discovered)
#       ├── skills/            ← 500+ skills from 5 libraries
#       ├── hooks/             ← lifecycle hooks
#       ├── plugins/agent-v01/ ← the full kernel (self-contained)
#       └── .mcp.json          ← ruflo harness MCP
#
# Usage:
#   ./agent-v01/install-to-project.sh /path/to/new/project
#   ./agent-v01/install-to-project.sh --symlink /path/to/new/project   (links instead of copies)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MODE="copy"
TARGET=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --symlink) MODE="symlink"; shift ;;
    *) TARGET="$1"; shift ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "Usage: $0 [--symlink] /path/to/new/project"
  exit 1
fi

CLAUDE_DIR="$TARGET/.claude"
AGENT_V01="$ROOT/agent-v01"

echo "━━━ Installing agent-v01 into $TARGET/.claude/ ━━━━━━━━━"
echo "  Mode: $MODE"
echo ""

# Create target .claude structure
mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills" \
         "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/plugins" "$CLAUDE_DIR/helpers"

install_item() {
  local src="$1" dst="$2" label="$3"
  # src with trailing "/." = copy contents, not the dir itself
  local contents_only=false
  [[ "$src" == *"/." ]] && contents_only=true && src="${src%/}"
  # Skip missing sources (e.g. core-skills not published in git repo) instead of aborting
  if [ ! -e "$src" ]; then
    echo "  ⚠️  $label — source missing (not published in repo). Copy from the original working copy if needed."
    return 0
  fi
  if [ "$MODE" = "symlink" ]; then
    if [ "$contents_only" = true ]; then
      ln -sfn "$src"/* "$dst"/ 2>/dev/null || true
    else
      ln -sfn "$src" "$dst"
    fi
    echo "  🔗 $label → $dst"
  else
    if [ "$contents_only" = true ]; then
      cp -R "$src"/. "$dst"/
    elif [ -d "$src" ]; then
      rm -rf "$dst"
      cp -R "$src" "$dst"
    else
      cp "$src" "$dst"
    fi
    echo "  ✅ $label → $dst"
  fi
}

# ── 1. Slash commands (auto-discovered from .claude/commands/) ──
echo "[1/7] Slash commands..."
install_item "$AGENT_V01/.claude/commands/." "$CLAUDE_DIR/commands/" "commands (7)"

# ── 2. Agents (auto-discovered from .claude/agents/) ──────────
echo ""
echo "[2/7] Agent personas..."
install_item "$AGENT_V01/agents/." "$CLAUDE_DIR/agents/" "personas (8)"

# ── 3. Skills (auto-discovered from .claude/skills/) ──────────
echo ""
echo "[3/7] Skill libraries..."
install_item "$AGENT_V01/core-skills/claude-skills/skills" "$CLAUDE_DIR/skills/claude-skills" "claude-skills (66)"
install_item "$AGENT_V01/core-skills/agent-skills-general-sdlc/skills" "$CLAUDE_DIR/skills/sdlc" "SDLC skills (27)"
install_item "$AGENT_V01/core-skills/awesome-copilot/skills" "$CLAUDE_DIR/skills/awesome-copilot" "awesome-copilot (377)"
install_item "$AGENT_V01/core-skills/claude-software-skills" "$CLAUDE_DIR/skills/software-skills" "software-skills (55)"
install_item "$AGENT_V01/core-skills/ruflo-skills" "$CLAUDE_DIR/skills/ruflo-skills" "ruflo-skills (21)"

# ── 4. Hooks ───────────────────────────────────────────────────
echo ""
echo "[4/7] Hooks..."
install_item "$AGENT_V01/hooks/." "$CLAUDE_DIR/hooks/" "hooks"

# ── 5. Full kernel as plugin (self-contained) ──────────────────
echo ""
echo "[5/7] agent-v01 kernel (plugin)..."
if [ "$MODE" = "symlink" ]; then
  ln -sfn "$AGENT_V01" "$CLAUDE_DIR/plugins/agent-v01"
else
  rm -rf "$CLAUDE_DIR/plugins/agent-v01"
  cp -R "$AGENT_V01" "$CLAUDE_DIR/plugins/agent-v01"
fi
echo "  ✅ kernel → $CLAUDE_DIR/plugins/agent-v01/"

# ── 6. Ruflo harness (.mcp.json) ───────────────────────────────
echo ""
echo "[6/7] Ruflo harness..."
if [ -f "$ROOT/.mcp.json" ]; then
  install_item "$ROOT/.mcp.json" "$CLAUDE_DIR/.mcp.json" "ruflo MCP"
fi

# ── 7. CLAUDE.md (project rules) ───────────────────────────────
echo ""
echo "[7/7] CLAUDE.md..."
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  install_item "$ROOT/CLAUDE.md" "$TARGET/CLAUDE.md" "CLAUDE.md"
else
  echo "  – CLAUDE.md exists in target — keeping it (merge manually if needed)"
fi

echo ""
echo "━━━ Installation complete ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Target structure:"
echo "  $CLAUDE_DIR/"
echo "  ├── commands/    (7 slash commands — /discover /spec /arch-design /plan /qa /build /review)"
echo "  ├── agents/      (8 personas — auto-discovered)"
echo "  ├── skills/      (5 libraries, 500+ skills)"
echo "  ├── hooks/       (lifecycle hooks)"
echo "  ├── plugins/agent-v01/ (full kernel)"
echo "  └── .mcp.json    (ruflo harness)"
echo ""
echo "Next steps:"
echo "  1. cd $TARGET && claude"
echo "  2. Type /discover to start, or /help to list commands"
echo "  3. For the ruflo harness: npx ruflo init --minimal (in $TARGET)"
