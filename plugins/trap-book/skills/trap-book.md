---
name: trap-book
description: Use when the UserPromptSubmit hook has surfaced trap-book results, when the user references "trap-book" or past pitfalls, or when deciding whether to invoke the trap-extractor subagent after seeing a queue directive. Explains how to interpret status/confidence, dedup rules, and safety constraints.
---

# trap-book skill

trap-book is a self-learning KB of pitfalls (failure patterns) and strategies (success patterns) persisted at `~/.claude-trap-book/`, indexed by `kb-mcp`.

## When traps appear in additionalContext

If you see a section titled "過去の関連 trap (trap-book)":

- **`status: verified`** — trustable, use as strong prior
- **`status: auto_extracted`** — unreviewed extraction, confidence score tells you how much weight to give
- **`status: deprecated`** — do not use; a newer strategy superseded it
- **`confidence: >= 0.7`** — high-signal
- **`confidence: < 0.5`** — treat as a hint, verify before applying

Reference relevant traps in your reasoning but do not blindly copy solutions — the context may differ.

## When to invoke trap-extractor

The UserPromptSubmit hook sometimes emits a directive like:
> [trap-book] 直前セッションで解決シグナルが検出されました…

When you see that directive, do this:

1. Read the provided `<transcript-excerpt>`.
2. Decide if there is a generalizable lesson. If not — literally one-off typos, questions, or trivial fixes — do not invoke the subagent.
3. If yes, invoke:
   ```
   Agent(subagent_type="trap-extractor", model="haiku", prompt=<the excerpt>)
   ```
4. After it returns, relay the 1-line summary to the user only if the user will care (i.e. `wrote:` or `merged:`; don't bother surfacing `skip:`).

## Safety

- Never write to `~/.claude-trap-book/` directly. Always go through the subagent (which enforces schema) or let the user use `/trap-save` / `/trap-search`.
- Respect opt-outs: `.trap-book-ignore` in cwd, `[PRIVATE]` prefixes in prompts, `TRAP_BOOK_DISABLE=1`.
- Do not extract content containing secrets — the `lib/redact.sh` pass should have stripped them, but sanity-check the excerpt before forwarding to the subagent.

## Limitations (v0.1.0)

- Auto-extraction is opt-in (`TRAP_BOOK_AUTO_EXTRACT=1`). Without it, only `/trap-save` triggers extraction.
- No `/trap-review`, `/trap-debug`, or `/trap-export` commands yet (v0.2.0).
- No automatic confidence decay or TTL-based deprecation (v0.2.0).
- Windows users need WSL or Git Bash; native PowerShell is not supported.
