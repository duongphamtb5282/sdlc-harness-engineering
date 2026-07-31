# Specification: Multi-Tenant Healthcare SaaS Platform

**Status:** Reviewed
**Version:** 1.0
**Date:** 2026-07-31
**Author:** bmad-product-manager (John)
**Source:** `documents/saas.md` §2 (PRD) + §6 (User Stories); idea: `ideas/saas.md`

---

## 1. Objectives

### Business Goal
Ship a HIPAA-compliant multi-tenant SaaS that lets clinics run scheduling, billing, and documentation in one system — cutting provider documentation time by 70% (AI SOAP), reducing claim denials by 40% (AI coding), and collecting 3x more at time of service (cost estimation).

### Success Criteria
- SC-1: Tenant can onboard end-to-end (register → schema provisioned → SSO login → register patient) in < 10 min
- SC-2: Cost estimate displayed at check-in for 100% of insured patients with active eligibility
- SC-3: 100% of payments collected at checkout generate a receipt; Stripe failures never block checkout
- SC-4: AI SOAP draft generated from 5-min audio in < 10 s with transcription accuracy ≥ 95%
- SC-5: No cross-tenant data access possible — isolation test suite green on every release
- SC-6: 100% of PHI field reads and writes appear in the immutable audit log
- SC-7: Claim submission runs fully automated (X12 837 valid → clearinghouse acknowledged)

## 2. User Stories

### Story 1: TENANT-001 — Clinic Registration & Onboarding
```gherkin
As a clinic admin
I want to register my clinic and get a provisioned tenant with SSO
So that my staff can start working immediately with isolated data

Acceptance Criteria:
- Given a new clinic with NPI "1234567890" and tax ID "98-7654321"
  When they submit the registration form
  Then a tenant record is created with status "pending"
  And a PostgreSQL schema "tenant_{id}" is provisioned within 3 seconds
  And an Auth0 SSO connection is configured for the tenant domain
  And a welcome email is sent within 60 seconds
  And the response status is 201
- Given an existing tenant with NPI "1234567890"
  When a new registration with the same NPI is submitted
  Then the response status is 409 with error "NPI already registered"
- Given Tenant A and Tenant B have data
  When a query is executed on Tenant A's schema
  Then Tenant B's data is NOT accessible (response < 200 ms)

RED test: internal/tenant/handler/register_test.go — TestRegisterTenant_Success, _DuplicateNPI, _SchemaIsolation
```

### Story 2: TENANT-003 — Role-Based Access Control (RBAC)
```gherkin
As a tenant admin
I want to invite users with role-scoped permissions and enforce MFA
So that access to PHI is controlled by role + tenant scope

Acceptance Criteria:
- Given an authenticated tenant admin
  When they invite "dr.smith@clinic.com" with role "physician"
  Then an invitation email is sent and the user is created with status "pending"
  And the role has permissions: ["read:patients", "write:encounters", "write:prescriptions"]
- Given User A belongs to Tenant A and User B to Tenant B
  When User A queries Tenant B's patients
  Then the response is 403 Forbidden
- Given a user with role "front_desk"
  When they attempt to DELETE a patient record
  Then the response is 403 Forbidden and the denied attempt is audit-logged
- Given a user with any role except "read-only"
  When they log in
  Then MFA is prompted; access denied if not completed within 5 minutes

RED test: internal/auth/rbac_test.go — TestRBAC_PhysicianCanWriteEncounters, _FrontDeskCannotDeletePatients, _CrossTenantAccessDenied, _MFARequiredForAllRoles
```

