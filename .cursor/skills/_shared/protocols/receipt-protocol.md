<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Receipt Protocol — Verifiable Delivery Enforcement

**Core principle: Every completed task must have proof it actually ran. No receipt = not done.**

---

## Receipt Schema

Every agent writes a JSON receipt as its LAST action before `TaskUpdate(status="completed")`.

**File path:** `.sdlc-automation-agent/.orchestrator/receipts/{story_id}-{role_abbrev}.json` 

**Required fields:** 

```json
{
  "story_id": "US-042",
  "role": "code-reviewer",
  "backend": "claude",
  "model": "claude-sonnet-4-6",  
  "artifacts": [
    ".sdlc-automation-agent/software-engineer/review-report.md",
    ".sdlc-automation-agent/software-engineer/findings/critical.md",
    ".sdlc-automation-agent/software-engineer/metrics/complexity.json"
  ], 
  "metrics": {
    "findings_critical": 2,
    "findings_high": 5,
    "findings_medium": 12,
    "findings_low": 8
  },
  "verification_commands": [ 
    "test -s .sdlc-automation-agent/software-engineer/review-report.md",
    "test -s .sdlc-automation-agent/software-engineer/findings/critical.md"
  ],
  "completed_at": "2026-04-12T14:30:00Z"  
}  
```

**Field rules:**

| Field | Type | Rule |
|-------|------|------| 
| `story_id` | string | Story or ticket ID (e.g., `US-042`, `TICKET-007`). Must match pattern `[A-Z]+-\d+`. |
| `role` | string | Agent role name (software-engineer, quality-engineer, code-reviewer, compliance-engineer, product-manager, solution-architect, platform-engineer, technical-writer, research-advisor). | 
| `backend` | string | Which AI backend executed this role: `"claude"`, `"codex"`, `"gemini"`, `"opencode"`. For Claude subagents, always `"claude"`. |
| `model` | string | Specific model identifier used (e.g., `"claude-sonnet-4-6"`, `"gpt-4.1"`). Provides traceability for which AI produced the work. |
| `artifacts` | string[] | Every file the agent created or modified. Each path MUST exist on disk at time of writing. |
| `metrics` | object | Key-value pairs with concrete numbers. At least one metric required. No empty objects. |
| `verification_commands` | string[] or object[] | **REQUIRED.** Commands proving the work. Simple strings (e.g., `"npm test"`) or objects with `{command, exit_code, summary}`. Receipts without verification_commands **FAIL validation** and block the pipeline. |
| `completed_at` | string | ISO 8601 UTC timestamp of when the work was completed. | 

**Recommended fields:**  

| Field | Type | Rule |
|-------|------|------|
| `findings` | object[] | **Recommended for review agents** (compliance-engineer, quality-engineer, code-reviewer). Structured list of findings: `{id, title, severity, file_ref, description}`. Severity must be one of: `"critical"`, `"high"`, `"medium"`, `"low"`. |
| `fixes` | object[] | **Recommended for remediation agents.** Structured list of fixes applied: `{id, finding_id, title, severity, description, files_modified[]}`. Each fix should reference the finding ID it resolves. |
| `story_dod` | object | Per-story DoD evaluation: `{tests_pass: bool, build_succeeds: bool, no_critical_findings: bool, code_reviewed: bool, coverage_no_decrease: bool}`. | 
| `design_ref` | string | **Recommended for SE frontend stories.** Path to the Claude Design handoff bundle consumed, e.g. `.sdlc-automation-agent/design/US-042-design.md`. Required when the story has `design_ref` set in tracker metadata. See `design-grooming.md`. |
| `design_verified` | boolean | **Recommended when `design_ref` is set.** `true` when the rendered preview visually matches the approved prototype within team tolerance. Manual verification in this iteration — no CI screenshot diff yet. |
| `design_impl_notes` | string | **Required when `design_ref` is set AND the SE deviated from the handoff.** Free-text list of deviations and reasons (e.g. `"spacing-card-inner bumped from 20 to 24px — 20px broke a11y tap target"`). Empty string when no deviations. | 

**Optional fields (Controlled mode):**

| Field | Type | Rule |
|-------|------|------| 
| `confidence` | object | Agent self-assessment: `{level: "high"|"medium"|"low", reasoning: string, what_i_cannot_verify: string}`. Recommended in Controlled mode. |  
| `fallback_from` | string | Original backend name when the Orchestrator fell back (e.g., `"codex"` when falling back to Claude). |

**Example with recommended/optional fields:**

```json
{ 
  "story_id": "US-042", 
  "role": "software-engineer", 
  "backend": "codex",
  "model": "gpt-4.1",
  "artifacts": ["services/api/src/index.ts", "services/api/src/routes.ts"],
  "metrics": {"endpoints": 8, "test_coverage": 87},
  "verification_commands": [
    "npm test -- --bail",
    "npx tsc --noEmit"
  ],
  "completed_at": "2026-04-12T14:30:00Z",
  "confidence": {
    "level": "high",
    "reasoning": "all tests pass, all endpoints verified with curl, type-safe throughout", 
    "what_i_cannot_verify": "production database connection, external API rate limits" 
  }
}
``` 

