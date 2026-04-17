# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [0.2.0] - 2026-04-18

### Changed

- Stop フックを prompt 型から command 型（`hooks/stop-reminder.sh`）へ置き換え。以下の条件で **サイレント終了** するようゲートを追加し、ループと空プロジェクトへの誤発火を解消:
  - `stop_hook_active=true` のとき（Stop フック自身による再起動時）
  - プロジェクトルートに `features.json` も `claude-progress.txt` も存在しないとき
- リマインド文言に「成果物の変更を伴わないターンでは停止してよい」旨を明示し、質問応答のみのターンでの不要な継続を抑制

## [0.1.1] - 2026-03-30

### Fixed

- Stop hook のファイルパス解決を改善 — Glob ツールによる明示的なファイル存在確認とプロジェクトルート（CWD）での検索指示を追加し、導入先プロジェクトで `features.json` / `claude-progress.txt` が見つからないエラーを修正

## [0.1.0] - 2026-03-26

Initial release.

### Added

- `/harness-init` コマンド — `features.json` と `claude-progress.txt` のスキャフォールド
- `evaluator` エージェント — 4軸スコアリングによる品質評価（PASS/FAIL 判定）
- `planner` エージェント — ブリーフからプロダクト仕様を策定
- `harness-guide` スキル — ハーネス設計ベストプラクティス（5社の知見統合）
- Stop フック — セッション終了時の `features.json` 更新・進捗記録リマインド
- マニュアル（`documents/harness-kit-manual.md`）
