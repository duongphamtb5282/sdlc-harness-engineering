# Nexus Agent Kernel

Single-kernel agent system: **execution harness** (memory, swarms, MCP, daemon) + **methodology layer** (8 personas, 9 protocols, 22 stacks, 500+ skills) + **slash command pipeline** for requirement discovery → spec → architecture → plan → QA test cases → build → review.

```
Agent = Model + Harness
  Harness executes (memory, parallel swarms, MCP tools, daemon)
  Methodology decides (personas, protocols, SDLC pipeline)
```

---

## Origin & Attribution

This repository is a **customized distribution derived from the BMAD-METHOD kernel** — *Breakthrough Method of Agile AI-driven Development* by Brian (BMad) Madison ([MIT license](https://opensource.org/licenses/MIT), v6.10.0, `agent-v01/BMAD-METHOD/`).

It is published as **proprietary IP**: the third-party skill libraries (`agent-v01/core-skills/`, ~308 MB of vendored open-source skills) and internal design documents (`documents/`) are intentionally **not included** in this repository. To install into a new project, copy `core-skills/` in from the original working copy first — `install-to-project.sh` installs it when present and skips it gracefully when absent.

---

## Table of Contents

1. [Architecture](#architecture)
2. [Technology Stack](#technology-stack)
3. [Setup & Installation](#setup--installation)
4. [Commands](#commands)
5. [Skill Detection](#skill-detection--yes-the-agent-detects-needed-skills-per-task)
6. [Ruflo Harness](#ruflo-harness--start--use)
7. [Cost Management](#cost-management)
8. [Project Structure](#project-structure)
9. [Protocol Sync](#protocol-sync)
10. [Validation](#validation)
11. [Further Reading](#further-reading)

---

## Architecture

### Layer Model

```
┌──────────────────────────────────────────────────────────────────┐
│  EXECUTION HARNESS (how agents run — runtime)                   │
│  Ruflo daemon (7 workers) · AgentDB memory · swarm (mesh, max 5)│
│  MCP server (memory_store, swarm_init, flow-nexus) · hooks       │
│  .claude-flow/ · .swarm/memory.db · .mcp.json · .claude/settings│
├──────────────────────────────────────────────────────────────────┤
│  SLASH COMMANDS (entry points)                                   │
│  /discover  /spec  /arch-design  /plan  /qa  /build  /review     │
├──────────────────────────────────────────────────────────────────┤
│  AGENT PERSONAS (who does the work)                              │
│  ┌──────────┬───────────┬───────────┬───────────┬──────────┐     │
│  │ Mary     │ John      │ Winston   │ Amelia    │ Sally    │     │
│  │ Analyst  │ PM        │ Architect │ Engineer  │ UX       │     │
│  └──────────┴───────────┴───────────┴───────────┴──────────┘     │
├──────────────────────────────────────────────────────────────────┤
│  SKILL DETECTION (which skills a task needs)                     │
│  ROUTING-TABLE.yaml (16 patterns → persona + skill + cost tier)  │
├──────────────────────────────────────────────────────────────────┤
│  SKILL ECOSYSTEM (what they know)                                │
│  ┌─────────────────┬─────────────────────┬──────────────────┐    │
│  │ claude-skills   │ SDLC skills         │ awesome-copilot  │    │
│  │ (66 domain      │ (27 process         │ (377+ tech       │    │
│  │  experts)       │  workflows)         │  skills)         │    │
│  ├─────────────────┼─────────────────────┼──────────────────┤    │
│  │ software-skills │ ruflo-skills        │ STACK REPOS      │    │
│  │ (55 reference   │ (21 — SPARC, swarm, │ (22 technology   │    │
│  │  guides)        │  AgentDB memory)    │  stacks)         │    │
│  └─────────────────┴─────────────────────┴──────────────────┘    │
├──────────────────────────────────────────────────────────────────┤
│  METHODOLOGY (canonical kernel)                                  │
│  BMAD-METHOD — 5 phases: analysis → planning → solutioning →     │
│  implementation → review · 32 skills · core skills · v6 shims    │
├──────────────────────────────────────────────────────────────────┤
│  PROTOCOLS (how they behave)                                     │
│  boundary-safety  conflict-resolution  input-validation          │
│  loop-protocol  freshness-protocol  receipt-protocol  ... (9)    │
├──────────────────────────────────────────────────────────────────┤
│  OUTPUT TEMPLATES (what they produce)                            │
│  idea-template  spec-template  adr-template  design-doc-template │
│  trade-off-doc-template  review-template  architecture.drawio    │
└──────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User request
  → Skill Detection (ROUTING-TABLE: 16 patterns → persona + skill + cost)
  → Persona First Action (loads protocols + canonical kernel skill)
  → Mode Dispatch (22-stack → claude-skill map)
  → Supplementary skills by context (SDLC / copilot / ruflo / vendor)
  → Pipeline: /discover → /spec → /arch-design → /plan → /qa → /build → /review
  → Artifacts: ideas → SPEC → ADRs + trade-off docs + diagrams → tasks → test cases → code + tests → review report
  → Receipt written (protocols/receipts/)
  → Review findings loop back into /plan (loop-protocol)
```

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Platform** | Claude Code (CLI/plugin) | Host runtime — tools, filesystem, permissions |
| **Harness** | Ruflo v3.33 (daemon, AgentDB, swarm, MCP) | Execution: memory, parallelism, orchestration |
| **Methodology** | BMAD-METHOD (bmm-skills + core-skills) | Canonical SDLC workflow kernel |
| **Skills** | claude-skills (66) · SDLC (27) · awesome-copilot (377) · software-skills (55) · ruflo-skills (21) | Domain expertise, process workflows, references |
| **Stacks** | 22 technology stacks (direct copies) | nestjs, spring-boot, golang, dot-net, java, python, react, nextjs, vue, nuxt, ui-ux, flutter, swift-ui, android, kotlin-compose, react-native, aws, azure, langchain, mlflow, ml-agents, context-engineering |
| **State** | Ruflo AgentDB (`.swarm/memory.db`) | Cross-session memory |
| **Config** | YAML (ROUTING-TABLE, SKILL-INDEX, AUTHORITY-MAP, MCP-CONFIG) | Routing, catalogs, authority, cost |
| **Scripts** | Bash + Ruby (`agent-v01/scripts/`) | Install, start, validate, sync |
| **Output** | Markdown + Draw.io | SPEC, ADRs, trade-off docs, architecture diagrams, QA test cases, review reports |

### Development Languages Supported (via stacks)

| Category | Stacks |
|----------|--------|
| **Backend** | NestJS, Spring Boot, Java, Golang, .NET, Python |
| **Frontend** | React, Next.js, Vue, Nuxt, UI/UX |
| **Mobile** | Flutter, Swift UI, Android, Kotlin Compose, React Native |
| **Cloud** | AWS, Azure |
| **AI/ML** | LangChain, MLflow, ML Agents, Context Engineering |

---

## Setup & Installation

### Prerequisites

- **Claude Code** v2.1.220+ (or Cursor)
- **Node.js** v20.12+
- **Python** 3.10+
- **Ruby** (macOS built-in — for YAML validation)

### Option A: Install into a new project (everything in `.claude/`)

```bash
# 1. Clone this repo (anywhere)
git clone <this-repo-url> nexus-agent-kernel

# 2. Install — everything lands in your project's .claude/
./nexus-agent-kernel/agent-v01/scripts/install-to-project.sh /path/to/your-project

#    (symlink mode — single source of truth)
./nexus-agent-kernel/agent-v01/scripts/install-to-project.sh --symlink /path/to/your-project

# 3. Start Claude Code
cd /path/to/your-project && claude
```

### Option B: Load without installing (session-only)

```bash
claude --plugin-dir ./nexus-agent-kernel/agent-v01
```

### Option C: Marketplace install (requires your own repo hosting)

```bash
claude plugin marketplace add <your-repo>
claude plugin install nexus-agent-kernel@nexus-agent-kernel-marketplace
```

### Option D: Ruflo execution harness (optional but recommended)

```bash
# In the target project, after install
npx ruflo init --minimal
./.claude/plugins/agent-v01/scripts/start-harness.sh

# Intel Mac fix (onnxruntime darwin/x64): see documents/harness-knowledge.md §5.2
```

### What you get

```
your-project/
├── CLAUDE.md                  ← project rules
└── .claude/
    ├── commands/              ← 7 slash commands (auto-discovered)
    ├── agents/                ← 8 BMAD personas (auto-discovered)
    ├── skills/                ← 5 libraries, 500+ skills
    ├── hooks/                 ← lifecycle hooks
    ├── plugins/agent-v01/     ← full kernel (self-contained)
    ├── helpers/               ← status line helpers
    └── .mcp.json              ← ruflo harness MCP
```

---

## Commands

| Command | Persona | Purpose | Key SDLC Skills | Produces |
|---------|---------|---------|-----------------|----------|
| `/discover` 🧠 | bmad-analyst (Mary) | **Idea → concept.** Refines raw ideas; surfaces assumptions; spec-frames output. | idea-refine, spec-driven-development | `docs/ideas/{name}.md` |
| `/spec` 📋 | bmad-product-manager (John) | **Concept → contract.** TDD-style user stories — each AC testable, each story names its RED test. | spec-driven-development, test-driven-development | `SPEC.md` |
| `/arch-design` 🏛 | bmad-architect (Winston) | **Contract → design.** ADRs, trade-off document, API contracts, data models, Draw.io. Direct entry supported (no SPEC needed). | api-and-interface-design, sparc-methodology, bmad-architecture | `docs/adr/*.md`, `docs/trade-offs/*.md`, `docs/architecture/*.md`, `*.drawio` |
| `/plan` 📊 | bmad-analyst/PM | **Design → tasks.** Dependency-ordered, vertically-sliced tasks. | planning-and-task-breakdown, bmad-create-epics-and-stories | `tasks/plan.md`, `tasks/todo.md` |
| `/qa` 🧪 | QA engineer (bmad-qa) | **Tasks → test cases.** Per-story unit/API/E2E test cases from acceptance criteria. | bmad-qa-generate-e2e-tests, test-master, test-driven-development, browser-testing-with-devtools | `docs/qa/test-cases.md` (coverage map) |
| `/build` 🛠 | bmad-engineer (Amelia) | **Tasks → code.** TDD (RED→GREEN→REFACTOR) — RED tests derived from QA test cases. `auto` = full plan in one pass. | test-driven-development, bmad-build, bmad-build-auto, bmad-qa-generate-e2e-tests | Code + tests (traceable to test cases), E2E automation summary, per-task commits |
| `/review` 🔍 | bmad-review | **Code → verdict.** 4-lens review (Quality, Security, Architecture, Dependency). | security-and-hardening, bmad-review, bmad-code-review | `BMAD-REVIEW-REPORT.md` |

### Quick Start

```bash
/discover "Build a multi-tenant appointment scheduler"   # 1. Idea (risk, assumptions, cost, roadmap)
/spec                                                    # 2. Contract
/arch-design                                             # 3. Design (ADRs + trade-off doc)
/plan                                                    # 4. Tasks
/qa                                                      # 5. Test cases per story/task
/build auto                                              # 6. Build all (RED tests from test cases)
/review                                                  # 7. Verdict
```

---

## Skill Detection — Yes, the agent detects needed skills per task

### Progressive Skill Routing (Tier 0-3) — lazy loading to avoid huge reads

The kernel has ~1,800 skills. Instead of embedding all skill tables in agent files (engineer was 179 lines / 157 refs), routing is **progressive disclosure**:

| Tier | What | When | Size |
|------|------|------|------|
| **0** | `ROUTING-TABLE.yaml` — task → persona + cost | task start | ~1KB |
| **1** | Agent stub — persona + workflow (no skill tables) | persona adopted | ~300 words |
| **2** | `SKILL-ROUTER.yaml` — persona → phase → skills | **only when skill needed** | ~294 words |
| **3** | `skills/profiles/{persona}.yaml` + specific SKILL.md | on-demand | ~10 lines/skill |

**Result:** "fix a typo" loads 300 words instead of 1,005 (**-70%**). "build flutter screen" loads 428 instead of 1,005 (**-57%**). Generate profiles: `ruby agent-v01/scripts/generate-skill-profiles.rb`.

### Level 1: ROUTING-TABLE (16 pattern rules → persona + skill)

| Phase | Example pattern | Dispatches to |
|-------|----------------|---------------|
| Analysis | `explore codebase\|analyze\|research` | bmad-analyst |
| Planning | `requirements\|user story\|spec\|epic` | bmad-product-manager |
| Solutioning | `architecture\|system design\|adr` | bmad-architect |
| Implementation | `implement\|build\|develop\|add feature` | bmad-engineer |
| Review | `review\|code review\|audit\|test` | bmad-review |
| Documentation | `document\|docs\|readme` | bmad-tech-writer |

### Level 2: Tech-specific routing (priority: critical — fires before generic)

| Task keyword | Routes to |
|--------------|-----------|
| `flutter`/`dart` | `stacks/mobile/flutter/` (22 skills) + flutter-expert |
| `graphql`/`apollo` | `supplements/graphql/` (14 Apollo skills) + graphql-architect |
| `terraform`/`iac` | `stacks/cloud/terraform/` (13 HashiCorp skills) |
| `aws` | `stacks/cloud/aws/` + cloud-architect + agentic-awesome/cloud |
| `azure` | `stacks/cloud/azure/` (27 MS skills) + per-language azure-sdk |
| `react` | `stacks/frontend/react/` + react-expert |
| `python` | `stacks/backend/python/` (incl. 39 azure-sdk-python) + python-pro |
| `java` | `stacks/backend/java/` (incl. 26 azure-sdk-java) + java-architect |
| `dotnet`/`.net` | `stacks/backend/dot-net/` (incl. 28 azure-sdk-dotnet) + csharp-developer |
| `typescript` | `stacks/frontend/typescript-azure-sdk/` (24 skills) + typescript-pro |
| `stripe`, `supabase`, `auth0` | vendor skill from `supplements/database-design/` |
| `swarm`, `memory`, `parallel` | ruflo skill (swarm-orchestration, agentdb) |

### Level 3: Categorized skill libraries (unique skills by task)

| Library | Skills | Organization |
|---------|--------|--------------|
| `core-skills/agentic-awesome/` | 1,198 skills | 16 categories (backend, frontend, mobile, cloud, database, ai-ml, security, ...) |
| `stacks/cloud/terraform/` | 13 HashiCorp skills | code-gen, module-gen, policy, provider-dev |
| `stacks/*/azure-sdk/` | 117 MS skills | python (39), java (26), dot-net (28), typescript (24) |

### Example trace

```
"Build a Flutter payment screen with Stripe"
  → ROUTING-TABLE: "implement|build|develop" → bmad-engineer
  → Stack: "flutter" → flutter-expert claude-skill
  → Vendor: "stripe" → stripe skill from CATALOG.md
  → Loads: engineer persona + flutter-expert + stripe vendor skill
```

---

## Ruflo Harness — Start & Use

### Start (one command)

```bash
./agent-v01/scripts/start-harness.sh           # daemon + memory + swarm + MCP + validate
./agent-v01/scripts/start-harness.sh --status  # check only
./agent-v01/scripts/start-harness.sh --stop    # stop all
```

### Cross-session memory (the "I can't remember" fix)

```bash
ruflo memory store -k <key> -v "<value>"   # save
ruflo memory get -k <key>                   # recall (any session)
./agent-v01/scripts/test-harness-memory.sh  # verify persistence
```

### Manual steps

```bash
ruflo daemon start    # 7 background workers
ruflo memory init     # memory database
ruflo swarm init      # mesh topology, max 5 agents
ruflo mcp status      # MCP server
```

> **Intel Mac note:** env vars in `~/.zshrc`:
> ```bash
> export CLAUDE_FLOW_MEMORY_BACKEND=better-sqlite3
> export CLAUDE_FLOW_DAEMON=0
> ```
> Details in `documents/harness-knowledge.md` §5.2.

---

## Cost Management

| Layer | Mechanism | Prevents |
|-------|-----------|----------|
| **Skill routing** | Load only persona-relevant skills; stacks per-mode | Wasted context (~80-99% savings) |
| **MCP gating** (`MCP-CONFIG.yaml`) | 4 cost tiers with daily budgets; concurrency cap 3/agent + 10 total; soft budget (warn 80%, block 100%) | Unbounded paid API calls |
| **Model routing** | default sonnet-5, routing haiku-4.5; S1-S2 cheap / S4-S5 expensive | Premium models on trivial tasks |
| **Hooks + receipts** | Pre-tool guard, post-tool audit, receipt protocol | Rework from incomplete work |

---

## Project Structure

```
nexus-agent-kernel/
├── .claude-flow/              # Ruflo runtime (config, data, logs, sessions)
├── .swarm/memory.db           # Ruflo memory database
├── .mcp.json                  # Ruflo MCP server config
├── CLAUDE.md                  # Project rules
├── documents/                 # Architecture docs (harness-knowledge.md, etc.)
└── agent-v01/
    ├── agents/                # 8 BMAD personas
    ├── protocols/             # 9 protocols (synced)
    ├── scripts/               # ALL scripts (install, start, validate, sync)
    ├── .claude/commands/      # 7 slash commands (source)
    ├── .claude-plugin/        # plugin.json + marketplace.json
    ├── stacks/                # 22 technology stacks
    ├── supplements/           # 10 collections (incl. database-design)
    ├── references/            # templates + skill catalogs
    ├── methodologies/         # bmad-method, ruflo/SPARC, general-sdlc, bmad-builder
    ├── core-skills/
    │   └── ...                # stack repos, vendor skills
    ├── hooks/                 # lifecycle hooks
    ├── mcp/                   # MCP server configs
    ├── BMAD-METHOD/           # canonical kernel (5 phases, 32 skills)
    ├── SKILL-INDEX.yaml       # master catalog
    ├── SKILL-ROUTER.yaml     # Tier 2: lazy skill routing index
    ├── skills/profiles/      # Tier 3: per-agent skill profiles (generated)
    ├── ROUTING-TABLE.yaml     # skill detection
    ├── AUTHORITY-MAP.yaml     # canonical source priorities
    ├── MCP-CONFIG.yaml        # cost gating
    └── MCP-AGENT-MAP.yaml     # persona → MCP mapping
```

---

## Protocol Sync

```bash
./agent-v01/scripts/sync-protocols.sh --check   # verify sync
./agent-v01/scripts/sync-protocols.sh --apply   # sync diverged files
```

---

## Validation

| Validator | Checks | Run |
|-----------|--------|-----|
| `validate-structure.sh` | agents, stacks, supplements, references, methodologies, commands, protocols, plugin | `bash agent-v01/scripts/validate-structure.sh` |
| `validate-harness.sh` | daemon, config, memory.db, MCP, skills, git hygiene | `bash agent-v01/scripts/validate-harness.sh` |
| `validate-hooks.sh` | hooks.json, referenced scripts, syntax | `bash agent-v01/scripts/validate-hooks.sh` |
| `validate-skills-frontmatter.sh` | agents + skills frontmatter, no symlinks | `bash agent-v01/scripts/validate-skills-frontmatter.sh` |
| `validate-yaml.rb` | all YAML syntax | `ruby agent-v01/scripts/validate-yaml.rb` |

---

## Further Reading

| Document | Description |
|----------|-------------|
| `documents/harness-knowledge.md` | Full harness architecture + how to use + memory fix |
| `documents/agent-redesign.md` | Design document (3,700+ lines) |
| `agent-v01/SKILL-INDEX.yaml` | Master catalog of all skills |
| `agent-v01/ROUTING-TABLE.yaml` | Skill detection rules |
| `agent-v01/AUTHORITY-MAP.yaml` | Canonical source priorities |
| `agent-v01/MCP-CONFIG.yaml` | MCP cost tiers + budget enforcement |
| `agent-v01/protocols/` | 9 behavioral protocol files |
| `agent-v01/references/templates/` | Output templates (7 files + Draw.io) |
