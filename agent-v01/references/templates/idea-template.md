# Idea: {Idea Name}

**Status:** Draft / Refined / Approved
**Date:** {YYYY-MM-DD}
**Author:** bmad-analyst (Mary)

---

## Problem Statement

{One clear sentence describing the problem this idea solves. If you can't state it in one sentence, the idea isn't refined enough.}

## Target Users

{Who experiences this problem? Be specific — demographics, role, context.}

## Recommended Direction

{The chosen approach after diverging and converging. Why this direction over the alternatives?}

## Key Assumptions

1. {Assumption 1} — {What would happen if this is wrong?}
   - **Validate how:** {experiment, user interview, spike, data pull}
   - **By when:** {date or phase gate}
2. {Assumption 2} — {What would happen if this is wrong?}
   - **Validate how:** {…}
   - **By when:** {…}
3. {Assumption 3} — {What would happen if this is wrong?}
   - **Validate how:** {…}
   - **By when:** {…}

> ⚠️ Per spec-driven-development: each assumption carries a **validation gate**. A phase may not advance past its gate with an unvalidated assumption. Mark inferred assumptions `[ASSUMPTION]` (bmad-product-brief convention) so the user can correct them at review.

## MVP Scope

{The minimal set of features that solves the core problem. What MUST be in v1?}

## Future Considerations

{What explicitly is NOT in v1 but could be added later.}

## Not Doing

{Explicit list of things this idea is NOT about. Helps prevent scope creep.}

---

## Cost & Effort

### Build Effort (rough order of magnitude)

| Phase (kernel workflow) | Effort (person-weeks) | Notes |
|---|---|---|
| Discovery → one-pager approved | {n} | This document |
| `/spec` (SPEC.md + acceptance criteria) | {n} | Gates on assumptions validated |
| `/arch-design` (ADRs + trade-off doc + diagrams) | {n} | |
| `/build` (implementation per epics) | {n} | Break out by epic if large |
| QA / hardening / launch | {n} | |

### Run Cost (v1 steady-state)

| Item | Monthly | Notes |
|---|---|---|
| Infrastructure | {USD} | {cloud, compute, storage} |
| Third-party / licensing | {USD} | {APIs, SaaS, tooling} |
| People (support/ops beyond build) | {USD} | {roles, FTE} |

**Total monthly:** {USD}
**Budget envelope:** {approved ceiling, or "TBD — requires approval above {n} USD"}
**Funding source:** {internal budget / client / investment}

> Costs are estimates, not commitments. Re-estimate at `/spec` and again at `/arch-design` when the trade-off document lands.

## Roadmap

Gates align to the kernel workflow: **a phase does not start until its gate is met** (spec-driven-development gating).

| Phase | Deliverable | Gate (exit criteria) | Est. duration |
|---|---|---|---|
| Discovery | This one-pager **approved by user** | Problem clear; assumptions surfaced; cost/roadmap agreed | {n} d |
| Specification | `SPEC.md` | Assumptions validated; success criteria measurable | {n} w |
| Architecture | ADRs + trade-off doc + diagrams | Every load-bearing decision has alternatives considered; boundary-safety checked | {n} w |
| Build | Epics → stories → shippable increments | Per `bmad-create-epics-and-stories`; implementation readiness checked | {n} w |
| Launch | Release + retrospective | Success criteria met; `bmad-retrospective` run | {n} w |

**Dependencies / external inputs:** {teams, data sources, vendors that must be ready before each phase}
**Milestones:** {M1: … , M2: …}

## Risks and Mitigations

| Risk | Likelihood | Impact | Owner | Early-warning signal | Mitigation |
|------|-----------|--------|-------|---------------------|------------|
| {Risk} | H/M/L | H/M/L | {who owns it} | {trigger that fires before it bites} | {Mitigation} |

> Every risk gets an **owner** and an **early-warning signal** (bmad-prfaq internal-FAQ rigor: feasibility and hard trade-offs are surfaced here, not discovered at launch).

## Alternatives Considered

| Alternative | Why Rejected |
|-------------|-------------|
| {Alternative 1} | {Reason} |
| {Alternative 2} | {Reason} |
