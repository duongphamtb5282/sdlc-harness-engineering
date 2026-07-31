# agent-v01 Agent System

This is the BMAD-METHOD hybrid agent kernel — a structured agent system with personas, protocols, skills, and slash commands.

## Structure

```
agent-v01/                     # Self-contained agent kernel
├── agents/                    # 8 BMAD persona definitions
├── protocols/                 # 9 production-grade protocols
├── agent-skills/              # Symlinks to BMAD-METHOD skills
├── core-skills/
│   ├── claude-skills/         # 65 domain expert skills
│   ├── agent-skills-general-sdlc/  # 27 process workflow skills
│   ├── awesome-copilot/       # 377+ technical skills
│   └── claude-software-skills/     # 55 reference guides
├── references/templates/      # Output templates + Draw.io
├── .claude/commands/          # 7 slash commands
└── BMAD-METHOD/               # BMAD kernel source (npm package)
```

## Key Rules

- **Do NOT modify** `BMAD-METHOD/` source files — it's an upstream npm package. Symlinks in `agent-skills/` point into it.
- **Do NOT add** embedded `.git/` repos to `core-skills/` — strip them before committing.
- **Protocols** live in `protocols/` and are synced from `core-skills/claude-code-production-grade-plugin/skills/_shared/protocols/` via `agent-v01/scripts/sync-protocols.sh`.
- **Agent definitions** are in `agents/` — each `.md` file defines one persona with First Action, Workflow, and Supplementary skill tables.
- **Slash commands** live in `.claude/commands/` at BOTH the project root AND inside `agent-v01/` (for plugin mode discovery).
- **Output templates** live in `references/templates/`.
- **Trade-off documents** — every load-bearing architecture decision gets BOTH an ADR (`docs/adr/`) and a TO-N row in the trade-off document (`docs/trade-offs/{component}-trade-offs.md`). Deferred decisions are named with revisit conditions (bmad-architecture).
- **QA test cases** — once stories/tasks exist (after `/plan`), generate test cases with `/qa` → `docs/qa/test-cases.md`. `/build` derives RED tests from them; no acceptance criterion ships without a test case.

## When Adding Skills

1. Add the skill to the appropriate `core-skills/{source}/skills/{name}/SKILL.md`
2. Reference it in the relevant agent's `agents/{persona}.md` Supplementary table
3. Update the `bmad-method.md` dispatch table if it's a primary skill

## When Adding Commands

1. Create `.md` in `agent-v01/.claude/commands/`
2. Copy to root `.claude/commands/` for workspace-level discovery
3. Reference the appropriate agent persona and skills in the command body

## Pipeline & Artifacts

Each stage produces artifacts the next stage consumes:

| Stage | Command | Artifacts produced |
|-------|---------|--------------------|
| Discovery | `/discover` | `docs/ideas/{name}.md` — problem, assumptions (with validation gates), risk (owner + early-warning signal), cost, roadmap |
| Specification | `/spec` | `SPEC.md` — objectives, user stories, ACs, assumptions |
| Architecture | `/arch-design` | `docs/adr/*.md`, `docs/trade-offs/*.md`, `docs/architecture/{component}.md`, `*.drawio`, API contracts (direct entry supported — no SPEC required) |
| Planning | `/plan` | `tasks/plan.md` (dependency graph), `tasks/todo.md` (ordered tasks) |
| QA test cases | `/qa` | `docs/qa/test-cases.md` — per-story unit/API/E2E test cases + coverage map |
| Build | `/build` | Code + tests (RED tests derived from `/qa` test cases), `tests/test-summary.md`, per-task commits |
| Review | `/review` | `BMAD-REVIEW-REPORT.md`, `protocols/receipts/{name}.json` |

**Flow:** `/discover → /spec → /arch-design → /plan → /qa → /build → /review`

**Direct entry is allowed at any stage** (e.g. `/arch-design` straight from a requirements conversation — the bmad-architecture elicitation; `/qa` straight after `/plan`).

## Ruflo Harness Integration

The project has the **Ruflo execution harness** installed (`.claude-flow/`):

- **Memory:** `.claude-flow/data/` — AgentDB memory (cross-session recall)
- **Swarm:** mesh topology, max 5 agents (`claude-flow swarm init` to start)
- **MCP:** `claude-flow` server via `.mcp.json` (memory_store, swarm_init, flow-nexus)
- **Daemon:** `ruflo daemon start` — background workers (map, audit, optimize)
- **Config:** `.claude-flow/config.yaml` (canonical)
- **Skills:** `.claude/skills/` (8 ruflo skills) + `.agents/skills/ruflo/`
- **Hooks:** agent-team hooks via `claudeFlow.agentTeams.hooks` in `.claude/settings.json`

**When to use the harness:**
- Cross-session memory → ruflo AgentDB (`claude-flow memory`)
- Parallel tasks → `claude-flow swarm` / `swarm-orchestration` skill
- Task routing → the hook system auto-routes

**BMAD remains the methodology layer** — ruflo executes; BMAD decides what and how.
