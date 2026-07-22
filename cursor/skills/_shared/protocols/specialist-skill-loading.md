<!-- sdlc-automation-agent-id: specialist-skill-loading -->
# Specialist Skill Loading Protocol

> **Audience:** All role agents (SE, SA, PE, QE, CR, CE, PM, TW, Research Advisor).
> **Source:** Curated copy of [claude-software-skills](https://github.com/miles990/claude-software-skills) under `skills/_shared/specialist-skills/`.

## Purpose

Load **2–5 deep domain skills** per dispatch from the agent's `skill-extensions/registry.yaml`. Do not load all skills — orchestrator + registry select what applies.

## Base path

```
${CLAUDE_PLUGIN_ROOT}/skills/_shared/specialist-skills/
```

**Do not load** `${CLAUDE_PLUGIN_ROOT}/new-skills/` — reference only. See [reference-sources.md](./reference-sources.md).

## Loading procedure

1. Read `agents/{role}/skill-extensions/registry.yaml`
2. Read `docs/architecture/tech-stack.yaml` if it exists; else read `.sdlc-automation-agent.yaml`
3. Resolve `language_map` → one programming-language skill
4. Resolve `stack_map` / `cloud_map` / `domain_map` as applicable
5. Load `always_load` skills (parallel Read of each `SKILL.md`)
6. Evaluate `conditional` rules; load matching skills
7. Print progress: `✓ Specialist skills: {comma-separated names}`

## Load format

```python
Read("${CLAUDE_PLUGIN_ROOT}/skills/_shared/specialist-skills/{category}/{skill-name}/SKILL.md")
```

Load `templates/` and `reference.md` **only when implementing** that concern (e.g. generating CI YAML), not at agent startup.

## Precedence (conflict resolution)

| Priority | Wins |
|----------|------|
| 1 | `_shared/protocols/*` |
| 2 | Agent phase instructions (`phases/*.md`, `modes/*.md`) |
| 3 | Agent `SKILL.md` body |
| 4 | Specialist skills |
| 5 | Legacy `tech-packs/*.md` |

Specialist skills **supplement**; they do not override receipts, verification, or boundary-safety rules.

For **stack-specific multi-file skills** (Next.js topics, Go micro-skills, AWS/Azure), also follow [stack-skill-loading.md](./stack-skill-loading.md) and `plugins/AGENT-SKILL-MAP.yaml`.

## Language detection fallback

If `tech-stack.yaml` is missing, infer language from project files:

| Signal | Registry key |
|--------|--------------|
| `pom.xml`, `build.gradle`, `build.gradle.kts` | `java` |
| `pyproject.toml`, `requirements.txt` + fastapi/django | `python` |
| `package.json` with `@nestjs/core` | `nestjs` |
| `package.json` with `express` | `nodejs` |
| `package.json` with `react` / `next` | `typescript` |
| `go.mod` | `go` |
| `Cargo.toml` | `rust` |
| `*.csproj`, `*.sln` | `csharp` |

## Receipt requirement

When a specialist skill drove a major decision (e.g. CI template from `devops-cicd`), note it in the receipt:

```json
"specialist_skills_loaded": ["java-kotlin", "backend", "code-quality"]
```
