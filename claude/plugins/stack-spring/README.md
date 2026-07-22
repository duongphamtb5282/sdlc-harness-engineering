# stack-spring — Spring Boot skills plugin

Upstream:
- `new-skills/spring-boot-skills` → `scripts/merge-spring-boot-skills.sh`
- `new-skills/claude-code-java` → `scripts/merge-claude-code-java.sh`

## Install

```bash
claude --plugin-dir /path/to/agents/plugins/stack-spring
```

Pair with repo root SDLC plugin + `packs/languages/java-spring` tech pack.

## Skills (Spring Boot 3.x — default)

| Skill | Load when |
|-------|-----------|
| `rest-api-conventions` | Controllers, DTOs, pagination, versioning |
| `problem-details-rfc9457` | Exception handlers, error responses |
| `layered-architecture` | Classic controller → service → repository |
| `hexagonal-architecture` | `domain/`, `application/`, `infrastructure/` packages |
| `openapi-first` | `openapi.yaml`, ApiDelegate, openapi-generator |
| `spring-data-jpa` | Entities, repositories, queries |
| `flyway-migrations` | Schema migrations |
| `spring-security-jwt` | Custom JWT auth service (jjwt) |
| `oauth2-resource-server` | External IdP (Keycloak, Cognito, Auth0) |
| `spring-data-redis` | Caching |
| `domain-driven-design` | Aggregates, value objects, domain events |
| `testing-pyramid` | Unit, slice, integration tests |
| `transactional-patterns` | `@Transactional` boundaries |
| `multi-module-maven` | Parent POM, module layout |
| `hateoas` | Hypermedia APIs |
| `spring-batch` | Batch jobs |
| `spring-ai-integration` | Spring AI chat/RAG |
| `ai-observability` | AI audit/metrics advisors |
| `mcp-server` | MCP Java SDK in Spring Boot |

## Review & quality (claude-code-java)

| Skill | Load when |
|-------|-----------|
| `java-code-review` | Java PR review checklist |
| `architecture-review` | Package/module boundary audit |
| `api-contract-review` | REST API contract audit before release |
| `jpa-patterns` | N+1, lazy load, query performance debugging |
| `test-quality` | JUnit 5 + AssertJ test style |
| `security-audit` | OWASP checklist (findings only) |
| `concurrency-review` | Thread safety, virtual threads, `@Async` |
| `performance-smell-detection` | Code-level performance smells |
| `spring-boot-patterns` | Bootstrap / generic Spring Boot help |
| `clean-code`, `solid-principles`, `design-patterns` | Refactoring / design review |
| `logging-patterns` | SLF4J, MDC, structured logging |
| `java-migration` | Java version upgrades (8→25) |
| `maven-dependency-audit` | Dependency/CVE audit |
| `git-commit`, `changelog-generator`, `issue-triage` | Workflow helpers |

See [STACK-RULES.md](./STACK-RULES.md) §5 and [docs/claude-code-java-merge-review.md](../../docs/claude-code-java-merge-review.md).

## Spring Boot 4.x (opt-in)

Skills for Boot 4 / Framework 7 live under `references/spring-boot-4/`. Load manually when `spring-boot.version` ≥ 4.0 — do not mix SB3 and SB4 dependency coordinates in one project.

## Conflict resolution

See [STACK-RULES.md](./STACK-RULES.md) and [docs/spring-boot-skills-merge-review.md](../../docs/spring-boot-skills-merge-review.md).

## Related

| Layer | Path |
|-------|------|
| Tech pack | `packs/languages/java-spring/` |
| Catalog index | `plugins/claude-skills-catalog/skills/spring-boot-engineer/` |
| Specialist | `skills/_shared/specialist-skills/programming-languages/java-kotlin/` |
