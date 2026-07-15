<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
## Phase 7: Spec Design Sync (Kiro)

> **Anchor: You are the Solution Architect. Write feature-scoped `design.md` — not a duplicate of SAD/OpenAPI.**

**Run when:** Orchestrator provides `spec-id` OR `.sdlc-automation-agent/specs/{spec-id}/requirements.md` exists with `requirements_approved: true`.

**Skip when:** No spec folder for this feature (brownfield story-only work).

### Inputs

1. `.sdlc-automation-agent/specs/{spec-id}/requirements.md` — EARS REQ-IDs
2. `.sdlc-automation-agent/specs/{spec-id}/metadata.yaml`
3. `docs/architecture/tech-stack.yaml` — stack constraints
4. Existing `docs/architecture/`, `api/` — canonical artifacts (link, do not duplicate)

### Output

Write `.sdlc-automation-agent/specs/{spec-id}/design.md` using template `skills/_shared/templates/specs/design.tmpl.md`.

### Required sections

1. **Overview** — 1 paragraph linking to SAD/ADRs
2. **Components** — which services/modules implement this feature
3. **API changes** — links to `api/openapi/` paths (not full spec inline)
4. **Data model** — links to ERD sections / migration files
5. **REQ traceability table** — every REQ-ID mapped to component/API/data

| REQ-ID | Component / API | Notes |
|--------|-----------------|-------|
| REQ-01 | `POST /v1/...` | ... |

### Gates

- Every REQ-ID in `requirements.md` appears in traceability table
- No REQ-ID marked "TBD" without `<!-- BLOCKED: OD-NNN -->` in open-decisions
- Update `metadata.yaml`: `status: design`, set `gates.design_approved: true` after Controlled sign-off

### Handoff

PM creates `tasks.md` (Step 6b) referencing this design. SE executes tasks — not free-form implementation.
