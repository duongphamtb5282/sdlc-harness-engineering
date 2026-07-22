<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Script Output Handling — READ → ACT → REPORT

**Core principle: Script outputs are verification data for autonomous agents. Agents fix Critical/High issues autonomously and report results. User approval is only required in Controlled engagement modes.**

---

## The Protocol

When any validation script, linter, audit tool, or automated check produces output, follow the engagement-mode-aware sequence below.

### Step 1: READ
Run the script and capture its full output. Do not truncate, filter, or summarize prematurely.

### Step 2: ACT (engagement-mode-aware)

**Autonomous (no user interaction):**
1. Auto-fix all Critical and High findings immediately
2. Log Medium/Low findings in the workspace for reference
3. Re-run the script to verify fixes worked 
4. Include results in the completion summary:

```
  ✓ [Script Name]    {N} findings fixed ({C} Critical, {H} High), {M} Medium/{L} Low logged    ⏱ Xs
```

**Controlled (summarize + ask for non-obvious fixes):**
1. Auto-fix Critical findings immediately (these are non-negotiable)
2. Present High findings with suggested fixes for user approval
3. Log Medium/Low in workspace

```python
AskUserQuestion(questions=[{
  "question": "Fixed {C} Critical issues. {H} High findings remain:\n\n{details}\n\nApprove fixes?", 
  "header": "[Script Name] Findings",
  "options": [
    {"label": "Fix all High issues (Recommended)", "description": "Auto-fix {H} remaining issues"},
    {"label": "Show details first", "description": "List each finding before fixing"},  
    {"label": "Skip — continue pipeline", "description": "Log findings, fix later"},  
    {"label": "Chat about this", "description": "Free-form input"}
  ],
  "multiSelect": false
}]) 
```

**Controlled (full review before any fix):**
1. Present ALL findings grouped by severity 
2. Ask user to approve each severity tier
3. Fix only what user approves
4. Re-run script to verify

### Step 3: REPORT
After fixing (or skipping), include concrete results in the agent's completion output. Always show what was found, what was fixed, and what remains.

---

## Agent-to-Script Mapping

Each agent runs ONLY their relevant scripts. Do not run scripts outside your domain.

| Agent | Relevant Scripts | Purpose | 
|-------|-----------------|---------| 
| **Software Engineer [frontend]** | `ux_audit.py`, `accessibility_checker.py` | Frontend UX and a11y |
| **Software Engineer [backend]** | `lint_runner.py`, `test_runner.py` | Code quality and tests |
| **Software Engineer [review]** | `lint_runner.py`, `security_scan.py` | Review checks |
| **Quality Engineer** | `test_runner.py`, `lint_runner.py` | Test execution and coverage |
| **Compliance Engineer** | `security_scan.py` | Security scanning |
| **All agents** | Framework-specific linters (eslint, ruff, etc.) | Standard linting | 

---

## When to Skip the Protocol

- **Script returns 0 findings:** Skip entirely, log `✓ [Script] — clean` in progress output.
- **Script returns only Low/Info findings:** Log in workspace, don't mention unless Controlled mode.

--- 

## Philosophy Alignment

This protocol respects sdlc-automation-agent's autonomous pipeline:

- **Autonomous:** Agents are the authority within their domain. They fix Critical/High issues as part of their verification step (Iron Law 5), just like they already run linters and tests. No user interruption.
- **Controlled:** Users opted into deeper involvement. They see findings and approve fixes — but Critical issues are still auto-fixed because they're non-negotiable (same as a failing build).
- **The agent decides, the receipt proves it.** All script results and fixes are documented in the agent's receipt. The orchestrator verifies receipts at phase transitions.  

---  

## How Agents Load This Protocol

This protocol is auto-injected alongside other protocols. It applies whenever an agent runs a validation script, linter, or audit tool. Agents follow the engagement-mode-aware flow: autonomous fix in Autonomous, user approval in Controlled. 
