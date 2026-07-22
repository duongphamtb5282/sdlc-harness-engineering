# Design: {{TITLE}}

**Spec ID:** `{{SPEC_ID}}`  
**Requirements:** [requirements.md](./requirements.md)  
**Status:** draft | design_review | approved

---

## Summary

{{ONE_PARAGRAPH_TECHNICAL_APPROACH}}

---

## Requirements traceability

| REQ-ID | Design element | Location |
|--------|----------------|----------|
| REQ-01 | {{COMPONENT_OR_API}} | `{{PATH_OR_ADR}}` |

Every REQ-ID from requirements.md MUST appear in this table before design approval.

---

## Architecture

### Components

| Component | Responsibility | Technology |
|-----------|----------------|------------|
| {{NAME}} | {{PURPOSE}} | {{FROM_TECH_STACK}} |

### API (link, do not duplicate)

- OpenAPI: `api/openapi/{{SERVICE}}.yaml`
- Key endpoints: {{BULLET_LIST}}

### Data

- ERD section: `docs/architecture/ERD.md#{{ENTITY}}`
- Migrations: `schemas/migrations/{{FILE}}`

---

## Decisions

| ADR | Decision | Rationale |
|-----|----------|-----------|
| ADR-NNN | {{DECISION}} | {{WHY}} |

---

## Security & compliance

| Concern | Approach |
|---------|----------|
| Auth | {{PATTERN}} |
| PII | {{HANDLING}} |

---

## Risks & mitigations

| Risk | Mitigation |
|------|------------|
| {{RISK}} | {{MITIGATION}} |

---

## Approval

- [ ] Traceability table complete
- [ ] Linked artifacts exist or are scheduled in SA phases
- [ ] Design reviewed (Controlled mode: user sign-off)
