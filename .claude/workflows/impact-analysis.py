#!/usr/bin/env python3
"""Impact Analysis — traces which user stories touch which files.

Given a file path, shows all stories that modified it.
Given a story ID, shows all files it touches.

Usage:
    python3 impact-analysis.py --file services/auth/src/login.ts --project .
    python3 impact-analysis.py --story US-001 --project .
    python3 impact-analysis.py --report --project .    # Full impact report
"""

import os
import sys
import json
from datetime import datetime


class ImpactAnalyzer:
    """Traces relationships between user stories and implementation files."""

    def __init__(self, project_dir="."):
        self.project_dir = project_dir
        self.orchestrator_dir = os.path.join(
            project_dir, ".sdlc-automation-agent", ".orchestrator"
        )
        self.story_file = os.path.join(self.orchestrator_dir, "story-registry.yaml")
        self.index_file = os.path.join(self.orchestrator_dir, "file-story-index.json")
        self.stories = self._load_stories()
        self.index = self._build_index()

    def _load_stories(self):
        import yaml
        if os.path.exists(self.story_file):
            with open(self.story_file) as f:
                data = yaml.safe_load(f) or {}
            return data.get("stories", {})
        return {}

    def _build_index(self):
        """Build reverse index: file_path → [story_ids]"""
        index = {}
        for sid, story in self.stories.items():
            impl = story.get("implementation", {})
            for f in impl.get("files", []):
                index.setdefault(f, []).append(sid)
            for t in impl.get("tests", []):
                index.setdefault(t, []).append(sid)
        # Persist index for fast lookup
        os.makedirs(self.orchestrator_dir, exist_ok=True)
        with open(self.index_file, "w") as f:
            json.dump(index, f, indent=2)
        return index

    def by_file(self, file_path):
        """Find all stories that touch a given file."""
        # Normalize path
        file_path = file_path.replace("\\", "/")
        # Check exact match
        stories = self.index.get(file_path, [])
        # Check prefix match (directory-level)
        prefix_stories = []
        for indexed_file, sids in self.index.items():
            if file_path in indexed_file or indexed_file.startswith(file_path.rstrip("/")):
                for sid in sids:
                    if sid not in stories:
                        prefix_stories.append(sid)
        stories.extend(prefix_stories)

        if stories:
            print(f"\n━━━ Impact: {file_path} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            for sid in sorted(set(stories)):
                story = self.stories.get(sid, {})
                title = story.get("title", "—")
                status = story.get("status", "unknown")
                print(f"  {sid}: {title}")
                print(f"         Status: {status}")
                print()
        else:
            print(f"\n  No stories found for: {file_path}")
            print("  (Run story-registration stage first to build the index)\n")

    def by_story(self, story_id):
        """Show all files touched by a given story."""
        story = self.stories.get(story_id)
        if not story:
            print(f"\n  Story {story_id} not found in registry\n")
            return

        print(f"\n━━━ {story_id}: {story.get('title', '—')} ━━━━━━━━━━━━━━━━━━━\n")
        print(f"  Status: {story.get('status', 'pending')}")
        print(f"  Linked ADR: {story.get('linked_adr', '—')}")
        print()

        impl = story.get("implementation", {})
        files = impl.get("files", [])
        tests = impl.get("tests", [])

        if files:
            print("  Implementation files:")
            for f in files:
                print(f"    • {f}")
        else:
            print("  Implementation files: (none)")

        if tests:
            print(f"\n  Test files ({len(tests)}):")
            for t in tests:
                print(f"    • {t}")
        else:
            print("\n  Test files: (none)")

        # Show reverse impact: what depends on this story's files
        print("\n  Affects files also touched by:")
        affected = set()
        for f in files:
            for other_sid, other_story in self.stories.items():
                if other_sid == story_id:
                    continue
                if f in other_story.get("implementation", {}).get("files", []):
                    affected.add(other_sid)
        if affected:
            for sid in sorted(affected):
                print(f"    ⚠ {sid}: {self.stories.get(sid, {}).get('title', '—')}")
        else:
            print("    (no overlapping files with other stories)")
        print()

    def full_report(self):
        """Generate a full impact analysis report."""
        print("\n━━━ Full Impact Analysis Report ━━━━━━━━━━━━━━━━━━━━━━━━━\n")
        print(f"  Stories tracked: {len(self.stories)}")
        print(f"  Files indexed: {len(self.index)}")
        print()

        # Stories with most files
        story_file_counts = []
        for sid, story in self.stories.items():
            count = len(story.get("implementation", {}).get("files", []))
            story_file_counts.append((count, sid, story.get("title", "")))
        story_file_counts.sort(reverse=True)

        print("  Top stories by file count:")
        for count, sid, title in story_file_counts[:5]:
            print(f"    {sid}: {count} files — {title[:50]}")

        # Files touched by multiple stories
        file_story_counts = [(len(sids), f) for f, sids in self.index.items()]
        file_story_counts.sort(reverse=True)

        shared = [(c, f) for c, f in file_story_counts if c > 1]
        if shared:
            print(f"\n  Shared files (touched by multiple stories): {len(shared)}")
            for count, f in shared[:5]:
                stories_list = ", ".join(self.index[f])
                print(f"    {f}")
                print(f"      → {stories_list}")

        # Unimplemented stories
        unimplemented = [
            (sid, s) for sid, s in self.stories.items()
            if not s.get("implementation", {}).get("files")
        ]
        if unimplemented:
            print(f"\n  Stories with no implementation files: {len(unimplemented)}")
            for sid, s in unimplemented[:5]:
                print(f"    ⬜ {sid}: {s.get('title', '—')[:50]}")

        print()


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Impact analysis: trace stories ↔ files")
    parser.add_argument("--file", help="File path to find impacting stories")
    parser.add_argument("--story", help="Story ID to show its files")
    parser.add_argument("--report", action="store_true", help="Full impact report")
    parser.add_argument("--project", default=".", help="Project directory")
    args = parser.parse_args()

    analyzer = ImpactAnalyzer(args.project)

    if args.file:
        analyzer.by_file(args.file)
    elif args.story:
        analyzer.by_story(args.story)
    elif args.report:
        analyzer.full_report()
    else:
        print("Usage: python3 impact-analysis.py --file <path> | --story <id> | --report")
        sys.exit(1)


if __name__ == "__main__":
    main()
