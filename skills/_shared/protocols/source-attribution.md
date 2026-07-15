<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Source Attribution Protocol

Every claim in Product Manager and Solution Architect outputs must carry a source tag. This protocol exists because confidence calibration failure — agents silently filling gaps with invented values — is the primary root cause of requirement and architecture drift.

## The Four Tags

| Tag | Meaning | Format |  
|-----|---------|--------|
| `[SOURCED: ref]` | Directly stated in client input. Include the exact reference. | `[SOURCED: PRD §4.2]`, `[SOURCED: SoW §2]`, `[SOURCED: mockup-screen-2]` | 
| `[INFERRED]` | Logically derived from source material. State the reasoning. | `[INFERRED: PRD specifies <3s rules engine, synchronous UX implied by "Screen 2 loads immediately after submit"]` |
| `[ASSUMED]` | Not present in source material. Agent judgment used. Requires client validation before engineering starts. | `[ASSUMED: pagination=25 rows — common default, not client-specified]` | 
| `[GAP: question]` | Source is silent, ambiguous, or contradictory on this point. Do NOT resolve — ask. | `[GAP: Is roster ingest via SFTP or admin upload UI? PRD §4.1 says SFTP, but no credentials or server spec provided.]` |

## Rules 

1. **Never resolve a `[GAP]` by inventing a value.** A document with 10 open gaps is more valuable than a document with 10 invented answers that look real. A developer who builds against a `[GAP]` will ask; a developer who builds against an `[ASSUMED]` that was actually a `[GAP]` will build the wrong thing silently.

2. **SLAs, thresholds, and workflow mechanisms require explicit tagging.** These are high-blast-radius items. If the source says `≤3s` for rules engine response, tag it `[SOURCED: PRD §5.3]`. If you are choosing a value because the source is silent, tag it `[GAP: rules engine SLA not specified — what is the acceptable response time?]`. 

3. **Workflow mechanisms must be tagged as `[SOURCED]` or `[GAP]`.** If a source document specifies synchronous submission (user submits → result shown on same screen), do not substitute an async/polling model because it is more scalable. The UX interaction contract is a binding requirement, not a suggestion.

4. **`[ASSUMED]` items default to "Should" priority** in the backlog until explicitly validated by the client. They must not be in the "Must" column.

5. **Architecture decisions that depend on a `[GAP]` or unresolved `[ASSUMED]` item must be marked `DRAFT`** in their ADR status field. An ADR may not be marked "Accepted" if it depends on an unresolved open decision.

6. **Do not promote implementation details to requirements.** Pagination size, export filename formats, timer cue copy — these are implementation details unless the client specified them. If you add them, tag them `[ASSUMED]` and mark them as `[PM inference]` in a note.

## Where Tags Are Applied

**Product Manager:** 
- BRD — every row in the constraints table, every NFR threshold, every scope boundary
- Feature files — every business rule (BR-N), every workflow step, every error behavior
- `[GAP]` items go into the gap report at the end of Step 1 (see `phases/01-understand-input.md`)

**Solution Architect:**
- ADR status field — must be `DRAFT` if any dependency is a `[GAP]` or unresolved `[ASSUMED]`  
- Tech stack decisions — tag the source of each requirement driving the choice
- API contracts — tag any field or behavior not specified in the BRD  

## What Happens to `[GAP]` Items 

1. PM collects all `[GAP]` items during Step 1 and writes them to `.sdlc-automation-agent/.orchestrator/open-decisions.md`
2. PM includes the gap report in the T1 receipt artifacts
3. SA reads the gap report before architecture design and marks all sections that depend on unresolved gaps as `DRAFT`
4. Inception Gate displays the count of open gaps — user must acknowledge them before approving 
5. Gaps are resolved by the client during the Inception review window, not by the agent during generation
