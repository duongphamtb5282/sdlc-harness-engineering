<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Product Requirements Document (As-Built)

Generated: [date]
Last updated: [date]
Source: Discover mode full analysis
Run type: [full | update]

> This PRD documents the **existing system as-is** — what it does, how it works, and what risks exist. It synthesizes all Discover mode analysis artifacts into a single reference for reimplementation, modernization, or major enhancement planning.
>
> **This is not a feature spec.** For new feature requirements, see the BRD produced by `/sdlc-automation-agent`.

---

## 1. Overview 

[What this system does, who uses it, and scope boundaries. 2-3 paragraphs.]

- **Purpose**: [primary function of the system]
- **Users**: [who uses it — roles, teams, external parties] 
- **Scale**: [N] modules, [N] source files, [N] test files, active since [date]
- **Classification**: [monolith / modular monolith / microservices / distributed monolith]

---

## 2. Architecture Summary

- **Pattern**: [monolith / modular monolith / microservices / distributed monolith (anti-pattern)]
- **Languages**: [primary language(s)]
- **Frameworks**: [detected frameworks]
- **Infrastructure**: [cloud provider, CI/CD, containerization]

### Module Map

| Module | Path | Language | LOC | Entry Points | Risk Score |
|---|---|---|---|---|---|
| [name] | [dir] | [lang] | [N] | [files] | [1-10] |  

<!-- Repeat for each module — sourced from dependency-map.md -->

### Dependency Overview

- Total dependencies: [N] 
- Hidden couplings: [N] 
- Circular dependencies: [Y/N — list if yes]

Source: `dependency-map.md`, `module-inventory.md` 

---

## 3. Domain Model 

### 3.1 Key Entities

<!-- Repeat for each significant entity -->
#### [Entity Name]  

- **Location**: [file:line] or [database table]
- **Properties**:
  | Property | Type | Required | Constraints | Source |
  |---|---|---|---|---|
  | [name] | [type] | Y/N | [validation rules] | [code / DB / both] |

### 3.2 Entity Relationships

| From | To | Relationship | Mechanism | Source |
|---|---|---|---|---|
| [entity] | [entity] | has_many / belongs_to / has_one | FK / ORM / implicit | [code / DB / both] |

### 3.3 Data Flow  

[How data moves between modules — API calls, shared databases, message queues, file system.]  

Source: `dependency-map.md`, `interface-contracts.md`, `data-schema.md`

--- 

## 4. User Interfaces & Screens

> This section is populated only if live app exploration (Step 2.5) was performed.

### Screen Inventory 

| Screen | Route | Purpose | Forms | Navigation To |
|---|---|---|---|---|
| [name] | [path] | [purpose] | [N] | [screen list] |  

### Key Form Schemas

<!-- Repeat for each significant form -->
#### [Form on Screen Name] 

| Field | Type | Required | Validation | Notes | 
|---|---|---|---|---|
| [label] | [input type] | Y/N | [rules] | [constraints] |

### Navigation Map

[Primary user flows and screen connectivity.] 

Source: `ui-contracts.md`  

---  

## 5. Business Rules & Logic

### Summary

- Total rules extracted: [N]
- High confidence (unit tested): [N]
- Medium confidence (partial evidence): [N]
- Low confidence / need verification: [N]

### Rules by Module

<!-- Repeat for each module with rules -->
#### [Module Name]

| Rule ID | What It Does | Confidence | Location | Assumption Risk |
|---|---|---|---|---|
| BR-[module]-[NNN] | [plain language] | HIGH/MEDIUM/LOW/INFERRED | [file:line] | [risk] | 

Source: `business-rules-inventory.md`, `db-business-rules.md` 

---

## 6. Workflows & Processes

<!-- Repeat for each significant workflow --> 
### [Workflow Name]

- **Trigger**: [what initiates this workflow]
- **Outcome**: [what the workflow produces]
- **Steps**:
  1. [step] — [module/screen involved]
  2. [step] — [module/screen involved]
- **Business rules applied**: [BR-xxx, BR-yyy]
- **Source**: [file:line or ui-contracts screen references]

---

## 7. API & Interface Contracts

### Inter-Module Contracts

<!-- Repeat for each interface -->
#### [Module A] → [Module B]

- **Protocol**: [REST / gRPC / queue / shared DB]  
- **Fragility**: [HIGH / MEDIUM / LOW]  
- **Key endpoints**:
  | Method | Path | Request | Response | Auth |  
  |---|---|---|---|---|
  | [verb] | [path] | [shape] | [shape] | [method] |

### Runtime-Observed APIs 

> Populated only if live app exploration (Step 2.5) was performed.

[API endpoints captured from network monitoring during live crawl.]

Source: `interface-contracts.md`, `ui-contracts.md` 

--- 

## 8. Data Schema  

> This section is populated only if live database analysis (Step 3.5) was performed.

### Tables

<!-- Repeat for each table -->
#### [table_name]

| Column | Type | Nullable | Default | Constraints |
|---|---|---|---|---|
| [name] | [type] | Y/N | [default] | [PK/FK/UNIQUE/CHECK] |

- **Indexes**: [list]
- **Foreign keys**: [relationships] 
- **Row estimate**: [N]  

