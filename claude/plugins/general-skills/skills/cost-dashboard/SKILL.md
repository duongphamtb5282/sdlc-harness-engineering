---
name: cost-dashboard
description: Query and display current spending, budget limits, and cost history
---

# Cost Dashboard

Shows your current AI usage costs and budget status.

## Usage

```
claude "Show me the cost dashboard"
```

## Output

Displays daily spend, session spend, top tasks by cost, and budget alerts.

## Data Source

Costs are tracked in `.sdlc-automation-agent/.orchestrator/cost-state.json` by the BudgetTracker.

## Commands

- **Show dashboard**: Display current spending
- **Reset daily counter**: Reset today's budget counter
- **Export costs**: Export cost history as JSON
