---
name: trap-search
description: Search the trap-book KB for pitfalls or strategies matching a query. Calls kb-mcp search with the user-supplied query and renders results inline.
allowed-tools: Bash(kb-mcp:*)
disable-model-invocation: false
argument-hint: "<search query>"
---

# /trap-search

Search `~/.claude-trap-book/` for relevant entries.

## Procedure

1. Run:

   ```bash
   kb-mcp search "${ARGUMENTS}" --kb-path ~/.claude-trap-book --format text --limit 5
   ```

2. If results are empty, tell the user "no matching traps found".
3. If results are non-empty, render them verbatim. Each entry carries its `status` in the frontmatter — point out which are `auto_extracted` (unreviewed) vs `verified`.

## Notes

- The user is asking, so this is explicit intent — never filter by `project` scope automatically.
- Do NOT invoke the trap-extractor subagent from this command.
