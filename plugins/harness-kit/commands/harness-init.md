---
name: harness-init
description: プロジェクトにハーネス管理ファイル（features.json、claude-progress.txt）をスキャフォールドする
---

# /harness-init

プロジェクトにGenerator-Evaluatorハーネスの管理ファイルを初期化する。

## 手順

### 1. 既存ファイルの確認

まずプロジェクトルートに以下が既に存在するか確認する:
- `features.json`
- `claude-progress.txt`

既に存在する場合は上書きせず、ユーザーに報告して終了する。

### 2. features.json の作成

プロジェクトの内容を Read/Glob で確認し、既存のコードベースから機能を推測して `features.json` を作成する:

```json
{
  "project": "{プロジェクト名}",
  "created": "{YYYY-MM-DD}",
  "features": [
    {
      "id": 1,
      "category": "core",
      "description": "{機能の説明}",
      "status": "failing",
      "verification": "{完了条件: 何をどう確認するか}"
    }
  ]
}
```

- 既にコードがある場合: 実装済み機能は `"passing"`、未実装は `"failing"` に設定
- 新規プロジェクトの場合: ユーザーにブリーフを聞き、plannerエージェントの利用を提案

### 3. claude-progress.txt の作成

```
# Progress Log
# プロジェクト: {プロジェクト名}
# 開始日: {YYYY-MM-DD}

## {YYYY-MM-DD}
- harness-kit 初期化完了
- features.json 作成（{N}件の機能を登録）
```

### 4. CLAUDE.md への追記提案

以下の内容をCLAUDE.mdに追記するか確認する:

```markdown
## 開発ワークフロー（harness-kit）

- `features.json` でタスク管理。実装完了した機能は status を "passing" に変更
- テストの削除・編集は禁止（機能が壊れる原因になる）
- 各機能の実装後は `evaluator` エージェントで品質チェック
- 進捗は `claude-progress.txt` に逐次記録（append-only）
- 新セッション開始時: progress確認 → features.json確認 → 次タスク特定
```

### 5. .gitignore の確認

`claude-progress.txt` をgit管理に含めるかユーザーに確認する（通常は含めて良い）。

### 6. 完了報告

```
harness-kit 初期化完了:
- features.json: {N}件の機能を登録
- claude-progress.txt: ログファイル作成
- CLAUDE.md: ワークフロー追記 {済/スキップ}

使い方:
- 「plannerエージェントで仕様を作成して」 → 仕様策定
- 「evaluatorエージェントで品質チェックして」 → 品質評価
- features.json の status を確認して次のタスクに着手
```
