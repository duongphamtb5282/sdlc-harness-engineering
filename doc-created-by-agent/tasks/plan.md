# Plan: Multi-Tenant Healthcare SaaS

**Status:** Reviewed
**Date:** 2026-07-31
**Source:** `documents/saas.md` §6 (tasks), §7 (dependency graph), §11 (sprint plan); `SPEC.md`

---

## Overview

28 engineering-weeks across 4 two-week sprints (3 devs). Each task is a vertical slice with acceptance criteria; every task maps to QA test cases (`../qa/test-cases.md`) that `/build` implements as RED tests first.

## Dependency Graph

```
Sprint 1 (Weeks 1-2)              Sprint 2 (Weeks 3-4)
┌─────────────────────────┐  ┌─────────────────────────────┐
│  T1.1 Go scaffold       │  │  A1.1 Appointment schema    │
│    ↓                    │  │    ↓                        │
│  T1.2 Registration      │  │  A1.2 Availability calc     │
│    ↓         ↓          │  │    ↓                        │
│  T1.3 Schema  T3.1      │  │  A1.3 Booking + trigger     │
│    ↓         ↓          │  │    ↓                        │
│  P1.1 → P1.2  T3.2      │  │  A2.1 → A2.2 → A2.3        │
│    ↓    ↓    ↓          │  │    ↓                        │
│  P1.3  P1.4  P2.1      │  │  A3.1 → A3.2 → A3.3        │
│              ↓          │  │    ↓                        │
│             P2.2        │  │  CE1.1 → CE1.2 → CE1.3     │
│              ↓          │  │              ↓              │
│             P2.3        │  │             CE1.4           │
│              ↓          │  └─────────────────────────────┘
│             P3.1        │
│              ↓          │  Sprint 3 (Weeks 5-6)
│             P3.2/P3.3   │  ┌─────────────────────────────┐
└─────────────────────────┘  │  AI1.1 (Bedrock SDK)        │
                             │    ↓          ↓             │
Sprint 4 (Weeks 7-8)         │  AI1.2      AI1.4           │
┌─────────────────────────┐  │    ↓          ↓             │
│  B1.1 → B1.2 → B1.3    │  │  AI1.3      AI1.7           │
│               ↓         │  │    ↓          ↓             │
│         B1.4 → B2.1     │  │  AI1.5 → AI1.6             │
│                ↓        │  │    ↓                        │
│         B2.2 → B2.3     │  │  AI2.1 → AI2.2 → AI2.3    │
│                │        │  │    ↓                        │
│         B3.1 → B3.2     │  │  AI3.1 → AI3.2 → AI3.3    │
│                │        │  └─────────────────────────────┘
│                └→ B3.3  │
└─────────────────────────┘  Sprint 3 cont.
                             ┌─────────────────────────────┐
                             │  CE2.1 → CE2.2 → CE2.3     │
                             │              ↓              │
                             │             CE2.4           │
                             │                             │
                             │  CE3.1 → CE3.2 → CE3.3     │
                             │              ↓              │
                             │             CE3.4           │
                             └─────────────────────────────┘
```

## Phases (Sprints)

### Sprint 1 (Weeks 1–2): Foundation — "tenant registers, logs in, registers a patient"
| Story | Tasks | Priority | Owner |
|---|---|---|---|
| TENANT-001 Registration/onboarding | T1.1–T1.6 | P0 | Backend |
| TENANT-002 Clinic profile | T2.1–T2.3 | P1 | Backend |
| TENANT-003 RBAC | T3.1–T3.5 | P1 | Backend |
| PATIENT-001 Registration | P1.1–P1.4 | P1 | Backend |

**Gates:** assumption 1 (HIPAA RLS posture) + assumption 4 (payer eligibility availability) validated by sprint end.

### Sprint 2 (Weeks 3–4): Scheduling + Check-in — "patient books, checks in, sees estimate"
| Story | Tasks | Priority | Owner |
|---|---|---|---|
| APPT-001 Booking | A1.1–A1.4 | P0 | Backend |
| APPT-002 Calendar/block | A2.1–A2.3 | P1 | Backend |
| APPT-003 Check-in | A3.1–A3.3 | P1 | Backend |
| COST-001 Check-in estimate | CE1.1–CE1.4 | P1 | Backend+FE |

**Gates:** assumptions 3 (AI spike: STT ≥ 95%, SOAP < 10 s) + 6 (pricing interviews) validated.

### Sprint 3 (Weeks 5–6): AI + Payments — "AI writes SOAP; patient pays at checkout"
| Story | Tasks | Priority | Owner |
|---|---|---|---|
| AI-001 SOAP notes | AI1.1–AI1.7 | P0 | AI |
| AI-002 ICD-10/CPT coding | AI2.1–AI2.3 | P1 | AI |
| COST-002 Checkout finalize | CE2.1–CE2.4 | P1 | Backend |
| COST-003 Payment collection | CE3.1–CE3.4 | P1 | Backend |

**Gate:** assumption 2 (Bedrock HIPAA eligibility) validated.

### Sprint 4 (Weeks 7–8): Billing + Compliance + Portal — "full revenue cycle"
| Story | Tasks | Priority | Owner |
|---|---|---|---|
| BILL-001 Claims | B1.1–B1.4 | P0 | Backend |
| BILL-002 ERA/denials | B2.1–B2.3 | P1 | Backend |
| COST-004 Patient portal | CE4.1–CE4.4 | P1 | Frontend |
| AI-003 No-show prediction | AI3.1–AI3.3 | P1 | AI |
| COMP-001/002 Audit + dashboard | B3.1–B3.3 | P1 | Backend+FE |

**Gate:** success criteria SC-1..SC-7; HIPAA pre-audit; retrospective.

## Handoff

- `/qa` test cases (`../qa/test-cases.md`) are the RED-test source for every task
- `../architecture/saas.md` + `../trade-offs/saas-trade-offs.md` constrain implementation (isolation, boundaries)
