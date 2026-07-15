<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# OpenCode Backend Wrapper

> **Status:** Not yet implemented. Planned for Wave 5+.

## Overview

The OpenCode backend will dispatch work via the OpenCode CLI. It will support both sync and async execution modes, following the same dispatch contract as the Codex backend.  

## Current Action

If a role is configured with `backend: "opencode"`, the Orchestrator should: 

1. Report to the user:
   ```
   The OpenCode backend is not yet available in sdlc-automation-agent v2.0. 
   Falling back to Claude backend for {role_name}.
   
   To use an external backend now, configure Codex instead:
     agents:
       roles:  
         {role_name}: "codex"
   ```

2. Fall back to the Claude backend for this dispatch.
3. Record `"fallback_from": "opencode"` in the receipt.

## Future Implementation 

When implemented, the OpenCode wrapper will follow the same structure as `codex.md`:
- Prerequisite check (`opencode --version`)
- Prompt translation via `prompt_translator.py`
- Sync dispatch via `opencode` CLI
- Async dispatch via background process
- Receipt construction by Orchestrator 
