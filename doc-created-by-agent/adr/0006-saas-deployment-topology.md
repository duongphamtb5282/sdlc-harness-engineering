# ADR-006: Deployment Topology

**Status:** Accepted
**Date:** 2026-07-31
**Author:** bmad-architect (Winston)
**Source:** `documents/saas.md` ADR-006

---

## Context

Seven Go microservices + Next.js SPA + AI pipeline need a HIPAA-aligned, cost-predictable deployment. The team is small (3 devs); ops must be minimal. Budget: $2,650–3,650/mo infra at 10 tenants.

## Decision

**AWS ECS Fargate + Aurora PostgreSQL + ElastiCache Redis + WAF v2 + CloudFront CDN.** S3 for audio/backups, asynq (Redis) for background jobs, Datadog for observability.

## Alternatives Considered

### Alternative 1: ECS Fargate + Aurora (chosen)
- **Pros:** Serverless-ish ops (no EC2 patching); AWS-native HIPAA posture; Aurora auto-scaling for schema growth; predictable per-hour cost
- **Cons:** Fargate per-service cost floor; cold starts on scale-to-zero (avoided — keep min 1)
- **Why chosen:** Small team, minimal ops, all services already AWS-native (ADR-002/003)

### Alternative 2: Kubernetes (EKS)
- **Pros:** Flexible, industry standard at scale
- **Cons:** Ops burden (control plane, node groups) on a 3-dev team; overkill for 7 services
- **Why rejected:** Ops tax exceeds benefit at this scale; revisit trigger: > 20 services or multi-region

### Alternative 3: Lambda + API Gateway
- **Pros:** Scale-to-zero cost
- **Cons:** Long-lived connections (gRPC), pgx pools, asynq workers fit poorly; cold-start latency vs < 200 ms targets
- **Why rejected:** Service profile (gRPC, queues, connections) is container-shaped

## Consequences

### Positive
- One-click-ish deploys; Aurora gives HA + cross-tenant schema capacity; WAF + CloudFront for DDoS/TLS edge
- Cost model matches the $2,650–3,650/mo budget at 10 tenants

### Negative
- AWS lock-in (all decisions in this ADR set are AWS-shaped) → mitigation: provider interfaces (AI, eligibility) so only infra stays AWS; revisit triggers defined
- Fargate per-service minimum cost → mitigation: consolidate 7 services into shared clusters by tier

### Neutral
- Multi-region not in v1 (deferred; revisit when RTO < 1 h or second region required)

## Compliance Checklist

- [x] Team informed about this decision
- [x] Migration plan exists (if replacing existing system — greenfield, N/A)
- [x] Rollback plan exists (image rollback + DB restore)
- [x] Security reviewed (WAF, VPC, encryption, backups)
- [x] Performance impact assessed (Aurora capacity for thousands of schemas)

## Related ADRs

- ADR-001 (Multi-Tenancy — Aurora per-tenant schema capacity)
- ADR-002 (AI Pipeline — Bedrock within same account/VPC)

---

*Template: agent-v01/references/templates/adr-template.md*
