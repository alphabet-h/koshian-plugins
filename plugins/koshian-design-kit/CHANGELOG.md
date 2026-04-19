# Changelog

## [0.1.0] - 2026-04-19

### Added
- Initial release of `koshian-design-kit` plugin
- `/create-design-skill` slash command for template-driven design skill creation
- 3 templates: `ui-component` (full), `brand-voice` (full, industry-agnostic), `audit` (stub for v0.2)
- Pluggable template mechanism: drop a template in `~/.claude/design-skill-templates/<name>/` to add custom templates
- Three output destinations: project-local, user-global, plugin (with optional marketplace.json registration)
- Optional integration with `skill-creator:skill-creator` eval loop when detected
- Common scripts: `scaffold-plugin.sh`, `update-marketplace.sh` (shared with future `koshian-design-forge`)
