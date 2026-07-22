<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Interface Contracts (As-Built)

Generated: [date]
Last updated: [date]
Source: Discover mode analysis

These are the actual contracts between modules as observed in code — not what documentation says, but what the code does.

---

## [module-A] → [module-B] 

- **Protocol**: HTTP REST / gRPC / Message Queue / Shared Database / File System
- **Direction**: [A calls B / bidirectional / A publishes, B subscribes]
- **Authentication**: [API key / JWT / service account / none]
- **Endpoints/Channels**:
  | Method | Path/Topic | Request Format | Response Format | Error Handling | 
  |---|---|---|---|---|
  | [GET/POST/PUB/SUB] | [path or topic] | [schema summary] | [schema summary] | [retry/fail/fallback] |
- **Implicit assumptions**:
  - [e.g., "assumes response within 5s", "assumes JSON content-type", "no schema validation"]
- **Contract documentation**: [documented / undocumented / partially documented / contradicts docs]
- **Fragility**: HIGH / MEDIUM / LOW
- **Notes**: [anything notable about this interface]

<!-- Repeat for each inter-module interface -->

--- 

## External Service Contracts 

## [module] → [external-service]

- **Service**: [e.g., Stripe API, SendGrid, AWS S3]
- **SDK/Client**: [library used]
- **Version**: [API version if detectable]  
- **Authentication**: [API key / OAuth / IAM role]
- **Error handling**: [retry logic, fallback behavior]
- **Rate limiting**: [if detectable from code]

<!-- Repeat for each external integration --> 
