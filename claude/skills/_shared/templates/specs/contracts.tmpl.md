# Contracts: {{SPEC_ID}}

**Spec ID:** `{{SPEC_ID}}`  
**Requirements:** [requirements.md](./requirements.md)  
**Status:** draft | review | approved

---

## Behavioral Contracts

Each REQ-ID from requirements.md has a behavioral contract defining inputs, outputs, error states, and side effects.

### {{REQ-ID_01}} — {{TITLE}}

| Aspect | Specification |
|--------|--------------|
| **Input** | `{{INPUT_SHAPE}}` |
| **Output** | `{{OUTPUT_SHAPE}}` — HTTP {{STATUS_CODE}} |
| **Error: Client** | `{{ERROR_CONDITION}}` → HTTP {{STATUS_CODE}} `{{ERROR_BODY}}` |
| **Error: Server** | `{{ERROR_CONDITION}}` → HTTP {{STATUS_CODE}} `{{ERROR_BODY}}` |
| **Side effects** | {{SIDE_EFFECTS}} |
| **Idempotent** | {{YES / NO — if yes, idempotency key}} |
| **Rate limit** | {{LIMIT}} per {{WINDOW}} |
| **Caching** | {{TTL}} / {{NO}} |

**Example request:**
```json
{{EXAMPLE_REQUEST}}
```

**Example response:**
```json
{{EXAMPLE_RESPONSE}}
```

---

### {{REQ-ID_02}} — {{TITLE}}

| Aspect | Specification |
|--------|--------------|
| **Input** | `{{INPUT_SHAPE}}` |
| **Output** | `{{OUTPUT_SHAPE}}` |
| **Error: Client** | `{{ERROR_CONDITION}}` → HTTP {{STATUS_CODE}} |
| **Error: Server** | `{{ERROR_CONDITION}}` → HTTP {{STATUS_CODE}} |
| **Side effects** | {{SIDE_EFFECTS}} |
| **Idempotent** | {{YES / NO}} |

**Example request/trigger:**
```json
{{EXAMPLE_TRIGGER}}
```

---

## Event Contracts (for event-driven REQ-IDs)

| REQ-ID | Event | Payload | Publisher | Consumer |
|--------|-------|---------|-----------|----------|
| REQ-02 | `user.consent.granted` | `{user_id, consent_type, timestamp}` | user-service | email-service, analytics-service |

---

## State Transition Contracts (for state-driven REQ-IDs)

| REQ-ID | State Machine | Transitions |
|--------|--------------|-------------|
| REQ-03 | ConsentStatus | `pending → granted | denied`, `granted → revoked` |

---

## Approval

- [ ] Every REQ-ID from requirements.md has a behavioral contract
- [ ] All error states are documented
- [ ] Side effects are documented
- [ ] Example request/response matches expected API shape
