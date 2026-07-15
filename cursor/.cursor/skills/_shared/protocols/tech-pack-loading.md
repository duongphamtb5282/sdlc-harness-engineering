<!-- sdlc-automation-agent-id: tech-pack-loading -->
# Tech Pack Loading Protocol

> **Audience:** Software Engineer, Quality Engineer, Platform Engineer, Solution Architect (scaffold phase).
> **Complements:** [specialist-skill-loading.md](./specialist-skill-loading.md) (deep patterns) and legacy `agents/software-engineer/tech-packs/*.md`.

## Purpose

Load **stack-native, executable** guidance from `packs/` based on `docs/architecture/tech-stack.yaml`. Packs provide verify commands, layout rules, CI snippets, and test patterns — not generic process.

## Base paths

```
${CLAUDE_PLUGIN_ROOT}/packs/languages/{pack}/
${CLAUDE_PLUGIN_ROOT}/packs/clouds/{cloud}/
${CLAUDE_PLUGIN_ROOT}/agents/software-engineer/tech-packs/   # legacy fallback
```

## Loading procedure

1. Read `docs/architecture/tech-stack.yaml` (preferred) or `.sdlc-automation-agent.yaml` → `packs.*`
2. If missing, run **auto-detection** (below) and note packs in progress output
3. Load role-specific files (parallel Read):

| Agent | Files to load |
|-------|---------------|
| **Software Engineer** | `conventions.md` |
| **Quality Engineer** | `testing.md` |
| **Platform Engineer** | `ci-snippet.yml` + `packs/clouds/{cloud}/conventions.md` + `ci-deploy-snippet.yml` |
| **Solution Architect** (Phase 6 scaffold) | `conventions.md` + `scaffold/` layout rules |

4. Print: `✓ Tech packs: {language-pack}[, {cloud-pack}]`
5. Use `verify.*` from `tech-stack.yaml` for all verification — never invent commands when yaml exists

## Auto-detection (when tech-stack.yaml missing)

| Files / signals | `packs.language` | Default `verify.test` |
|-----------------|------------------|----------------------|
| `pom.xml` or `build.gradle*` | `java-spring` | `./gradlew test` |
| `nest-cli.json` or `@nestjs/core` in package.json | `nodejs-nestjs` | `npm test` |
| `express` in package.json (no nest) | `nodejs-express` | `npm test` |
| `pyproject.toml` + `fastapi` | `python-fastapi` | `pytest` |
| `go.mod` | `go` | `go test ./...` |
| `next.config.*` | `nextjs` (legacy tech-pack) | `npm test` |

| Files / signals | `packs.cloud` |
|-----------------|---------------|
| `terraform/**/*.tf` with `provider "aws"` | `aws` |
| `provider "azurerm"` | `azure` |
| `provider "google"` | `gcp` |

Write detected values to `.sdlc-automation-agent.yaml` → `packs` during init if config exists.

## Load format

```python
# Language pack
Read("${CLAUDE_PLUGIN_ROOT}/packs/languages/java-spring/conventions.md")
Read("${CLAUDE_PLUGIN_ROOT}/packs/languages/java-spring/testing.md")      # QE only
Read("${CLAUDE_PLUGIN_ROOT}/packs/languages/java-spring/ci-snippet.yml")  # PE only

# Cloud pack (PE + SA deploy decisions)
Read("${CLAUDE_PLUGIN_ROOT}/packs/clouds/aws/conventions.md")
Read("${CLAUDE_PLUGIN_ROOT}/packs/clouds/aws/ci-deploy-snippet.yml")
```

## Legacy fallback

If `packs/languages/{pack}/` does not exist, fall back to `agents/software-engineer/tech-packs/{name}.md` when a matching legacy pack exists (e.g. `python-fastapi`, `go`, `nextjs`).

## Precedence

| Priority | Wins |
|----------|------|
| 1 | `_shared/protocols/*` (especially verification-discipline) |
| 2 | Agent phase instructions |
| 3 | `tech-stack.yaml` verify commands |
| 4 | Tech packs |
| 5 | Specialist skills |
| 6 | Legacy tech-packs |

## Receipt requirement

```json
"tech_packs_loaded": ["java-spring", "aws"],
"verification_commands": ["./gradlew test", "./gradlew bootJar"]
```

`verification_commands` MUST match `tech-stack.yaml` → `verify` when that file exists.

## Available packs (this repo)

| Pack | Path |
|------|------|
| Java / Spring Boot | `packs/languages/java-spring/` |
| Node / NestJS | `packs/languages/nodejs-nestjs/` |
| AWS | `packs/clouds/aws/` |

Add packs under `packs/languages/` and `packs/clouds/` following the same file layout.
