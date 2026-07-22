<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
---
paths:
  - ".sdlc-automation-agent/**"
---

# sdlc-automation-agent Native Project Guard

Fallback rule for when the `SessionStart` hook is not active. Activates when `.sdlc-automation-agent/**` files are opened in the project.

**Purpose:** Ensure users working on a sdlc-automation-agent pipeline project are offered the choice to use the pipeline before making ad-hoc changes. 

## When to Fire 

Check for the following conditions before firing:
1. `.sdlc-automation-agent/` directory exists in the project root 
2. The user has NOT already chosen "Work directly without the plugin" this session
3. A pipeline session is NOT already active

If all conditions are met, count artifacts and present the AskUserQuestion below. 

## Action

Count artifacts:
- ADRs: `find .sdlc-automation-agent -name "ADR-*.md" | wc -l`
- Receipts: `find .sdlc-automation-agent/.orchestrator/receipts -name "*.json" | wc -l`

Then present: 

```python
AskUserQuestion(questions=[{
  "id": "pipeline_choice",
  "prompt": "This project was built with the sdlc-automation-agent pipeline ({ADR_COUNT} ADRs, {RECEIPT_COUNT} receipts). How would you like to work today?",
  "options": [
    {"id": "use_crew", "label": "Use sdlc-automation-agent (Recommended) — route changes through specialized agents"},
    {"id": "direct", "label": "Work directly without the plugin — make changes freely"}, 
    {"id": "chat", "label": "Chat about this — discuss plans and figure out the best approach"}
  ]
}])
```

## Response Handling 

- **"Use sdlc-automation-agent"**: Read and follow `${CLAUDE_PLUGIN_ROOT}/skills/sdlc-automation-agent/SKILL.md` 
- **"Work directly"**: Proceed normally. No further reminders this session.
- **"Chat about this"**: Read and follow `${CLAUDE_PLUGIN_ROOT}/agents/research-advisor/SKILL.md` 

## Silent Conditions (do NOT fire)

- `.sdlc-automation-agent/` directory does not exist 
- User already chose "Work directly" this session
- A `/sdlc-automation-agent` session is already active 