### Stored Procedures

| Procedure | Parameters | Called From | Tables Accessed | Status |
|---|---|---|---|---|
| [name] | [params] | [file:line or ORPHANED] | [tables] | active / orphaned |

### Schema Drift

| Item | In Code | In Database | Type | Risk | 
|---|---|---|---|---|
| [item] | [code def] | [DB def] | [mismatch type] | HIGH/MEDIUM/LOW | 

Source: `data-schema.md`

---

## 9. Integrations & External Dependencies  

| External System | Module | Direction | Protocol | Auth | Error Handling |
|---|---|---|---|---|---| 
| [service name] | [module] | inbound/outbound/bidirectional | [REST/gRPC/queue/file] | [method] | [retry/fail/fallback] |

Source: `interface-contracts.md`, `dependency-map.md`

--- 

## 10. Security & Access Control 

- **Authentication**: [method — JWT / session / OAuth / API key / etc.]
- **Authorization model**: [RBAC / ABAC / custom] 
- **Roles detected**:
  | Role | Permissions | Source |
  |---|---|---|
  | [role] | [what they can do] | [file:line] |  

Source: `business-rules-inventory.md` (access control rules), `ui-contracts.md`

--- 

## 11. Risk Assessment 

### Critical Risks

| Risk ID | Category | Severity | Affected Modules | Description | Mitigation Status |
|---|---|---|---|---|---|
| RISK-[NNN] | [category] | CRITICAL/HIGH | [modules] | [description] | [status] |

### Hotspot Files

| File | Commits (12mo) | Authors | Bus Factor | Assessment |
|---|---|---|---|---|
| [file] | [N] | [N] | CRITICAL/HIGH/MEDIUM/LOW | [stable/chaotic churn] | 

### Hidden Couplings

| Modules | Mechanism | Risk |
|---|---|---|
| [A] ↔ [B] | [shared DB / shared type / temporal] | [what breaks if one changes] | 

Source: `risk-register.md`, `health-assessment.md` 

--- 

## 12. Technical Debt & Known Issues

### Debt Summary  

- Total items: [N]
- Intentional shortcuts: [N]
- Outdated patterns: [N]
- Workarounds: [N]
- Unknown origin: [N]

### Dead Code Candidates

| Function/Method | Location | Callers Found | Risk |
|---|---|---|---|
| [name] | [file:line] | 0 | [reflection/dynamic dispatch/external caller] | 

### Implicit Assumptions

- [assumption — e.g., "hardcoded timezone UTC in pricing calculation" at file:line]

Source: `technical-debt-register.md`, `dead-code-candidates.md`, `implicit-assumptions.md`

---

## 13. Test Coverage & Quality 

- **Overall coverage**: [N]% ([measured / estimated])
- **Coverage tool**: [jest / pytest-cov / jacoco / estimated]
- **Characterization tests generated**: [N]

### Priority Files (Highest Risk, Lowest Coverage)

| File | Risk Score | Coverage | Priority | Business Rules | Hidden Coupling |
|---|---|---|---|---|---|
| [file] | [1-10] | [%] | P1/P2/P3 | Y/N | Y/N |  

Source: `health-assessment.md`, `coverage-baseline.json`

---

## 14. Open Questions 

Issues requiring stakeholder clarification or further investigation. Each arose from contradictions, gaps, or unverifiable assumptions found during analysis.

| # | Question | Context | Source |
|---|---|---|---|
| 1 | [question] | [what analyses disagree about or what couldn't be verified] | [which packages/files] |

<!-- Repeat for each open question -->

---

## 15. Migration Considerations 

- **Schema drift items**: [N] mismatches between code and database 
- **Breaking changes to account for**: [list]
- **Data volume estimates**: [if available from DB analysis] 
- **Stored procedure dependencies**: [N] active, [N] orphaned

Source: `data-schema.md`, `risk-register.md` 

--- 

## 16. Glossary

| Term | Definition | Source |
|---|---|---|
| [domain term] | [meaning in this system] | [where it appears — code, DB, UI] |

<!-- Alphabetized — sourced from entity names, enum values, config keys, UI labels --> 

--- 

## 17. Sources

| Analysis File | Generated | Contribution |
|---|---|---|
| `dependency-map.md` | [date] | Module inventory, dependency graph, architecture pattern |
| `interface-contracts.md` | [date] | API contracts, external integrations | 
| `business-rules-inventory.md` | [date] | Business rules, confidence levels |  
| `risk-register.md` | [date] | Risk items, hotspot files, bus factor |
| `health-assessment.md` | [date] | Coverage baseline, health scores |
| `ui-contracts.md` | [date] | Screens, forms, navigation, runtime APIs |  
| `data-schema.md` | [date] | DB schema, drift, DB-level rules |
| `module-inventory.md` | [date] | Module details, LOC, entry points |
| `hidden-coupling.md` | [date] | Non-obvious coupling patterns |
| `implicit-assumptions.md` | [date] | Magic numbers, hardcoded values |
| `dead-code-candidates.md` | [date] | Unused functions/methods |
| `technical-debt-register.md` | [date] | TODO/HACK/FIXME items |
| `risk-priority-map.md` | [date] | File-level risk × coverage ranking |
