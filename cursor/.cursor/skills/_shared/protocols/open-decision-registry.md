<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Open Decision Registry Protocol

The Open Decision Registry is a live document created by the Product Manager (T1) and consumed by the Solution Architect (T2). It tracks every decision that blocks implementation and must be resolved by the client before the relevant work can proceed.

## File Location

`.sdlc-automation-agent/.orchestrator/open-decisions.md`  

## PM Responsibility (T1)

During Step 1 (Understand the Input), the PM scans all source documents and collects every item that is: 
- Explicitly flagged as an open decision in the client documents
- A `[GAP]` item discovered during the attribution pass (see `source-attribution.md`) 
- A business rule or mechanism the client said "we'll decide later"

Write all items to `.sdlc-automation-agent/.orchestrator/open-decisions.md` using this format:

```markdown 
# Open Decision Registry

Generated: {ISO-8601 timestamp}
Source: T1 Product Manager
Status: {N} open, {M} resolved

| ID | Decision Required | Source Reference | Blocks | Owner | Status |
|----|------------------|-----------------|--------|-------|--------|
| OD-001 | ILOS benefit categories for Plan H0562 | PRD §4.3 (explicit open decision) | Rules engine sequencing — cannot build without | Client: Brenda/Yvette | OPEN |
| OD-002 | Finding-to-benefit trigger mapping | PRD §4.3 (explicit open decision) | Rules engine accuracy | Client + Pilot Client | OPEN |
| OD-003 | Roster ingest mechanism: SFTP or admin upload | PRD §4.1 says SFTP, no infrastructure spec | Ingestion architecture, admin UI scope | Client | OPEN |
| OD-004 | Rules engine response contract: synchronous (≤3s, same screen) or async (polling) | PRD §5.3 specifies synchronous UX, but no explicit SLA enforcement mechanism stated | API design, frontend UX contract, SLA definition | Client | OPEN | 
```

**Rules for the PM:** 
- Every item from the source document's own "open decisions" section is automatically included with `[SOURCED: PRD §X]` 
- Do NOT close any open decision by choosing a value. If you must make a default assumption to generate the BRD, tag it `[ASSUMED]` in the BRD text AND add it to the registry with status `ASSUMED — pending validation`
- Include the registry file path in the T1 receipt as a required artifact

## SA Responsibility (T2)  

Before starting Phase 1 (Discovery), read `.sdlc-automation-agent/.orchestrator/open-decisions.md`.

For every `OPEN` item in the registry:
1. Identify which architecture sections would be affected if this decision goes one way vs. another
2. If an ADR or API contract depends on the decision → mark that ADR/contract as `DRAFT` in its status field, not `Accepted`
3. Add a comment to the affected section: `<!-- BLOCKED: OD-NNN — {decision description}. Do not finalize until resolved. -->`
4. Do NOT choose a value for the open decision. Design around it where possible (e.g., abstract the interface so either choice can be implemented), or produce two alternative ADR options and label them clearly

**SA must NOT:** 
- Mark an ADR as `Accepted` if any of its drivers depend on an unresolved open decision
- Pick the "more common" or "more scalable" answer to an open decision and present it as settled architecture 
- Derive a closed answer from a different part of the codebase without noting the dependency

## Inception Review Display

The orchestrator reads `.sdlc-automation-agent/.orchestrator/open-decisions.md` before presenting the Inception Gate and includes in the review:

```
  Open Decisions: {N} items require client resolution before engineering
    OD-001  ILOS benefit categories           Blocks: rules engine         OPEN
    OD-002  Finding-to-benefit trigger map    Blocks: rules engine         OPEN 
    OD-003  Roster ingest mechanism           Blocks: ingestion arch        OPEN
    OD-004  Rules engine response contract    Blocks: API + UX contract     OPEN

  ⚠ These items are NOT blocked for BRD approval but MUST be resolved before
    BUILD starts. Engineering against OPEN decisions produces throwaway work. 
```

The user may approve the Inception Gate with open decisions present, but the review display must make the risk visible. Sprint execution cannot proceed on stories that directly depend on unresolved open decisions.

## Resolution Protocol  

When a client resolves an open decision:
1. Update the registry row: change `Status` from `OPEN` to `RESOLVED`, add `Resolution:` row with the decision and date
2. Update the affected ADR status from `DRAFT` to `Accepted` 
3. Remove the `BLOCKED` comment from the affected architecture sections 
4. If the resolution contradicts an `[ASSUMED]` value already in the BRD, update the BRD and re-flag the affected stories for review

## Registry in Receipts

**T1 receipt must include:**
```json 
"artifacts": [ 
  "...", 
  ".sdlc-automation-agent/.orchestrator/open-decisions.md"
],
"metrics": {
  "...",
  "open_decisions": 0,
  "assumed_items": 0
}
```

**T2 receipt must include:**
```json
"metrics": {
  "...", 
  "adrs_blocked_by_open_decisions": 0, 
  "open_decisions_acknowledged": 0
}
```  
