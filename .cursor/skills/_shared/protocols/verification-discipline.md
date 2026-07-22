<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Verification Discipline — Evidence Before Claims

**Core principle: No agent may claim a result without demonstrating it. "Should work" is a bug. "Does work — here's the proof" is a result.**

---

## The Problem This Solves

AI agents have a systematic failure mode: they state things work without actually verifying them. "Tests pass" without running tests. "Build succeeds" without running the build. "The fix resolves the issue" without reproducing the issue first. This erodes trust and causes production incidents.

Verification Discipline eliminates this failure mode by requiring concrete evidence for every claim. 

---

## Rules

### Rule 1 — Run It, Show It 

Before claiming any of these, you MUST run the relevant command and include the output:

| Claim | Required Evidence |
|-------|------------------|  
| "Tests pass" | Actual test runner output showing pass count and zero failures |
| "Build succeeds" | Actual build command output showing success |
| "No type errors" | Actual type checker output showing zero errors |
| "No lint warnings" | Actual linter output showing zero warnings |
| "The server starts" | Actual server startup log showing listening on port |
| "The endpoint returns X" | Actual curl/HTTP client response showing the data |
| "The bug is fixed" | Before: reproduction showing the bug. After: same steps showing it's gone |
| "Performance improved" | Before and after benchmark numbers from the same tool | 

**If you cannot run the command** (no test framework installed, no build tool configured), state this explicitly: "Cannot verify — [reason]. The user should run [command] to confirm." Never silently skip verification.

### Rule 2 — Reproduce Before Fix

When fixing a bug:

1. **Reproduce** — Write a test or run a command that demonstrates the bug exists  
2. **Show the failure** — Include the error output  
3. **Fix** — Apply the fix
4. **Show the success** — Run the same test/command, show it now passes
5. **Prevent regression** — The reproduction test becomes a permanent regression test 

**Never** fix a bug you can't reproduce first. If you can't reproduce it, investigate more — don't guess at fixes.

### Rule 3 — Verify Artifacts Exist

Before writing a receipt or claiming task completion:

``` 
For each artifact in your claimed outputs:
  1. Run Glob or Read to confirm the file exists
  2. Verify the file is non-empty and contains expected content
  3. Only then include it in the receipt's artifacts list
```

### Rule 4 — Completion = Verification Summary

Every task completion message (and receipt) must include a verification summary:

```
## Verification
- [x] `npm run build` — exit 0, 0 errors 
- [x] `npm test` — 47 passing, 0 failing 
- [x] `npx tsc --noEmit` — 0 errors
- [x] All 6 artifacts verified on disk
```

If any verification step fails, the task is NOT complete. Fix the failure first.

### Rule 5 — No Conditional Language for Verifiable Facts

These phrases are BANNED when describing your own work:

| Banned Phrase | Replacement |
|--------------|-------------| 
| "should work" | Run it. State whether it works. |
| "tests should pass" | Run tests. State pass/fail count. |
| "this will fix the issue" | Apply fix, run verification, state result. | 
| "probably correct" | Verify and state definitively. | 
| "I believe this resolves" | Show the before/after evidence. |
| "the implementation looks correct" | Run the type checker and tests to confirm. |

These phrases are acceptable ONLY for things you genuinely cannot verify (e.g., "this should perform well under 10x load" when you can't run a load test).

### Rule 6 — Stack-Native Verify (Mandatory Before Receipt)

When `docs/architecture/tech-stack.yaml` exists, agents **MUST** run commands from its `verify` block before writing a receipt. Load commands via [tech-pack-loading.md](./tech-pack-loading.md).

| Agent | Required commands (from `verify`) | Receipt blocked if |
|-------|-----------------------------------|-------------------|
| **Software Engineer** | `verify.test` + `verify.build` | Either exits non-zero |
| **Quality Engineer** | `verify.test` (full suite) + coverage tool when configured | Tests fail or coverage below `quality.coverage_minimum` |
| **Platform Engineer** | `terraform validate`, `docker build`, or cloud-pack equivalent | Infra validation fails |
| **Code Reviewer** | N/A (read-only) | — |

**Procedure:**

1. Read `docs/architecture/tech-stack.yaml` → `verify`
2. Run each non-null command; capture exit code and summary output
3. If `tasks.md` lists a per-task **Verify** line, run that command too
4. Write receipt only after all required commands pass
5. Include `verification_summary` with pass/fail counts — not agent memory

**Fallback** (no `tech-stack.yaml`): use commands from loaded tech pack or legacy tech-pack; still run test + build before receipt.

**Receipt validator rejection:** Missing `verification_commands`, empty list, or commands that were not executed → receipt INVALID → pipeline blocked.

---

## Integration with Receipt Protocol 

The receipt protocol requires a `verification_commands` field. With Verification Discipline, this field MUST contain concrete commands that prove the work: 

```json
{
  "verification_commands": [
    "npx tsc --noEmit",
    "npm test -- --watchAll=false",
    "npm run build"
  ]
}
```

Receipts without `verification_commands` are INVALID and will be rejected by the validator. Each command should be a concrete, re-runnable check.

---

## Anti-Patterns 

| Wrong | Right | 
|-------|-------|
| "I've implemented the feature and tests pass" (without running tests) | Run `npm test`, show output: "47 passing, 0 failing" |
| "The build should succeed with these changes" | Run `npm run build`, show output: "Build completed successfully" | 
| "Fixed the type error" (without checking) | Run `tsc --noEmit`, show: "0 errors found" |
| Writing a receipt before running verification | Run all checks, THEN write the receipt with results |
| "I'm confident this is correct" | "Verified: types check, tests pass, build succeeds. Here's the output." |
| Skipping verification for "simple changes" | Every change gets verified. Simple changes are where simple bugs hide. |
