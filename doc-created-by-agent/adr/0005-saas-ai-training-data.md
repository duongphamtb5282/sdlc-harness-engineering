# ADR-005: AI Training Data Flow

**Status:** Accepted
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)
**Source:** `documents/saas.md` ADR-005

---

## Context

The fundraising moat is "proprietary AI trained on de-identified clinical data." We must define how training data flows from tenants without violating HIPAA and without building our own LLM training infrastructure.

## Decision

**Per-tenant AI models (pgvector `ai_cache`) + OPT-IN global base model** from aggregated de-identified data. **Incentive:** tenants that contribute de-identified data get lower pricing. De-identification uses the same Comprehend Medical pipeline as ADR-002 (PHI → placeholders) before anything leaves the tenant schema.

## Alternatives Considered

### Alternative 1: Opt-in global base model + per-tenant cache (chosen)
- **Pros:** Moat narrative backed by real aggregated data; tenants get per-tenant personalization (embeddings in pgvector); privacy is opt-in (defensible)
- **Cons:** Base-model quality depends on opt-in volume; incentive pricing complexity
- **Why chosen:** Only path that builds a moat while staying HIPAA-defensible

### Alternative 2: No shared model; fully per-tenant
- **Pros:** Simplest compliance story
- **Cons:** No moat; per-tenant models start cold (small data = weak personalization)
- **Why rejected:** Kills the fundraising narrative (assumption 5 depends on the moat)

### Alternative 3: Train global model on all data (no opt-in)
- **Pros:** Best model quality
- **Cons:** HIPAA violation risk; opt-out impossible; reputational damage if disclosed
- **Why rejected:** Non-negotiable compliance boundary

## Consequences

### Positive
- Differentiated AI moat; per-tenant embeddings improve with usage; pricing incentive grows the data pool

### Negative
- Aggregation pipeline must be airtight (de-identify → validate no residual PHI → aggregate) → mitigation: automated PHI-scrub verification (regex + model-based scan) before aggregation
- Pricing model complexity (discount for contributors) → mitigation: documented incentive matrix

### Neutral
- pgvector per schema serves both per-tenant retrieval and (opted-in) aggregate source

## Compliance Checklist

- [x] Team informed about this decision
- [x] Security reviewed (de-identification + residual-PHI verification)
- [x] Opt-in consent flow defined
- [ ] Legal review of incentive pricing

## Related ADRs

- ADR-002 (AI Pipeline)
- ADR-004 (Data Model — ai_cache)

---

*Template: agent-v01/references/templates/adr-template.md*
