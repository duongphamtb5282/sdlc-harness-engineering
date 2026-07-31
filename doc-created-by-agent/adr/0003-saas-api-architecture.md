# ADR-003: API Architecture

**Status:** Accepted
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)
**Source:** `documents/saas.md` ADR-003

---

## Context

Seven Go microservices must expose external APIs (portal, FHIR, payments) and communicate internally. We need one router/contract style that is type-safe, fast, and standards-compliant, plus FHIR R4 interoperability for EHRs.

## Decision

**Go microservices** with:
- **Chi router** for REST (external — public API gateway)
- **Connect RPC (gRPC)** for internal service-to-service communication
- **FHIR R4 API** for EHR interoperability (read; Epic/Cerner proprietary APIs out of scope)

## Alternatives Considered

### Alternative 1: Chi + Connect RPC + FHIR R4 (chosen)
- **Pros:** Chi is idiomatic, fast, zero deps; Connect RPC gives type-safe gRPC with HTTP/1.1 fallback; FHIR R4 is the healthcare standard (interop + audit credibility)
- **Cons:** Three API paradigms to maintain; FHIR validation adds complexity
- **Why chosen:** Matches team stack (sqlc, pgx); FHIR compliance is a market requirement

### Alternative 2: Full gRPC everywhere (including external)
- **Pros:** One paradigm
- **Cons:** External clients (browsers, third parties) don't speak gRPC natively; FHIR is REST/JSON by definition
- **Why rejected:** External consumers need REST; FHIR mandates it

### Alternative 3: REST-only (no internal gRPC)
- **Pros:** Simplest
- **Cons:** JSON overhead, no schema-enforced contracts between 7 services; drift risk
- **Why rejected:** Contract drift between microservices is a real cost at 7 services

## Consequences

### Positive
- Type-safe internal contracts (protobuf) prevent interface drift; FHIR R4 read opens EHR integrations
- Gateway enforces tenant context, rate limiting, audit logging, FHIR compliance in one place

### Negative
- Three paradigms: skill tax; protobuf codegen in the build
- FHIR mapping complexity → mitigation: FHIR model types in shared `pkg/fhir`, validation tests per resource

### Neutral
- Connect RPC supports both gRPC and JSON — internal clients can use either

## Compliance Checklist

- [x] Team informed about this decision
- [x] Security reviewed (gateway middleware: authn/authz, tenant context, audit)
- [x] Performance impact assessed (gRPC overhead negligible; FHIR serialization cost known)

## Related ADRs

- ADR-001 (Multi-Tenancy — tenant context middleware)
- ADR-004 (Data Model)

---

*Template: agent-v01/references/templates/adr-template.md*