### Story 3: PATIENT-001 — Patient Registration with PHI Encryption
```gherkin
As a front-desk staff member
I want to register patients with duplicate detection and encrypted PHI
So that records are safe and never double-entered

Acceptance Criteria:
- Given a valid patient with name "John Doe", DOB "1990-01-15", phone "555-0101"
  When POST /api/patients is called
  Then a patient is created with a tenant-scoped unique ID and response status 201
  And the SSN column contains ciphertext (never plaintext), keyed per-tenant
- Given an existing patient with the same name + DOB + phone
  When registered again
  Then the response status is 409 with "duplicate_patient: John Doe (ID: pat-123)"
- Given Patient A is registered under Tenant A
  When Tenant B searches for Patient A by name
  Then the result is empty

RED test: internal/patient/register_test.go — TestRegisterPatient_Success, _DuplicateDetection, _SSNEncryptedAtRest, _TenantIsolation
```

### Story 4: APPT-001 — Patient Books Appointment Online
```gherkin
As a patient
I want to book a provider slot online
So that I don't have to call the clinic

Acceptance Criteria:
- Given a provider has available slots on "2026-08-15 14:00-15:00"
  When a patient books 14:30 for "checkup"
  Then the appointment is created with status "confirmed" and a confirmation email is sent
  And the provider's schedule shows 14:00-14:30 available, 14:30-15:00 booked
- Given an appointment exists at 14:30-15:00 for Provider A
  When another patient books the same slot
  Then the response status is 409 with error "slot_already_booked" (DB-level trigger, not just app check)
- Given a provider's hours are "09:00-17:00" with lunch "12:00-13:00"
  When GET /api/providers/{id}/slots?date=2026-08-15 is called
  Then available slots are 09:00-12:00 and 13:00-17:00
- Given a provider's hours are "09:00-17:00"
  When a patient books at 18:00
  Then the response status is 400 with error "outside_working_hours"

RED test: internal/appointment/booking_test.go — TestBook_Success, _DoubleBookingRejected, _AvailabilityCalculation, _OutOfHoursRejected
```

### Story 5: COST-001 — Check-In: Estimate Patient Responsibility
```gherkin
As a front-desk staff member
I want the patient's financial responsibility estimated at check-in
So that we collect the right amount at time of service

Acceptance Criteria:
- Given a patient with copay=$20 and deductible_remaining=$500
  When they check in for an office visit (CPT 99213)
  Then eligibility returns "active" and the estimate is: copay $20 (due today), total $60
  And the message is "Your estimated visit cost is $60. $20 copay is due today."
- Given deductible_remaining=$1,500 and visit charge=$200
  When the estimate is calculated
  Then patient pays full $200 toward deductible
- Given deductible_remaining=$0 and coinsurance=20%
  When the estimate is calculated for a $200 visit
  Then patient pays $40; insurance pays $160
- Given the patient has met their $3,000 out-of-pocket max
  When the estimate is calculated
  Then patient pays $0; insurance pays 100%
- Given eligibility returns "inactive"
  When the estimate is calculated
  Then the patient is notified "Unable to verify insurance..." and check-in is NOT blocked

RED test: internal/cost/estimator_test.go — TestEstimate_CopayOnly, _DeductibleNotMet, _CoinsuranceApplies, _OOPMaxReached, _InsuranceInactive
```

### Story 6: COST-002 — Checkout: Finalize Charges
```gherkin
As a billing staff member
I want itemized final charges with insurance adjudication at checkout
So that the patient sees an accurate balance

Acceptance Criteria:
- Given a visit with CPT codes 99213 ($150.00) and 96372 ($75.00)
  When checkout is calculated
  Then itemized charges total $225.00
- Given copay=$20, deductible_remaining=$500, coinsurance=20%, charges=$225.00
  When adjudication is calculated
  Then contractual adjustment is -$67.50 (30% contract rate), allowed amount $157.50
  And copay -$20, deductible -$137.50, patient balance $0.00
- Given deductible_remaining=$0, coinsurance=20%, allowed $157.50, copay collected $20
  When adjudication is calculated
  Then patient balance = $27.50

RED test: internal/cost/adjudicator_test.go — TestAdjudicate_ContractualAdjustment, _BalanceAfterDeductibleMet
```

