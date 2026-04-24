---
name: trap-setup
description: Initialize the trap-book knowledge base at ~/.claude-trap-book/, validate that kb-mcp is installed and ≥ v0.1.0, and print a copy-pasteable .mcp.json snippet.
allowed-tools: Bash(bash:*, ls:*, cat:*, test:*), Read
disable-model-invocation: true
---

# /trap-setup

Run the setup script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/bin/setup.sh"
```

Then display the output, including the `.mcp.json` snippet the user needs to add. If the script exits non-zero, surface the error and stop — do not attempt remediation.

After success, tell the user:

> Setup complete. Add the printed snippet to your `.mcp.json`, restart Claude Code, then you can start using `/trap-save`, `/trap-search`. Auto-extraction is **disabled by default**; set `TRAP_BOOK_AUTO_EXTRACT=1` in your shell environment when you are ready to enable it.
