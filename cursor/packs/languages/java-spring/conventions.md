# Java / Spring Boot — Conventions Pack

> **Pack ID:** `java-spring` | **Verify:** `./gradlew test`, `./gradlew bootJar`

## Project layout

```
src/main/java/{package}/
  config/           # @Configuration, security, beans
  domain/           # entities, value objects (no framework imports)
  application/      # use cases, DTOs, mappers
  infrastructure/   # JPA repos, external clients, messaging
  api/              # @RestController, request/response records
src/main/resources/
  application.yml
  db/migration/     # Flyway V{n}__description.sql
src/test/java/      # mirror main package structure
```

## Standards

- **Java 21+**, Spring Boot 3.x, Gradle (Kotlin DSL preferred)
- **DTOs:** Java records for API request/response; MapStruct for entity ↔ DTO
- **Validation:** Jakarta Bean Validation on request records; `@Valid` on controller params
- **Persistence:** Spring Data JPA; entities in `domain/`; no entities in controllers
- **API:** OpenAPI via springdoc; controller paths match `api/openapi/` spec exactly
- **Errors:** RFC 9457 `ProblemDetail` (preferred greenfield) — load `stack-spring/problem-details-rfc9457`; or match existing `ApiResponse` envelope / `ErrorResponse` record (declare in `tech-stack.yaml` → `api.error_format`)
- **Security:** Spring Security 6; method-level `@PreAuthorize` where RBAC applies
- **Config:** externalize via `application.yml`; secrets from env / SSM — never hardcode
- **Logging:** SLF4J + structured JSON (logstash encoder) in production profiles

## Common mistakes

| Mistake | Fix |
|---------|-----|
| `@Transactional` on controllers | Move to service layer |
| Lazy-loading outside transaction | Use `@EntityGraph` or fetch join in repository |
| Returning entities from API | Map to DTO/record |
| `Optional.get()` without check | `orElseThrow` with domain exception |
| Missing Flyway migration for schema change | Every entity change → `V{n}__*.sql` |

## Dependencies (baseline)

- `spring-boot-starter-web`, `spring-boot-starter-data-jpa`, `spring-boot-starter-validation`
- `spring-boot-starter-security` (when auth in scope)
- `org.flywaydb:flyway-core`
- `org.mapstruct:mapstruct` + processor
- Test: `spring-boot-starter-test`, Testcontainers for integration tests
