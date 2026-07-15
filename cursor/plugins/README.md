# Claude Code Plugins — SDLC + Stack Skills

**Runtime install bundles** for Claude Code. Each plugin bundles **multi-file skills** (index `SKILL.md` + topic/rule markdown).

**Reference shelf:** upstream repos live in `new-skills/` (read-only for agents). **Do not load `new-skills/` at runtime** — use paths below.

**Agent mapping:** [AGENT-SKILL-MAP.yaml](./AGENT-SKILL-MAP.yaml)  
**Agent roster:** [../agents/AGENTS-ROSTER.md](../agents/AGENTS-ROSTER.md)  
**Plugin agent quarantine:** [PLUGIN-AGENT-MAP.yaml](./PLUGIN-AGENT-MAP.yaml) — upstream personas in `plugins/*/reference/agents/` only  
**Agent separation protocol:** [../skills/_shared/protocols/agent-separation.md](../skills/_shared/protocols/agent-separation.md)  
**Reference → canonical map:** [REFERENCE-MAP.yaml](./REFERENCE-MAP.yaml)  
**Loading protocol:** [../skills/_shared/protocols/stack-skill-loading.md](../skills/_shared/protocols/stack-skill-loading.md)  
**Never use new-skills at runtime:** [../skills/_shared/protocols/reference-sources.md](../skills/_shared/protocols/reference-sources.md)

## Agents vs skills (one project)

| Layer | Path | Install |
|-------|------|---------|
| **14 SDLC delivery agents** | `agents/` + `claude-agents/` stubs | Root plugin only |
| **Plugin skills** | `plugins/*/skills/` | Per stack/workflow plugin |
| **Quarantined upstream personas** | `plugins/*/reference/agents/` | Not auto-loaded |

Do **not** install duplicate `code-reviewer` from `sdlc-workflows` or `pr-review-toolkit` — use root `agents/code-reviewer/` only.

## Quick install

```bash
# From this repo root — SDLC 9-agent orchestrator
claude --plugin-dir /path/to/agents

# Stack plugins (add alongside orchestrator)
claude --plugin-dir /path/to/agents/plugins/stack-frontend
claude --plugin-dir /path/to/agents/plugins/stack-golang
claude --plugin-dir /path/to/agents/plugins/stack-aws
claude --plugin-dir /path/to/agents/plugins/system-design
```

## Plugin catalog

