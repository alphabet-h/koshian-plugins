---
description: プロジェクトにNFD（Nurture-First Development）ワークフローの基盤を構築する
allowed-tools: Read, Write, Edit, Bash(git:*,mkdir:*,ls:*,test:*,cat:*), Glob, Grep, AskUserQuestion
argument-hint: [nfd-dir-path]
---

# NFD 基盤構築

プロジェクトに NFD（Nurture-First Development）ワークフローの基盤ディレクトリとファイルを構築する。

## 手順

### Step 1: NFDディレクトリのパスを決定

引数 `$ARGUMENTS` が指定されている場合はそのパスを使用する。
指定がない場合はデフォルトの `.nfd` を使用する。
以降、このパスを `<nfd-dir>` と表記する。

### Step 2: 既存のNFD環境を確認

`<nfd-dir>` が既に存在するか確認する。

- 存在する場合: AskUserQuestion で「既存のNFDディレクトリが見つかりました。上書きしますか？」と確認する。ユーザーが拒否した場合は中止する。
- 存在しない場合: 続行する。

### Step 3: ディレクトリ構造を作成

以下のディレクトリを作成する:

```
<nfd-dir>/
├── traces/       # 経験トレース（6カテゴリでタグ付け）
├── crystals/     # 結晶化の中間成果物
└── metrics/      # 計測データ（将来用）
```

### Step 4: 初期ファイルを生成

#### `<nfd-dir>/README.md`

以下の内容で作成する:

```markdown
# NFD（Nurture-First Development）

このディレクトリはNFDワークフローの経験データを管理する独立リポジトリです。

## 目次

- [ディレクトリ構造](#ディレクトリ構造)
- [使い方](#使い方)
- [経験トレースの6カテゴリ](#経験トレースの6カテゴリ)

## ディレクトリ構造

- `traces/` — 経験トレース（セッションごとの断片的な気づき）
- `crystals/` — 結晶化の中間成果物（パターン抽出結果）
- `metrics/` — 計測データ（将来用）
- `config.md` — データソース設定
- `crystallization-log.md` — 結晶化の進捗ログ

## 使い方

### 日常の運用（ナーチャリングワークスペース）

- 通常の開発セッションで作業する。経験は自動的に蓄積される（セッションログ、auto memory）
- 気づきがあれば `traces/` に手動で記録してもよい

### 結晶化の実行（サージカルワークスペース）

結晶化は **日常の作業セッションとは別のセッション** で実行することを推奨する。

1. 新しいターミナルまたは新規セッションで `/crystallize` を実行する
2. 結晶化の結果は `crystals/` に出力される
3. レポートを確認し、有用なパターンを日常セッションでルール/スキルに統合する

## 経験トレースの6カテゴリ

| カテゴリ | タグ | 記録する内容 |
|----------|------|-------------|
| 操作記録 | `[operational]` | 決定とアクションの事実 |
| 推論追跡 | `[reasoning]` | 判断の背後にあるロジックと前提条件 |
| パターン観察 | `[pattern]` | 繰り返し発生する事象の共通点 |
| 失敗原因 | `[error]` | 間違いの本質的理由と修正手順 |
| 文脈注釈 | `[context]` | プロジェクト背景やチーム固有の方針 |
| 洞察断片 | `[insight]` | 未整理だが将来重要になり得る気づき |
```

#### `<nfd-dir>/crystallization-log.md`

以下の内容で作成する:

```markdown
# 結晶化ログ

結晶化プロセスの実行履歴と、各データソースの処理位置を記録する。

## 処理位置

各データソースのインクリメンタル処理のために、前回の処理位置を記録する。

| データソース | 最終処理位置 | 最終処理日 |
|-------------|-------------|-----------|
| （未設定）   | —           | —         |

## 実行履歴

<!-- 結晶化を実行するたびに、以下の形式で記録される -->
<!-- ### YYYY-MM-DD 第N回結晶化 -->
<!-- - 入力ソース: ... -->
<!-- - 抽出パターン数: N -->
<!-- - 出力: crystals/YYYY-MM-DD-crystallization.md -->
```

