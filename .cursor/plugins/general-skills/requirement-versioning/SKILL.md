---
name: requirement-versioning
description: Track requirement changes over time using git-based versioning of BRD, story registry, and acceptance criteria
---

# Requirement Versioning

Tracks changes to requirements, user stories, and acceptance criteria using git history.

## How It Works

All requirements artifacts are stored as files that can be version-controlled:

```
.sdlc-automation-agent/.orchestrator/
├── story-registry.yaml          # Current story state
├── story-registry-history/      # Archived versions (copied before each change)
│   ├── 2026-07-20-v1.yaml
│   ├── 2026-07-21-v2.yaml
│   └── ...
├── traceability-matrix.md       # Auto-generated traceability report
└── requirements-changelog.md    # Human-readable change log
```

## Commands

### Track a Change
```
Record requirement change:
  - What changed: Added story US-005 for password reset
  - Who approved: PM review 2026-07-20
  - Why: Security audit requirement
→ Appends to requirements-changelog.md
→ Archives current story-registry.yaml with date stamp
```

### Show History
```
Show requirement changes for US-001
→ Lists all versions of that story with timestamps
→ Shows what changed between versions (diff)
```

### Compare Versions
```
Compare story-registry v1 vs v2
→ Shows added/modified/removed stories
→ Shows changed acceptance criteria
```

## Integration

- **BRD changes**: Tracked via git on `docs/requirements/brd.md`
- **Story changes**: Tracked via `story-registry-history/` archive
- **Acceptance criteria**: Tracked per-story in the registry
- **ADRs**: Tracked via git on `docs/architecture/ADR-*.md`

## Commands

```bash
# Archive current state
cp .sdlc-automation-agent/.orchestrator/story-registry.yaml \
   .sdlc-automation-agent/.orchestrator/story-registry-history/$(date +%Y-%m-%d)-v{N}.yaml

# Show diff between versions
diff .sdlc-automation-agent/.orchestrator/story-registry-history/2026-07-20-v1.yaml \
     .sdlc-automation-agent/.orchestrator/story-registry-history/2026-07-21-v2.yaml

# Show git log for BRD
git log --oneline docs/requirements/brd.md
```
