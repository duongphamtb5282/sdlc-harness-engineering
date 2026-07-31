# Idea: Multi-Tenant Healthcare SaaS Platform

**Status:** Refined
**Date:** 2026-07-31
**Author:** bmad-analyst (Mary)
**Source:** `documents/saas.md` (full design v1, generated 2026-07-30)

---

## Problem Statement

Clinics lose revenue to documentation overhead (providers spend 4–6 h/day), denied claims (15% denial rate), and surprise bills (40% of patients don't pay) — fragmented legacy EHRs make it impossible to fix any of the three.

## Target Users

| Persona | Role | Context |
|---|---|---|
| Clinic Admin | Runs the practice | Spreadsheets + legacy EHR, no unified billing/scheduling |
| Physician | Documents visits, orders, prescribes | 4–6 h/day documentation, fragmented systems |
| Patient | Books, attends, pays | Phone calls, paper forms, surprise bills |
| Billing Staff | Claims + reimbursement | Manual coding, 15% claim denial rate |

## Recommended Direction

A HIPAA-compliant, multi-tenant cloud-native SaaS (Go microservices + Next.js + PostgreSQL + AWS) delivering patient records, scheduling, billing, telehealth, and AI clinical intelligence — with **real-time cost estimation at check-in/checkout** as the revenue-cycle differentiator and **AI SOAP notes/coding** as the moat. Hybrid multi-tenancy (per-tenant schemas standard, dedicated DB for enterprise) balances isolation vs. cost.

## Key Assumptions

1. **Hybrid multi-tenancy (per-tenant schema + RLS) meets HIPAA for standard tenants** — {if wrong: need dedicated DBs for all → infra cost ~10x}
   - **Validate how:** HIPAA risk assessment + security review of RLS isolation; pilot with 2–3 design-partner clinics
   - **By when:** End of Sprint 1 (before building Patient Management on top)
2. **AWS Bedrock + AgentCore are HIPAA-eligible without a separate BAA** — {if wrong: AI pipeline must pivot to another provider or add a BAA process → 2–3 mo delay}
   - **Validate how:** Confirm current AWS HIPAA-eligible services list + enterprise agreement terms (claimed Feb 2026)
   - **By when:** Before Sprint 3 (AI Integration)
3. **Speech-to-text accuracy ≥ 95% and SOAP generation < 10 s via Bedrock** — {if wrong: AI features degrade to manual notes → value prop and fundraising narrative collapse}
   - **Validate how:** Spike with 100 de-identified sample notes; measure accuracy + latency
   - **By when:** End of Sprint 2 (AI spike before Sprint 3 commitment)
4. **Real-time insurance eligibility APIs are available for the target payers** — {if wrong: cost estimation at check-in falls back to best-effort/offline → weaker "collect 3x at time of service" claim}
   - **Validate how:** Integration review with 2–3 clearinghouse/payer API partners
   - **By when:** End of Sprint 1
5. **Market claims: $27.5–33.2B (20.6% CAGR), 15% denial baseline, 40% non-payment** — {if wrong: fundraising narrative and pricing model need rework}
   - **Validate how:** Independent market-research citations + investor feedback round
   - **By when:** Before any external raise/pitch
6. **Clinics will adopt per-provider $200–500/mo + AI premium pricing** — {if wrong: unit economics change; 2% transaction fee may need adjustment}
   - **Validate how:** Pricing interviews with 10+ target clinics
   - **By when:** End of Sprint 2

> ⚠️ Per spec-driven-development: each assumption carries a **validation gate** — no phase advances past its gate with an unvalidated assumption. Inferred items marked `[ASSUMPTION]` (bmad-product-brief convention).

## MVP Scope (v1)

- **Tenant Management:** registration/onboarding, schema provisioning, RBAC, SSO + MFA
- **Patient Management:** registration (PHI encryption), search, chart view, FHIR R4 read
- **Appointment Scheduling:** online booking, double-booking prevention, provider calendar, check-in
- **Cost Estimation (differentiator):** check-in eligibility + estimate, checkout adjudication, payment collection (Stripe), patient portal
- **AI Integration (moat):** SOAP note generation (transcribe → de-identify → Claude → re-identify), ICD-10/CPT coding suggestions, no-show prediction
- **Billing & Claims:** X12 837 generation/submission, ERA posting, denial management
- **Compliance:** HIPAA audit log (granular, read+write), compliance dashboard

## Future Considerations

- Telehealth video visits (Twilio) — v1.1
- Patient-facing portal beyond balance/payment (records, messaging)
- Drug interaction checks, predictive analytics, population health (value-based care)
- Global AI base model from opt-in de-identified data with tenant pricing incentives

## Not Doing

- Dedicated database per tenant for standard tier (enterprise-only, later)
- On-premise / private-cloud deployment
- Own LLM training (Bedrock managed models only)
- Direct EHR integration beyond FHIR R4 read (no Epic/Cerner proprietary APIs)
- Consumer wellness app / patient-owned records (no HIPAA-right-of-access portal in v1)

---

## Cost & Effort

### Build Effort (rough order of magnitude)

| Phase (kernel workflow) | Effort (person-weeks) | Notes |
|---|---|---|
| Discovery → one-pager approved | 1 | This document |
| `/spec` (SPEC.md + ACs) | 1 | Gates on assumptions 1–2 |
| `/arch-design` (ADRs + trade-off doc + diagrams) | 2 | Gates on assumption 2 |
| `/build` (4 sprints × 2 wks, 3 devs) | 28 | Source §11/§12: $84,000 @ 3 devs |
| QA / hardening / HIPAA pre-audit / launch | 4 | + compliance counsel |

**Total build:** ~36 person-weeks (~$108,000–120,000 incl. QA + counsel)

### Run Cost (v1 steady-state, 10 tenants)

| Item | Monthly | Notes |
|---|---|---|
| ECS Fargate (6 microservices) | $800 | source §12 |
| Aurora PostgreSQL (1 cluster) | $400 | per-tenant schemas |
| ElastiCache Redis | $150 | sessions + asynq |
| S3 + CloudFront | $100 | audio, backups |
| AWS Bedrock (pay-per-use) | $500–1,000 | AI pipeline |
| Auth0 | $200 | SSO/SAML/MFA |
| Stripe (2.9% + $0.30/txn) | Variable | payment collection |
| Twilio + Datadog + misc | $500 | SMS, observability |
| **Total monthly** | **$2,650–3,650** | per source §12 |

**Per-tenant economics:** $200–500/provider/mo + $100–200 AI premium + 2% of collected claims → $1,500–3,500/clinic/mo; breakeven at ~10 clinics (month 3–4); 75–80% gross margin.
**Budget envelope:** $120K build + $40K/yr run (10 tenants). **Funding source:** TBD — investor pitch (AI moat narrative) or internal budget.

> Costs are estimates, not commitments. Re-estimate at `/spec` and again at `/arch-design` when the trade-off document lands.

## Roadmap

Gates align to the kernel workflow: **a phase does not start until its gate is met** (spec-driven-development gating).

| Phase | Deliverable | Gate (exit criteria) | Est. duration |
|---|---|---|---|
| Discovery | This one-pager **approved** | Assumptions 1–2 validation started; cost/roadmap agreed | 1 w |
| Specification | `SPEC.md` | Assumption 1 validated (HIPAA RLS posture); success criteria measurable | 1 w |
| Architecture | ADRs + trade-off doc + diagrams | Every load-bearing decision has alternatives; boundary-safety checked; assumption 2 validated | 2 w |
| Build — Sprint 1 | Foundation: tenant onboarding, schema, RBAC, patient register | T1.1–T1.6 + P1.1–P1.4 done; assumption 4 validated | 2 w |
| Build — Sprint 2 | Scheduling + check-in + eligibility | A1–A3, CE1.1–CE1.4; assumptions 3, 6 validated | 2 w |
| Build — Sprint 3 | AI + payments | AI1.1–AI1.7, CE2, CE3 | 2 w |
| Build — Sprint 4 | Billing + compliance + portal | B1–B3, CE4, COMP | 2 w |
| Launch | Release + HIPAA readiness + retrospective | Success criteria met; `bmad-retrospective` run | 1 w |

**Dependencies / external inputs:** payer eligibility APIs (assumption 4), AWS enterprise agreement for Bedrock HIPAA (assumption 2), Stripe Connect, Auth0 tenant, design-partner clinics for pilot.
**Milestones:** M1 = tenant can register + login + register a patient (end S1) · M2 = patient books + checks in + sees cost estimate (end S2) · M3 = AI SOAP + payment at checkout (end S3) · M4 = full revenue cycle (end S4).

## Risks and Mitigations

| Risk | Likelihood | Impact | Owner | Early-warning signal | Mitigation |
|---|---|---|---|---|---|
| HIPAA violation / PHI breach (RLS misconfig, logging PHI, encryption gap) | M | Critical | Architect + compliance | Audit log gaps, security-review findings, RLS bypass test failures | Boundary-safety review each sprint; per-tenant keys; granular audit; pre-launch HIPAA assessment; breach-response runbook |
| AWS Bedrock HIPAA eligibility claim wrong / changes | M | High | Architect | AWS service-list change; BAA terms ambiguity | Fallback AI provider plan; negotiate BAA; don't store PHI outside de-identified pipeline |
| AI hallucination in SOAP/coding (clinical harm) | M | High | AI lead | Provider override rate > 20%; low-confidence flags ignored | Guardrails, provider review + approve gate (never auto-commit), confidence thresholds, logging overrides |
| Payer eligibility API unavailable/latent (>2 s) | H | Medium | Backend lead | Integration pilot latency; timeouts | Cache eligibility 24 h; degrade gracefully to best-effort estimate; offline queue |
| Multi-tenant isolation bug leaks cross-tenant data | L | Critical | Architect | RLS test failures; cross-tenant 403 tests fail | RLS enforced at DB level; per-tenant schema + search_path; automated isolation test suite each release |
| Single-vendor lock-in (AWS + Auth0 + Stripe) | M | Medium | CTO | Pricing hikes; outage | Abstract AI/eligibility behind interfaces (trade-off doc revisit triggers) |
| Claim denial / X12 rejection rate stays 15% | M | Medium | Billing lead | Denial-rate dashboard flat | AI coding + appeal engine (AI-006); denial reason-code analytics |
| Market assumptions stale (CAGR, denial baseline) | M | Medium | Founder | Investor feedback contradicts pitch | Re-validate assumption 5 before raise |

## Alternatives Considered

| Alternative | Why Rejected |
|---|---|
| Shared DB + shared schema (RLS only) | Cheapest, but HIPAA isolation posture weakest for mid-market; tenant size skew causes noisy-neighbor problems |
| Dedicated DB per tenant (all tenants) | Gold-standard isolation but ~10x infra cost; infeasible for 10–1,000 small tenants economics |
| Single monolithic backend | Faster start, but tenant/schema isolation, AI pipeline, and billing need independent scaling + release cadence |
| Self-hosted LLM for SOAP/coding | No HIPAA-eligible managed option at v1 scale; GPU ops + PHI in our custody = higher risk surface |
| OpenAI API for clinical AI | Lacked HIPAA-eligible agentic pipeline at decision time; Bedrock AgentCore covers orchestration |
| Buy an existing EHR | Does not solve multi-tenant SaaS economics; no cost-estimation or AI moat differentiation |
