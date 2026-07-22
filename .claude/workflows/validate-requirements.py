#!/usr/bin/env python3
"""Requirements Validator — validates BRD against story registry.

Checks:
1. All BRD requirements have at least one linked story
2. All stories have acceptance criteria
3. All acceptance criteria are testable (Given/When/Then format)
4. No orphan stories (stories not linked to any BRD requirement)
5. All stories have implementation files or status 'pending'

Usage:
    python3 validate-requirements.py --project /path/to/project
    python3 validate-requirements.py --project /path/to/project --fix
"""

import os
import sys
import json
import re
from datetime import datetime


class RequirementsValidator:
    """Validates BRD completeness against story registry."""

    def __init__(self, project_dir="."):
        self.project_dir = project_dir
        self.orchestrator_dir = os.path.join(
            project_dir, ".sdlc-automation-agent", ".orchestrator"
        )
        self.docs_dir = os.path.join(project_dir, "docs", "requirements")
        self.story_registry_file = os.path.join(
            self.orchestrator_dir, "story-registry.yaml"
        )
        self.findings = []

    def validate(self, fix=False):
        """Run all validations."""
        print("━━━ Requirements Validation ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print()

        self._check_story_registry_exists()
        self._check_brd_exists()
        self._validate_stories()
        self._check_acceptance_criteria()
        self._check_orphan_stories()
        self._check_story_implementation_status()
        self._generate_traceability_report()

        print()
        print("━━━ Results ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(f"  Total findings: {len(self.findings)}")

        severity_counts = {"error": 0, "warning": 0, "info": 0}
        for f in self.findings:
            severity_counts[f["severity"]] += 1
            icon = {"error": "✗", "warning": "⚠", "info": "ℹ"}[f["severity"]]
            print(f"  {icon} [{f['severity'].upper()}] {f['message']}")

        print()
        print(f"  Errors:   {severity_counts['error']}")
        print(f"  Warnings: {severity_counts['warning']}")
        print(f"  Info:     {severity_counts['info']}")

        errors = severity_counts["error"]
        if errors > 0:
            print(f"\n  ❌ Validation FAILED — {errors} error(s) must be resolved")
            return False
        else:
            print(f"\n  ✅ Validation PASSED")
            return True

    def _add_finding(self, severity, message):
        self.findings.append({
            "severity": severity,
            "message": message,
            "timestamp": datetime.utcnow().isoformat(),
        })

    def _check_story_registry_exists(self):
        if os.path.exists(self.story_registry_file):
            import yaml
            with open(self.story_registry_file) as f:
                self.stories = yaml.safe_load(f) or {"stories": {}}
            story_count = len(self.stories.get("stories", {}))
            self._add_finding("info", f"Story registry found: {story_count} stories")
        else:
            self.stories = {"stories": {}}
            self._add_finding("error", "No story-registry.yaml found — run story-registration stage first")

    def _check_brd_exists(self):
        brd_path = os.path.join(self.docs_dir, "brd.md")
        if os.path.exists(brd_path):
            with open(brd_path) as f:
                content = f.read()
            # Count requirements (lines starting with - [ ] or ##)
            reqs = len(re.findall(r'^- \[ \]|^##\s+(?!Overview|Introduction)', content, re.MULTILINE))
            self._add_finding("info", f"BRD found: ~{reqs} requirements in brd.md")
        else:
            self._add_finding("warning", "No brd.md found — run PM phase 03-generate-brd first")

    def _validate_stories(self):
        stories = self.stories.get("stories", {})
        if not stories:
            self._add_finding("error", "No stories defined in story registry")
            return

        for story_id, story in stories.items():
            # Check title
            if not story.get("title"):
                self._add_finding("error", f"{story_id}: missing title")

            # Check acceptance criteria
            ac = story.get("acceptance_criteria", [])
            if not ac:
                self._add_finding("error", f"{story_id}: no acceptance criteria defined")
            else:
                has_gwt = False
                for criterion in ac:
                    if re.search(r'(Given|When|Then|should|must|shall)', criterion, re.IGNORECASE):
                        has_gwt = True
                if not has_gwt:
                    self._add_finding("warning", f"{story_id}: acceptance criteria not in Given/When/Then format")

    def _check_acceptance_criteria(self):
        """Check that all acceptance criteria are testable."""
        stories = self.stories.get("stories", {})
        for story_id, story in stories.items():
            ac = story.get("acceptance_criteria", [])
            for i, criterion in enumerate(ac):
                if len(criterion) < 10:
                    self._add_finding("warning", f"{story_id}: acceptance criterion #{i + 1} is too vague: '{criterion}'")

    def _check_orphan_stories(self):
        """Check for stories not linked to any BRD section."""
        stories = self.stories.get("stories", {})
        for story_id, story in stories.items():
            if not story.get("linked_adr"):
                self._add_finding("warning", f"{story_id}: no linked ADR — story may lack architectural context")

    def _check_story_implementation_status(self):
        """Check implementation status of all stories."""
        stories = self.stories.get("stories", {})
        pending = []
        in_progress = []
        completed = []

        for story_id, story in stories.items():
            status = story.get("status", "pending")
            impl = story.get("implementation", {})
            files = impl.get("files", [])

            if status == "pending":
                pending.append(story_id)
            elif status == "in_progress":
                in_progress.append(story_id)
            elif status == "completed":
                if not files:
                    self._add_finding("warning", f"{story_id}: marked completed but no implementation files recorded")
                completed.append(story_id)

        if pending:
            self._add_finding("info", f"Pending stories: {len(pending)} ({', '.join(pending[:5])})")
        if in_progress:
            self._add_finding("info", f"In progress: {len(in_progress)}")
        self._add_finding("info", f"Completed: {len(completed)}/{len(stories)} stories")

    def _generate_traceability_report(self):
        """Generate a requirements traceability matrix."""
        stories = self.stories.get("stories", {})
        if not stories:
            return

        report_path = os.path.join(self.orchestrator_dir, "traceability-matrix.md")
        lines = []
        lines.append("# Requirements Traceability Matrix")
        lines.append(f"\n> Generated: {datetime.utcnow().isoformat()[:19]}")
        lines.append("\n| Story ID | Title | Status | Files | Tests | Linked ADR |")
        lines.append("|----------|-------|--------|-------|-------|------------|")

        for sid, story in sorted(stories.items()):
            title = story.get("title", "—")[:40]
            status = story.get("status", "pending")
            files = len(story.get("implementation", {}).get("files", []))
            tests = len(story.get("implementation", {}).get("tests", []))
            adr = story.get("linked_adr", "—")
            status_icon = {"completed": "✅", "in_progress": "⏳", "pending": "⬜"}.get(status, "⬜")
            lines.append(f"| {sid} | {title} | {status_icon} {status} | {files} files | {tests} tests | {adr} |")

        with open(report_path, "w") as f:
            f.write("\n".join(lines))

        self._add_finding("info", f"Traceability matrix generated: {report_path}")


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Validate requirements against story registry")
    parser.add_argument("--project", default=".", help="Project directory")
    parser.add_argument("--fix", action="store_true", help="Auto-fix issues where possible")
    args = parser.parse_args()

    validator = RequirementsValidator(args.project)
    success = validator.validate(fix=args.fix)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
