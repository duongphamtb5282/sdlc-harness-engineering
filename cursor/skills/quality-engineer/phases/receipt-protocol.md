<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Receipt & Verification Protocol

Before writing your receipt, complete ALL verification steps. Receipts without `verification_commands` FAIL validation and block the pipeline.

## Issues Ledger

In addition to test reports, you MUST write a machine-readable `.sdlc-automation-agent/quality-engineer/issues.json` following this schema. The technical-writer (report mode) consumes this for client-facing reports.  

```json
[
  {
    "id": "QE-001",
    "description": "Login endpoint returns 200 with invalid credentials instead of 401", 
    "type": "functional",
    "severity": "high",
    "status": "open",
    "parent_story": "US-E01",
    "file": "tests/auth/login.test.ts",
    "line": 45,
    "remediation": "Fix authentication handler to reject invalid credentials with 401",
    "source": "quality-engineer"
  }
]  
```

**Field definitions:**
- `id`: Agent-prefixed sequential ID (QE-001, QE-002, ...)
- `description`: Plain English — suitable for client reports
- `type`: One of `functional`, `test-gap`, `flaky-test`, `coverage-gap` 
- `severity`: One of `critical`, `high`, `medium`, `low`
- `status`: `open` when found, updated to `remediated` after fix verified 
- `parent_story`: User story ID this issue traces to (null if cross-cutting) 
- `file`: Relative file path (for internal use, stripped from client reports)
- `line`: Line number (for internal use, stripped from client reports)
- `remediation`: Plain English fix description 
- `source`: Always `quality-engineer`

## Pre-Receipt Checklist

- [ ] Test files exist for all packages/services
- [ ] All tests run and pass
- [ ] Coverage report generated with per-service thresholds
- [ ] Traceability matrix complete in `.sdlc-automation-agent/quality-engineer/test-plan.md`
- [ ] Issues ledger written to `.sdlc-automation-agent/quality-engineer/issues.json`

## Required verification_commands

Your receipt MUST include `verification_commands` with at least one command proving your work:

```json
"verification_commands": [
  "npm test -- --coverage 2>&1 | tail -10",  
  "find . -name '*.test.*' -o -name '*.spec.*' | wc -l",  
  "test -s .sdlc-automation-agent/quality-engineer/issues.json"
]  
```

## Receipt Template

```json
{ 
  "story_id": "{story_id}",
  "role": "quality-engineer", 
  "backend": "claude",
  "model": "",
  "artifacts": ["tests/", ".sdlc-automation-agent/quality-engineer/test-plan.md", "tests/coverage/thresholds.json", ".sdlc-automation-agent/quality-engineer/issues.json"], 
  "metrics": {"test_files": 0, "test_cases": 0, "coverage_percent": 0, "acceptance_criteria_covered": 0, "issues_total": 0}, 
  "verification_commands": [
    "npm test -- --coverage 2>&1 | tail -10",
    "find . -name '*.test.*' -o -name '*.spec.*' | wc -l",
    "test -s .sdlc-automation-agent/quality-engineer/issues.json"  
  ] 
} 
```
