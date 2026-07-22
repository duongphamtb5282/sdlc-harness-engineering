<!-- sdlc-automation-agent-id: stack-skill-loading -->
# Stack Skill Loading Protocol

> **Audience:** All role agents when stack-specific plugin skills apply.
> **Complements:** [specialist-skill-loading.md](./specialist-skill-loading.md), [tech-pack-loading.md](./tech-pack-loading.md).
> **Map:** `plugins/AGENT-SKILL-MAP.yaml`

## Purpose

Load **2–5 stack plugin skills** from `plugins/` based on agent role, `tech-stack.yaml`, and task context. Plugin skills contain multi-file best practices (topics, rules, references) — load index `SKILL.md` first, then 1–3 topic files.

## Base paths

```
${CLAUDE_PLUGIN_ROOT}/plugins/stack-golang/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/stack-spring/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/stack-vue/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/stack-nuxt/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/stack-frontend/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/stack-aws/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/stack-azure/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/sdlc-workflows/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/agent-toolkit/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/system-design/skills/
${CLAUDE_PLUGIN_ROOT}/plugins/claude-skills-catalog/skills/   # SA: architecture-designer (phase 2)
```

**Do not load** `${CLAUDE_PLUGIN_ROOT}/new-skills/` — reference only. See [reference-sources.md](./reference-sources.md).

## Loading procedure

1. Read `plugins/AGENT-SKILL-MAP.yaml` → `agents.{role}`
2. Read `docs/architecture/tech-stack.yaml` (or `.sdlc-automation-agent.yaml`) for language, frontend, cloud
3. Load **always** skills for the role (max 2 plugin SKILL.md indexes)
4. Resolve `stack_by_language` / `stack_by_mode` / `cloud` entries
5. Read plugin skill **index only** (`SKILL.md`); follow its links to topic/rule files
6. Print: `✓ Stack plugin skills: {plugin}/{skill-name}[, ...]`

## Polyglot projects (e.g. Next.js + Java + AWS)

When `tech-stack.yaml` has **both** `packs.language` (backend) and `packs.frontend` (or `frontend.framework: nextjs`):

1. Read `profile: polyglot` and `paths.backend` / `paths.frontend` / `paths.infra`
2. **Route by edited files or SE mode**, not by a single language field:

| Task context | Load |
|--------------|------|
| Files under `paths.backend` or SE **backend** mode | `packs/languages/java-spring/*` + specialist `java-kotlin` |
| Files under `paths.frontend` or SE **frontend** mode | `plugins/stack-frontend` → `next-best-practices`, `react-best-practices`, `composition-patterns`, `react-view-transitions` (Next.js) |
| Terraform / deploy / PE work | `packs/clouds/aws/*` + `plugins/stack-aws` skills |
| SA HLD / capacity | `plugins/system-design` orchestrator + building blocks |

3. Run **verify** from the matching block: `verify.backend.*`, `verify.frontend.*`, or `verify.infra.*`

Example config: `docs/examples/tech-stack-nextjs-java-aws.yaml`

Auto-detection alone is **not enough** for polyglot — SA must write `tech-stack.yaml` explicitly in phase 3.

## Load format

```python
# Index first (router)
Read("${CLAUDE_PLUGIN_ROOT}/plugins/stack-frontend/skills/next-best-practices/SKILL.md")

# Then 1–3 topic files referenced in the index
Read("${CLAUDE_PLUGIN_ROOT}/plugins/stack-frontend/skills/next-best-practices/rsc-boundaries.md")
```

For nested AWS skills:

```python
Read("${CLAUDE_PLUGIN_ROOT}/plugins/stack-aws/skills/core-skills/aws-containers/SKILL.md")
```

## Detection fallback (no tech-stack.yaml)

| Signal | Plugin | Default skill |
|--------|--------|---------------|
| `go.mod` | stack-golang | golang-how-to → golang-project-layout (+ task skills) |
| `pom.xml` / `build.gradle*` | stack-spring | rest-api-conventions → layered-architecture or hexagonal-architecture (+ task skills) |
| `nuxt.config.*` | stack-nuxt | nuxt → vueuse / nuxt-ui as needed (+ stack-vue/vue-best-practices) |
| `*.vue` + Vite, no Nuxt | stack-vue | vue-best-practices → vue-router / vue-pinia / vue-testing as needed |
| `next.config.*` | stack-frontend | next-best-practices, react-view-transitions |
| `package.json` + react, no next | stack-frontend | react-best-practices, composition-patterns |
| React Native / Expo | stack-frontend | react-native-skills |
| Vercel deploy / optimize | stack-frontend | deploy-to-vercel, vercel-optimize |
| Docs / prose review | stack-frontend | writing-guidelines |
| UI / a11y audit | stack-frontend | web-design-guidelines |
| `angular.json` | stack-frontend | (future angular pack) |
| `provider "aws"` in terraform | stack-aws | aws-containers |
| `provider "azurerm"` | stack-azure | azure-architecture |
| HLD / architecture / scale design | system-design | system-design (orchestrator) |

For system-design building blocks, load provider variant when cloud is known:

```python
Read("${CLAUDE_PLUGIN_ROOT}/plugins/system-design/skills/data-storage/SKILL.md")
Read("${CLAUDE_PLUGIN_ROOT}/plugins/system-design/skills/data-storage/references/providers/aws.md")
```

## Precedence

| Priority | Wins |
|----------|------|
| 1 | `_shared/protocols/*` |
| 2 | Agent phase instructions |
| 3 | tech-stack.yaml verify commands |
| 4 | Tech packs (`packs/languages/*`) |
| 5 | Stack plugin skills (this protocol) |
| 6 | Specialist skills |

## Receipt

```json
"stack_plugin_skills_loaded": ["stack-frontend/next-best-practices", "stack-golang/golang-testing"]
```

## Install plugins (Claude Code)

```bash
# Repo root — SDLC orchestrator
claude --plugin-dir /path/to/agents

# Stack plugins (add to product repo session)
claude --plugin-dir /path/to/agents/plugins/stack-frontend
claude --plugin-dir /path/to/agents/plugins/stack-golang
claude --plugin-dir /path/to/agents/plugins/stack-spring
claude --plugin-dir /path/to/agents/plugins/stack-aws
claude --plugin-dir /path/to/agents/plugins/system-design
claude --plugin-dir /path/to/agents/plugins/claude-skills-catalog   # SA: architecture-designer
```

See `plugins/README.md` for bundle presets.
