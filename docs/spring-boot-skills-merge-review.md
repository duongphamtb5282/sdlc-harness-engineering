# Spring Boot skills merge review

**Source:** `new-skills/spring-boot-skills` (rrezartprebreza/spring-boot-skills)  
**Target:** `plugins/stack-spring/` (runtime) + updates to `packs/languages/java-spring`, `spring-boot-engineer`  
**Date:** 2026-07-11

## Summary

| Item | Count |
|------|-------|
| Skills merged (Boot 3.x) | 19 |
| Reference skills (Boot 4.x) | 19 (opt-in under `references/spring-boot-4/`) |
| Conflicts found | 5 areas |
| Blocking conflicts | 0 (all resolved via STACK-RULES precedence) |

## What existed before merge

| Layer | Path | Role |
|-------|------|------|
| Tech pack | `packs/languages/java-spring/` | Layout, verify commands, testing baseline |
| Catalog skill | `plugins/claude-skills-catalog/skills/spring-boot-engineer/` | General Spring Boot 3 workflow + 5 reference files |
| Specialist | `skills/_shared/specialist-skills/programming-languages/java-kotlin/` | JVM language patterns |
| **Gap** | No `stack-spring` plugin | Docs said "Java uses packs only — no stack plugin yet" |

## Conflicts reviewed

### 1. Error response shape — **compatible with rules**

| Source | Approach |
|--------|----------|
| `spring-boot-engineer` | `Map` in `@RestControllerAdvice` (tutorial quick start) |
| `rest-api-conventions` | `ApiResponse<T>` success/error envelope |
| `problem-details-rfc9457` | RFC 9457 `ProblemDetail` |
| `java-spring` pack | "problem+json or consistent ErrorResponse" |

**Verdict:** Not a hard conflict — these are **style options**. SDLC rule: **detect existing pattern**; greenfield defaults to **ProblemDetail** per `STACK-RULES.md`. Updated `packs/languages/java-spring/conventions.md` to document the choice in `tech-stack.yaml`.

### 2. Layered vs hexagonal architecture — **complementary**

Both skills ship in upstream repo for different project styles. Our `java-spring` pack layout (`domain/application/infrastructure/api`) matches **hexagonal**.

**Verdict:** Load **one** architecture skill based on package structure. Agents must not apply layered conventions to a hexagonal codebase (and vice versa).

### 3. Custom JWT vs OAuth2 resource server — **complementary**

- `spring-security-jwt` — app-issued tokens (jjwt filter)
- `oauth2-resource-server` — external IdP JWT validation
- `spring-boot-engineer/references/security.md` — overlaps both (custom filter example)

**Verdict:** Mutually exclusive per service. Security Engineer + SA pick one in ADR. **Do not load both** implementation skills for the same task.

### 4. OpenAPI code-first vs spec-first — **complementary**

- `java-spring` pack: springdoc, controller paths match spec
- `openapi-first`: openapi-generator + ApiDelegate

**Verdict:** Spec-first when generator config exists; otherwise code-first. Aligns with SA phase 4 (API contracts).

### 5. Spring Boot 3 vs 4 duplicate skills — **isolated**

Upstream ships identical skill names for Boot 3 and Boot 4 with different dependency coordinates.

**Verdict:** Runtime loads **Boot 3 only** (`plugins/stack-spring/skills/`). Boot 4 copied to `references/spring-boot-4/` for manual load when projects upgrade.

## Alignment with SDLC rules

| SDLC rule | spring-boot-skills alignment |
|-----------|------------------------------|
| Constructor injection | ✅ All skills enforce; matches `spring-boot-engineer` MUST DO |
| No secrets in config | ✅ Matches security skills + `java-spring` pack |
| Receipt + verify | ✅ `testing-pyramid` supports QE verify discipline |
| SA owns API contracts | ✅ `openapi-first` supports phase 4 |
| Security Engineer authority | ✅ Security skills are implementation guides; SE implements, Security audits |
| Code Reviewer read-only | ✅ No conflict — CR checks conformance only |
| Flyway for schema | ✅ `flyway-migrations` matches pack "every entity change → migration" |

## No conflict with NestJS / polyglot rules

`stack-skill-loading.md` routes Java backend to `packs/java-spring` + `stack-spring` and frontend to `stack-frontend`. Polyglot example (`nextjs-java-aws`) updated to install `stack-spring`.

## Merge actions taken

1. `scripts/merge-spring-boot-skills.sh` — rsync Boot 3 → `plugins/stack-spring/skills/`
2. Boot 4 → `plugins/stack-spring/references/spring-boot-4/`
3. `plugins/stack-spring/STACK-RULES.md` — precedence and detection rules
4. `plugins/REFERENCE-MAP.yaml` — mapping entry
5. `scripts/sync-from-new-skills.sh` — calls merge script
6. `plugins/AGENT-SKILL-MAP.yaml` — `stack-spring` plugin + SE/SA/QE wiring
7. `packs/languages/java-spring/conventions.md` — api error/envelope options
8. `spring-boot-engineer/SKILL.md` — index table → stack-spring skills

## Recommended install bundle

```bash
claude --plugin-dir /path/to/agents
claude --plugin-dir /path/to/agents/plugins/stack-spring
claude --plugin-dir /path/to/agents/plugins/system-design
claude --plugin-dir /path/to/agents/plugins/stack-aws    # if AWS
claude --plugin-dir /path/to/agents/plugins/sdlc-workflows
```

## Maintainer sync

```bash
./scripts/merge-spring-boot-skills.sh
# or full pipeline:
./scripts/sync-from-new-skills.sh
```
