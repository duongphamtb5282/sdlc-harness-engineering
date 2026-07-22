<!-- sdlc-automation-agent-id: spec-driven-requirements -->
# Spec-Driven Requirements Protocol (Kiro-aligned)

> **Audience:** Product Manager, Solution Architect, orchestrator, Software Engineer.
> **Inspired by:** [Kiro spec-driven development](https://kiro.dev/) and [jasonkneen/kiro](https://github.com/jasonkneen/kiro) (Requirements → Design → Tasks).

## Purpose

Bridge **business intent** (BRD) and **agent-executable work** (stories, tasks, code) using **feature-scoped specs** with **EARS notation** for testable requirements.

**End-to-end guide:** [docs/spec-driven-sdlc-flow.md](../../../docs/spec-driven-sdlc-flow.md) — how this protocol runs Inception → Sprint → Release.

sdlc-automation-agent keeps the **BRD + tracker** as program-level truth. Each feature also gets a **three-file spec** agents can execute without re-reading the entire BRD.

---

## When to use

| Situation | Action |
|-----------|--------|
| Greenfield feature (inception / PM full mode) | Create spec folder per epic or feature before SA design |
| Single feature add (`PM feature` mode) | Spec folder is the primary deliverable |
| Brownfield story | Spec optional if story already has full handoff contract |
| SA triggered mid-sprint | Extend `design.md`; append tasks to `tasks.md` |

---

## Spec folder layout

```
.sdlc-automation-agent/specs/{spec-id}/
  requirements.md    # EARS requirements + acceptance criteria (PM)
  design.md          # Technical design summary + links (SA)
  tasks.md           # Checkbox implementation plan (PM + SE)
  metadata.yaml      # ids, status, traceability
```

**spec-id:** kebab-case slug matching feature or epic (e.g. `email-opt-in`, `order-checkout`).

### metadata.yaml

```yaml
spec_id: email-opt-in
title: Email opt-in for marketing
status: requirements | design | tasks | implementing | done
brd_section: "§3.2 Marketing consent"
epic_id: EPIC-003
feature_id: FEAT-012
owner_agent: product-manager
created: 2026-06-03
gates:
  requirements_approved: false
  design_approved: false
  tasks_approved: false
```

---

## Phase 1 — Requirements (PM)

### Inputs

- Source docs (SoW, PRD, stakeholder notes)
- BRD lenses (PM Step 3) — summary only in spec; full tables stay in `docs/requirements/BRD.md`

### EARS notation (required for functional requirements)

Use [EARS](https://github.com/jasonkneen/kiro/tree/main/spec-process-guide) patterns. Every functional requirement gets an **REQ-ID** and exactly one pattern:

| Pattern | Template | Example |
|---------|----------|---------|
| **Ubiquitous** | The `<system>` shall `<response>` | REQ-01: The API shall reject duplicate email addresses with HTTP 409. |
| **Event-driven** | When `<trigger>`, the `<system>` shall `<response>` | REQ-02: When a user submits the opt-in form, the system shall persist consent with timestamp and source. |
| **State-driven** | While `<precondition>`, the `<system>` shall `<response>` | REQ-03: While the user is unauthenticated, the system shall not expose marketing preferences. |
| **Optional** | Where `<feature flag/variant>`, the `<system>` shall `<response>` | REQ-04: Where double opt-in is enabled, the system shall send a confirmation email before marking consent active. |
| **Unwanted behavior** | If `<trigger>`, then the `<system>` shall `<response>` | REQ-05: If the email service is unavailable, then the system shall queue the request and show a retry message. |

### Requirements file structure

Use template: `skills/_shared/templates/specs/requirements.tmpl.md`

**Rules:**

1. Each REQ-ID maps to ≥1 acceptance criterion (Given/When/Then).
2. Non-functional requirements reference NFR-IDs from BRD NFR grid.
3. Open questions → `.sdlc-automation-agent/.orchestrator/open-decisions.md` with `<!-- BLOCKED: OD-NNN -->` in spec.
4. **Gate:** Human or Controlled-mode approval before `design.md` (orchestrator sets `requirements_approved: true` in metadata).

---

## Phase 2 — Design (SA)

### Inputs

- `requirements.md` (approved)
- Codebase context (brownfield)
- `docs/architecture/tech-stack.yaml` when it exists

### Outputs

- `design.md` using `skills/_shared/templates/specs/design.tmpl.md`
- Links to canonical artifacts: ADRs, OpenAPI paths, ERD sections — **do not duplicate** full OpenAPI in design.md

**Gate:** Cross-check every REQ-ID appears in design (component, API, or data model). SA writes traceability table in `design.md`.

---

## Phase 3 — Tasks (PM + SE)

### Inputs

- Approved `requirements.md` + `design.md`

### Outputs

- `tasks.md` using `skills/_shared/templates/specs/tasks.tmpl.md`
- Checkbox tasks sequenced by dependency; each task references REQ-IDs

**Task rules (Kiro-style):**

1. One task = one committable unit (≈ sdlc-automation-agent story sizing rule: one endpoint / one screen / one job).
2. Each task lists: **Refs** (REQ-IDs), **Verify** (command from `tech-stack.yaml`), **Owner** (SE/QE/PE).
3. SE marks tasks complete only after verify passes; updates checkboxes in `tasks.md`.

**Gate:** Orchestrator may start SE implementation only when `tasks_approved: true`.

---

## Mapping: Kiro ↔ sdlc-automation-agent agents

| Kiro phase | Kiro artifact | sdlc-automation-agent agent | sdlc-automation-agent artifact |
|------------|---------------|-----------------|-------------------|
| Requirements | EARS spec | **Product Manager** | `.sdlc-automation-agent/specs/{id}/requirements.md` + BRD |
| Design | Architecture spec | **Solution Architect** | `design.md` + `docs/architecture/*`, `api/` |
| Tasks | Implementation plan | **PM** (breakdown) + **SE** (execute) | `tasks.md` + tracker stories |
| Implement | Agent runs tasks | **Software Engineer** | Code + receipts |
| Verify | Tests / hooks | **QE** + CI | `verify.*` + GitHub Actions |
| Steering | Project rules | **Init** + protocols | `.sdlc-automation-agent/steering/*.md`, `.sdlc-automation-agent.yaml` |

---

## Steering documents (Kiro "steering")

Project-specific rules live in `.sdlc-automation-agent/steering/` (not global plugin protocols):

```
.sdlc-automation-agent/steering/
  product.md       # domain language, personas, compliance
  tech.md          # stack conventions (or pointer to tech-stack.yaml)
  structure.md     # repo layout rules
  workflow.md      # branch, PR, review rules
```

Init mode scaffolds empty steering files on greenfield. PM/SA update `product.md` and `tech.md` during inception.

---

## Orchestrator integration

### Inception / Build mode

After PM Step 3 (BRD), for each **Must** feature in Sprint 1:

1. PM creates `.sdlc-automation-agent/specs/{spec-id}/requirements.md`
2. SA creates `design.md` (foundation mode: lightweight; blueprint: full)
3. PM creates `tasks.md`; sync story IDs to tracker
4. **Inception gate** includes: all Sprint 1 specs have `requirements_approved` + `design_approved`

### Kanban / single feature

```
User request → PM feature mode → spec folder (3 files) → SA if needed → SE executes tasks.md
```

### Sprint execution

SE prompt MUST include:

```
Read .sdlc-automation-agent/specs/{spec-id}/tasks.md
Implement next unchecked task only
Update checkbox on completion
Run verify commands from tech-stack.yaml before receipt
```

---

## Optional: Kiro Claude plugin

Install [kiro-spec-driven](https://github.com/jasonkneen/kiro) alongside sdlc-automation-agent for standalone EARS help:

```text
/plugin marketplace add https://github.com/jasonkneen/kiro
/plugin install kiro-spec-driven@kiro-marketplace
```

**Division of labor:**

| Tool | Role |
|------|------|
| **Kiro plugin** | EARS drafting aid, prompting patterns, spec examples |
| **sdlc-automation-agent** | Full SDLC orchestration, agents, gates, deploy, multi-stack packs |

Do not run both orchestrators on the same feature without syncing to `.sdlc-automation-agent/specs/`.

---

## Quality gates (automated checks)

Before marking spec phase complete:

| Check | Rule |
|-------|------|
| REQ coverage | Every REQ-ID has ≥1 AC line |
| Design trace | Every REQ-ID in design traceability table |
| Task trace | Every REQ-ID in ≥1 task Refs line |
| No orphan tasks | Every task references ≥1 REQ-ID |
| NFR link | Performance/security reqs cite NFR-ID from BRD |

---

## Anti-patterns

| Anti-pattern | Fix |
|--------------|-----|
| BRD only, no feature specs | Add spec folder per Sprint 1 feature |
| EARS in chat, not in repo | Write `requirements.md` to disk |
| design.md duplicates full OpenAPI | Link to `api/openapi/` |
| tasks.md without verify commands | Pull from `tech-stack.yaml` |
| SE ignores tasks.md | Orchestrator dispatch requires spec path |
