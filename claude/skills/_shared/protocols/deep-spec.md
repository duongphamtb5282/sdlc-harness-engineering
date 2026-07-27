<!-- sdlc-automation-agent-id: deep-spec -->
# Deep Spec Protocol

> **Audience:** Product Manager, Solution Architect, Software Engineer, Quality Engineer, Code Reviewer, Security Engineer
> **Purpose:** Make the spec the single source of truth for ALL agents — not just PM→SA→SE but QE, CR, CE too. Every agent reads from the spec, validates against it, and writes back to it.

## Core Principle

The spec folder `.sdlc-automation-agent/specs/{spec-id}/` is the single source of truth for that feature's delivery. Every agent reads it on startup. Every agent writes back to it on completion. A spec is not "done" until it has been validated by every agent in the pipeline.

## Spec Folder Layout (Deep Spec)

```
.sdlc-automation-agent/specs/{spec-id}/
  requirements.md    # EARS requirements + acceptance criteria (PM)
  contracts.md       # Behavioral contracts per REQ-ID (PM) — NEW
  design.md          # Technical design summary + links (SA)
  tasks.md           # Checkbox implementation plan (PM + SE)
  tests.md           # Test specification per REQ-ID (QE) — NEW
  coverage.json      # File-REQ-ID mapping (SE) — NEW
  metadata.yaml      # ids, status, traceability
```

## Traceability Chain (Bidirectional)

```
REQ-ID → Contracts (input/output/errors) → Design (component/API/ADR) →
Tasks (checkbox) → Code (files) → Tests (assertions) → Receipts (verification)
```

Each link in the chain is machine-verifiable:
- **REQ-ID → Contracts:** Every REQ-ID has an entry in contracts.md
- **Contracts → Design:** Every REQ-ID appears in design traceability table
- **Design → Tasks:** Every task references REQ-IDs
- **Tasks → Code:** SE writes coverage.json mapping files → REQ-IDs
- **Code → Tests:** QE writes tests.md mapping test cases → REQ-IDs
- **Tests → Receipts:** Receipt includes verification_commands that prove REQ-ID coverage

## Agent Responsibilities

| Agent | Reads | Writes | Validates |
|-------|-------|--------|-----------|
| PM | Source docs, BRD | `requirements.md`, `contracts.md` | Every REQ-ID has ≥1 AC + behavioral contract |
| SA | `requirements.md`, `contracts.md` | `design.md`, ADRs | Every REQ-ID in traceability table; ADRs tagged with REQ-IDs |
| PM | `requirements.md`, `design.md` | `tasks.md` | Every REQ-ID referenced by ≥1 task |
| SE | `requirements.md`, `contracts.md`, `tasks.md` | `coverage.json`, code | Implementation covers assigned REQ-IDs only |
| QE | `requirements.md`, `contracts.md`, `design.md` | `tests.md` | Every REQ-ID has ≥1 test case |
| CR | `requirements.md`, `tasks.md`, `coverage.json` | Findings | Code implements exactly the spec'd REQ-IDs (no scope creep) |
| CE | `requirements.md`, `design.md` | Security findings | Threat model scoped to spec's REQ-ID scope |

## Enforcement Gates

These gates are checked by the orchestrator before allowing pipeline progression:

| Gate | Checked By | Blocks | Condition |
|------|-----------|--------|-----------|
| `requirements_approved` | PM + Human | Design start | All REQ-IDs have ACs + behavioral contracts |
| `design_approved` | SA + Human | Tasks creation | Traceability table complete + ADRs tagged |
| `tasks_approved` | PM + Human | Implementation | Every REQ-ID in ≥1 task |
| `test_coverage_pass` | QE | Release sign-off | Every REQ-ID has ≥1 test case in tests.md |
| `spec_compliance_pass` | CR | Merge | Changed files map to spec'd REQ-IDs only |

## Spec-Driven Execution Rule

SE reads `tasks.md`, picks the **next unchecked task**, implements ONLY that task's REQ-ID scope, runs verify, marks checkbox, writes `coverage.json`. Repeat. No implementation outside the tasks.

## Contract-First Testing

QE reads `contracts.md` to derive test cases:
- **Happy path:** Valid input → expected output (from contracts.md)
- **Error path:** Invalid input → expected error (from contracts.md error states)
- **Side effects:** Verify side effects match contracts.md specification
- **Contract tests:** Assert API responses match OpenAPI contracts linked in design.md

## Spec Update Protocol

When requirements change mid-sprint:
1. PM updates `requirements.md` (add/change REQ-IDs)
2. If design affected → SA updates `design.md`
3. If tasks affected → PM updates `tasks.md`
4. QE re-validates test coverage against updated REQ-IDs
5. All gates re-check

No agent writes code for a REQ-ID that doesn't exist in `requirements.md`. No agent marks a task done if its REQ-IDs aren't in `contracts.md`.
