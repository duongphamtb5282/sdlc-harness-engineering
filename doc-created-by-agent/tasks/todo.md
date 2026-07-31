# Todo: Multi-Tenant Healthcare SaaS — Ordered Execution

**Source:** `plan.md` (dependency graph) · Order: bottom-up by dependency, execution order below.

## Sprint 1 (Weeks 1–2)

| # | ID | Task | Depends on | Complexity | AC reference |
|---|----|------|------------|------------|--------------|
| 1 | T1.1 | Go project scaffold: chi, pgx, sqlc, dirs (7 services) | — | M | TENANT-001 |
| 2 | T1.2 | Tenant registration handler: validate NPI/tax ID, create tenant | T1.1 | L | TENANT-001 |
| 3 | T1.3 | Schema provisioning: CREATE SCHEMA + per-tenant migrations | T1.2 | M | TENANT-001 |
| 4 | T1.4 | Auth0 automation: SSO connection via Management API | T1.2 | L | TENANT-001 |
| 5 | T1.5 | Onboarding email: asynq + SendGrid | T1.3 | S | TENANT-001 |
| 6 | P1.1 | Patient schema (per-tenant) + sqlc queries | T1.3 | M | PATIENT-001 |
| 7 | T3.1 | RBAC model: roles, permissions (Go types + sqlc) | T1.4 | L | TENANT-003 |
| 8 | P1.2 | Patient registration handler + validation | P1.1 | M | PATIENT-001 |
| 9 | P1.3 | Duplicate detection (name+DOB+phone) | P1.1 | M | PATIENT-001 |
| 10 | P1.4 | PHI column-level encryption (AEAD per-tenant key) | P1.1 | L | PATIENT-001 |
| 11 | T3.2 | User invitation flow: invite → email → accept → activate | T3.1 | M | TENANT-003 |
| 12 | T2.1 | Clinic profile CRUD: sqlc + handler | T1.3 | M | TENANT-002 |
| 13 | T2.2 | Business hours + holiday configuration | T2.1 | S | TENANT-002 |
| 14 | T2.3 | Audit logging middleware for config changes | T2.1 | S | TENANT-002 |
| 15 | T3.3 | SAML/SSO integration (Auth0) | T1.4 | L | TENANT-003 |
| 16 | T3.4 | MFA middleware + enforcement | T3.2 | M | TENANT-003 |
| 17 | T3.5 | Permission-check middleware for all PHI endpoints | T3.1 | M | TENANT-003 |
| 18 | T1.6 | Integration test: registration, isolation, timing (<3 s, email <60 s) | T1.5 | L | TENANT-001 |

## Sprint 2 (Weeks 3–4)

| # | ID | Task | Depends on | Complexity | AC reference |
|---|----|------|------------|------------|--------------|
| 19 | A1.1 | Appointment schema + sqlc | P1.1 | M | APPT-001 |
| 20 | A1.2 | Availability calculation (hours/lunch/booked) | A1.1 | M | APPT-001 |
| 21 | A1.3 | Booking + DB-level double-booking trigger | A1.2 | L | APPT-001 |
| 22 | A1.4 | Confirmation email (asynq) | A1.3 | S | APPT-001 |
| 23 | A2.1 | Provider calendar view | A1.3 | M | APPT-002 |
| 24 | A2.2 | Block time slots | A2.1 | S | APPT-002 |
| 25 | A2.3 | Cancel/reschedule + patient notification | A2.1 | M | APPT-002 |
| 26 | A3.1 | Check-in handler (front desk) | A1.3 | M | APPT-003 |
| 27 | A3.2 | Provider notification on check-in | A3.1 | S | APPT-003 |
| 28 | A3.3 | Kiosk check-in + wait-time tracking | A3.1 | M | APPT-003 |
| 29 | CE1.1 | Insurance verification (payer API, 24h cache) | T1.4 | L | COST-001 |
| 30 | CE1.2 | Benefits calculator (copay/deductible/coinsurance/OOP cap) | CE1.1 | M | COST-001 |
| 31 | CE1.3 | Cost display at check-in (FE) | CE1.2 | M | COST-001 |
| 32 | CE1.4 | Store estimate (cost_estimates, status=estimated) | CE1.2 | S | COST-001 |

