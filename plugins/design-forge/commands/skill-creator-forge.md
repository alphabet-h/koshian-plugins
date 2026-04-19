---
description: フリー入力 + Q&A 駆動でデザイン用エージェントスキルを作成する。業種を問わない汎用版。design-kit（テンプレ駆動、v0.1 は Web/IT 寄り）と並列配布。
allowed-tools: [Bash, Read, Write, Edit, Glob, WebFetch, AskUserQuestion]
---

# /skill-creator-forge

`design-forge` プラグインの `skill-creator-forge` スキルを起動する。

スキルが対話形式で以下を進める:
1. ペルソナ抽出（フリー入力）
2. 自動分類（Generator / Auditor / Process / Hybrid）
3. 動的質問生成（question-bank 駆動）
4. 構造提案 + 調整
5. SKILL.md 生成
6. 出力先選択（project-local / user-global / plugin）
7. skill-creator 検出時、eval ループ実行確認

詳細は、ロード済みスキル本体（`skill-creator-forge`）の SKILL.md を参照。
