<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Coverage Ratchet Protocol

Active when `brownfield.coverage_ratchet: true` in `.sdlc-automation-agent.yaml`.

## Purpose

Ensure that code modifications on brownfield projects never decrease test coverage. Coverage can only increase or stay the same — never go backwards. This is enforced through agent behavior, not hard blocking.  

## Rules for Code-Modifying Agents

Software Engineer, Software Engineer [frontend mode], and any agent performing remediation MUST follow these rules when modifying existing source files: 

### Before Modifying a Source File 

1. Check if the file has a corresponding test file (same name with test/spec suffix, or test in same directory)
2. If test file exists: read it, understand what's covered, run tests to verify baseline 
3. If NO test file exists AND file is in the coverage baseline (`reverse-engineering/coverage/coverage-baseline.json`):
   - Write at minimum one characterization test that captures the file's current observable behavior BEFORE making any production code change
   - Mark the test: `// CHARACTERIZATION TEST — captures existing behavior as of [date]`
   - The test asserts what the code DOES, not what it SHOULD do

### After Modifying a Source File

1. Run all tests that cover the modified file
2. Verify no existing tests broke (zero regressions)
3. If you changed behavior that a characterization test captured: update the test only if the behavior change is intentional and part of the current task

### Coverage Direction

- Coverage percentage for a modified file must be >= the baseline recorded in `reverse-engineering/coverage/coverage-baseline.json`
- If baseline data does not exist (Discover mode was never run), apply the spirit of the protocol: check for tests before modifying, add tests alongside changes

## Enforcement Level

- **BLOCK** (for modified files): If a source file has existing test coverage in the baseline and your changes cause coverage to decrease, you MUST add tests to restore coverage before proceeding. Log the coverage delta in your receipt. This is a hard stop — do not mark the task complete with decreased coverage on files that had coverage.
- **WARN** (for files without baseline): If a file has no entry in the coverage baseline (never measured), log a warning and proceed. Write characterization tests when practical.  

## Greenfield Coverage Minimum  

For **new code** (files that did not exist before this task):
- Every new service module must have at least one corresponding test file 
- Minimum coverage target: 70% line coverage on new files containing business logic (handlers, services, repositories, validators) 
- Excluded from minimum: configuration files, type definitions, generated code, boilerplate wiring
- Enforcement: WARN — log coverage for new files in the receipt. The QE agent will flag gaps during VERIFY if coverage is insufficient.

## Reading the Baseline 

``` 
Read: .sdlc-automation-agent/reverse-engineering/coverage/coverage-baseline.json
```

Schema:  
```json
{
  "generated_at": "ISO timestamp",
  "files": { 
    "<relative file path>": {
      "coverage_percent": 0, 
      "risk_tier": "P1 | P2 | P3",
      "has_characterization_tests": false, 
      "last_measured": "ISO timestamp" 
    } 
  }
}
```

## What This Protocol Does NOT Do

- Does not require 100% coverage  
- Does not apply to configuration, documentation, or test files themselves
- Does not block initial file creation — only blocks decreased coverage on files that had measured coverage
