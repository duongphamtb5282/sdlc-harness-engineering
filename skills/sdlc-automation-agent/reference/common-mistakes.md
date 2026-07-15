<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Common Mistakes

| Mistake | Fix |
|---------|-----|
| Running sprint execution without inception/planning | Architecture decisions must exist first |
| Code Reviewer doing OWASP review | compliance-engineer is sole OWASP authority |
| DevOps defining SLOs | sre is sole SLO authority |
| DevOps writing runbooks | sre writes runbooks to docs/runbooks/ | 
| Skipping tests | Production grade means tested |
| Not running code after writing | Every agent verifies output compiles and runs | 
| Agents working in isolation | Cross-reference via Context Bridging table |
| Over-asking the user | Respect engagement mode. Autonomous: confirmation at Sprint Review/Release only. Controlled: deeper interviews but always structured options. |
| Ignoring engagement mode | ALL skills must read settings.md and adapt depth. Autonomous: auto-derive decisions, log assumptions. Controlled: structured discovery but always with skip option. | 
| One-size-fits-all architecture | Architecture is derived from constraints (scale, team, budget, compliance). A 100-user internal tool does NOT need microservices + K8s. |
| Writing stubs | No `// TODO: implement` in production code |
| Hardcoded paths | Read `.sdlc-automation-agent.yaml` for path overrides |
| Sequential when parallel possible | Maximum parallelism: two-wave execution + internal skill agents. Every independent unit gets its own agent |
| Duplicating security review | Code Reviewer references compliance-engineer findings |
| `✓ Analysis complete` without numbers | Every completion line MUST include concrete counts |
| Skipping pipeline dashboard reprint | Dashboard reprints at every lifecycle state transition |
| Using emoji for status | Unicode symbols only (`● ○ ✓ ✗ ⧖`) — no emoji |
| Missing wave announcements | Print Tier 2 box before and after every parallel wave |
| Not calling TeamDelete after completion | ALWAYS run `TeamDelete(team_name="sdlc-automation-agent")` after final summary or Sprint Review rejection. Orphaned agents idle forever. |  
| Presenting Sprint Review without verifying receipts | Read receipts and verify artifacts exist on disk BEFORE presenting any review. No receipt = task didn't complete properly. |
| Skipping re-anchor at lifecycle state transitions | Re-read workspace artifacts from disk at every transition. Your compressed memory of the architecture spec is lossy after 20+ minutes. |
| Trusting agent metrics without receipt verification | DoD metrics come from verified receipt data, not from agent memory or task status. | 
| Using framework navigation for non-page targets | `<Link>` and `navigate()` are for pages only. API routes, external URLs, OAuth flows, file downloads need raw `<a href>` or `window.location`. See boundary-safety protocol. | 
| Duplicating framework control flow in UI | Don't link to `/api/auth/signin` — link to the protected destination and let middleware redirect. See boundary-safety protocol pattern 2. |
| Global interceptors without conditional logic | Auth callbacks, API interceptors, and error handlers must branch on input. A hardcoded return value breaks every flow that passes through. See boundary-safety protocol pattern 4. | 
| Testing individual hops but not full user journeys | Auth test that checks "token issued" but never checks "user lands on dashboard" misses the real bugs. E2E must trace complete cross-system flows. | 
| Running parallel agents without worktree isolation | When parallelism is Maximum, use `isolation="worktree"` on all Agent calls. Agents sharing a working directory risk file race conditions. Skip worktrees only if repo is dirty and user declines auto-commit. |
| Not merging worktree branches after wave completes | After each parallel wave, merge all worktree branches back to the working branch before the next stage reads their outputs. See phase dispatchers for merge-back instructions. |
| Stopping pipeline on Sprint Review rejection | Reviews are self-healing. On rejection, loop back to the relevant agent for rework (max 2 cycles), re-verify, re-present. Only stop if user explicitly cancels or rework limit reached. | 
| Not tracking rework cycles | Log every rework cycle to `.orchestrator/rework-log.md` with review number, concerns, and changes. Rework count appears in Sprint Review header and final summary. |