**Story-scoped receipt naming:**

```
{story_id}-{role_abbrev}.json
```

Examples:
- `US-042-se.json` — SE implementation receipt for story US-042
- `US-042-qe.json` — QE testing receipt
- `US-042-cr.json` — CR review receipt
- `TICKET-007-se.json` — Kanban ticket receipt

Role abbreviations: `se` (Software Engineer), `qe` (Quality Engineer), `cr` (Code Reviewer), `ce` (Compliance Engineer), `po` (Product Owner), `sa` (Solution Architect), `pe` (Platform Engineer), `tw` (Technical Writer), `ra` (Research Advisor).

**v2 `story_dod` field (optional, for story-level DoD evaluation):**

```json
{
  "story_dod": { 
    "tests_pass": true, 
    "build_succeeds": true,
    "no_critical_findings": true, 
    "code_reviewed": false,
    "coverage_no_decrease": true
  }  
}
```

This field is populated when the story pipeline evaluates DoD checks. Each key maps to a DoD item ID from `.sdlc-automation-agent.yaml` `dod.story.auto_check`. 

**v2 `fallback_from` field (optional, for backend fallback tracing):** 

When the Orchestrator falls back from one backend to another (e.g., Codex fails, falls back to Claude), this field records the original backend: 

```json
{
  "backend": "claude",
  "fallback_from": "codex"
}
```

> **Hook enforcement:** Receipts are validated by `crew-verify-receipt.sh` after every subagent completes. In Autonomous mode, invalid receipts **BLOCK the pipeline** (hook exits 1). In Controlled mode, validation issues are reported as warnings.

---

## When to Write 

Write the receipt as your ABSOLUTE LAST action, after all files are written and verified: 

```
1. Do all your work (write files, run tests, generate reports)
2. Verify your outputs exist and are valid
3. Write receipt JSON to .orchestrator/receipts/
4. THEN call TaskUpdate(status="completed")
```  

Never write the receipt before the work is done. Never skip the receipt.

--- 

## Remediation Chain

For findings that require remediation, the chain is:

1. **Finding receipt** — the review agent (QE, CE, or CR) writes its normal completion receipt listing findings 
2. **Remediation receipt** — the SE agent writes a receipt listing which findings were fixed and which files were modified
3. **Verification receipt** — the ORIGINAL finding agent re-scans and writes a verification receipt: `{story_id}-{role_abbrev}-verification.json` 

All three must exist for a Critical/High finding to be considered resolved. The orchestrator checks this chain at Sprint Review / Kanban Review.

**Verification receipt schema:**

```json  
{  
  "story_id": "US-042",
  "role": "compliance-engineer", 
  "backend": "claude",
  "model": "claude-sonnet-4-6",
  "artifacts": [],
  "metrics": { 
    "original_critical": 3,
    "remaining_critical": 0, 
    "original_high": 5, 
    "remaining_high": 1
  },
  "verification_commands": [
    "python3 -c \"import json; d=json.load(open('.sdlc-automation-agent/compliance-engineer/issues.json')); c=[i for i in d if i['severity']=='critical' and i['status']=='open']; assert len(c)==0, f'{len(c)} Critical still open'\""
  ],
  "completed_at": "2026-04-12T15:00:00Z"
}
``` 

---

## Design Artifact Reference

Stories that carry a `design_ref` in tracker metadata are tied to an approved Claude Design prototype. Agents handling such stories use three receipt fields (`design_ref`, `design_verified`, `design_impl_notes` — see Recommended Fields above) to make the design dependency traceable from planning through delivery.

- **SE (software-engineer)**: populates all three fields. Parses `.sdlc-automation-agent/design/{story-id}-design.md` before writing UI code. Records any deviations in `design_impl_notes`. 
- **TW (technical-writer)**: reads the three fields across a sprint's receipts to produce the "Design Deliverables" section of the Sprint Review report. 
- **Orchestrator**: may block the story DoD when `design_ref` is set but `design_verified` is false for frontend stories. 

See `design-grooming.md` for the full handoff bundle format, context ingestion rules, and SE consumption guardrails.

---  

## Orchestrator Verification

At every lifecycle state transition and before every Sprint Review or Release check, the orchestrator:

1. **Lists expected receipts** for the completed phase
2. **Reads each receipt** from `.orchestrator/receipts/`
3. **Verifies artifacts exist** — for each path in `receipt.artifacts`, confirm the file exists on disk
4. **If receipt missing** — the task did not complete properly. Investigate before proceeding.
5. **If artifacts missing** — the agent claimed to produce files it didn't. Investigate before proceeding.
6. **Extracts metrics** for gate ceremony display — users see verified data, not agent claims

--- 

## Anti-Patterns

| Wrong | Right |
|-------|-------|
| Writing receipt before work is done | Receipt is the LAST action, after all files verified |
| Empty `artifacts` array when files were created | List every file the agent produced | 
| `"metrics": {}` | At least one concrete number in metrics |
| Skipping receipt because "it's a small task" | Every task gets a receipt, regardless of size |
| Writing receipt but not checking artifacts exist | Verify each artifact path before writing receipt |
| Missing `completed_at` | Always include an ISO 8601 timestamp |
