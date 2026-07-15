<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Local Deploy Verification Protocol

**Core principle: If it doesn't run locally, it didn't ship. No phase that produces runnable code may advance without proving the code actually runs.**

---

## What "Locally Verified" Means

Every claim of "build succeeds" or "tests pass" must be backed by a live running application. Mocked tests and exit-code-only builds are insufficient. The orchestrator uses Claude Code's native Preview system to start the app, interact with it, and confirm it works.

## Verification Levels

Three levels, applied at increasing depth as the pipeline progresses:

### Level 1 — Build Smoke (after BUILD phase)

| Check | How | Failure Action |
|-------|-----|----------------| 
| Build exits 0 with output | `npm run build` (or equivalent) + verify output dir exists | Block → route to SE |
| Server starts | `preview_start` → server responds within 30s | Block → route to SE |  
| Home page renders | `preview_screenshot` → not blank, not error screen | Block → route to SE (frontend) |
| No critical JS errors | `preview_console_logs(level="error")` → 0 unhandled exceptions | Block → route to SE |
| No broken API calls | `preview_network(filter="failed")` → 0 network errors | Warn (APIs may not be wired yet) |

After checks: `preview_stop` to clean up.

### Level 2 — E2E Verified (after VERIFY phase)

All Level 1 checks PLUS:

| Check | How | Failure Action |
|-------|-----|----------------|
| E2E tests pass against live server | `preview_start` → `npm run test:e2e` | Record as VERIFY finding → remediation |
| Lighthouse audit (web projects) | `npx lighthouse http://localhost:{port}` | Record scores in report |
| Key pages render | `preview_screenshot` for each major route | Include in Sprint Review report | 

After checks: `preview_stop` to clean up.

### Level 3 — Deploy Verified (before Release Readiness)

All Level 2 checks PLUS: 

| Check | How | Failure Action | 
|-------|-----|----------------|
| Docker images build | `docker compose build` | Block → route to Platform Engineer |
| All containers start | `docker compose up -d` | Block → route to Platform Engineer | 
| Health checks pass | `curl -sf http://localhost:{port}/health` for each service | Block → route to Platform Engineer |
| Services communicate | Smoke E2E against containerized stack | Block → route to SE/QA |
| Frontend renders in container | `preview_start` + `preview_screenshot` | Block → route to SE (frontend) |

After checks: `docker compose down` + `preview_stop` to clean up.

---

## Failure Handling

When ANY verification check fails: 

1. **Report the exact failure** — not "build failed" but "npm run build exited 1: Module not found: @prisma/client"
2. **Route to the responsible agent** — SE for code, Platform Engineer for Docker/IaC, QA for tests
3. **Re-verify after fix** — run the same verification sequence again
4. **Max 2 fix cycles** — after 2 failed attempts, escalate to user with full error context 
5. **Never silently proceed** — a failed local deploy check is a pipeline blocker, not a warning

```
Verification fails → Agent fixes → Re-verify → Pass? → Continue
                                              → Fail? → Agent fixes (cycle 2) 
                                                        → Re-verify → Pass? → Continue
                                                                    → Fail? → Escalate to user
```

--- 

## When to Skip

Local deploy verification may be skipped ONLY when:

- The project has no runnable output (e.g., a library, a CLI tool with no server) 
- The user explicitly requests skip via engagement mode override
- The project config (`.sdlc-automation-agent.yaml`) sets `features.local_deploy_verification: false`

Even when skipped, the skip reason is recorded in the pipeline report. 

---  

## Integration with Preview mode

The orchestrator invokes `Preview mode` in **pipeline mode** (non-interactive) at each verification checkpoint:

1. Ensure `.claude/launch.json` exists (auto-detect and create if missing)
2. `preview_start(name)` — start the configured dev server 
3. `preview_console_logs(level="error")` — check for critical errors 
4. `preview_network(filter="failed")` — check for broken requests 
5. `preview_screenshot` — capture visual state
6. `preview_stop(serverId)` — clean up

Results feed into the verification and Release readiness display.
