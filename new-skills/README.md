# new-skills — reference only (do not use at runtime)

This folder holds **upstream skill and plugin repositories for comparison and manual sync**.  
Agents, hooks, and protocols in this project **must not read, write, or load paths under `new-skills/`** during delivery.

## Canonical locations (use these instead)

| Reference folder (`new-skills/…`) | Canonical copy (runtime) | Purpose |
|-----------------------------------|--------------------------|---------|
| `claude-software-skills/` | `skills/_shared/specialist-skills/` | Universal deep skills (44+ skills) |
| `claude-software-skills/` | `skills/_shared/specialist-skills-source/` | Maintainer mirror for diff/sync |
| `cc-skills-golang/` | `plugins/stack-golang/skills/` | Go stack best practices |
| `claude-code-nextjs-skills/` | `plugins/stack-frontend/skills/` | React / Next.js / AI SDK |
| `agent-toolkit-for-aws/` | `plugins/stack-aws/skills/` | AWS service skills |
| `Agent-Skills/` | `plugins/stack-azure/skills/` | Azure service skills |
| `agent-skills1/` | `plugins/sdlc-workflows/skills/` | TDD, spec-driven, review workflows |
| `agent-toolkit/` | `plugins/agent-toolkit/skills/` | Jira, diagrams, OpenAPI utilities |
| `system-design-skills/` | `plugins/system-design/skills/` | HLD building blocks |
| `claude-code-production-grade-plugin/` | `plugins/production-grade/skills/` | Alternative production pipeline |
| `claude-code/plugins/*` | `plugins/delivery-toolkit/*/` | feature-dev, pr-review, security, … |
| `claude-code-staff-engineer/` | `plugins/staff-engineer/` | Senior staff engineer workflow (optional) |
| `claude-skills/` | `plugins/claude-skills-catalog/` *(optional)* | Extended 66-skill catalog — sync on demand |
| `sample-claude-code-plugins-for-startups/` | — | Samples only; not installed by default |

**Orchestrator:** repo root (`agents/`, `skills/sdlc-automation-agent/`) — not under `new-skills/`.

## Maintainer sync

When upstream changes, copy **into canonical paths** (never edit `new-skills/` from agents):

```bash
./scripts/sync-from-new-skills.sh           # core plugins + specialist skills
./scripts/sync-from-new-skills.sh --all   # include optional claude-skills catalog
```

Then commit changes under `plugins/`, `skills/_shared/specialist-skills/`, not `new-skills/`.

## Protocol

See [skills/_shared/protocols/reference-sources.md](../skills/_shared/protocols/reference-sources.md).

## Agent mapping

Runtime skill routing: [plugins/AGENT-SKILL-MAP.yaml](../plugins/AGENT-SKILL-MAP.yaml).
