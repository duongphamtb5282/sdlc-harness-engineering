#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# generate-skill-profiles.py — Generate per-agent skill profiles
# (Tier 3) from SKILL-ROUTER.yaml (Tier 2).
#
# Each agent gets a compact profile at agent-v01/skills/profiles/
# listing ONLY its applicable skills — so an agent loads a small
# file instead of scanning inline tables.
#
# Usage: python3 agent-v01/scripts/generate-skill-profiles.py
# ═══════════════════════════════════════════════════════════════

import os
import sys

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML required — pip install pyyaml")
    sys.exit(1)

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROUTER = os.path.join(ROOT, "agent-v01", "SKILL-ROUTER.yaml")
PROFILES_DIR = os.path.join(ROOT, "agent-v01", "skills", "profiles")

def main():
    if not os.path.exists(ROUTER):
        print(f"ERROR: {ROUTER} not found")
        sys.exit(1)

    with open(ROUTER) as f:
        data = yaml.safe_load(f)

    os.makedirs(PROFILES_DIR, exist_ok=True)
    router = data.get("router", {})

    for persona, phases in router.items():
        # Collect all skills for this persona
        core_skills = []
        additional = []
        conditional = {}

        for phase, sections in phases.items():
            core_skills.extend(sections.get("core", []))
            additional.extend(sections.get("additional", []))
            if "conditional" in sections:
                conditional.update(sections.get("conditional", {}))
            if "stacks" in sections:
                conditional.update({"stacks": list(sections["stacks"].keys())})
            if "security" in sections:
                additional.extend(sections.get("security", []))

        profile = {
            "persona": persona,
            "phases": list(phases.keys()),
            "core_skills": sorted(set(core_skills)),
            "additional_skills": sorted(set(additional)),
            "conditional_skills": conditional,
            "total_skills": len(set(core_skills + additional)),
            "load_strategy": "lazy — load SKILL.md only when task matches",
        }

        out_path = os.path.join(PROFILES_DIR, f"{persona}.yaml")
        with open(out_path, "w") as f:
            yaml.safe_dump(profile, f, sort_keys=False, default_flow_style=False)
        print(f"  ✅ {persona}: {profile['total_skills']} skills → {os.path.relpath(out_path, ROOT)}")

    print(f"\nProfiles generated in {os.path.relpath(PROFILES_DIR, ROOT)}")

if __name__ == "__main__":
    main()
