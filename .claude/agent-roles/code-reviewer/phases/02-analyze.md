# Phase 2: Analyze

## Objectives
- Deep analysis of changed code
- Identify issues across multiple dimensions

## Dimensions
- **Correctness**: Logic errors, edge cases, race conditions
- **Security**: OWASP Top 10, injection, auth, data exposure
- **Performance**: N+1 queries, memory leaks, unnecessary allocations
- **Maintainability**: Code complexity, naming, duplication, testability
- **Architecture**: Conformance to ADRs, patterns, layering

## Activities
- Review each changed file line by line
- Cross-reference with existing patterns in codebase
- Check for test coverage gaps

## Outputs
- Findings list with severity (Critical/High/Medium/Low)
- File-level comments and suggestions
