# Tests: {{SPEC_ID}}

**Spec ID:** `{{SPEC_ID}}`  
**Requirements:** [requirements.md](./requirements.md)  
**Contracts:** [contracts.md](./contracts.md)  
**Status:** draft | in_progress | complete

---

## Test Coverage Map

Every REQ-ID must have ≥1 test case. Every test case maps to ≥1 AC-ID.

| REQ-ID | AC-ID | Test file | Test name | Type | Status |
|--------|-------|-----------|-----------|------|--------|
| REQ-01 | AC-01 | `tests/unit/{{path}}` | `test_{{description}}` | Unit | planned / passing / failing |
| REQ-02 | AC-02 | `tests/integration/{{path}}` | `test_{{description}}` | Integration | planned / passing / failing |
| REQ-03 | AC-03 | `tests/e2e/{{path}}` | `test_{{description}}` | E2E | planned |
| REQ-05 | AC-05 | `tests/contract/{{path}}` | `test_{{description}}` | Contract | planned |

---

## Test Cases by REQ-ID

### REQ-01 — {{TITLE}}

| Aspect | Detail |
|--------|--------|
| **Contract reference** | contracts.md → REQ-01 |
| **Test type** | Unit |
| **File** | `tests/unit/{{path}}` |
| **Name** | `test_{{description}}` |

**Scenario:** {{GIVEN}} → {{WHEN}} → {{THEN}}

**Input:**
```json
{{INPUT}}
```

**Expected output:**
```json
{{OUTPUT}}
```

**Assertions:**
- [ ] Status code matches contracts.md
- [ ] Response body matches expected shape
- [ ] Error message matches contracts.md for error cases

---

### REQ-02 — {{TITLE}}

| Aspect | Detail |
|--------|--------|
| **Contract reference** | contracts.md → REQ-02 |
| **Test type** | Integration |
| **File** | `tests/integration/{{path}}` |

**Scenario:** {{GIVEN}} → {{WHEN}} → {{THEN}}

**Assertions:**
- [ ] Correct HTTP status
- [ ] Side effects verified (e.g., DB record created, event published)
- [ ] Idempotency: second identical call returns same result

---

### REQ-05 — {{TITLE}} (Error/Unwanted Behavior)

| Aspect | Detail |
|--------|--------|
| **Contract reference** | contracts.md → REQ-05 |
| **Test type** | Unit |
| **File** | `tests/unit/{{path}}` |

**Scenario:** When {{TRIGGER}} → system shall {{RESPONSE}}

**Assertions:**
- [ ] Correct error status code per contracts.md
- [ ] Error body matches expected shape
- [ ] Fallback/retry behavior works as specified

---

## Edge Cases

| Edge case | REQ-ID | Expected behavior |
|-----------|--------|-------------------|
| {{EDGE}} | REQ-0X | {{BEHAVIOR}} |
| {{EDGE}} | REQ-0X | {{BEHAVIOR}} |

---

## Coverage Summary

| Metric | Count |
|--------|-------|
| Total REQ-IDs | {{N}} |
| REQ-IDs with ≥1 test | {{N}} |
| Test coverage % | {{%}} |
| Passing | {{N}} |
| Failing | {{N}} |
| Planned (not yet written) | {{N}} |

---

## Approval

- [ ] Every REQ-ID has ≥1 test case planned
- [ ] All contract error states have negative tests
- [ ] All side effects have verification assertions
- [ ] Edge cases documented
- [ ] Coverage summary shows 100% REQ-ID coverage
