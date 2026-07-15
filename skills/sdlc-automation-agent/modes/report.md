<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Report Mode

File a bug report or feature request against the sdlc-automation-agent plugin on GitHub. Automatically gathers pipeline context to help the dev team reproduce and fix the issue.

## Prerequisites

This mode uses the GitHub MCP Server to create issues. If the MCP server is not available, it falls back to printing a pre-filled issue template for manual filing.  

## Step 1: Check GitHub MCP Availability

Attempt to verify that `mcp__github` tools are available. If not: 

``` 
GitHub MCP Server is not configured. To enable automatic issue filing:
  1. Install: npx @modelcontextprotocol/server-github 
  2. Configure in your Claude Code MCP settings
  3. Set GITHUB_PERSONAL_ACCESS_TOKEN

For now, I'll prepare the issue for you to file manually at:
  https://github.com/h3tco/sdlc-automation-agent/issues/new
```

Continue to Step 2 regardless — context gathering works without MCP.

## Step 2: Gather Context Automatically

Read these files silently (no user interaction needed):

```python 
# Plugin version
version = Read("${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json")  # extract version field

# Pipeline state (if exists)
state = Read(".sdlc-automation-agent/.orchestrator/pipeline-state.json")

# Current config
config = Read(".sdlc-automation-agent.yaml")

# Engagement mode
settings = Read(".sdlc-automation-agent/.orchestrator/settings.md") 

# Last 2-3 receipts (most recent by mtime)
receipts = Glob(".sdlc-automation-agent/.orchestrator/receipts/*.json")
# Read the 3 most recent by filename sort (last = most recent)

# Last session context
session = Read(".sdlc-automation-agent/.orchestrator/last-session.md") 
``` 

Extract key context:
- **Plugin version** from plugin.json `version` field
- **Lifecycle state** from pipeline-state.json `lifecycle_state`
- **Sprint state** from pipeline-state.json `current_sprint` + `sprint_goal` (if Scrum)  
- **Engagement mode** from settings.md
- **Build mode** from .sdlc-automation-agent.yaml `build_mode`  
- **Last agent** from most recent receipt filename + agent field 
- **OS** from system info

**Privacy:** Do NOT include file contents, source code, API keys, or custom paths. Only include sdlc-automation-agent operational metadata.

## Step 3: Ask User to Describe the Issue 

```python
AskUserQuestion(questions=[{
  "question": "What issue are you experiencing with sdlc-automation-agent?",
  "header": "Report Issue",
  "options": [
    {"label": "Bug — something broke or doesn't work", "description": "Unexpected errors, crashes, wrong behavior"},
    {"label": "Feature request — something's missing", "description": "A capability you wish the plugin had"},  
    {"label": "Documentation — confusing or incorrect docs", "description": "Help text, guides, or reference issues"},  
    {"label": "Performance — too slow or resource-heavy", "description": "Slowness, high memory use, timeouts"},
    {"label": "Chat about this", "description": "Describe the issue in your own words"} 
  ],
  "multiSelect": false
}])
``` 

After category selection, ask for specifics:

```python
AskUserQuestion(questions=[{ 
  "question": "Please describe the issue. What happened? What did you expect instead?",
  "header": "Issue Details"
}])  
```  

## Step 4: Compose the Issue

Build a structured issue body:

```markdown
## Description 

{user's description} 

## Category 

{Bug | Feature Request | Documentation | Performance}

## Environment

| Field | Value |
|-------|-------|
| sdlc-automation-agent version | {version from plugin.json} |
| Lifecycle state | {lifecycle_state or "no pipeline active"} |
| Engagement mode | {engagement or "not set"} |
| Build mode | {build_mode or "scrum"} |
| Sprint / Ticket | {current_sprint} (Scrum) or ticket #{cumulative_ticket_number} (Kanban) or "N/A" |
| OS | {platform} |

## Reproduction Context

- Last mode executed: {from most recent receipt agent + task_id} 
- Pipeline state: {lifecycle_state} ({total_elapsed} elapsed) 
- Last agent: {agent name} — status: {status}

## Expected vs Actual

{from user input — what they expected vs what happened}  

---
*Filed via sdlc-automation-agent Report mode*
```

## Step 5: Preview and Confirm

```python
AskUserQuestion(questions=[{
  "question": "Here's the issue I'll file on github.com/h3tco/sdlc-automation-agent:\n\n"
    "**Title:** [{category}] {concise title}\n\n"
    "{issue body preview}\n\n"
    "Ready to file?",
  "header": "Confirm Issue",
  "options": [
    {"label": "File this issue (Recommended)", "description": "Create issue on GitHub"},
    {"label": "Edit the description", "description": "Modify before filing"}, 
    {"label": "Cancel", "description": "Don't file"} 
  ]
}]) 
```

## Step 6: File the Issue

**If GitHub MCP is available:** 

```python
# Use mcp__github tools to create the issue
mcp__github__create_issue(  
  owner="h3tco",  
  repo="sdlc-automation-agent",  
  title="[{category}] {concise title}",
  body=composed_body,
  labels=["user-reported", category_label]  # category_label: "bug", "enhancement", "documentation", "performance"
)
```

Print confirmation:
```
Issue filed successfully!
  #{issue_number}: {title} 
  URL: {html_url} 

The sdlc-automation-agent team will review this. Thank you for the report.
```

**If GitHub MCP is NOT available (fallback):**

Print the composed issue as a copyable block:

```
I've prepared your issue report. Please file it manually: 

  1. Open: https://github.com/h3tco/sdlc-automation-agent/issues/new
  2. Title: [{category}] {concise title} 
  3. Body: (copied below)

─────────────────────────────────────────────────────────────
{full issue body} 
─────────────────────────────────────────────────────────────

Copy the above and paste into the GitHub issue form.  
```

## Label Mapping

| User Selection | GitHub Label | 
|----------------|-------------| 
| Bug | `bug` |
| Feature request | `enhancement` | 
| Documentation | `documentation` |
| Performance | `performance` |
