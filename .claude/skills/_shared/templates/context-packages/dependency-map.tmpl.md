<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Dependency Map

Generated: [date]
Last updated: [date]
Source: Discover mode analysis

## Summary  

- Modules mapped: [N]
- Total dependencies: [N] 
- Hidden couplings: [N]
- Circular dependencies: [N] 

---

## Module: [module-name]

### Identity
- **Location**: [directory path]
- **Language/Framework**: [language, framework]
- **Purpose**: [1-2 sentence description derived from code, not guessed]
- **Entry points**: [controllers, handlers, main files]

### Dependencies (outbound)
| Target | Type | Contract | Fragility |
|---|---|---|---|
| [module/service] | api_call / shared_db / shared_lib / message_queue / file_system | [expected format/schema] | HIGH / MEDIUM / LOW |

### Depended on by (inbound)
| Source | Type | Notes |
|---|---|---|
| [module/service] | [type] | [notes] |

### Hidden Couplings
| Coupled With | Mechanism | Discovered Via | Risk If Changed | 
|---|---|---|---|
| [module] | [shared DB table / implicit ordering / polling / shared config] | [code pattern that revealed it] | [what breaks] |

### Database Access
- Tables owned: [list] 
- Tables shared with other modules: [list — THIS IS COUPLING] 

<!-- Repeat for each module -->

---

## Top 10 Highest-Risk Dependencies

| # | From | To | Type | Fragility | Why | 
|---|---|---|---|---|---|
| 1 | [module] | [module] | [type] | HIGH | [reason] | 
