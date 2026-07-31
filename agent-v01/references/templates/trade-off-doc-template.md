# Trade-off Document: {System/Component}

**Status:** Draft / Reviewed / Approved
**Version:** 1.0
**Date:** {YYYY-MM-DD}
**Author:** bmad-architect (Winston)

---

## Purpose

This document is the **system-level ledger of every load-bearing decision**. ADRs record one decision each (context → decision → consequences); this ledger records the *trade-offs across decisions* — what was given up to gain what, and what that means for the system as a whole.

Per `bmad-architecture`: load-bearing calls are **shown, not silently made** — the realistic alternatives weighed, and why one way was chosen. Decisions that fail the "real trade-off" test (two independent builders could not choose incompatibly) belong in **Deferred**, not here.

## 1. Decision Register

| ID | Decision | Chose | Over | Trade-off in one line | Status | ADR |
|----|----------|-------|------|------------------------|--------|-----|
| TO-1 | {e.g. Event-driven vs request/response} | {X} | {Y} | {gained latency isolation, accepted eventual consistency} | Proposed / Accepted | ADR-0001 |
| TO-2 | {…} | {X} | {Y} | {…} | | ADR-0002 |

> Every row links to its ADR. No ADR without a trade-off row; no trade-off row without an ADR.

## 2. Trade-off Analysis

Repeat per decision (TO-N) — one block each.

### TO-N: {Decision name}

**The trade-off:** We chose {X} over {Y}. We gained {primary benefit}, and accepted {what we gave up}.

**Options compared:**

| Criterion (weight) | Option A: {X} | Option B: {Y} | Option C: {Z} |
|---|---|---|---|
| {e.g. Development speed (3)} | {5/5} | {3/5} | {2/5} |
| {e.g. Operational complexity (2)} | {2/5} | {4/5} | {3/5} |
| {e.g. Cost (2)} | {3/5} | {4/5} | {5/5} |
| {e.g. Fit with team skills (1)} | {4/5} | {3/5} | {1/5} |
| **Weighted total** | {n} | {n} | {n} |

**Why {X} won:** {the deciding factors — the weights were not the whole story}

**Accepted costs & mitigations:**
- {Cost 1} → {Mitigation}
- {Cost 2} → {Mitigation}

**Revisit trigger:** {under what real-world signal this decision gets reopened — e.g. "when volume exceeds N req/s", "when a second consumer needs the event stream"}

## 3. Cross-Decision Effects

{How the decisions interact at system level — a decision made in one area constrains another. This is what the ADRs alone cannot show.}

- {TO-1} + {TO-2} → {combined effect, e.g. "the event-driven choice means the reporting component inherits eventual consistency — it must be idempotent by design"}
- {…}

**Boundary Safety check** (patterns 1–6 per `boundary-safety.md`):
- [ ] Patterns 1–6 reviewed against each TO-N
- [ ] No trade-off silently weakens a boundary
- [ ] Inversion-of-control boundaries used where teams/units diverge

## 4. Deferred Decisions

| Deferred decision | Why not decided now | Revisit condition |
|---|---|---|
| {e.g. Multi-region failover} | {single region sufficient for v1} | {second region required or RTO > 1h} |

> From `bmad-architecture`: defer deliberately, name the revisit condition. A whole dimension left *silent* is the failure, not a deferred decision.

## 5. Open Questions

- {Question needing resolution before /build}
- {Question needing resolution before /build}

---

## Related Documents

- ADR-{NNNN} – ADR-{NNNN} (per decision register above)
- `docs/architecture/{component}.md` (design doc)
- `docs/architecture/{component}-*.drawio` (diagrams)

*Template: agent-v01/references/templates/trade-off-doc-template.md*
