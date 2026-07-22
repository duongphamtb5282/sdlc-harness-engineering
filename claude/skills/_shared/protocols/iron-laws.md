<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Iron Laws — Non-Negotiable Development Discipline

**Core principle: Iron Laws are hard constraints, not guidelines. They cannot be overridden by convenience, time pressure, or "this is a simple case." Violations are treated as bugs.**

---

## What Are Iron Laws?

Iron Laws are behavioral constraints that prevent the most common and costly AI agent failure modes. Unlike protocols (which guide how to work), Iron Laws define what MUST happen and what MUST NOT happen — with no exceptions.

Every agent loads this protocol alongside its skill. Iron Laws override agent judgment when they conflict. 

--- 

## Universal Iron Laws (All Agents)

### Iron Law 1 — Evidence Before Claims

**NEVER claim something works without running it and showing the output.**

- Before stating "tests pass" → run the tests, show the output
- Before stating "builds successfully" → run the build, show the output
- Before stating "no errors" → run the linter/type checker, show the output  
- Before stating "the fix works" → demonstrate the fix with a concrete test or command

**Enforcement:** Every completion claim in a receipt MUST reference a specific command output or test result. Receipts with unverified claims are invalid.

**Forbidden thoughts:**
- "This should work" — Run it and prove it works.
- "Tests probably pass" — Run them and show the output.
- "The change is straightforward, no need to verify" — Every change needs verification. No exceptions.
- "I'll just say it's done" — Unverified claims are lies.

### Iron Law 2 — Read Before Write

**NEVER modify code you haven't read. NEVER generate code for a file you haven't inspected.**

- Before editing a function → read the entire file and understand its context  
- Before adding to a module → read existing patterns, naming, and style
- Before generating tests → read the source code, understand function signatures and types
- Before suggesting a fix → read the surrounding code to understand dependencies 

**Enforcement:** Tool call logs must show Read/Grep before any Edit/Write for the same file path. 

**Forbidden thoughts:**
- "I know what this file probably looks like" — Read it.
- "This is a standard pattern, I don't need to check" — Check anyway. 
- "I'll write the code first and adjust if it doesn't compile" — Understand first, write second.

### Iron Law 3 — No Phantom Artifacts

**NEVER reference files, functions, endpoints, or configurations that don't exist.**  

- Before importing a module → verify the module exists with Glob/Read
- Before referencing a function → verify it exists and check its actual signature
- Before listing artifacts in a receipt → verify each file path exists on disk
- Before suggesting a patch to a file → read the current file contents first

**Enforcement:** Receipt verification checks every artifact path. Missing artifacts = failed receipt.

**Forbidden thoughts:**
- "There's probably a utils module at..." — Find it or create it explicitly.
- "This function likely takes these parameters" — Read the actual signature.
- "I'll reference the file I'm about to create" — Create it first, reference it second.

--- 

## TDD Iron Law (Software Engineer + Quality Engineer)  

### Iron Law 4 — Test First, Code Second

**When implementing new functionality: write the failing test FIRST, then write the code to make it pass.**

The Red-Green-Refactor cycle is mandatory, not optional:

1. **RED** — Write a test that describes the expected behavior. Run it. Watch it fail. If it passes, your test is wrong (testing nothing new).
2. **GREEN** — Write the MINIMUM code to make the test pass. No more. No "while I'm here" additions.
3. **REFACTOR** — Clean up both test and implementation. Run tests again to confirm they still pass. 

**Scope:** This law applies to:
- Every new endpoint (handler + service + repository)
- Every new business rule or domain logic function
- Every new utility or helper function
- Every bug fix (write a test that reproduces the bug FIRST)  

**Exceptions (where test-after is acceptable):**
- Generated code (OpenAPI codegen, protobuf stubs, migration files)
- Configuration files (docker-compose, CI/CD, env templates)
- Pure boilerplate (DI wiring, app bootstrap, middleware registration)
- Exploratory/spike work explicitly marked as throwaway 

**Enforcement:** For each new source file in `services/` or `libs/`, a corresponding test file MUST exist in `tests/`. The test file's git timestamp (or creation order in the session) should precede or match the source file's. During code review (Code Reviewer), flag any new source file without a corresponding test. 

**Forbidden thoughts:**
- "This is too simple to test" — Simple code has simple tests. Write them. 
- "I'll write the tests after" — After never comes. Write the test now.
- "Just this once, I'll skip the test" — Just this once is how tech debt starts. 
- "Testing this would be hard, so I'll skip it" — If it's hard to test, the design is wrong. Fix the design.
- "The integration test will catch it" — Unit tests catch it faster, cheaper, and with better error messages. 

---  

## Verification Iron Law (All Agents)

### Iron Law 5 — Verify At Every Gate

**Before marking any task as complete, run ALL relevant verification commands and report results.**

Minimum verification checklist (run what applies to the project):

| Check | Command Pattern | Must Pass |
|-------|----------------|-----------|
| Type check | `tsc --noEmit` / `mypy .` / `go vet ./...` | Yes |
| Lint | `eslint .` / `ruff check .` / `golangci-lint run` | Yes |
| Unit tests | `npm test` / `pytest` / `go test ./...` | Yes |
| Build | `npm run build` / `go build ./...` / `cargo build` | Yes |

**Enforcement:** Completion receipts MUST include a `verification_commands` field listing every command run and its exit code. Receipts without verification commands are invalid.

**Forbidden thoughts:**
- "The linter will probably pass" — Run it and find out.
- "I didn't change anything that would break the build" — Run the build anyway.
- "The tests are unrelated to my change" — Run them anyway. Side effects exist. 

--- 

## Rationalization Prevention

The most dangerous failure mode is when an agent convinces itself that an Iron Law doesn't apply to the current situation. These are the common rationalization patterns — if you catch yourself thinking any of these, STOP and follow the Iron Law:

| Rationalization | Reality |
|----------------|---------|
| "This is a trivial change" | Trivial changes cause production outages. Verify anyway. |
| "Time pressure means we skip tests" | Skipping tests costs MORE time when the bug ships. |
| "The user asked me to go fast" | Fast AND correct. Never trade correctness for speed. |
| "I already know what this code does" | Code changes. Read it fresh. |
| "This test would be slow to write" | A slow test is infinitely better than no test. | 
| "The other agent will catch this" | Defense in depth. Every agent verifies their own work. |
| "It worked in a similar project" | This is not that project. Verify in THIS context. | 
| "I'm confident this is right" | Confidence is not evidence. Run the verification. |

---

## How Agents Load This Protocol 

This protocol is auto-injected alongside other protocols. Agents MUST treat Iron Laws as higher priority than any skill-specific instruction that would weaken them. 

**Priority order:**
1. Iron Laws (this file) — highest
2. Skill-specific phase instructions
3. Protocol guidelines (UX, visual identity, etc.)
4. Agent judgment and defaults — lowest

If a phase instruction says "skip tests for boilerplate" and the code is NOT boilerplate, the Iron Law wins: write the test. 
