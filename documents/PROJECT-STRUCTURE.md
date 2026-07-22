# Recommended project structure

This repo ships **portable runtime packages** for Claude Code and Cursor. Product application code lives in a **separate repository** with `.claude/` and/or `.cursor/` copied in.

## Layout of this repo

```
agents/
├── .claude/            # Claude Code source of truth + portable package
│   ├── skills/         # Orchestrator + _shared
│   ├── agents/         # Role stubs
│   ├── agent-roles/    # Full 13+ delivery roles
│   ├── hooks/          # Lifecycle hooks
│   ├── packs/          # Verify snippets
│   ├── plugins/        # Stack plugins
│   ├── rules/          # Crew rules (.md)
│   └── plugin.json
├── .cursor/            # Curated Cursor package (built from .claude)
│   ├── rules/          # *.mdc
│   ├── skills/         # Roles + stack skills
│   └── AGENTS.md
├── docs/               # Guides
├── scripts/            # Merge / package / sync
└── new-skills/         # Reference shelf — NEVER runtime
```

## Two-runtime model

| Runtime | Path | Purpose |
|---------|------|---------|
| **Claude Code** | `.claude/` | Full runtime: agents, hooks, packs, plugins |
| **Cursor** | `.cursor/` | Rules + curated skills (rebuilt from `.claude/`) |
| **Shelf** | `new-skills/` | Upstream reference for maintainer sync only |

### Portable install

```bash
./scripts/package-claude.sh
./scripts/package-cursor.sh

rsync -a --delete .claude/ /path/to/product/.claude/
rsync -a --delete .cursor/ /path/to/product/.cursor/
```

## Product repo layout

```
your-product/
├── CLAUDE.md                        # Commands, safety, skill index (optional)
├── .sdlc-automation-agent.yaml      # Project config (from init)
├── .sdlc-automation-agent/
│   ├── specs/
│   ├── steering/
│   └── .orchestrator/
│       ├── receipts/
│       ├── lifecycle-state.json
│       └── story-pipeline.json
├── docs/architecture/
│   └── tech-stack.yaml
├── .claude/                         # From this repo
└── .cursor/                         # From this repo (if using Cursor)
```

## Maintainer sync

```bash
./scripts/sync-from-new-skills.sh   # new-skills → .claude/
./scripts/sync-all.sh               # full validate + package both runtimes
./scripts/sync-to-cursor.sh [product]
```

See [portable-packages.md](./portable-packages.md) and the root [README.md](../README.md).
