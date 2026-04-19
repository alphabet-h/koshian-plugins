---
description: テンプレート駆動でデザイン用エージェントスキルを作成する。UI Component / Brand Voice / Audit から選択、または自作テンプレを使用。
allowed-tools: [Bash, Read, Write, Edit, Glob, AskUserQuestion]
---

# /skill-creator-design

`design-kit` プラグインの `skill-creator-design` スキルを起動する。

スキルが対話形式で以下を進める:
1. テンプレート列挙（同梱 + ユーザ override）
2. テンプレ選択 (AskUserQuestion)
3. テンプレ固有質問
4. 出力先選択 (project-local / user-global / plugin)
5. ファイル生成
6. skill-creator 検出時、eval ループ実行確認

詳細は `${CLAUDE_PLUGIN_ROOT}/skills/skill-creator-design/SKILL.md` を参照。
