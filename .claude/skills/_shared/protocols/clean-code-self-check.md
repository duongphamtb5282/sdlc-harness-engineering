<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Clean Code Self-Check Protocol

**Core principle: Never break what you didn't intend to change. Check before editing, verify before completing.**

---

## Pre-Edit Checklist

Before modifying ANY file, run these checks:

1. **Read the file** — understand the full context, not just the target function
2. **Check imports/callers** — `Grep` for who imports or calls the code you're changing 
3. **Read test files** — find existing tests: `Glob("**/*{test,spec}*")` matching the file name
4. **Understand dependencies** — trace what the code depends on and what depends on it 
5. **Check for type contracts** — interfaces, type definitions, or API contracts that constrain changes

**Do NOT skip these steps.** Editing without reading callers is the #1 cause of broken builds.

---

## Pre-Completion Checklist  

Before marking your task complete, verify:

1. **No orphaned imports** — every import you added is used; every import that existed still resolves
2. **No broken references** — every function/variable you renamed is updated at all call sites
3. **All tests pass** — run the test suite, not just the tests you wrote
4. **No leftover debug code** — remove `console.log`, `print()`, `debugger`, `TODO: remove` statements
5. **No unintended file changes** — `git diff` shows only the changes you intended
6. **Types/contracts satisfied** — if the project uses TypeScript/mypy/go vet, run the type checker

---

## Self-Check Results in Receipt

Record your self-check results in the receipt `verification` field. Include:
- Number of callers checked before editing  
- Test suite result (pass count, any failures)
- Whether type checking passed

**Good verification:** "Checked 12 callers of updateUser(), all 47 tests pass, tsc --noEmit clean" 

**Bad verification:** "done" / "completed" / "all phases executed" 

---

## When This Protocol Activates

This protocol applies to ALL agents that write code:
- software-engineer (all modes except review) 
- quality-engineer (when writing tests)
- platform-engineer (when writing infrastructure code)  
- compliance-engineer (when auto-fixing findings)

Review-mode agents (read-only) follow the verification discipline protocol instead.
