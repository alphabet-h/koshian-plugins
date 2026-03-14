# NFD Plugin for Claude Code

Nurture-First Development（NFD）ワークフローを Claude Code プラグインとしてパッケージ化したもの。

## 目次

- [概要](#概要)
- [インストール](#インストール)
- [コンポーネント](#コンポーネント)
- [使い方](#使い方)
- [設定](#設定)
- [参考文献](#参考文献)

## 概要

NFD は Linghao Zhang の論文 "[Nurture-First Agent Development](https://arxiv.org/abs/2603.10808)"（2026年3月）に基づく開発手法。AIエージェントを「書く」のではなく「育てる」アプローチで、日常の対話から得た経験を定期的に構造化知識に変換する **Knowledge Crystallization Cycle（KCC）** が核心。

### 3層の知識構造

| 層 | 役割 | Claude Codeでの実装 |
|----|------|-------------------|
| 憲法層 (Constitutional) | アイデンティティと根本原則 | CLAUDE.md + `.claude/rules/` |
| スキル層 (Skill) | タスク特化型の具体的機能 | `.claude/skills/` |
| 経験層 (Experiential) | 運用記録とケースメモリ | セッションログ + auto memory + NFDトレース |

このプラグインは、経験層からスキル層への昇華プロセス（結晶化）を体系化する。NFDの詳細な解説は [NFD方法論リファレンス](documents/nfd-methodology.md) を参照。

## インストール

### 1. マーケットプレイスを追加

```
/plugin marketplace add alphabet-h/koshian-plugins
```

### 2. プラグインをインストール

```
/plugin install claude-nfd@alphabet-h-koshian-plugins
```

インストール後、`/nfd-init` でNFD基盤を構築し、`/nfd-help` で次のステップを確認できます。

## コンポーネント

### `/nfd-init` コマンド

プロジェクトにNFDワークフローの基盤を構築する。

```
/nfd-init [nfd-dir-path]
```

- NFDディレクトリの作成（デフォルト: `.nfd/`）
- 初期ファイル（README.md、config.md、crystallization-log.md）の生成
- `traces/`、`crystals/`、`metrics/` サブディレクトリの作成
- 独立Gitリポジトリの初期化
- 親リポジトリの `.gitignore` への追加提案

### `/nfd-help` コマンド

NFDワークフローの現在の状態を自動診断し、次にすべきことを案内する。

```
/nfd-help
```

- NFD基盤の導入状態を自動判定
- データソースの設定状況を表示
- 結晶化の実行履歴と未統合パターンの確認
- 状態に応じた具体的な次のステップを提示

### `crystallize` スキル

経験データからパターンを抽出し、再利用可能な知識に変換する結晶化プロセス。

`/crystallize` または「結晶化して」「パターンを抽出して」等で起動。

**8ステップのプロセス:**

1. 設定読み込みと処理位置確認
2. データソースの収集
3. 並列抽出（サブエージェントによる分析）
4. 統合と重複排除
5. 過学習防止ガードと脱文脈化
6. 結晶化レポート出力
7. ログ更新とGit commit
8. 結果報告と人間検証

## 使い方

### 1. 基盤構築

```
/nfd-init
```

### 2. データソースの設定

生成された `config.md`（デフォルト: `.nfd/config.md`）のYAMLフロントマターを編集:

```yaml
---
nfd_dir: .nfd
data_sources:
  traces: .nfd/traces/               # NFDトレース
  auto_memory: true                   # Claude Code標準のauto memory
  session_logs: true                  # セッション会話ログ（JSONL）
  session_data: false                 # claude-mem MCP（インストール済みなら true に）
  custom:
    # decision_log: docs/decisions/  # プロジェクト固有のソースを追加
---
```

### 3. 結晶化の実行（サージカルワークスペース）

認知干渉を防ぐため、**日常の作業セッションとは別のセッション**で実行する:

```bash
# 新しいターミナルで（同じディレクトリでOK）
claude
/crystallize
```

結果は `crystals/YYYY-MM-DD-crystallization.md` に出力される。

> **ポイント**: デュアルワークスペースの「分離」とは認知コンテキスト（セッション）の分離であり、ファイルシステムの分離ではない。別ディレクトリに移動する必要はなく、同じディレクトリで新しいセッションを開くだけで十分。auto memory 等の共有リソースは両方のセッションからアクセスされることが設計上想定されている。詳しくは [NFD方法論リファレンス](documents/nfd-methodology.md#デュアルワークスペースパターン) を参照。

### 4. 知識の統合（ナーチャリングワークスペース）

日常の作業セッションに戻り、結晶化レポートを確認して有用なパターンを手動でルール/スキルに統合する。

## 設定

### config.md フロントマター

| フィールド | 型 | デフォルト | 説明 |
|-----------|------|-----------|------|
| `nfd_dir` | string | `.nfd` | NFDディレクトリのパス（`/nfd-init` の引数で指定した値） |
| `data_sources.traces` | string | `<nfd_dir>/traces/` | NFDトレースのディレクトリ |
| `data_sources.auto_memory` | boolean | `true` | Claude Code標準のauto memory（MEMORY.md + memory/） |
| `data_sources.session_logs` | boolean | `true` | Claude Codeのセッション会話ログ（JSONL） |
| `data_sources.session_data` | boolean | `false` | claude-mem MCPセッションデータの使用 |
| `data_sources.custom` | object | — | プロジェクト固有のデータソース（`名前: パス` のペア） |

### データソースの優先順位

1. **セッションログ**（デフォルト有効）— 全会話の生データ。6カテゴリすべてに対応する最もリッチなソース
2. **auto memory**（デフォルト有効）— 構造化された判断パターン・フィードバック・プロジェクト知識
3. **NFDトレース** — 日常の開発中に蓄積する構造化された気づき
4. **カスタムソース** — プロジェクト固有のドキュメント（設計判断ログ、振り返りメモ等）
5. **セッションデータ**（オプション）— claude-mem MCPが必要。インストールされていなくても動作する

## 参考文献

- [Nurture-First Agent Development](https://arxiv.org/abs/2603.10808) — Linghao Zhang, 2026年3月