#### `<nfd-dir>/config.md`

以下の内容で作成する（YAMLフロントマターで設定を管理）:

```markdown
---
nfd_dir: <nfd-dir の実際のパス>
data_sources:
  # 自動収集（デフォルトで有効）
  traces: <nfd-dir>/traces/
  auto_memory: true                  # Claude Code標準のauto memory（MEMORY.md + memory/）
  session_logs: true                 # Claude Codeのセッション会話ログ（JSONL）

  # オプション（外部ツール）
  session_data: false                # claude-mem MCPを使用する場合は true に変更

  # プロジェクト固有（任意に追加可能）
  custom:
    # 例:
    # decision_log: docs/decisions/
    # retrospectives: docs/retro/
    # dev_notes: notes/
---

# NFD 設定

## データソース

結晶化プロセスの入力となるデータソースを上のYAMLフロントマターで設定する。

### 自動収集ソース

- **traces**: NFDトレースのディレクトリ（デフォルト: `<nfd-dir>/traces/`）
- **auto_memory**: Claude Code標準のauto memory を使用するか（デフォルト: `true`）
  - プロジェクトの `MEMORY.md` と `~/.claude/projects/<project-hash>/memory/` 内のファイルを読み込む
- **session_logs**: Claude Codeのセッション会話ログを使用するか（デフォルト: `true`）
  - `~/.claude/projects/<project-hash>/*.jsonl` のセッション履歴を読み込む
  - 全会話の生データ（ツール呼び出し、判断、フィードバック等）が含まれる

### オプション（外部ツール）

- **session_data**: claude-mem MCPのセッションデータを使用するか（デフォルト: `false`）
  - claude-mem MCPをインストール済みの場合のみ `true` に変更する

### プロジェクト固有のカスタムソース

`custom` セクションに任意の `名前: パス` のペアを追加して、プロジェクト固有のデータソースを設定できる。パスは `${CLAUDE_PROJECT_ROOT}` からの相対パスで指定する。

例:
- 設計判断ログ: `decision_log: docs/decisions/`
- 振り返りメモ: `retrospectives: docs/retro/`
- 開発メモ: `dev_notes: notes/`
```

### Step 5: 独立Gitリポジトリを初期化

`<nfd-dir>` 内で `git -C "<nfd-dir>" init` を実行する。
初期ファイルをすべて add してコミットする:

```bash
git -C "<nfd-dir>" add -A
git -C "<nfd-dir>" commit -m "Initial NFD setup"
```

### Step 6: 親リポジトリの .gitignore を確認

親リポジトリの `.gitignore` に `<nfd-dir>` のパスが含まれているか確認する。

- 含まれていない場合: AskUserQuestion で「`.gitignore` に `<nfd-dir>` を追加しますか？NFDデータは個人的な経験データのため、親リポジトリに含めないことを推奨します。」と提案する。承認された場合は追加する。
- 含まれている場合: 何もしない。

### Step 7: ブートストラップ結晶化の提案

基盤構築が完了したら、以下を報告する:

1. 作成したディレクトリとファイルの一覧
2. 次のステップとして以下を提案:
   - 「`config.md` のフロントマターを編集して、プロジェクト固有のデータソースを設定してください」
   - 「既存の経験データがある場合は、新しいセッションで `/crystallize` を実行してブートストラップ結晶化を行えます（認知干渉を防ぐため、日常の作業セッションとは別のセッションでの実行を推奨します）」
   - 「日常の開発中に得た気づきは `traces/` ディレクトリに記録できます」

## 注意事項

- Gitコマンドは必ず `git -C "<nfd-dir>"` の形式で実行し、親リポジトリではなくNFDリポジトリに対して操作すること
- `cd` は使用しない
- パスにスペースが含まれる場合はダブルクォートで囲むこと
