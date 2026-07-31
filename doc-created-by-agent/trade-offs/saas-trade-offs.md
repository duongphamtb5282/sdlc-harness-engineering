# Trade-off Document: Multi-Tenant Healthcare SaaS

**Status:** Reviewed
**Version:** 1.0
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)

---

## Purpose

System-level ledger of every load-bearing decision for the healthcare SaaS. ADRs record each decision individually; this document records the *trade-offs across decisions* — what was given up to gain what, and how decisions constrain each other. Load-bearing calls are shown, not silently made (bmad-architecture).

## 1. Decision Register

| ID | Decision | Chose | Over | Trade-off in one line | Status | ADR |
|----|----------|-------|------|------------------------|--------|-----|
| TO-1 | Multi-tenancy model | Hybrid (per-tenant schema + dedicated for enterprise) | Shared-schema RLS-only / all-dedicated | Gained audit-defensible isolation at commodity cost; accepted schema-count ops complexity | Accepted | ADR-001 |
| TO-2 | AI pipeline provider | AWS Bedrock + AgentCore | Self-hosted LLM / OpenAI BAA | Gained HIPAA-eligible managed pipeline, PHI stays in AWS; accepted AWS lock-in + per-token cost | Accepted | ADR-002 |
| TO-3 | API architecture | Chi REST + Connect gRPC + FHIR R4 | gRPC-everywhere / REST-only | Gained type-safe internal contracts + EHR interop; accepted 3-paradigm skill tax | Accepted | ADR-003 |
| TO-4 | Data isolation mechanism | Per-tenant schema + RLS (two layers) | RLS-only | Gained defense-in-depth isolation; accepted migration ops overhead (loop over schemas) | Accepted | ADR-004 |
| TO-5 | AI training data | Opt-in global base model + per-tenant pgvector | No shared model / train on all data | Gained a defensible moat; accepted aggregation-pipeline risk + pricing complexity | Accepted | ADR-005 |
| TO-6 | Deployment | ECS Fargate + Aurora | EKS / Lambda | Gained minimal ops on a 3-dev team; accepted AWS lock-in + Fargate cost floor | Accepted | ADR-006 |

## 2. Trade-off Analysis

### TO-1: Multi-tenancy model

**The trade-off:** We chose hybrid per-tenant-schema over RLS-only. We gained a hard database-level isolation boundary defensible in a HIPAA audit, and accepted operational complexity managing thousands of schemas.

**Options compared:**

| Criterion (weight) | Per-tenant schema (A) | Shared schema RLS-only (B) | All dedicated DB (C) |
|---|---|---|---|
| Isolation posture (5) | 5/5 | 2/5 | 5/5 |
| Infra cost @ 100 tenants (4) | 4/5 | 5/5 | 1/5 |
| Ops complexity (3) | 2/5 | 4/5 | 2/5 |
| Enterprise-readiness (2) | 4/5 | 1/5 | 5/5 |
| **Weighted total** | **5·5+4·4+3·2+2·4 = 59** | 5·2+4·5+3·4+2·1 = 40 | 5·5+4·1+3·2+2·5 = 45 |

**Why A won:** isolation is non-negotiable (PHI), cost is the market constraint (small/mid clinics), and enterprise tier (C) is kept as the hybrid's premium arm — the two options are complements, not rivals.

**Accepted costs & mitigations:**
- Thousands-of-schemas ops → per-tenant migration tooling, automated isolation test suite on every release
- RLS + search_path wiring is load-bearing → middleware sets context per request; deny-by-default policies

**Revisit trigger:** when a tenant count ceiling forces shared-schema (10k+) — reconsider only with contract-grade RLS guarantees; or when > 20% of tenants are enterprise (dedicated DB becomes the default tier).

### TO-2: AI pipeline provider

**The trade-off:** We chose AWS Bedrock over self-hosting/OpenAI. We gained a HIPAA-eligible managed pipeline with zero GPU ops and PHI never leaving AWS; we accepted AWS lock-in and per-token costs.

**Options compared:**

| Criterion (weight) | Bedrock + AgentCore (A) | Self-hosted LLM (B) | OpenAI + BAA (C) |
|---|---|---|---|
| HIPAA eligibility (5) | 5/5 | 2/5 | 4/5 |
| Team ops burden (4) | 5/5 | 1/5 | 4/5 |
| Quality of clinical output (3) | 4/5 | 2/5 | 5/5 |
| Cost predictability (2) | 3/5 | 3/5 | 3/5 |
| **Weighted total** | **5·5+4·5+3·4+2·3 = 63** | 5·2+4·1+3·2+2·3 = 26 | 5·4+4·4+3·5+2·3 = 57 |

**Why A won:** compliance is the gate; ops burden is the constraint (3-dev team); OpenAI's quality edge doesn't beat the compliance/ops delta, and Bedrock serves Claude models anyway.

**Accepted costs & mitigations:**
- Lock-in → AI provider behind an interface (assumption 2 fallback); revisit trigger: Bedrock HIPAA eligibility changes, price increase > 2x, or quality regression
- Hallucination → guardrails, low-confidence flags, provider approve gate (never auto-commit)

**Revisit trigger:** Bedrock eligibility change; sustained transcription accuracy < 95%; per-tenant AI cost > $50/provider/mo.

### TO-3: API architecture

**The trade-off:** We chose three API paradigms (REST + gRPC + FHIR) over a single paradigm. We gained type-safe internal contracts and FHIR-compliant external interop; we accepted a permanent skill tax and codegen in the build.

**Options compared:**