## Sprint 3 (Weeks 5–6)

| # | ID | Task | Depends on | Complexity | AC reference |
|---|----|------|------------|------------|--------------|
| 33 | AI1.1 | Bedrock SDK integration + AgentCore wiring | — | M | AI-001 |
| 34 | AI1.2 | Audio upload (S3) + Transcribe job | AI1.1 | M | AI-001 |
| 35 | AI1.4 | Claude SOAP prompt + guardrails | AI1.1 | M | AI-001 |
| 36 | AI1.3 | PHI de-identification (Comprehend Medical) | AI1.2 | M | AI-001 |
| 37 | AI1.7 | Re-identification (placeholder → patient) | AI1.3 | M | AI-001 |
| 38 | AI1.5 | Provider review/approve/edit gate | AI1.7 | M | AI-001 |
| 39 | AI1.6 | SOAP save to chart + audit log | AI1.5 | S | AI-001 |
| 40 | CE2.1 | Service line builder (CPT → charge) | P1.1 | M | COST-002 |
| 41 | CE2.2 | Insurance adjudication | CE2.1, CE1.2 | L | COST-002 |
| 42 | CE2.3 | Checkout summary display (FE) | CE2.2 | M | COST-002 |
| 43 | CE3.1 | Stripe Connect integration | CE2.2 | M | COST-003 |
| 44 | CE3.2 | Multi-method payment (card/HSA/cash) | CE3.1 | M | COST-003 |
| 45 | CE3.3 | Payment plans (installments) | CE3.1 | M | COST-003 |
| 46 | CE3.4 | Receipt email + finalize estimate | CE3.2 | S | COST-003 |
| 47 | AI2.1 | ICD-10/CPT suggestion engine | AI1.5 | M | AI-002 |
| 48 | AI2.2 | Confidence scoring + low-confidence flags | AI2.1 | S | AI-002 |
| 49 | AI2.3 | Provider confirmation workflow → billing queue | AI2.2 | M | AI-002 |

## Sprint 4 (Weeks 7–8)

| # | ID | Task | Depends on | Complexity | AC reference |
|---|----|------|------------|------------|--------------|
| 50 | B1.1 | Claim schema + sqlc | CE2.2 | M | BILL-001 |
| 51 | B1.2 | ICD-10/CPT → claim builder | B1.1 | M | BILL-001 |
| 52 | B1.3 | X12 837 generation + syntax validation | B1.2 | L | BILL-001 |
| 53 | B1.4 | Clearinghouse submission (SFTP) + 277 tracking | B1.3 | L | BILL-001 |
| 54 | B2.1 | ERA (835) posting | B1.3 | M | BILL-002 |
| 55 | B2.2 | Denial management (reason codes + guidance) | B2.1 | M | BILL-002 |
| 56 | B2.3 | Auto-appeal generation (AI) | B2.2, AI2.1 | L | BILL-002 |
| 57 | CE4.1 | Patient balance dashboard (FE) | CE3.2 | M | COST-004 |
| 58 | CE4.2 | Online payment + receipt download | CE4.1, CE3.1 | M | COST-004 |
| 59 | CE4.3 | Payment history | CE4.1 | S | COST-004 |
| 60 | CE4.4 | Automated reminders (balance due, SMS+email) | CE4.1 | M | COST-004 |
| 61 | AI3.1 | No-show prediction model + feature store | AI1.1 | M | AI-003 |
| 62 | AI3.2 | Risk-tiered reminders (48h/24h) | AI3.1 | M | AI-003 |
| 63 | AI3.3 | No-show rate dashboard + measurement | AI3.2 | S | AI-003 |
| 64 | B3.1 | Audit log service (append-only, field granularity) | T2.3 | L | COMP-001 |
| 65 | B3.2 | HIPAA compliance dashboard (FE) | B3.1 | M | COMP-002 |
| 66 | B3.3 | Isolation test suite CI gate + pre-launch HIPAA review | B3.1, T3.5 | L | COMP-001/002 |

## Completion Criteria

- [ ] All 66 tasks done, per-task commits
- [ ] Every RED test traces to `../qa/test-cases.md`
- [ ] Isolation test suite green (SC-5); audit coverage 100% (SC-6)
- [ ] Success criteria SC-1..SC-7 measured and reported
