# Changelog

## [0.1.0] - 2026-04-19

### Added
- Initial release of `design-kit` plugin
- `/skill-creator-design` slash command for template-driven design skill creation (named to sort next to `skill-creator:skill-creator` in suggestions)
- 3 templates: `ui-component` (full), `brand-voice` (full, industry-agnostic), `audit` (stub for v0.2)
- Pluggable template mechanism: drop a template in `~/.claude/design-skill-templates/<name>/` to add custom templates
- Three output destinations: project-local, user-global, plugin (with optional marketplace.json registration)
- Optional integration with `skill-creator:skill-creator` eval loop when detected
- Common scripts: `scaffold-plugin.sh`, `update-marketplace.sh` (shared with future `design-forge`)

### Requirements
- Python 3.6+ (used by `scaffold-plugin.sh` / `update-marketplace.sh` for JSON I/O). See README.
- Future: planned migration to bash + jq or a zero-dep alternative in v0.2+.

### Verified
- End-to-end manual verification 2026-04-19 on Windows 11 / Git Bash:
  - Marketplace register + install via local path (renamed to `koshian-plugins-dev` during testing)
  - `/skill-creator-design` launches, template list enumerates, ui-component flow generates a project-local skill
  - Plugin output mode: `standard` scaffold creates plugin.json / LICENSE / README / CHANGELOG
  - Plugin output mode: `with-marketplace` runs scaffold + dry-run preview + AskUserQuestion confirm + `--yes` write without errors
  - `find_marketplace_root` snippet resolves correctly (exit 0 after the `return`→`exit` fix)
  - `<PLUGIN_ROOT>` placeholder resolves cleanly after Step 0 guidance is added
