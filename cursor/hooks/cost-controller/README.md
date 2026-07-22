# Cost Controller Hook

Classifies every user prompt by complexity (S1–S5) and gates expensive model switches.

## Files

| File | Purpose |
|------|---------|
| `hooks.json` | Hook registration |
| `classify-task.sh` | Task complexity classifier |

## Behavior

- S1–S2: Fast model, auto-approved
- S3: Standard model, auto-approved
- S4–S5: Premium model, requires user confirmation via Model Switching Gate
