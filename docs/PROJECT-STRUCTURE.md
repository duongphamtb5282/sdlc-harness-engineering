# Recommended project structure

This repo is a **Claude Code plugin meta-repo**. Product application code (e.g. seat-reservation) lives in a **separate repository** with this plugin installed on top.

## Two-runtime model

| Runtime | Path | Purpose |
|---------|------|---------|
| **Claude Code (canonical)** | Repo root | Orchestrator, 13 delivery agents, hooks, packs, plugins |
| **Cursor (optional kit)** | `cursor/` | Standalone Cursor install — maintained separately; do not symlink from root |

| Shelf (never runtime) | `new-skills/` | Upstream reference for maintainer sync only |

## Canonical layout (Claude Code)

```
agents/                              # Claude Code plugin root
├── .claude-plugin/
│   └── plugin.json                  # skills + agents + hooks
├── agents/{role}/                   # 13 delivery roles (SKILL.md, agent.md, references/)
├── claude-agents/                   # File copies of agents/*/agent.md (no symlinks)
├── skills/
│   ├── sdlc-automation-agent/       # Orchestrator
│   └── _shared/                     # protocols, specialist-skills, templates
├── hooks/                           # Lifecycle enforcement (see hooks/README.md)
│   ├── hooks.json                   # SessionStart, PreToolUse, PostToolUse, Stop, …
│   ├── lib/                         # State machines, receipt validator (called by skills)
│   └── data/compacted-rules.md      # Rules re-injected after compaction
├── packs/                           # Stack verify snippets (languages/, clouds/)
├── plugins/                         # Optional stack bundles (skills only at runtime)
│   ├── system-design/
│   ├── stack-frontend/
│   ├── stack-aws/
│   ├── sdlc-workflows/
│   ├── claude-skills-catalog/
│   └── delivery-toolkit/            # security-guidance has its own hooks plugin
├── rules/                           # Crew rules source (flaky tests, receipts, …)
├── scripts/                         # Maintainer sync (not loaded at runtime)
├── docs/                            # Architecture and guides
└── new-skills/                      # Reference shelf — NOT loaded at runtime
```

## Product repo layout (NestJS + React + AWS)

Install the root plugin + stack plugins, then init SDLC workspace **in the product repo**:

```
your-product/
├── CLAUDE.md                        # Commands, safety, skill index
├── .sdlc-automation-agent.yaml      # Project config (from init)
├── .sdlc-automation-agent/
│   ├── specs/                       # Feature specs
│   ├── steering/                    # Product/tech steering
│   └── .orchestrator/
│       ├── receipts/                # Agent handoff receipts (JSON)
│       ├── lifecycle-state.json     # Scrum/Kanban state (hooks/lib)
│       └── story-pipeline.json      # Per-story SE→QE→CR state
├── docs/architecture/
│   └── tech-stack.yaml              # Polyglot stack declaration (SA phase 3)
└── .claude/docs/                    # Optional team memory index
```

**Cursor-specific** (product repo, not this meta-repo):

```
your-product/
├── .cursor/rules/                   # Project rules (.mdc)
├── .cursor/skills/                  # Curated stack skills (~35, not full catalog)
└── .cursor/hooks.json               # Optional — product-specific Cursor hooks
```

## What was wrong before

| Gap | Fix |
|-----|-----|
| `hooks/` had only `data/` — skills referenced missing `hooks/lib/*.py` | Added `hooks/lib/` + `hooks/hooks.json` |
| Root `plugin.json` had no `hooks` key | Wired `"hooks": "./hooks/hooks.json"` |
| `claude-agents/` used symlinks | File copies via `scripts/sync-claude-agents-stubs.sh` |
| Docs said "9 agents" | Updated to 13 delivery agents + orchestrator |
| Hooks split across plugins only | Root orchestrator hooks + optional `security-guidance` plugin |

## Install order (Claude Code)

```bash
# 1. Root orchestrator (agents + skills + hooks)
claude --plugin-dir /path/to/agents

# 2. Stack plugins for your profile
claude --plugin-dir /path/to/agents/plugins/system-design
claude --plugin-dir /path/to/agents/plugins/stack-frontend
claude --plugin-dir /path/to/agents/plugins/stack-aws
claude --plugin-dir /path/to/agents/plugins/sdlc-workflows

# 3. Optional: security hook plugin (additional PostToolUse/Stop review)
claude --plugin-dir /path/to/agents/plugins/delivery-toolkit/security-guidance
```

## Maintainer sync

```bash
./scripts/sync-all.sh
```
