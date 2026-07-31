# QA Test Cases: Multi-Tenant Healthcare SaaS

**Status:** Reviewed
**Date:** 2026-07-31
**Author:** QA engineer (bmad-qa)
**Source:** `SPEC.md` (acceptance criteria), `tasks/todo.md` (tasks), `documents/saas.md` §6

---

## Coverage Map

| Story | # cases | Layers | Test data needed |
|---|---|---|---|
| TENANT-001 Registration/onboarding | 4 | API, Integration, E2E | NPI fixtures, tenant schemas |
| TENANT-003 RBAC | 5 | API | users, roles, 2 tenants |
| PATIENT-001 Patient registration | 4 | API, DB | PHI fixtures |
| APPT-001 Booking | 4 | API, DB | provider schedules |
| COST-001 Check-in estimate | 5 | Unit, API | insurance plan matrix |
| COST-002 Checkout finalize | 3 | Unit, API | CPT → charge table |
| COST-003 Payment collection | 4 | API, E2E | Stripe test mode |
| COST-004 Patient portal | 4 | E2E | balances, payment history |
| AI-001 SOAP notes | 6 | API, E2E | sample audio, transcripts |
| AI-002 Coding | 4 | API | SOAP fixtures |
| AI-003 No-show prediction | 3 | API | historical appts |
| BILL-001 Claims | 3 | Unit, API | X12 fixtures |
| BILL-002 ERA/denials | 3 | API | X12 835 fixtures |
| **Total** | **52** | | |

**Gap check:** every acceptance criterion from `SPEC.md` has ≥ 1 test case — no gaps. ⚠️ Flagged untestable: none (all ACs observable via API/DB/E2E).

---

## Test Cases

### TENANT-001 — Clinic Registration & Onboarding (4)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-001 | AC1 | API | P0 | Register new clinic | POST /api/tenants {npi:"1234567890", tax_id:"98-7654321"} | 201; tenant status "pending"; schema `tenant_{id}` exists; email queued; < 3 s |
| TC-002 | AC2 | API | P0 | Duplicate NPI | POST /api/tenants with existing NPI | 409 "NPI already registered" |
| TC-003 | AC3 | Integration | P0 | Schema isolation | As Tenant A, query Tenant B's schema | No data accessible; < 200 ms |
| TC-004 | AC4 | E2E | P1 | Onboarding completes | Register → poll schema + email | Schema < 3 s; welcome email < 60 s |

### TENANT-003 — RBAC (5)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-005 | AC1 | API | P0 | Admin invites physician | POST invite dr.smith@clinic.com role=physician | Email sent; user pending; perms [read:patients, write:encounters, write:prescriptions] |
| TC-006 | AC2 | API | P0 | Cross-tenant forbidden | User A queries Tenant B patients | 403 Forbidden |
| TC-007 | AC3 | API | P0 | Role permission enforced | front_desk DELETE patient | 403 + denied attempt audit-logged |
| TC-008 | AC4 | API | P0 | MFA enforcement | Login as non-read-only user | MFA prompted; denied after 5 min |
| TC-009 | AC5 | API | P1 | SSO/SAML login | Enterprise tenant login via IdP | JWT contains tenant_id, role, permissions, email |

### PATIENT-001 — Patient Registration (4)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-010 | AC1 | API | P0 | Register patient | POST /api/patients {name:"John Doe", dob, phone} | 201; tenant-scoped ID; SSN column = ciphertext |
| TC-011 | AC1 | DB | P0 | PHI at rest | Read patients row directly (bypass API) | ssn is ciphertext, not plaintext; per-tenant key |
| TC-012 | AC2 | API | P1 | Duplicate detection | Register same name+DOB+phone | 409 "duplicate_patient: John Doe (ID: pat-123)" |
| TC-013 | AC4 | API | P0 | Tenant isolation | Tenant B searches Tenant A's patient by name | Empty result |

### APPT-001 — Booking (4)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-014 | AC1 | API | P0 | Book appointment | POST slot 2026-08-15 14:30 | 201 confirmed; schedule shows booked; email sent |
| TC-015 | AC2 | DB | P0 | Double-booking at DB level | Two concurrent bookings of same slot | Exactly one succeeds; other 409 "slot_already_booked" (trigger) |
| TC-016 | AC3 | API | P1 | Availability calculation | GET slots 2026-08-15, hours 09:00-17:00, lunch 12-13 | Slots 09:00-12:00 and 13:00-17:00; booked excluded |
| TC-017 | AC4 | API | P1 | Out-of-hours rejected | Book at 18:00 | 400 "outside_working_hours" |

### COST-001 — Check-In Estimate (5) — the differentiator

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-018 | AC1 | Unit | P0 | Copay only | plan copay=20, ded_remaining=500, visit=200 | due_today=20, total=60, msg "Your estimated visit cost is $60. $20 copay is due today." |
| TC-019 | AC2 | Unit | P0 | Deductible not met | ded_remaining=1500, charge=200 | patient pays full $200 toward deductible |
| TC-020 | AC3 | Unit | P0 | Coinsurance applies | ded=0, coins=20%, charge=200 | patient $40, insurance $160 |
| TC-021 | AC4 | Unit | P0 | OOP max reached | oop_met=3000 (max) | patient $0, insurance 100% |
| TC-022 | AC5 | API | P0 | Eligibility inactive | payer API returns inactive | Notify "Unable to verify insurance..."; check-in NOT blocked |
| TC-023 | AC-elig | API | P1 | Payer API timeout | payer API > 2 s / timeout | Graceful degrade: best-effort estimate + retry queue (NFR-1) |

