<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# TDD Discipline — Red-Green-Refactor Enforcement

Extends Iron Law 4 with detailed enforcement, anti-patterns, and rationalization counters.

## The Cycle

```
RED ──→ VERIFY RED ──→ GREEN ──→ VERIFY GREEN ──→ REFACTOR ──→ VERIFY GREEN
 ↑                                                                    │ 
 └────────────────────────────────────────────────────────────────────┘
```

### RED — Write a Failing Test

1. Write a test that describes the expected behavior
2. Run it
3. **Watch it fail** — if it passes, your test is wrong (testing nothing new)
4. The failure message should clearly describe what's missing

### VERIFY RED

Run the test. Confirm it fails. If it passes:
- You're testing existing behavior (not new)
- Your test has no assertions
- Your mock returns the expected value

**Fix the test before proceeding.**

### GREEN — Minimal Code

Write the MINIMUM code to make the test pass:
- No "while I'm here" additions 
- No optimization 
- No edge case handling beyond what the test requires
- Hardcode if that's the minimum (the next test will force generalization) 

### VERIFY GREEN  

Run ALL tests (not just the new one):
- New test passes
- No existing tests broken 
- If existing tests broke → your "minimal" change wasn't minimal enough 

### REFACTOR 

Clean up both test and implementation:
- Remove duplication
- Improve naming 
- Extract methods/functions 
- **Do NOT change behavior** — only restructure

### VERIFY GREEN (again)

Run all tests after refactoring. They must all still pass.  

---

## Anti-Patterns

### 1. Code Before Test

**Symptom:** Writing implementation code, then writing a test that exercises it.

**Why it's wrong:** The test is shaped by the code, not by the requirement. You test what you built, not what you should have built. Missing behaviors never get tests.

**If caught:** Delete the code. Write the test. Start over. The sunk cost of the code is zero — it took 30 seconds to write and will take 30 seconds to rewrite. 

### 2. Test That Passes Immediately

**Symptom:** New test passes without any code changes.  

**Why it's wrong:** Either you're testing existing behavior (wasted test) or your test has no meaningful assertions. 

**Fix:** Add assertions that target the NEW behavior you're about to implement.

### 3. Testing Mock Behavior

**Symptom:** Test mocks a dependency and then asserts the mock returned what you told it to return. 

**Why it's wrong:** You're testing your test setup, not your code. The mock always does what you programmed it to do.

**Fix:** Mock only at boundaries (external APIs, databases). Test real logic with real (in-memory) implementations.

### 4. Test-Only Methods

**Symptom:** Adding public methods to production code solely so tests can call them.  

**Why it's wrong:** Production API is polluted with test hooks. Future developers may depend on these methods.

**Fix:** Test through the public interface. If you can't test it without a back door, the design needs restructuring.

### 5. Assertion-Free Tests

**Symptom:** Test runs code but has no `expect()`, `assert`, or equivalent.

**Why it's wrong:** The test can never fail. It provides zero safety. 

**Fix:** Every test must assert on specific, concrete values. 

### 6. Spirit-of-TDD Violations

**Symptom:** "I'm following TDD because I write tests" — but tests are written after, or tests don't drive design.  

**Reality:** TDD is a design discipline, not a testing technique. The test comes first because it forces you to think about the API before implementing it. Writing tests after is just "testing" — useful, but not TDD.

--- 

## Rationalization Counters

| Rationalization | Counter | 
|----------------|---------| 
| "This is too simple to test" | Simple code has simple tests. They take 30 seconds. Write one. |
| "I'll write the test after" | After never comes. You'll move to the next feature. Write it now. |
| "Manual testing is enough" | Manual testing doesn't prevent regressions. Automated tests do. |
| "The integration test will catch it" | Integration tests are slow and imprecise. Unit tests catch it faster. |
| "Testing this would require too much setup" | If setup is hard, the code has too many dependencies. Fix the design. |
| "This is just boilerplate/config" | Config bugs cause outages too. Test the critical config paths. |
| "I already spent time on the code, I'll just add a test" | Sunk cost fallacy. Delete the code. Write the test. 30 seconds to rewrite. |
| "The deadline is tight" | Skipping tests costs MORE time when the bug ships. Tight deadlines need MORE tests, not fewer. |
| "This is exploratory/spike work" | Mark it explicitly as throwaway. If it's not throwaway, test it. |

## Pressure Scenarios

These are the situations where TDD discipline breaks down. Be extra vigilant:

| Pressure | Response |
|----------|----------|
| **Time pressure** + simple change | Simple change = simple test. 30 seconds. Do it. |
| **Sunk cost** + code already written | Delete and restart. The code was a prototype. | 
| **Authority** + "just ship it" | Tests ARE shipping. Shipping without tests is shipping a timebomb. | 
| **Exhaustion** + "one more feature" | Exhaustion is when you make the most mistakes. Tests protect you. |
| **Excitement** + "this is working!" | Working now ≠ working tomorrow. Capture "working" in a test. |

## TDD Evidence Collection

To enable post-hoc verification that TDD was followed, the Software Engineer MUST record evidence during the build:

1. **Test-first commit sequence:** When implementing a story, commit the failing test BEFORE committing the implementation. The git history must show: `test: add failing test for {feature}` → `feat: implement {feature}` → `refactor: clean up {feature}`. This sequence is verifiable via `git log`.

2. **Story-map test tracing:** In `.sdlc-automation-agent/software-engineer/story-map.md`, for each implemented story, record:
   - Story ID
   - Test file(s) written
   - Implementation file(s) written 
   - Whether TDD was followed or an exception applied (with reason)

3. **Receipt evidence:** The SE receipt must include: 
   ```json
   "tdd_evidence": {
     "stories_with_tdd": 8,  
     "stories_with_exception": 2,  
     "exception_reasons": ["generated migration files", "DI wiring boilerplate"]
   }
   ```

4. **Code Reviewer verification:** During VERIFY Phase 4 (Test Quality), the Code Reviewer checks the git log for test-first commit ordering and flags violations as Medium severity findings.

---

## When TDD Exceptions Apply 

These are the ONLY cases where test-after is acceptable:

- Generated code (OpenAPI codegen, protobuf stubs, migration files)
- Configuration files (docker-compose, CI/CD, env templates)
- Pure boilerplate (DI wiring, app bootstrap, middleware registration)  
- Exploratory/spike work **explicitly marked as throwaway**

If in doubt: write the test first. The cost of an unnecessary test is near zero. The cost of a missing test is a production bug.
