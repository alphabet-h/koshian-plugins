# Changelog

## [0.1.0] - 2026-04-19

### Added
- Initial release of `design-forge` plugin
- `/skill-creator-forge` slash command for free-form Q&A driven design skill creation (named to sort next to `skill-creator:skill-creator` and `design-kit`'s `skill-creator-design`)
- **Any-industry positioning**: works for IT (Web / UI / アニメーション / 監査) and non-IT (建築 / 法律 / 教育 / ...) alike — the counterpart plugin `design-kit` ships v0.1 templates that are Web/IT-leaning, so `design-forge` covers anything that does not fit those templates
- Persona classification: Generator / Auditor / Process / Hybrid
- Dynamic question generation from `references/question-bank.md` (includes industry-agnostic patterns + concrete IT and non-IT examples)
- Three output destinations shared with `design-kit`: project-local, user-global, plugin (with optional marketplace.json registration)
- Optional integration with `skill-creator:skill-creator` eval loop when detected
- Common scripts and references copied from `design-kit` (`scaffold-plugin.sh`, `update-marketplace.sh`, `output-targets.md`, `eval-integration.md`)
- Intended as an A/B comparison counterpart to `design-kit`: users can try the same task through both and the marketplace install stats double as a usage preference signal

### Requirements
- Python 3.6+ (inherited from `design-kit` shared scripts). See README.
- Future: shared-part drift mitigation (sync script between kit and forge) planned for v0.2+.