| Plugin | Skills | Source | Best for |
|--------|--------|--------|----------|
| **sdlc-automation-agent** (repo root) | Orchestrator + 9 agents | This repo | Full delivery pipeline |
| **stack-golang** | 43 | `cc-skills-golang` | Go services, CLI, gRPC |
| **stack-frontend** | 28 | `claude-code-nextjs-skills` + `agent-skills-frontend` | React, Next.js, AI apps, Vercel performance |
| **stack-aws** | 52 | `agent-toolkit-for-aws` | AWS IaC, ECS, Lambda, Bedrock |
| **stack-azure** | 191 | `Agent-Skills` | Azure services (load on demand) |
| **sdlc-workflows** | 24 | `agent-skills1` | TDD, spec-driven, review workflows |
| **agent-toolkit** | 43 | `agent-toolkit` | Jira, diagrams, OpenAPI, README |
| **system-design** | 22 | `system-design-skills` | HLD, capacity, distributed systems |
| **staff-engineer** | 14 | `claude-code-staff-engineer` | Optional: TDD, delegation, forensic debug |
| **claude-skills-catalog** | 66 | `claude-skills` | Extended role skills (Spring Boot, FastAPI, Terraform, Vue, …) |
| **delivery-toolkit/** | 5 sub-plugins | `claude-code/plugins` | PR review, feature-dev, security |

## Recommended bundles

| Project type | Install |
|--------------|---------|
| **NestJS + React + AWS** (Hano) | root + `system-design` + `stack-frontend` + `stack-aws` + `sdlc-workflows` + `pr-review-toolkit` |
| **Go + AWS** | root + `system-design` + `stack-golang` + `stack-aws` + `sdlc-workflows` |
| **Next.js AI app** | root + `system-design` + `stack-frontend` + `sdlc-workflows` |
| **Java + Azure** | root + `system-design` + `stack-azure` + `sdlc-workflows` + `packs/languages/java-spring` |
| **Greenfield architecture** | root + `system-design` + `sdlc-workflows` + `agent-toolkit` |
| **Minimal** | root + `sdlc-workflows` |

## SDLC agent → plugin skills

| Agent | Primary plugins | Key skills |
|-------|-----------------|------------|
| **Product Manager** | sdlc-workflows, agent-toolkit | spec-driven-development, planning-and-task-breakdown, jira |
| **Solution Architect** | system-design, sdlc-workflows, agent-toolkit, stack-*, **claude-skills-catalog** | system-design (orchestrator), api-design, data-storage, **architecture-designer** (phase 2) |
| **Software Engineer** | stack-golang / stack-frontend, sdlc-workflows | next-best-practices, golang-project-layout, incremental-implementation |
| **Quality Engineer** | sdlc-workflows, stack-frontend | test-driven-development, chrome-devtools, golang-testing |
| **Platform Engineer** | stack-aws / stack-azure, system-design, sdlc-workflows | aws-containers, observability, load-balancing, ci-cd-and-automation |
| **Code Reviewer** | sdlc-workflows, delivery-toolkit | code-review-and-quality, pr-review-toolkit |
| **Compliance Engineer** | sdlc-workflows, stack-aws/azure | security-and-hardening, aws-iam, azure-key-vault |
| **Technical Writer** | sdlc-workflows, agent-toolkit | documentation-and-adrs, mermaid-diagrams |
| **Research Advisor** | system-design, sdlc-workflows, agent-toolkit | system-design, requirements-scoping, context-engineering |

Full mapping with conditional rules: [AGENT-SKILL-MAP.yaml](./AGENT-SKILL-MAP.yaml).

## Skill file patterns

Each stack skill uses the **next-best-practices** pattern:

```
skills/next-best-practices/
├── SKILL.md              # Index + links to topics
├── rsc-boundaries.md
├── data-patterns.md
└── ...

skills/react-best-practices/
├── SKILL.md              # Category index
└── rules/
    ├── async-parallel.md
    └── bundle-barrel-imports.md
```

Claude loads **SKILL.md first**, then **1–3 topic files** for the current task.

## Three knowledge layers

| Layer | Location | Purpose |
|-------|----------|---------|
| **Universal** | `skills/_shared/specialist-skills/` | Language-agnostic engineering |
| **Stack packs** | `packs/languages/*`, `packs/clouds/*` | Verify commands, CI snippets |
| **Stack plugins** | `plugins/stack-*/skills/` | Multi-file best practices (this folder) |

## Specialist skills sync

`claude-software-skills` is mirrored to `skills/_shared/specialist-skills/` (and `specialist-skills-source/` for maintainer diffs). Agent registries in `agents/*/skill-extensions/registry.yaml` reference specialist skills; `stack_plugins` references this folder.

## Updating from reference shelf (`new-skills/`)

**Agents must not edit or load `new-skills/` during delivery.** Maintainers sync into canonical paths:

```bash
./scripts/sync-from-new-skills.sh           # core plugins + specialist skills + claude-skills-catalog (66)
```

Map: [REFERENCE-MAP.yaml](./REFERENCE-MAP.yaml).

## Delivery sub-plugins

```bash
claude --plugin-dir plugins/delivery-toolkit/feature-dev
claude --plugin-dir plugins/delivery-toolkit/pr-review-toolkit
claude --plugin-dir plugins/delivery-toolkit/code-review
claude --plugin-dir plugins/delivery-toolkit/security-guidance
claude --plugin-dir plugins/delivery-toolkit/commit-commands
```

## Marketplace manifest

See [.claude-plugin/marketplace.json](./.claude-plugin/marketplace.json) for machine-readable plugin list.
