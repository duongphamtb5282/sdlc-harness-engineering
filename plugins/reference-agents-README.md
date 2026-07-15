# Quarantined upstream agent prompts

These files are **maintainer reference only**. They are **not** registered in any plugin `plugin.json` and must **not** be loaded at runtime.

Canonical delivery agents: `agents/{role}/`  
Absorbed playbooks: `agents/{role}/references/`  
Map: [PLUGIN-AGENT-MAP.yaml](../../PLUGIN-AGENT-MAP.yaml)

After sync from upstream, run:

```bash
./scripts/quarantine-plugin-agents.sh
```
