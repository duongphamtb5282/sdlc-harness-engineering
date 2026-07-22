# SDLC hooks (Claude Code)

Lifecycle enforcement for the root `sdlc-automation-agent` plugin.

## Events wired (`hooks/hooks.json`)

| Event | Script | Purpose |
|-------|--------|---------|
| `SessionStart` (startup) | `session-start.sh` | Git branch, config check, compacted rules, lifecycle JSON |
| `SessionStart` (compact) | `session-guard.sh` | Re-inject rules after context compaction |
| `UserPromptSubmit` | `user-prompt-guard.sh` | Flag likely secrets in prompts |
| `PreToolUse` (Bash) | `pre-tool-guard.sh` | Block force-push, prod deploy, destructive commands |
| `PostToolUse` (Edit/Write) | `post-tool-audit.sh` | Audit log of file edits |
| `PostToolUse` (Bash) | `post-bash-audit.sh` | Audit log of shell commands |
| `Stop` | `stop-receipt-reminder.sh` | Remind to write receipts + run verify |

## Library (`hooks/lib/`)

Called by orchestrator skills and ceremonies:

| Module | CLI |
|--------|-----|
| `scrum_state_machine.py` | `init`, `read`, `transition`, `complete_sprint`, `close_sprint`, `summary`, `evaluate_dod`, `transition_to_kanban` |
| `kanban_state_machine.py` | `init`, `read`, `transition`, `pull_ticket`, `complete_ticket`, `summary`, `evaluate_dod` |
| `story_pipeline.py` | `transition`, `list_stories`, `get_story`, `unblock`, `aggregate_dod` |
| `receipt_validator.py` | Validate receipt JSON + artifact paths |
| `update_claude_md.py` | Merge SDLC section into `CLAUDE.md` |

State files are written in the **product repo**:

```
.sdlc-automation-agent/.orchestrator/
├── lifecycle-state.json
├── story-pipeline.json
├── receipts/
└── audit/
```

## Optional: security-guidance plugin

For deeper security review (pattern warnings + async LLM diff review), also install:

```bash
claude --plugin-dir /path/to/agents/plugins/delivery-toolkit/security-guidance
```

## Validate

```bash
./scripts/validate-hooks.sh
chmod +x hooks/*.sh
```

## Product repo (Cursor)

For Cursor IDE hooks in a product repo, add `.cursor/hooks.json` separately — see [create-hook skill](https://cursor.com/docs) and `docs/PROJECT-STRUCTURE.md`.
