# ADR-002: HIPAA-Compliant AI Pipeline

**Status:** Accepted
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)
**Source:** `documents/saas.md` ADR-002

---

## Context

AI features (SOAP note generation from visit audio, ICD-10/CPT coding) process PHI. HIPAA requires a compliant pipeline: transcription, de-identification, LLM inference, re-identification, and a provider review gate. The LLM provider and orchestration must be HIPAA-eligible.

## Decision

**AWS Bedrock + Bedrock AgentCore** (HIPAA-eligible per AWS, Feb 2026) orchestrating: Transcribe (STT) → Comprehend Medical (de-identify) → Claude via Bedrock (SOAP/coding) → re-identify → provider review → save. **No separate BAA needed** for Bedrock services (verify assumption 2; fallback plan exists). Guardrails required to prevent hallucination.

## Alternatives Considered

### Alternative 1: AWS Bedrock + AgentCore (chosen)
- **Pros:** HIPAA-eligible managed services; AgentCore orchestrates the 5-step pipeline; pay-per-use; Claude models available; no PHI leaving AWS
- **Cons:** AWS dependence; guardrails are config not code; pricing at scale (pay-per-use)
- **Why chosen:** Only HIPAA-eligible managed path at v1 scale; no self-hosted GPU ops

### Alternative 2: Self-hosted LLM (vLLM/OpenAI-compatible)
- **Pros:** Full control; no per-token cost at scale
- **Cons:** PHI in our custody = larger risk surface; GPU ops; not HIPAA-eligible out of the box; team has no LLMOps muscle
- **Why rejected:** Risk/ops posture wrong for a healthcare startup; assumption 3 (quality) unproven on small models

### Alternative 3: OpenAI API with enterprise HIPAA BAA
- **Pros:** Strong models; familiar APIs
- **Cons:** BAA negotiation + PHI crosses to another provider; no managed agentic orchestration at decision time; AWS already hosts our data
- **Why rejected:** Bedrock keeps the whole PHI lifecycle inside one compliant account

## Consequences

### Positive
- Single-vendor PHI lifecycle (AWS only); provider approval gate keeps humans in the loop for all clinical content
- De-identification before LLM inference shrinks PHI exposure surface to Transcribe + Comprehend outputs

### Negative
- **AI hallucination risk** (clinical harm) → mitigation: guardrails, confidence thresholds, low-confidence flags, provider edit/approve gate, override logging, never auto-commit
- Single-vendor lock-in → mitigation: AI provider behind an interface; revisit trigger: Bedrock price hike or eligibility change

### Neutral
- Per-token cost model needs monitoring (Bedrock $500–1,000/mo at 10 tenants)

## Compliance Checklist

- [x] Team informed about this decision
- [x] Security reviewed (de-id pipeline, re-identification, guardrails)
- [ ] BAA status confirmed with AWS account team
- [x] Performance impact assessed (< 10 s SOAP target)

## Related ADRs

- ADR-005 (AI Training Data Flow)
- ADR-006 (Deployment Topology)

---

*Template: agent-v01/references/templates/adr-template.md*