### Story 7: AI-001 — AI-Assisted SOAP Note Generation
```gherkin
As a physician
I want AI to draft SOAP notes from my visit audio
So that I spend minutes instead of hours on documentation

Acceptance Criteria:
- Given a provider records 5 minutes of audio
  When the audio is uploaded to S3
  Then AWS Transcribe processes it within 2 minutes with accuracy ≥ 95%
- Given a transcript containing "Patient John Smith (DOB: 1990-01-15) has diabetes"
  When de-identification runs via Comprehend Medical
  Then "John Smith" → "[PATIENT_NAME]", "1990-01-15" → "[DOB]", "diabetes" preserved
- Given a de-identified transcript
  When Claude via Bedrock AgentCore generates the SOAP note
  Then the response contains non-empty Subjective/Objective/Assessment/Plan sections in < 10 s
- Given a de-identified draft with placeholders
  When re-identification runs
  Then placeholders are replaced with the actual patient values
- Given a draft SOAP note
  When the provider reviews and clicks "Approve"
  Then the note is saved to the chart and audit-logged ("provider [id] approved SOAP note for encounter [id]")
- Given a draft SOAP note
  When the provider edits the Assessment section before approving
  Then the edited version is saved and the original draft is preserved for audit

RED test: internal/ai/soap_test.go — TestSOAP_TranscribeAudio, _DeidentifyPHI, _ClaudeGeneratesValidSOAP, _Reidentify, _ProviderApprovalSavesToChart, _ProviderEditsBeforeApproval
```

### Story 8: BILL-001 — Claim Generation & Submission
```gherkin
As a billing staff member
I want automated X12 837 claim generation and submission
So that claims go out accurately without manual EDI work

Acceptance Criteria:
- Given a completed visit with CPT + ICD-10 codes and patient info
  When the claim is generated
  Then a valid X12 837 EDI file is produced (ISA header, GS segment, patient name, provider NPI, codes) passing syntax validation
- Given a validated X12 837 file
  When submitted via SFTP
  Then the clearinghouse acknowledges receipt and status becomes "submitted"
- Given a submitted claim
  When the X12 277 response is received
  Then status updates to "accepted" or "rejected" (rejection reason stored)

RED test: internal/billing/claim_test.go — TestClaim_GenerateValidX12837, _SubmitToClearinghouse, _TrackStatusFrom277
```

### Story 9: AI-003 — Predictive No-Show Detection (P1)
```gherkin
As a clinic admin
I want AI to flag likely no-shows and send enhanced reminders
So that we reduce the no-show rate by 35%

Acceptance Criteria:
- Given an appointment scheduled 48h from now
  When the no-show prediction runs
  Then a 0-100% probability is calculated; >70% flagged "high_risk"
- Given a "high_risk" appointment
  When reminders are sent
  Then TWO reminders go out (48h + 24h) with "Need to reschedule? Reply R to reschedule."
- Given the system has run for 3 months
  When the no-show rate is calculated
  Then the rate is ≤ 22% (baseline 35%)

RED test: internal/ai/noshow_test.go — TestNoShow_HighRiskFlagged, _EnhancedReminders, _RateReduction
```

## 3. Requirements

### Functional Requirements (summary of full story set in `documents/saas.md` §6)
- FR-1: Tenant lifecycle — registration, provisioning, RBAC, SSO/SAML, MFA (TENANT-001..003)
- FR-2: Patient lifecycle — CRUD, duplicate detection, search, chart, FHIR R4 read (PATIENT-001..003)
- FR-3: Scheduling — booking w/ DB-level double-booking prevention, calendar, block, check-in (APPT-001..003)
- FR-4: Cost estimation — eligibility, estimate, adjudication, payment collection, payment plans, portal (COST-001..004)
- FR-5: AI — SOAP notes, ICD-10/CPT coding, no-show prediction (AI-001..003)
- FR-6: Billing — X12 837/835, claims, ERA posting, denials (BILL-001..002)
- FR-7: Compliance — granular immutable audit log, HIPAA dashboard (COMP-001..002)

