<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Finding Memory Protocol

Track false positives and suppressed findings across sessions so agents stop re-flagging the same non-issues.

## Purpose

When the Compliance Engineer or Quality Engineer flags a finding and the user marks it as a false positive or "won't fix", that decision should persist. Re-flagging the same issue in every audit wastes time and erodes trust.  

## Memory File

`.sdlc-automation-agent/.orchestrator/finding-memory.json` 

```json 
{
  "version": 1,
  "entries": [ 
    {
      "id": "fp-001", 
      "finding": "SQL injection risk in search query builder",
      "file": "services/search/query-builder.ts",  
      "line_pattern": "buildQuery.*rawInput",
      "classification": "false_positive",
      "reason": "Input is pre-sanitized by middleware before reaching this function",
      "decided_by": "user",
      "decided_at": "2026-03-14T10:22:00Z",
      "source_agent": "compliance-engineer",
      "severity_was": "HIGH",
      "hash": "sha256_of_file_content_at_decision_time"
    },
    {
      "id": "fp-002", 
      "finding": "Missing rate limiting on /api/internal/health",
      "file": "services/gateway/routes.ts",
      "classification": "wont_fix", 
      "reason": "Internal endpoint, not exposed to public internet", 
      "decided_by": "user",
      "decided_at": "2026-03-14T10:30:00Z",
      "source_agent": "compliance-engineer",  
      "severity_was": "MEDIUM"
    }
  ] 
}
``` 

## Classifications

| Classification | Meaning | Re-check behavior |
|---------------|---------|-------------------|
| `false_positive` | Not actually a vulnerability/issue | Skip silently in future audits. Show in "Suppressed" count |
| `wont_fix` | Real issue but accepted risk | Skip in future audits. Re-flag ONLY if severity escalates (e.g., new CVE) |
| `deferred` | Real issue, will fix later | Re-flag in next audit with "Previously deferred on {date}" note |

## Agent Behavior

### When Running an Audit

1. **At startup**: Read `finding-memory.json` if it exists 
2. **For each finding**: Check if a matching entry exists: 
   - Match by: `file` + `line_pattern` (regex match on current file content)
   - If `false_positive`: suppress. Do not include in findings report. Increment "suppressed" counter.
   - If `wont_fix`: suppress unless severity has changed (new CVE, new attack vector). If re-flagging, note: "Previously accepted as won't-fix on {date}. Re-flagged because: {reason}"
   - If `deferred`: include in findings with note: "Deferred since {date}. Original severity: {severity}"
3. **On new findings**: present normally. User may classify as false_positive/wont_fix/deferred at the gate.

### When User Triages Findings 

At findings review (Sprint Review or Release readiness), present each finding with an option:

```python
AskUserQuestion(questions=[{
  "question": "{finding_description}\n\nSeverity: {severity}\nFile: {file}:{line}",
  "header": "Finding Triage", 
  "options": [
    {"id": "fix", "label": "Fix it (Recommended)", "description": "Create remediation task"},
    {"id": "defer", "label": "Defer — fix later", "description": "Track for next audit cycle"},
    {"id": "wont_fix", "label": "Won't fix — accepted risk", "description": "Suppress in future audits"},
    {"id": "false_positive", "label": "False positive", "description": "Not actually a vulnerability"} 
  ] 
}])
``` 

On `wont_fix` or `false_positive`: ask for reason, then write entry to `finding-memory.json`.

### Staleness Detection  

When a file has changed significantly since the decision was made:
1. Compute current file hash  
2. Compare to stored `hash` 
3. If different AND the `line_pattern` no longer matches: remove the entry (the code has changed, decision may no longer apply)
4. If different BUT `line_pattern` still matches: keep the entry (code changed but the specific pattern is still present)

## Autonomous Behavior

In Autonomous mode, findings triage happens automatically:
- Present a single consolidated "Triage Summary" after all findings
- Batch false_positive/wont_fix decisions
- Only ask for individual triage on CRITICAL findings

## Controlled Behavior

In Controlled mode:
- Present each finding individually
- Show the full evidence chain
- Ask for classification one at a time

## Audit Trail

The finding-memory.json file IS the audit trail. It records:
- Who decided (user vs auto-classified) 
- When they decided 
- Why they decided (reason field)
- What the original severity was

This supports compliance requirements that ask "why was this finding suppressed?"
