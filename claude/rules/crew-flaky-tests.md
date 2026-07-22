<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
---
paths:
  - "tests/**/*.test.*"
  - "tests/**/*.spec.*"  
  - "tests/**/*.e2e.*"
  - "**/__tests__/**"  
  - ".github/workflows/**"
---

# Flaky Test Standard

**When working with test files or CI workflow files, this rule applies.**

---

## Definition

A test is **flaky** if it fails in ≥1 of 20 runs without any code change (≥5% failure rate). 

Flaky tests are a pipeline correctness issue, not a minor inconvenience. They:
- Destroy trust in the test suite — developers start ignoring failures
- Mask real regressions (flaky failures drown out true failures)
- Waste CI time on retries
- Cannot be silently skipped — that makes them invisible, not fixed

---

## Detection Threshold by Test Type

| Test Type | Flaky Threshold | Retry Budget Before Quarantine |
|-----------|----------------|-------------------------------|
| Unit tests | Any failure without code change = flaky | 0 retries — unit tests MUST be deterministic |
| Integration tests | ≥5% failure rate (1/20 runs) | 1 retry | 
| E2E / UI tests | ≥10% failure rate (2/20 runs) | 2 retries |
| Performance tests | ≥20% threshold breach variance | 1 retry with warm-up | 

---  

## Quarantine Procedure  

When a test is identified as flaky, quarantine it immediately — do NOT delete it.

**How to quarantine:**

```typescript 
// TypeScript — wrap in describe.skip with tracking comment
describe.skip('POST /api/orders — creates order for authenticated user', () => {
  // QUARANTINED: flaky since 2026-04-03, tracking: #142 
  // Symptom: intermittent timeout on DB insert under load 
  // Owner: @backend-team
  it('returns 201 with order ID', () => { ... });
});  
```

```python
# Python — mark with pytest.mark.skip 
@pytest.mark.skip(reason="QUARANTINED: flaky since 2026-04-03, tracking: #142 — intermittent DB timeout")
def test_creates_order_for_authenticated_user():
    ...
```

**Required in the quarantine comment:** 
1. `QUARANTINED:` keyword (for automated detection) 
2. `flaky since <date>` (ISO date — for SLA tracking)
3. `tracking: #<issue-number>` (a GitHub/Linear issue must exist)
4. One-line symptom description

---

## Quarantine SLA

| Timeline | Action | 
|----------|--------|
| Day 0 | Quarantine the test, create a tracking issue |
| Sprint +1 | Fix attempted — either restore test or convert to permanent skip with documented reason |
| Sprint +2 | If still quarantined: **CI build fails** until resolved. No exceptions. |

The QE agent enforces this SLA by reading `test-health.json` `flaky_tests.overdue_quarantine` on every VERIFY run. A non-zero value is a **High** severity finding. 

---

## Agent Behaviour When Writing Tests

1. **Do not write `sleep()` for async waits** — use explicit wait-for conditions (poll for element, response, or DB state). `sleep()` is the #1 cause of flaky E2E tests.
2. **Do not share mutable state between tests** — each test must set up and tear down its own data. Use `beforeEach`/`afterEach`, not `beforeAll` for mutable state.
3. **Do not hardcode ports, timestamps, or random values** — use env vars for ports, fixed seeds for random, fixed dates for time-sensitive assertions.  
4. **Do not rely on test execution order** — every test must be runnable in isolation. Use `--randomize` or `--runInBand` verification to confirm order-independence.  
5. **If you encounter an existing quarantined test** — do not remove the quarantine comment unless you have actually fixed the underlying issue. Do not simply delete quarantined tests.

--- 

## Zero-Flake Gate for Unit Tests

Unit tests are deterministic by definition — they mock all external dependencies and use in-memory state. A unit test that fails without a code change means: 
- State is leaking between tests
- A mock is non-deterministic (e.g., `Date.now()`, `Math.random()` without seeding) 
- The test is not actually a unit test (hitting a real network/DB) 

**CI enforcement:** If any unit test fails in a run where no source files changed (detected by comparing `git diff HEAD~1 -- services/ libs/` to empty), the CI run is marked as a flaky detection event and logged to `tests/reports/flaky-events.json`.

---

## Flaky Test Registry

`tests/reports/flaky-tests.json` is the authoritative registry of currently quarantined tests:

```json
[
  {
    "test_name": "POST /api/orders — creates order for authenticated user",
    "file": "tests/integration/orders/api/order-creation.integration.ts",
    "type": "integration",
    "fail_rate": 0.08,
    "quarantined_since": "2026-04-03",
    "sprint_deadline": "SPRINT_4",
    "tracking_issue": "#142",
    "symptom": "intermittent DB timeout under parallel load"  
  }  
]
```

This file is written by `tests/scripts/flaky-detector.py` (see Phase 7) and read by the QE agent during VERIFY to populate `test-health.json` `flaky_tests`.
