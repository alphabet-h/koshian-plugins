# trap-book

Self-learning pitfall / strategy knowledge base for Claude Code, powered by [kb-mcp](https://github.com/alphabet-h/kb-mcp).

Claude auto-extracts lessons from failure → resolution sessions, deduplicates via semantic search, and injects relevant past traps on the next implement-intent prompt. All local, no telemetry.

## Table of Contents

- [Install](#install)
- [How It Works](#how-it-works)
- [Commands](#commands)
- [Opt-out](#opt-out)
- [Roadmap](#roadmap)
- [Privacy](#privacy)

## Install

Prerequisites:
- `kb-mcp` v0.1.0+ ([install](https://github.com/alphabet-h/kb-mcp))
- `jq`, `perl`, `bash` 4+
- WSL / Git Bash on Windows

### 1. Add marketplace

```
/plugin marketplace add alphabet-h/koshian-plugins
```

### 2. Install the plugin

```
/plugin install trap-book@koshian-plugins
```

### 3. Initialize the KB

```
/trap-setup
```

This creates `~/.claude-trap-book/`, indexes it, and prints a `.mcp.json` snippet to add. Restart Claude Code after editing `.mcp.json`.

## How It Works

```
┌──── UserPromptSubmit hook ────┐     ┌──── Stop hook ────┐
│                               │     │                   │
│  (1) queue consumption        │     │  scan transcript  │
│  (2) kb-mcp search on         │     │  for resolution   │
│      implement-intent         │     │  signal           │
│                               │     │                   │
└──────────── ↓ ────────────────┘     └──────── ↓ ────────┘
   additionalContext                     .queue/*.json
          ↓
  main Claude → Agent(trap-extractor, haiku)
          ↓
  ~/.claude-trap-book/{pitfall,strategy}/*.md
          ↓
  kb-mcp file watcher re-indexes
```

## Commands

| Command | Purpose |
|---|---|
| `/trap-setup` | One-shot init (KB directory, schema, kb-mcp version check, `.mcp.json` snippet) |
| `/trap-save [pitfall\|strategy\|auto]` | Manually extract a lesson from the current session |
| `/trap-search <query>` | Search the KB via kb-mcp |

(v0.2.0 will add `/trap-review`, `/trap-debug`, `/trap-export`, `/trap-feedback`.)

## Opt-out

All four levels disable **hooks only** — slash commands always work.

| Level | Mechanism |
|---|---|
| Single turn | Start the prompt with `[PRIVATE]` |
| Project | Create `.trap-book-ignore` in the project root |
| All hooks off | `export TRAP_BOOK_DISABLE=1` |
| Auto-extract off | Leave `TRAP_BOOK_AUTO_EXTRACT` unset (default for v0.1.0) |

Additional: `config.json.ignore_paths[]` for path patterns.

## Roadmap

- **v0.1.0** (this release): manual `/trap-save`, injection on implement-intent, opt-in auto-extract.
- **v0.2.0**: auto-extract default-on, `/trap-review` batch UI, confidence decay, TTL deprecation, `/trap-debug`, `/trap-export`, `/trap-feedback`.
- **v1.0.0** (GA): ≥ 10 "useful injection" events over a month of dog-food, dedup hit-rate ≥ 30%.

## Privacy

- **Fully local**: kb-mcp runs offline. The only outbound traffic is the Haiku subagent call, which is part of normal Claude Code usage.
- **Secret masking**: 7 common patterns (AWS/JWT/SSH/GCP/Bearer/api_key/password) are redacted before any excerpt is persisted.
- **File permissions**: `chmod 700 ~/.claude-trap-book/` and `chmod 600` on each `.md`; enforced by `bin/setup.sh`.
- **Opt-out** (see above) affects hooks; manual commands always work.

## Acknowledgements

- [reshadat/self-learning-claude](https://github.com/reshadat/self-learning-claude) — Playbook pattern
- [BayramAnnakov/claude-reflect](https://github.com/BayramAnnakov/claude-reflect) — confidence scoring
- [MindStudio: Self-Evolving Claude Code Memory](https://www.mindstudio.ai/blog/self-evolving-claude-code-memory-obsidian-hooks) — Stop hook + vault pattern
- [Moses Njau: The Memory Problem in AI Agents](https://medium.com/data-unlocked/the-memory-problem-in-ai-agents-is-half-solved-heres-the-other-half-ebbf218ae4d5) — multi-agent critique motivation
