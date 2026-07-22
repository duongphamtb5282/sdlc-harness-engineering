<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Data Schema (Live Database)

Generated: [date]
Last updated: [date]
Source: [DB engine] — connection verified at runtime

Schema extracted from a live database connection and cross-referenced against code-level ORM models and query patterns.

> **Security note**: Connection credentials are never persisted in this file. Only schema structure is recorded.

---

## Summary

- Database engine: [PostgreSQL / MySQL / SQLite / SQL Server / MongoDB]
- Tables: [N]
- Views: [N] 
- Stored procedures/functions: [N]
- Foreign key relationships: [N] 
- Indexes: [N]
- Schema drift items: [N] (code vs database mismatches)
- Database-level business rules: [N]

---

## Tables

### [table_name]

- **Purpose**: [inferred from columns and relationships]
- **Row estimate**: [approximate count if available]
- **Columns**:
  | Column | Type | Nullable | Default | Constraints |
  |---|---|---|---|---|
  | [name] | [data type] | Y/N | [default value] | [PK / FK / UNIQUE / CHECK] |

- **Indexes**: [index name → columns, type (btree/hash/gin)]  
- **Foreign keys**:
  - [column] → [referenced_table].[referenced_column] [ON DELETE action]
- **Code mapping**: [ORM model / entity class if found] at [file:line] 

<!-- Repeat for each table --> 

---

## Views

### [view_name]

- **Base tables**: [tables referenced] 
- **Purpose**: [inferred from query]
- **Used by**: [code files that reference this view]

<!-- Repeat for each view -->  

---

## Stored Procedures & Functions

### [procedure_name]

- **Parameters**:
  | Name | Type | Direction | Default | 
  |---|---|---|---|
  | [param] | [type] | IN / OUT / INOUT | [default] |

- **Called from code**: [file:line] or ORPHANED (no callers found)
- **Tables accessed**: [list]  
- **Business logic**: [summary of what it does]  

<!-- Repeat for each procedure/function -->

--- 

## Schema Drift (Code vs Database)

Mismatches between what the code assumes and what the database actually has. 

| # | Item | In Code | In Database | Type | Risk |
|---|---|---|---|---|---|
| 1 | [column/table/constraint] | [code definition or "missing"] | [DB definition or "missing"] | column_missing / type_mismatch / constraint_gap / extra_column | HIGH / MEDIUM / LOW | 

<!-- Repeat for each drift item -->

---

## Database-Level Business Rules

Rules enforced at the database layer (constraints, triggers, computed columns, defaults). 

### DBR-[NNN] 

- **Type**: check constraint / trigger / computed column / default / unique constraint
- **Table**: [table_name] 
- **Column**: [column_name if applicable]
- **Rule**: [plain language description] 
- **SQL**: [constraint expression or trigger logic summary]
- **Code equivalent**: [found at file:line / missing / different — describe discrepancy] 
- **Risk if removed**: [what breaks] 

<!-- Repeat for each database-level rule -->
