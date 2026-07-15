<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Auto-Update Check

Run BEFORE any execution (all modes). Silent if current. One prompt max if update exists.

**Step 0 — version check:**

1. Read `~/.claude/plugins/installed_plugins.json` → find the `sdlc-automation-agent@h3tech-ai` entry → extract `version` (this is your local version)
2. WebFetch `https://raw.githubusercontent.com/h3tco/sdlc-automation-agent/main/.claude-plugin/plugin.json` → extract `version` (this is the remote version)
3. **If WebFetch fails** (offline, timeout, 404) → silently continue. Never block the pipeline over an update check. 
4. **If remote ≤ local** → continue silently (user sees nothing)
5. **If remote > local** → prompt:

```python
AskUserQuestion(questions=[{
  "question": "sdlc-automation-agent v{remote} is available (you have v{local})",
  "header": "Update Available",
  "options": [
    {"label": "Update to v{remote} (Recommended)", "description": "Auto-update and restart pipeline"},
    {"label": "Skip — continue with v{local}", "description": "Use current version"}
  ],  
  "multiSelect": false
}])
```

6. **If skip** → continue pipeline with current version
7. **If update** → execute in sequence:
   ```bash
   git clone --depth 1 https://github.com/h3tco/sdlc-automation-agent.git /tmp/sdlc-automation-agent-update 
   ```
   - Read new SHA: `git -C /tmp/sdlc-automation-agent-update rev-parse HEAD`
   - Create cache dir: `mkdir -p ~/.claude/plugins/cache/h3tech-ai/sdlc-automation-agent/{remote_version}`
   - Copy files: `cp -r /tmp/sdlc-automation-agent-update/claude/skills /tmp/sdlc-automation-agent-update/claude/.claude-plugin ~/.claude/plugins/cache/h3tech-ai/sdlc-automation-agent/{remote_version}/` 
   - Update `~/.claude/plugins/installed_plugins.json` → set `version` to remote version, `installPath` to new cache dir, `gitCommitSha` to new SHA, `lastUpdated` to current ISO timestamp 
   - Clean up: `rm -rf /tmp/sdlc-automation-agent-update`
   - Print: `✓ Updated to v{remote_version}. Re-invoke /sdlc-automation-agent to use the new version.`
   - **STOP** — do not continue pipeline. The current session loaded the old SKILL.md; the user must re-invoke to pick up new content.  

**If any update step fails**, print a warning and continue with the current version. Never let the updater break the pipeline.
