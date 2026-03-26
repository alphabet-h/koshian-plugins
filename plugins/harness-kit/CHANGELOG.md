# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.1.0] - 2026-03-26

Initial release.

### Added

- `/harness-init` コマンド — `features.json` と `claude-progress.txt` のスキャフォールド
- `evaluator` エージェント — 4軸スコアリングによる品質評価（PASS/FAIL 判定）
- `planner` エージェント — ブリーフからプロダクト仕様を策定
- `harness-guide` スキル — ハーネス設計ベストプラクティス（5社の知見統合）
- Stop フック — セッション終了時の `features.json` 更新・進捗記録リマインド
- マニュアル（`documents/harness-kit-manual.md`）
