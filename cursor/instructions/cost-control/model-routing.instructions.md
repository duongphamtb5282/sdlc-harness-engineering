---
description: Cost control and model routing protocol for SDLC agents. Classifies task complexity (S1-S5) and gates expensive model usage.
paths:
  - "**/*.md"
  - "**/*.yaml"
  - "**/*.yml"
appliesTo: "**/.sdlc-automation-agent*/**"
---

# Cost Control & Model Routing

## Core Principle

Every task is classified by complexity (S1–S5). Cheap models handle simple tasks; expensive models require a user-facing gate.

## Complexity Classification

| Tier | Name | Characteristics | Examples |
|------|------|----------------|----------|
| S1 | Trivial | Single-operation, no decision needed | Typo fix, import sort, comment update |
| S2 | Simple | Well-scoped, single file, clear pattern | Bug fix with known cause, add validation, update config |
| S3 | Moderate | Multi-file, well-defined scope | New API endpoint, unit tests for module |
| S4 | Complex | Cross-cutting, architectural decisions | Feature design, service extraction, performance optimization |
| S5 | Strategic | Multi-system, organizational impact | Architecture overhaul, DB migration, security audit |

## Classification Algorithm

```python
COMPLEX_SIGNALS = [
    "architecture", "design", "migrate", "strategy", "security",
    "performance", "scale", "multi-service", "cross-cutting",
    "trade-off", "decision", "evaluate", "compare", "alternative"
]

def classify(task_description: str) -> str:
    signal_count = sum(1 for s in COMPLEX_SIGNALS if s in task_description.lower())
    word_count = len(task_description.split())
    
    if signal_count == 0 and word_count < 20:
        return "S1-S2"   # Fast/cheap model
    elif signal_count <= 2:
        return "S3"      # Standard model
    else:
        return "S4-S5"   # Premium model — user gate required
```

## Model Tier Reference

| Tier | Models | Cost/M tokens | Auto-approve? |
|------|--------|---------------|---------------|
| Fast | Claude Haiku, GPT-4o-mini | $0.15–0.25 | Yes (S1, S2) |
| Standard | Claude Sonnet, GPT-4o | $1.50–3.00 | Yes (S3) |
| Premium | Claude Opus, GPT-4-turbo | $7.50–15.00 | **Ask first** (S4, S5) |

## Model Switching Gate

When a task requires upgrading from the current model to a more expensive one, present this gate:

```
━━━ Model Switch Gate ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Current Task:   {description}
  Classification: {S1–S5}
  Current Model:  {model} (${cost}/1K tokens)
  Recommended:    {model} (${cost}/1K tokens)
  Cost Impact:    ${estimate}

  Reason: {why premium is needed}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

```python
AskUserQuestion(questions=[{
  "question": f"This task requires {premium_model} ({reason}).\n"
              f"Current: {current} | Recommended: {premium}\n"
              f"Estimated additional cost: ${cost}",
  "header": "Model Upgrade Required",
  "options": [
    {"label": f"Switch to {premium_model} (Recommended)", "description": reason},
    {"label": f"Stay on {current} — lower quality expected",
     "description": "May not handle complexity well"},
    {"label": "Chat about this", "description": "Discuss alternatives"}
  ]
}])
```

## Default Routing Table

| Task Type | Default Tier | Gate Required? |
|-----------|-------------|----------------|
| Code review (minor) | Fast | No |
| Code review (security) | Premium | **Yes** |
| Bug fix (simple) | Fast | No |
| Bug fix (unknown cause) | Standard | **Yes** |
| Feature implementation | Standard | No |
| Architecture design | Premium | **Yes** |
| Documentation | Fast | No |
| Test writing | Standard | No |
| Security audit | Premium | **Yes** |
| DB migration | Premium | **Yes** |
| AI/ML model selection | Premium | **Yes** |
| RAG implementation | Standard | No |
| Agent system design | Premium | **Yes** |
| IaC / CI/CD | Standard | No |
| Dependency upgrade (minor) | Fast | No |
| Dependency upgrade (major) | Standard | **Yes** |

## Configuration

```yaml
# .sdlc-automation-agent.yaml
cost_control:
  enabled: true
  default_model: "claude-sonnet"
  premium_model: "claude-opus"
  thresholds:
    auto_approve_simple: true
    auto_approve_moderate: false
    ask_before_premium: true
  budget_alerts:
    daily_limit: $10
    session_limit: $2
    hard_stop: $50
```
