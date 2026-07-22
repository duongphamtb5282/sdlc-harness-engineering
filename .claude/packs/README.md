# Tech Packs

Stack-native conventions, tests, and CI snippets consumed via [tech-pack-loading.md](../skills/_shared/protocols/tech-pack-loading.md).

## Layout

```
packs/
  languages/{pack}/
    conventions.md      # SE + SA scaffold
    testing.md          # QE
    ci-snippet.yml      # PE — build/test job
    scaffold/           # SA phase 6 layout hints
  clouds/{cloud}/
    conventions.md
    ci-deploy-snippet.yml
    terraform-patterns.md
```

## Machine-readable config

Solution Architect writes `docs/architecture/tech-stack.yaml` (phase 3). All agents read `packs.*` and `verify.*` from it.

## Current packs

| Pack | Language / cloud |
|------|------------------|
| `java-spring` | Java 21, Spring Boot 3, Gradle |
| `nodejs-nestjs` | TypeScript, NestJS 10+ |
| `aws` | ECS Fargate, ECR, Terraform |

## Stack plugins (multi-file best practices)

Installable Claude Code plugins with topic/rule markdown live in `plugins/`:

| Plugin | Use when |
|--------|----------|
| `plugins/stack-golang` | Go projects (`go.mod`) |
| `plugins/stack-frontend` | React, Next.js, AI frontend |
| `plugins/stack-aws` | AWS terraform / deploy |
| `plugins/stack-azure` | Azure terraform / deploy |
| `plugins/sdlc-workflows` | TDD, spec-driven, review workflows |

See [plugins/README.md](../plugins/README.md) and [plugins/AGENT-SKILL-MAP.yaml](../plugins/AGENT-SKILL-MAP.yaml).
