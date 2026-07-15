# claude-code-java merge review

**Source:** `new-skills/claude-code-java` (upstream Java review + patterns shelf)  
**Target:** `plugins/stack-spring/skills/` (additive — 18 skills alongside spring-boot-skills)  
**Date:** 2026-07-11

## Summary

| Item | Count |
|------|-------|
| Skills merged | 18 |
| Existing stack-spring (spring-boot-skills) | 19 |
| **Total stack-spring topic skills** | **37** |
| Blocking conflicts | 0 (complementary roles — see STACK-RULES §5) |

## Skills merged

| Skill | Role | Pair with |
|-------|------|-----------|
| `java-code-review` | Systematic Java PR review | `code-reviewer` agent |
| `architecture-review` | Macro package/module audit | `layered-architecture` / `hexagonal-architecture` |
| `api-contract-review` | REST contract audit | `rest-api-conventions`, `openapi-first` |
| `security-audit` | OWASP checklist (read-only) | `spring-security-jwt`, `oauth2-resource-server` |
| `jpa-patterns` | JPA pitfalls (N+1, lazy load) | `spring-data-jpa` |
| `concurrency-review` | Thread safety, virtual threads | — |
| `performance-smell-detection` | Code-level perf smells | `jpa-patterns` for DB perf |
| `test-quality` | JUnit 5 + AssertJ style | `testing-pyramid` |
| `spring-boot-patterns` | Broad Spring Boot overview | Topic skills (prefer for SDLC impl) |
| `clean-code` | DRY/KISS/naming | `solid-principles` |
| `solid-principles` | SOLID checklist | `code-reviewer` code quality phase |
| `design-patterns` | Gang-of-four patterns | SA design tasks |
| `logging-patterns` | SLF4J, MDC, structured logs | `ai-observability` |
| `java-migration` | Java 8→25 upgrades | `packs/java-spring` verify |
| `maven-dependency-audit` | Dep audit / CVE scan | `devops` release prep |
| `git-commit` | Conventional commits | — |
| `changelog-generator` | Release notes from git | `devops` |
| `issue-triage` | GitHub issue triage | `product-manager` |

## Overlap review (non-blocking)

### 1. `spring-boot-patterns` vs spring-boot-skills topic skills

| Source | Focus |
|--------|-------|
| `spring-boot-patterns` | Classic layered layout, Lombok, quick templates |
| `rest-api-conventions`, `layered-architecture`, `problem-details-rfc9457` | SDLC-aligned implementation |

**Verdict:** `spring-boot-patterns` is a **bootstrap/overview** skill. For SDLC delivery, load **topic skills** and match existing error/architecture patterns per STACK-RULES §1.

### 2. `jpa-patterns` vs `spring-data-jpa`

| Source | Focus |
|--------|-------|
| `spring-data-jpa` | Entity/repo generation conventions |
| `jpa-patterns` | Debugging N+1, LazyInitializationException, fetch tuning |

**Verdict:** Complementary. Load `spring-data-jpa` when writing code; add `jpa-patterns` when fixing persistence performance.

### 3. `test-quality` vs `testing-pyramid`

| Source | Focus |
|--------|-------|
| `testing-pyramid` | Test layer mix (unit/slice/integration) |
| `test-quality` | AssertJ patterns, test readability |

**Verdict:** Complementary — load both for QE tasks.

### 4. `security-audit` vs Security Engineer / spring-security skills

**Verdict:** `security-audit` is a **read-only checklist**. Security Engineer owns formal audit; SE implements via `spring-security-jwt` or `oauth2-resource-server`. Code Reviewer may load `security-audit` for findings only.

### 5. `java-code-review` vs `code-reviewer` agent

**Verdict:** Agent skill defines SDLC phases and tool restrictions. `java-code-review` adds **Java-specific checklist** — load when reviewing `.java` files.

## SDLC alignment

| Agent | New skills |
|-------|------------|
| **Code Reviewer** | `java-code-review`, `architecture-review`, `api-contract-review`, `jpa-patterns`, `concurrency-review`, `performance-smell-detection`, `security-audit`, `test-quality` |
| **Software Engineer** | `spring-boot-patterns` (bootstrap), `logging-patterns`, `java-migration` (on request) |
| **QE** | `test-quality` + `testing-pyramid` |
| **DevOps** | `maven-dependency-audit`, `changelog-generator`, `git-commit` |
| **Product Manager** | `issue-triage` |

## Maintainer sync

```bash
./scripts/merge-claude-code-java.sh
./scripts/sync-to-cursor.sh [/path/to/product]
```

`new-skills/claude-code-java` remains reference-only — never load at runtime.
