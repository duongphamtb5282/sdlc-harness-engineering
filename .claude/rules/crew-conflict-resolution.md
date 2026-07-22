<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Conflict Resolution Protocol

When two sdlc-automation-agent skills produce overlapping or contradictory outputs, this protocol determines which output takes authority.

## Authority Hierarchy

Each artifact type has a single authoritative skill. Contributors may flag issues but do NOT override the authority.

| Artifact | Authority (Sole Owner) | Contributors (Read-Only Input) |
|----------|----------------------|-------------------------------| 
| Business requirements (BRD) | **product-manager** | — |
| Architecture decisions (ADRs) | **solution-architect** | code-reviewer flags drift | 
| API contracts (OpenAPI, gRPC, AsyncAPI) | **solution-architect** | software-engineer requests changes via findings |
| Implementation code (services/, libs/) | **software-engineer** | reviewers produce findings only, do NOT modify code |
| Frontend code (frontend/) | **software-engineer [frontend mode]** | reviewers produce findings only, do NOT modify code |
| Test suites (tests/) | **quality-engineer** | — |
| Security findings (OWASP, STRIDE, pen-test) | **compliance-engineer** | code-reviewer does NOT perform OWASP review |
| Code quality / arch conformance findings | **code-reviewer** | — |
| SLO definitions, error budgets, runbooks | **platform-engineer** | — |
| Monitoring infrastructure (dashboards, alerts) | **platform-engineer** | — |
| Infrastructure (Terraform, K8s, CI/CD) | **platform-engineer** | — |
| Documentation (docs/) | **technical-writer [docs mode]** | — |
| Sprint & versioned reports (reports/) | **technical-writer [report mode]** | All agents provide data via receipts and workspace artifacts |

## Deduplication Rules 

When multiple skills analyze the same code and produce overlapping findings:

1. **Keep highest severity**: If compliance-engineer rates a finding as Critical and code-reviewer rates the same file:line as High, keep Critical.
2. **Deduplicate by location**: Findings targeting the same `file:line` are merged. The authoritative skill's finding wins.
3. **Cross-reference, don't duplicate**: code-reviewer should write "See compliance-engineer findings for OWASP analysis" instead of performing its own OWASP review. 

## Feedback Loops (Review → Implementation) 

When review agents (QE, CE, CR) find issues that require code changes:

1. **Findings become tasks**: The orchestrator reads all review findings and creates remediation TodoWrite entries.  
2. **Remediation assigned to SE**: Critical/High findings are assigned to the original SE agent (software-engineer or software-engineer [frontend mode]).  
3. **Re-scan after remediation**: After fixes are applied, the review agent re-scans the affected files.
4. **Termination after 2 cycles**: If issues persist after 2 fix-rescan cycles, escalate to user via AskUserQuestion.

## Specific Boundary Clarifications 

### compliance-engineer vs code-reviewer
- **compliance-engineer**: Sole authority on OWASP Top 10, STRIDE, penetration testing, PII, encryption, regulatory compliance.
- **code-reviewer**: Architecture conformance, code quality (SOLID, DRY), performance, test quality. Does NOT perform security review — references compliance-engineer findings instead.

### platform-engineer (unified) 
- **platform-engineer** owns both infrastructure provisioning AND reliability engineering. This includes: CI/CD pipelines, container orchestration, monitoring tool setup, SLO/SLI definitions, error budget policy, chaos engineering, incident management, runbooks, and capacity planning.

### product-manager vs solution-architect
- **product-manager**: Owns WHAT to build (requirements, user stories, acceptance criteria).
- **solution-architect**: Owns HOW to build it (architecture, tech stack, API contracts, data models). Does NOT change requirements — flags gaps back to PM.
