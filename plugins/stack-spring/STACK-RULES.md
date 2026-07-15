# stack-spring — precedence and conflict rules

> **Audience:** Software Engineer, Solution Architect, Quality Engineer, Security Engineer.
> **Precedence:** protocols → agent phases → tech-stack.yaml → `packs/java-spring` → **stack-spring** → `spring-boot-engineer` catalog → `java-kotlin` specialist.

## 1. Detect project patterns first (never guess)

Before loading stack-spring skills, inspect the product repo:

| Signal | Load |
|--------|------|
| `domain/port/` or `infrastructure/persistence/` | `hexagonal-architecture` |
| `api/` + `application/` + `domain/` (pack layout) | `hexagonal-architecture` OR `layered-architecture` — match existing naming |
| Flat `controller/service/repository` packages | `layered-architecture` |
| `openapi.yaml` + `ApiDelegate` | `openapi-first` + `rest-api-conventions` |
| `spring-boot-starter-oauth2-resource-server` in POM | `oauth2-resource-server` — **not** `spring-security-jwt` |
| Custom `JwtAuthenticationFilter` + jjwt | `spring-security-jwt` |
| `ProblemDetail` in existing handlers | `problem-details-rfc9457` |
| `ApiResponse<T>` envelope in existing controllers | `rest-api-conventions` |

## 2. Known conflicts (resolved)

### A. Error response format

| Source | Pattern |
|--------|---------|
| `spring-boot-engineer` quick start | `Map<String,String>` errors |
| `rest-api-conventions` | `ApiResponse` envelope with nested `ApiError` |
| `problem-details-rfc9457` | RFC 9457 `ProblemDetail` |
| `packs/java-spring` | "problem+json or consistent ErrorResponse record" |

**Rule:** Match the **existing codebase**. If greenfield, prefer **RFC 9457 ProblemDetail** for errors. Success payloads may be raw DTOs or `ApiResponse<T>` — pick one per project and document in `tech-stack.yaml`:

```yaml
api:
  error_format: problem-details   # problem-details | envelope
  success_envelope: false         # true → ApiResponse wrapper
```

Do **not** combine `ApiResponse` error branch with `ProblemDetail` on the same endpoint.

### B. Architecture style

| Skill | Style |
|-------|-------|
| `layered-architecture` | Controller → Service → Repository |
| `hexagonal-architecture` | Ports & adapters, domain without Spring |
| `packs/java-spring` layout | `domain/`, `application/`, `infrastructure/`, `api/` |

**Rule:** `packs/java-spring` layout aligns with **hexagonal**. Use `layered-architecture` only when the repo uses classic layered packages. Never mix entity exposure in controllers (both skills forbid it).

### C. Security: JWT implementations

| Skill | When |
|-------|------|
| `spring-security-jwt` | App issues its own tokens (login endpoint, jjwt) |
| `oauth2-resource-server` | Tokens from external IdP |
| `spring-boot-engineer/references/security.md` | Generic Security 6 patterns |

**Rule:** One auth model per service. SA documents choice in ADR. Security Engineer reviews against OWASP either way.

### D. OpenAPI approach

| Approach | Skill |
|----------|-------|
| Code-first (springdoc) | `packs/java-spring` + `rest-api-conventions` |
| Spec-first (openapi-generator) | `openapi-first` |

**Rule:** SA phase 4 owns the contract. If `api/openapi/` or `openapi-generator` exists → spec-first. Otherwise code-first with springdoc.

### E. Spring Boot 3 vs 4

| Runtime | Path |
|---------|------|
| Boot 3.x (default) | `plugins/stack-spring/skills/` |
| Boot 4.x | `plugins/stack-spring/references/spring-boot-4/` (manual load) |

**Rule:** Never blend SB3 and SB4 dependency versions. Init detects from `pom.xml` / `build.gradle`.

## 3. SDLC agent boundaries (no conflict)

| Agent | Uses stack-spring for |
|-------|----------------------|
| **SA** | `openapi-first`, `hexagonal-architecture`, `domain-driven-design` (design only) |
| **SE** | Implementation skills per task |
| **QE** | `testing-pyramid` |
| **Security** | `spring-security-jwt` or `oauth2-resource-server` (audit, not duplicate CR) |
| **Code Reviewer** | Checks conformance to loaded stack-spring rules — does not load security skills for implementation |

## 4. Receipt field

```json
"stack_plugin_skills_loaded": ["stack-spring/rest-api-conventions", "stack-spring/spring-data-jpa"]
```

## 5. Review & quality skills (claude-code-java)

Merged from `new-skills/claude-code-java` — **read-only / audit** skills complement implementation skills. See [docs/claude-code-java-merge-review.md](../../docs/claude-code-java-merge-review.md).

| Skill | Load when | Do not confuse with |
|-------|-----------|---------------------|
| `java-code-review` | Reviewing `.java` PRs | `code-reviewer` agent (orchestrates phases) |
| `architecture-review` | Package/module boundary audit | `layered-architecture` / `hexagonal-architecture` (implementation) |
| `api-contract-review` | Pre-release API audit | `rest-api-conventions` (implementation) |
| `jpa-patterns` | N+1, lazy load, query tuning | `spring-data-jpa` (entity/repo conventions) |
| `test-quality` | JUnit/AssertJ style review | `testing-pyramid` (layer mix) |
| `security-audit` | OWASP checklist (findings) | `spring-security-jwt` / `oauth2-resource-server` (implementation) |
| `performance-smell-detection` | Code-level perf smells | `jpa-patterns` for DB/query perf |
| `concurrency-review` | Thread safety, `@Async`, virtual threads | — |
| `spring-boot-patterns` | Greenfield bootstrap / generic Spring help | Topic skills for SDLC implementation |
| `clean-code`, `solid-principles`, `design-patterns` | Refactor / class design review | — |
| `logging-patterns` | Logging/MDC/structured logs | `ai-observability` (AI metrics) |
| `java-migration` | Java version upgrades | — |
| `maven-dependency-audit` | Dep/CVE audit before release | — |
| `git-commit`, `changelog-generator`, `issue-triage` | Workflow helpers | — |

**Rule:** Code Reviewer loads review skills (findings only). Software Engineer loads implementation topic skills. Never implement security fixes from `security-audit` inside Code Reviewer — route to SE + Security Engineer.
