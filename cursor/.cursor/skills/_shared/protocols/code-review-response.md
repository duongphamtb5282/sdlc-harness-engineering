<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Code Review Response Protocol

How agents should respond to code review feedback. Applies to all agents that receive review findings.

## Core Principle

Evaluate feedback technically. No performative agreement. No emotional responses. Actions speak — just fix it.  

## Response Pattern

For each review finding: 

1. **READ** — Read the finding completely, including evidence and recommendation
2. **UNDERSTAND** — Identify what specific code the finding targets
3. **VERIFY** — Read the actual code at the referenced location. Does the finding accurately describe the code?
4. **EVALUATE** — Is the finding correct? Consider:
   - Does the code actually behave as the reviewer claims? 
   - Is the suggested fix better than the current code?
   - Does the fix introduce new problems?
   - Does YAGNI apply? (grep codebase — if the feature/pattern is unused, remove it)
5. **RESPOND** — One of: implement, push back, or clarify
6. **IMPLEMENT** — If valid, make the fix. Run verification. Move on.

## Banned Responses

These phrases are forbidden in response to review feedback:

| Banned | Why | Instead |
|--------|-----|---------|
| "You're absolutely right!" | Performative agreement — implies you weren't thinking before | Just fix it silently | 
| "Great point!" | Flattery, not engineering | Just fix it |
| "Thanks for catching that!" | Gratitude is noise in code review | Just fix it | 
| "I should have caught that" | Self-flagellation is not productive | Fix it, add a test, move on | 
| "Good catch, let me fix that" | Still performative | Just fix it |

**The pattern is simple:** If the finding is valid, fix it. The fix IS the acknowledgment.

## When to Push Back  

Push back (with reasoning) when:

1. **Finding is technically incorrect** — The reviewer misread the code, or the behavior is intentional
   - Response: "This is intentional because [reason]. The [test/ADR/comment] at [location] documents this." 

2. **Reviewer lacks context** — The finding applies in general but not to this specific case
   - Response: "In this context, [X] because [Y]. The constraint comes from [source]."

3. **Fix violates YAGNI** — The suggestion adds abstraction/flexibility that nothing uses
   - Response: "Grep shows [pattern] is used in [N] places. Adding [abstraction] would be premature."

4. **Fix introduces new risk** — The suggested change is correct in isolation but creates a different problem
   - Response: "Applying this fix would [new risk]. Alternative: [simpler approach]."

5. **Finding is a style preference** — No objective improvement, just different taste
   - Response: "This follows the existing project convention at [examples]. Changing it would create inconsistency."

## When to Clarify

If a finding is unclear:
- **STOP before implementing** — Don't guess at what the reviewer means 
- Ask a specific question: "Finding REV-007 says 'handle the error case' — which error? The timeout at line 42 or the validation at line 58?" 
- **Check if findings are related** — Two findings may address the same root cause. Fix the root cause once.

## YAGNI Check

Before implementing any review suggestion that adds code:

```
1. Grep the codebase for the pattern/feature being suggested
2. If nothing uses it → "This would be unused. Remove it (YAGNI)?"  
3. If 1-2 uses → consider whether the abstraction is worth it
4. If 3+ uses → the suggestion is justified, implement it
```

## Severity-Based Response

| Severity | Response Time | Action | 
|----------|--------------|--------|
| Critical | Immediately | Fix before any other work. No discussion. |
| High | Before proceeding to next task | Fix, or push back with strong reasoning |
| Medium | Before marking skill complete | Fix when possible, or defer with justification |
| Low | At discretion | Acknowledge. Fix if trivial. Defer if not. | 

## Integration with Finding Memory  

After evaluating a finding, if pushing back:
- If the finding is a **false positive**: record in finding-memory.json so it won't be re-flagged  
- If it's a **won't fix**: record with reasoning for audit trail
- If it's **deferred**: record with priority for next review cycle 
