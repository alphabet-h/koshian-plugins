# Changelog

All notable changes to trap-book are documented here. Format: Keep a Changelog. Versioning: SemVer.

## [Unreleased]

### Fixed
- `skills/trap-book.md` was a flat file directly under `skills/`, which Claude Code does not
  auto-discover (that layout is for `commands/`; `skills/` requires `<name>/SKILL.md`).
  The skill was therefore never loaded — only the commands and the subagent were.
  Moved to `skills/trap-book/SKILL.md`.

## [0.1.0] - 2026-04-24

### Added
- Initial MVP release.
- `UserPromptSubmit` hook: kb-mcp search injection + `.queue/` consumption.
- `Stop` hook: resolution-signal detection with opt-in auto extract (`TRAP_BOOK_AUTO_EXTRACT=1`).
- `trap-extractor` Haiku subagent with self-critique checklist and kb-mcp dedup.
- Slash commands: `/trap-save`, `/trap-search`, `/trap-setup`.
- `kb-mcp-schema.toml` for frontmatter validation (`schema_version: 1`).
- `lib/redact.sh` masking 7 secret patterns (AWS/JWT/SSH/GCP/Bearer/api_key/password).
- Four-level opt-out: `[PRIVATE]` prefix, `.trap-book-ignore`, `TRAP_BOOK_DISABLE`, `config.json ignore_paths`.
- Layer-1 bats tests, fixture-driven.
- Append-only `metrics.jsonl` for `/trap-debug --stats` (v0.2).
