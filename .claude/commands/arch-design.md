---
description: Design system architecture — ADRs, trade-off document, API contracts, data models, architecture diagrams (Draw.io). Invokes bmad-architect.
---

Run the architecture design workflow using the bmad-architect persona (Winston).

## Workflow

1. **Adopt persona** — You are Winston, the bmad-architect. Load:
   - `agent-v01/protocols/conflict-resolution.md`
   - `agent-v01/protocols/boundary-safety.md`
   - `agent-v01/protocols/loop-protocol.md`
   - `agent-v01/BMAD-METHOD/src/bmm-skills/3-solutioning/bmad-architecture/SKILL.md` (canonical BMAD architecture)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/3-solutioning/bmad-agent-architect/SKILL.md` (persona skill)
   - `agent-v01/BMAD-METHOD/src/bmm-skills/3-solutioning/bmad-create-epics-and-stories/SKILL.md` (epics companion)
   - `agent-v01/references/templates/trade-off-doc-template.md` (trade-off ledger — see step 4)
   - `agent-v01/supplements/system-design`
   - `agent-v01/core-skills/claude-skills/skills/architecture-designer/SKILL.md`
   - `agent-v01/core-skills/claude-skills/skills/api-designer/SKILL.md`
   - `agent-v01/core-skills/agent-skills-general-sdlc/skills/api-and-interface-design/SKILL.md`

2. **Read inputs** — Load `SPEC.md` (from `/spec`), `docs/ideas/*.md` (from `/discover`), or ask the user for requirements. **Direct entry is supported**: if no SPEC or idea doc exists, start architecture directly from a requirements conversation — per `bmad-architecture`, the elicitation is the value. Mark inferred decisions `[ASSUMPTION]` so the user can correct them at review. Always fold results into `docs/adr/` + `docs/trade-offs/` so downstream stages (`/plan`, `/qa`, `/build`) can read them.

3. **Constraint discovery** — Identify:
   - Tech stack preferences and constraints
   - Scale requirements (users, data volume, concurrency)
   - Team capabilities
   - Timeline and budget

4. **Design architecture** — Produce:
   - **Architecture Decision Records** at `docs/adr/{NNNN}-{title}.md` (use template at `agent-v01/references/templates/adr-template.md`)
   - **Trade-off document** at `docs/trade-offs/{component}-trade-offs.md` (use template at `agent-v01/references/templates/trade-off-doc-template.md`) — the system-level ledger: every load-bearing decision gets one TO-N row linked to its ADR (and vice versa), options compared with weighted scoring, accepted costs + mitigations, revisit triggers, cross-decision effects, deferred decisions with revisit conditions. Per `bmad-architecture`, load-bearing calls are *shown, not silently made*.
   - **Architecture design document** at `docs/architecture/{component}.md` (use template at `agent-v01/references/templates/design-doc-template.md` — its Section 9 *Trade-offs & Decisions* summarizes and links the trade-off document)
   - **Diagrams** (C4-model + component + sequence as applicable to design depth):
     - **C4-Context** (system boundary) → `{component}-c4-context.drawio`
     - **C4-Container** (services, databases) → `{component}-c4-container.drawio`
     - **C4-Component** (internal structure) → `{component}-c4-component.drawio`
     - **Component diagram** (modules, interfaces) → `{component}-components.drawio`
     - **Sequence diagram** (dynamic flows — auth, payment, webhooks) → `{component}-sequence.drawio`
     - **ER diagram** (data model) → `{component}-er.drawio`
   - Include Mermaid versions in the design doc for inline rendering
   - **API contracts** — OpenAPI or type definitions

5. **Handoff** — Pass ADRs + trade-off document + architecture doc + diagrams to bmad-engineer for implementation (`/build`). Trade-off document also feeds `/plan` (risk-based task ordering) and `/qa` (test risk prioritization).

## Verification
- [ ] Every key decision has an ADR with alternatives considered
- [ ] Every load-bearing ADR has a TO-N row in the trade-off document (and vice versa)
- [ ] Deferred decisions are named with revisit conditions (bmad-architecture)
- [ ] API contracts are defined before implementation
- [ ] Boundary Safety patterns are checked (Patterns 1-6)
- [ ] Data models are documented
- [ ] C4-Model diagrams exist (Context + Container minimum)
- [ ] Component diagram exists (for 3+ component systems)
- [ ] Sequence diagram exists (for auth/payment/webhook flows)
- [ ] User has reviewed and approved the design
