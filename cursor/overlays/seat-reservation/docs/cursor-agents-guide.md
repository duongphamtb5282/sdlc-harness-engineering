# Cursor agents guide — Seat Reservation

## Where Cursor reads from

Cursor only loads from **`.cursor/`** at the repo root:

```
seat-reservation/
├── .cursor/
│   ├── rules/*.mdc          ← rules (auto-applied)
│   ├── skills/<name>/       ← skills (invoke by name)
│   └── AGENTS.md
├── packs/                   ← stack verify snippets
├── docs/architecture/tech-stack.yaml
└── .sdlc-automation-agent.yaml
```

Open **`seat-reservation`** in Cursor (File → Open Folder).

The optional `cursor/` folder is only a **sync backup** from the agents monorepo — Cursor does **not** read it unless you copy into `.cursor/`.

## Sync / refresh `.cursor/` from agents kit

```bash
# 1. Update vendored kit (optional backup)
bash /path/to/agents/cursor/scripts/sync-to-product.sh /path/to/seat-reservation

# 2. Install into .cursor/ (what Cursor actually uses)
cd /path/to/seat-reservation
bash cursor/scripts/install-into-workspace.sh --full
```

Or one-liner from agents repo:

```bash
KIT=/path/to/agents/cursor
SR=/path/to/seat-reservation
rsync -a "$KIT/.cursor/rules/" "$SR/.cursor/rules/"
rsync -a "$KIT/.cursor/skills/" "$SR/.cursor/skills/"
rsync -a "$KIT/packs/" "$SR/packs/"
```

## Prompting

Name skills explicitly:

```
Use skill add-api-endpoint:
Add POST /api/seats/:id/extend-hold via Kafka cmd seat.extend_hold.
Run pnpm build && pnpm test.
```

| Task | Skills |
|------|--------|
| New RPC | `add-api-endpoint` |
| Backend | `software-engineer` + `nestjs-expert` |
| Frontend | `frontend-engineer` + `react-best-practices` |
| Tests | `quality-engineer` + `test-driven-development` |
| Review | `code-reviewer` + `preflight-pr` |
| Architecture | `solution-architect` + `c4-architecture` |
| Full pipeline | `sdlc-automation-agent` (use sparingly) |
