# ADR-001: Multi-Tenancy Model

**Status:** Accepted
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)
**Source:** `documents/saas.md` ADR-001

---

## Context

A healthcare SaaS must isolate tenants' PHI while keeping unit economics viable for 10–1,000 tenants. We evaluated four multi-tenancy models: shared DB + shared schema, shared DB + per-tenant schema, dedicated DB per tenant, and a hybrid. HIPAA technical safeguards (access control, audit) plus per-tenant cost drive the decision.

## Decision

**Hybrid:** shared PostgreSQL with **per-tenant schemas** (`tenant_{id}`) as the standard tier, **dedicated database** for enterprise tenants. Isolation enforced at the database level: `search_path` set from tenant context + RLS on every PHI table. Migration path: tenant schema → move to dedicated DB with no code changes.

## Alternatives Considered

### Alternative 1: Shared DB, shared schema (RLS only)
- **Pros:** Cheapest; simplest migrations; pooling of resources
- **Cons:** Weakest isolation posture; noisy-neighbor; tenant size skew; HIPAA scrutiny highest
- **Why rejected:** Insufficient for mid-market healthcare; one tenant's workload or query bug risks all tenants

### Alternative 2: Shared DB, per-tenant schema (chosen for standard tier)
- **Pros:** Best balance of isolation/cost; HIPAA-friendly (recommended pattern); tenant schema migrations independent; straightforward to move a tenant to a dedicated DB
- **Cons:** Schema count grows with tenants (thousands of schemas need ops discipline); shared DB becomes scaling bottleneck at very large scale
- **Why chosen:** Mid-market (10–1,000 tenants) fits PostgreSQL schema capacity; isolation posture defensible in audits

### Alternative 3: Dedicated DB per tenant (chosen for enterprise tier)
- **Pros:** Gold-standard isolation; contract-mandated isolation for enterprises; per-tenant performance isolation
- **Cons:** ~10x infra cost; provisioning/ops overhead; untenable for small tenants
- **Why chosen:** Only where contracts/enterprise customers demand it (hybrid)

## Consequences

### Positive
- Standard tenants get real isolation at commodity cost; enterprise tier sells as premium
- RLS + schema isolation provides defense in depth (two independent mechanisms)
- Migration path is cheap (dump/restore schema → dedicated DB)

### Negative
- Operational complexity: schema provisioning, per-tenant migrations, connection pooling across thousands of schemas
- RLS misconfiguration is catastrophic (cross-tenant leak) → mitigation: automated isolation test suite on every release, boundary-safety review each sprint, RLS enabled by default with deny-by-default policies

### Neutral
- Schema DDL per tenant; monitoring must aggregate across schemas

## Compliance Checklist

- [x] Team informed about this decision
- [x] Migration plan exists (schema → dedicated DB)
- [ ] Rollback plan exists (dedicated → schema)
- [x] Security reviewed (RLS + per-tenant keys)
- [x] Performance impact assessed (search_path switch, schema count ceiling)

## Related ADRs

- ADR-004 (Data Model — RLS enforcement)
- ADR-006 (Deployment Topology — Aurora capacity)

---

*Template: agent-v01/references/templates/adr-template.md*