### Non-Functional Requirements
- NFR-1: Schema provisioning < 3 s; eligibility check < 2 s (cached 24 h); SOAP generation < 10 s
- NFR-2: Tenant isolation enforceable at DB level (RLS + per-tenant schema); cross-tenant access impossible
- NFR-3: PHI encrypted at rest (column-level AEAD, per-tenant keys) + in transit (TLS)
- NFR-4: Audit log append-only/immutable, covering reads AND writes with field granularity
- NFR-5: HIPAA alignment (technical safeguards: access control, audit, integrity, transmission)

## 4. Technical Boundaries

### Always Do
- Set `search_path` per request from tenant context; enable RLS on every PHI table
- Encrypt PHI columns (AEAD, per-tenant key); log reads and writes granularly
- DB-level constraint for double-booking (trigger, not just app check)
- Provider review-and-approve gate before any AI-generated clinical content commits
- TDD: RED test derived from `qa/test-cases.md` before implementation

### Ask First (requires human approval)
- Dedicated database per tenant (enterprise tier) — cost/ops decision
- AI provider change (Bedrock → other) — HIPAA eligibility + migration
- Storing raw PHI outside the de-identified pipeline (e.g., training data)
- Adding new external integrations that touch PHI (EHR, payers)

### Never Do
- Store plaintext SSN/PHI in the database or logs
- Serve cross-tenant data under any query path (no RLS bypass, no `SECURITY DEFINER` shortcuts)
- Auto-commit AI-generated SOAP notes/codes without provider approval
- Log full PHI payloads; use de-identified tokens/IDs in logs

## 5. Out of Scope

- Telehealth video (v1.1), patient records portal, drug-interaction checks, population health
- On-prem deployment; Epic/Cerner proprietary integrations (FHIR R4 read only)
- Self-hosted LLM training/inference
- Consumer wellness features; HIPAA patient-right-of-access portal

## 6. Assumptions

1. Hybrid multi-tenancy (per-tenant schema + RLS) meets HIPAA for standard tenants — **Impact if wrong:** dedicated DBs for all → ~10x infra cost. Gate: end of Sprint 1.
2. AWS Bedrock + AgentCore HIPAA-eligible without separate BAA — **Impact if wrong:** AI pipeline pivot → 2–3 mo delay. Gate: before Sprint 3.
3. STT accuracy ≥ 95%, SOAP < 10 s via Bedrock — **Impact if wrong:** AI value prop collapses. Gate: end of Sprint 2 spike.
4. Real-time payer eligibility APIs available — **Impact if wrong:** best-effort estimates. Gate: end of Sprint 1.
5. Market/pricing claims hold ($27.5–33.2B, $200–500/provider/mo) — **Impact if wrong:** fundraising narrative rework. Gate: before external raise.

---

## Appendix: Cost Estimation Flow (User Flow)

```
Check-in: verify identity → eligibility check (payer API) → estimate (copay/deductible/coinsurance, capped at OOP max) → display + collect copay → store cost_estimates(status=estimated)
Checkout: build service lines from CPT → adjudicate (contractual adj, copay, deductible, coinsurance) → itemized summary → collect payment (Stripe) → finalize → claim (async X12 837)
```

## Appendix: Data Dictionary (cost estimation core)

| Field | Type | Description | Required |
|---|---|---|---|
| insurance_plans.payer_id | text | Payer identifier (e.g., "BCBS-IL") | Yes |
| insurance_plans.coinsurance_percent | decimal(5,2) | e.g., 20% | Yes |
| patient_insurance.eligibility_status | text | active/inactive/not_found | Yes |
| cost_estimates.estimated_patient_total | decimal(10,2) | Patient financial responsibility | Yes |
| cost_estimates.status | text | estimated/finalized/billed | Yes |
| payments.payment_method | text | card/cash/hsa/fsa/payment_plan | Yes |