| Criterion (weight) | Chi + Connect + FHIR (A) | gRPC everywhere (B) | REST only (C) |
|---|---|---|---|
| External consumer fit (5) | 5/5 | 2/5 | 5/5 |
| Internal contract safety (4) | 5/5 | 5/5 | 2/5 |
| FHIR compliance (3) | 5/5 | 1/5 | 3/5 |
| Team simplicity (2) | 2/5 | 3/5 | 5/5 |
| **Weighted total** | **5·5+4·5+3·5+2·2 = 64** | 5·2+4·5+3·1+2·3 = 39 | 5·5+4·2+3·3+2·5 = 52 |

**Why A won:** FHIR is non-negotiable for healthcare interop; 7 services without schema-enforced contracts will drift.

**Accepted costs & mitigations:**
- 3 paradigms → protobuf shared in `pkg/`, one codegen step, FHIR validation tests per resource

**Revisit trigger:** when a 4th paradigm would be needed (e.g., GraphQL for the portal) — consolidate REST into the gateway instead.

### TO-4: Data isolation mechanism

**The trade-off:** We chose schema + RLS (two layers) over RLS-only. We gained defense in depth where a single misconfiguration cannot leak all tenants; we accepted per-tenant migration tooling and schema-count management.

**Accepted costs & mitigations:**
- Migration loops, schema sprawl → tooling + schema-count monitoring (revisit trigger: > 2,000 schemas → evaluate dedicated-DB tier shift for high-volume tenants)
- RLS/schema pairing must never diverge → isolation test suite gates every release

**Revisit trigger:** schema count ceiling; RLS bypass found in audit; performance degradation from search_path switching.

### TO-5: AI training data

**The trade-off:** We chose an opt-in global base model over no-shared-model. We gained the moat that justifies premium pricing and the raise; we accepted the risk that a single PHI leak in the aggregation pipeline is catastrophic.

**Accepted costs & mitigations:**
- Aggregation risk → automated residual-PHI verification (regex + model scan) before anything enters the aggregate; opt-in consent logged per tenant
- Pricing complexity → documented incentive matrix (contributors discount)

**Revisit trigger:** opt-in rate < 30% (moat doesn't materialize — re-scope AI roadmap); any residual-PHI detection failure (halt aggregation, full review).

### TO-6: Deployment topology

**The trade-off:** We chose Fargate + Aurora over EKS/Lambda. We gained minimal ops on a 3-dev team with a predictable $2,650–3,650/mo budget; we accepted AWS lock-in and a per-service cost floor.

**Accepted costs & mitigations:**
- Lock-in → infra is the only layer fully AWS-bound (AI, eligibility, payments are behind interfaces)
- Fargate floor → consolidate services into tiered clusters

**Revisit trigger:** > 20 services or multi-region requirement → EKS; sustained utilization < 20% → Lambda for bursty services (not gRPC/queue ones).

## 3. Cross-Decision Effects

- **TO-1 + TO-4 are mutually reinforcing:** the schema is the hard boundary, RLS the second layer — but both must be wired by the same middleware (tenant context → search_path + current_setting). A bug in that middleware defeats both layers at once. → Dedicated integration test per release; the middleware is the single most security-critical file in the system.
- **TO-2 + TO-5:** the de-identification pipeline (TO-2) is the same pipeline that feeds the opt-in aggregate (TO-5). Quality of de-identification directly determines moat safety. If de-id accuracy drops, both clinical safety and compliance degrade together.
- **TO-2 + TO-6:** everything is AWS-shaped; a change at the provider layer (TO-2) is the only escape hatch — keeping Bedrock behind an interface protects the deployment too.
- **TO-3 + TO-4:** the gateway's tenant-context middleware (TO-3) is the app-level counterpart of schema isolation (TO-4) — gateway misconfig surfaces as RLS-correct-but-403 errors, which are safe-by-design (deny by default).
- **TO-1 + TO-3 (cost estimation flow):** eligibility + adjudication cross the payer API and Stripe (external) while reading per-tenant schemas — the cost service inherits the strictest isolation requirements of both worlds.

**Boundary Safety check** (patterns 1–6 per `boundary-safety.md`):
- [x] Patterns 1–6 reviewed against each TO-N
- [x] No trade-off silently weakens a boundary (TO-1/TO-4 both harden tenant boundary)
- [x] Inversion-of-control boundaries used where units diverge (AI provider interface, eligibility interface, payment interface)

## 4. Deferred Decisions

| Deferred decision | Why not decided now | Revisit condition |
|---|---|---|
| Multi-region deployment | Single region (us-east-1) suffices for v1; RTO defined locally | RTO < 1 h or second region contractually required (TO-6) |
| Kubernetes (EKS) | Ops tax > benefit at 7 services | > 20 services or multi-region (TO-6) |
| Shared-schema tier at 10k+ tenants | Schema count ceiling not reached | > 2,000 schemas with sustained growth (TO-4) |
| Telehealth video (Twilio) | v1.1 scope; not load-bearing | Post-launch roadmap (explicit, not silent) |
| Own LLM training | No LLMOps capability; Bedrock managed models first | Global base-model quality plateaus AND opt-in pool > 1M notes (TO-5) |
| GraphQL for portal | REST suffices; avoid 4th paradigm | Portal API complexity grows beyond REST ergonomics (TO-3) |

## 5. Open Questions

- Confirm AWS Bedrock + AgentCore HIPAA eligibility in our enterprise agreement (gate: before Sprint 3) — assumption 2
- Which clearinghouse partner(s) for eligibility + X12 — affects TO-1/TO-3 integration surface (gate: end of Sprint 1)
- Design-partner clinics for the pilot — affects assumption 1 validation

---

## Related Documents

- ADR-001..006 (per decision register above)
- `architecture/saas.md` (design doc — Section 9 summarizes this ledger)
- `ideas/saas.md` (discovery — cost, roadmap, risk register)

*Template: agent-v01/references/templates/trade-off-doc-template.md*
