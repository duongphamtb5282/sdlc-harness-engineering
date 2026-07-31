# ADR-004: Data Model — Per-Tenant Schema with RLS

**Status:** Accepted
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)
**Source:** `documents/saas.md` ADR-004

---

## Context

All PHI tables must be isolated per tenant and protected at the database level, not just the application. We also need per-tenant encryption keys for column-level PHI encryption and a unified audit trail.

## Decision

**Per-tenant schemas** (`CREATE SCHEMA tenant_{id}`) with `search_path` set from tenant context, **RLS enabled on every PHI table**:

```sql
CREATE SCHEMA IF NOT EXISTS tenant_{id};
SET search_path TO tenant_{id};

ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON patients
  USING (tenant_id = current_setting('app.tenant_id')::UUID);
```

Core tables: `patients`, `providers`, `appointments`, `encounters`, `diagnoses`, `medications`, `lab_results`, `claims`, `payments`, `audit_log`, `ai_cache` (pgvector). Cost tables: `insurance_plans`, `patient_insurance`, `cost_estimates`, `payment_plans` (full DDL in `documents/saas.md` §Cost Estimation Data Model).

## Alternatives Considered

### Alternative 1: RLS-only on shared schema (tenant_id column)
- **Pros:** Single schema, simple migrations
- **Cons:** Every query must be RLS-correct; a missing policy or `SECURITY DEFINER` leak exposes ALL tenants; no schema-level firewall
- **Why rejected:** Defense in depth demands two independent isolation mechanisms (schema + RLS)

### Alternative 2: Per-tenant schema + RLS (chosen)
- **Pros:** Schema is the hard boundary (querying a non-existent/other schema fails); RLS is the second layer; search_path isolation prevents accidental cross-tenant access; natural fit for per-tenant migrations
- **Cons:** Thousands of schemas need ops discipline; migration tooling must loop over schemas
- **Why chosen:** Two independent mechanisms = audit-defensible isolation posture

## Consequences

### Positive
- Database-level isolation survives application bugs; cross-tenant query literally cannot resolve
- Per-tenant schema enables per-tenant migrations, per-tenant encryption keys, clean tenant teardown

### Negative
- Migration complexity (loop over schemas); schema count management; monitoring aggregation
- RLS policy + search_path wiring must be correct everywhere → mitigation: isolation test suite (cross-tenant access tests) green on every release; boundary-safety check

### Neutral
- `ai_cache` with pgvector per schema — AI embeddings isolated per tenant

## Compliance Checklist

- [x] Team informed about this decision
- [x] Security reviewed (RLS + per-tenant encryption keys + audit)
- [x] Performance impact assessed (< 200 ms cross-schema queries; search_path switch cost)

## Related ADRs

- ADR-001 (Multi-Tenancy Model)
- ADR-005 (AI Training Data Flow)

---

*Template: agent-v01/references/templates/adr-template.md*