### COST-002 — Checkout Finalize (3)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-024 | AC1 | Unit | P0 | Itemized charges | CPT 99213 + 96372 | Charges $150 + $75 = $225.00 |
| TC-025 | AC2 | Unit | P0 | Adjudication | copay=20, ded_remaining=500, coins=20%, charges=225 | adj -$67.50, allowed $157.50, copay -$20, ded -$137.50, balance $0 |
| TC-026 | AC3 | Unit | P0 | Balance after ded met | ded=0, allowed=157.50, copay collected=20 | balance = $27.50 |

### COST-003 — Payment Collection (4)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-027 | AC1 | API | P0 | Card payment | balance=70, pay with valid card | Stripe charge $70; status completed; receipt email |
| TC-028 | AC2 | API | P1 | HSA/FSA card | select "HSA" | Processed via HSA flow; marked "hsa" |
| TC-029 | AC3 | API | P1 | Payment plan | balance=210, 6 installments | 6 × $35; first charged now; 5 scheduled monthly |
| TC-030 | AC4 | API | P0 | Declined card | declined card | status "failed"; alternative method asked; checkout NOT blocked |

### COST-004 — Patient Portal (4)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-031 | AC1 | E2E | P1 | Balance dashboard | patient with $150 due | total_owed=150, overdue=0, due_date=2026-09-01 |
| TC-032 | AC2 | E2E | P1 | Online payment | pay $70 | balance 0; receipt downloadable |
| TC-033 | AC3 | E2E | P2 | Payment history | 5 past payments | 5 rows with date/amount/method/status |
| TC-034 | AC4 | E2E | P2 | Automated reminder | balance due in 3 days | SMS + email reminder sent |

### AI-001 — SOAP Notes (6)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-035 | AC1 | API | P0 | Transcription | upload 5-min audio | Transcribe done < 2 min, accuracy ≥ 95% |
| TC-036 | AC2 | API | P0 | De-identification | transcript w/ "John Smith (DOB: 1990-01-15)" | → [PATIENT_NAME], [DOB]; "diabetes" preserved |
| TC-037 | AC3 | API | P0 | Claude SOAP generation | de-identified transcript via Bedrock | S/O/A/P sections non-empty; < 10 s |
| TC-038 | AC4 | API | P0 | Re-identification | draft with placeholders | placeholders → actual patient values |
| TC-039 | AC5 | API | P0 | Provider approves | click "Approve" | note saved to chart; audit "provider [id] approved SOAP note for encounter [id]" |
| TC-040 | AC6 | API | P1 | Provider edits first | edit Assessment, approve | edited version saved; original draft preserved for audit |

### AI-002 — Coding (4)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-041 | AC1 | API | P1 | ICD-10 suggestion | "type 2 diabetes with neuropathy" | includes E11.40 with confidence |
| TC-042 | AC2 | API | P1 | CPT suggestion | documented procedures | CPT match; E&M codes by complexity |
| TC-043 | AC3 | API | P1 | Provider confirms | confirm E11.40 @92% | saved to encounter; billing queue picks up |
| TC-044 | AC4 | API | P1 | Low confidence flag | R10.9 @65% | flagged "Low confidence (65%). Please verify diagnosis." |

### AI-003 — No-Show Prediction (3)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-045 | AC1 | API | P1 | Prediction generated | appt 48h out | probability 0-100%; >70% → "high_risk" |
| TC-046 | AC2 | API | P1 | Enhanced reminders | high_risk appt | 2 reminders (48h + 24h) incl. "Reply R to reschedule." |
| TC-047 | AC3 | API | P2 | Rate reduction | 3 months of data | no-show rate ≤ 22% |

### BILL-001 — Claims (3)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-048 | AC1 | Unit | P0 | X12 837 generated | completed visit w/ codes | valid EDI: ISA, GS, patient, NPI, CPT, ICD-10; passes syntax validation |
| TC-049 | AC2 | API | P0 | Submission | valid file via SFTP | acknowledged; status "submitted" |
| TC-050 | AC3 | API | P0 | 277 tracking | receive 277 | status accepted/rejected; reason stored |

### BILL-002 — ERA/Denials (3)

| ID | AC ref | Layer | Priority | Scenario | Steps | Expected |
|----|--------|-------|----------|----------|-------|----------|
| TC-051 | AC1 | API | P1 | ERA posted | X12 835 from payer | payment posted; claim "paid"; balance reduced |
| TC-052 | AC2 | API | P1 | Denial reason code | 277 denial CO-45 | status denied; guidance displayed; billing staff notified |
| TC-053 | AC3 | API | P2 | Auto-appeal | correctable denial | appeal letter generated; queued for review |

---

## Test Data & Fixtures Required

- **Tenants:** NPI fixtures (unique + duplicate), 2 tenants for isolation tests
- **Insurance matrix:** plans covering copay-only / deductible / coinsurance / OOP-max / inactive eligibility (TC-018..022)
- **CPT table:** 99213 → $150, 96372 → $75; invalid codes for 422 path
- **Stripe:** test-mode cards (success, declined, HSA)
- **AI:** 5-min sample audio; transcripts with PHI patterns; de-identified drafts; SOAP fixtures for coding
- **EDI:** sample X12 837 + 835 + 277 files (clearinghouse test sandbox)

## Automation Notes

- Unit/API cases (TC-001..053) → Go tests per `bmad-qa-generate-e2e-tests`; RED-first in `/build` TDD cycle
- E2E cases (TC-004, TC-031..034) → Playwright suites on the Next.js portal
- **Run after each release:** isolation trio (TC-003, TC-006, TC-013) as the CI gate (SC-5)
- **Run pre-launch:** full 52-case regression + HIPAA pre-audit checklist
