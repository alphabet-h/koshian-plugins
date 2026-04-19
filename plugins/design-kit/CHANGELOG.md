# Changelog

## [0.1.0] - 2026-04-19

### Added
- Initial release of `design-kit` plugin
- `/create-design-skill` slash command for template-driven design skill creation
- 3 templates: `ui-component` (full), `brand-voice` (full, industry-agnostic), `audit` (stub for v0.2)
- Pluggable template mechanism: drop a template in `~/.claude/design-skill-templates/<name>/` to add custom templates
- Three output destinations: project-local, user-global, plugin (with optional marketplace.json registration)
- Optional integration with `skill-creator:skill-creator` eval loop when detected
- Common scripts: `scaffold-plugin.sh`, `update-marketplace.sh` (shared with future `design-forge`)

### Requirements
- Python 3.6+ (used by `scaffold-plugin.sh` / `update-marketplace.sh` for JSON I/O). See README.
- Future: planned migration to bash + jq or a zero-dep alternative in v0.2+.
