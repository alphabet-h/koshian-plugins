# harness-kit — Claude Code Plugin

Generator-Evaluator パターンによる長時間開発ハーネス。Anthropic の研究に基づくマルチエージェント品質保証ワークフローを提供する。

## 目次

- [概要](#概要)
- [インストール](#インストール)
- [コンポーネント](#コンポーネント)
- [使い方](#使い方)
- [設計の背景](#設計の背景)
- [参考文献](#参考文献)

## 概要

長時間の開発タスクにおいて、**生成と評価を構造的に分離**することで品質を担保するプラグイン。5社のプロダクションハーネスの研究（Anthropic, Manus, LangChain, OpenAI Codex, Stripe Minions）から抽出した知見に基づく。

核心のアイデア:
- **制約が自由より効果的** — エージェントの自由を拡張ではなく制限して成功させる
- **検証が生成と同等以上に重要** — 自己評価バイアスの構造的解決
- **外部アーティファクトがエージェントの記憶** — `features.json`、`claude-progress.txt`、git

## インストール

### 1. マーケットプレイスを追加

```
/plugin marketplace add alphabet-h/koshian-plugins
```

### 2. プラグインをインストール

```
/plugin install harness-kit@koshian-plugins
```

## コンポーネント

### `/harness-init` コマンド

プロジェクトに Generator-Evaluator ハーネスの管理ファイルをスキャフォールドする。

```
/harness-init
```

- `features.json` — 機能リストと完了状態（JSON で管理、LLM が壊しにくい）
- `claude-progress.txt` — 活動・決定の逐次ログ（append-only）
- CLAUDE.md へのワークフロー追記（確認あり）

### `evaluator` エージェント

成果物の品質を4軸（各1-10点、計40点満点）で評価し、PASS/FAIL を判定する。

```
「evaluator エージェントで品質チェックして」
```

**フロントエンド評価時:**

| 軸 | 内容 |
|---|---|
| Design Quality | 色・タイポグラフィ・レイアウトの一貫性 |
| Originality | AI っぽい汎用パターンへのペナルティ |
| Craft | 技術的実行品質 |
| Functionality | ユーザーがタスクを完遂できるか |

**バックエンド/フルスタック評価時:**

| 軸 | 内容 |
|---|---|
| Product Depth | 表示のみでなく実際に操作可能か |
| Functionality | API・DB・UI の連携 |
| Code Quality | 保守性・パフォーマンス・セキュリティ |
| Visual Design | UI の品質と一貫性 |

- 合計30点以上: **PASS**
- 合計30点未満: **FAIL** + 具体的改善リスト

Anthropic の研究では5〜15イテレーションで質的転換（創造的飛躍）が起きる場合がある。

### `planner` エージェント

短いブリーフから包括的なプロダクト仕様を策定する。

```
「planner エージェントで仕様作って: タスク管理アプリ」
```

### `harness-guide` スキル

ハーネス設計のベストプラクティスを提供するナレッジスキル。ハーネス設計に関する質問に自動で起動する。

### Stop フック

セッション終了時に以下を自動リマインド:
- `features.json` の status 更新
- `claude-progress.txt` への作業内容追記
- evaluator による品質チェックの提案

## 使い方

### 典型的なワークフロー

```
/harness-init                                  ← 管理ファイルを初期化
    ↓
「planner エージェントで仕様作って: {ブリーフ}」    ← 仕様策定
    ↓
仕様を確認・修正
    ↓
「この仕様に基づいて実装して」                     ← 通常の Claude Code で実装
    ↓
「evaluator エージェントで品質チェックして」         ← 品質評価
    ↓ FAIL
修正 → 再評価 → ... → PASS
    ↓
features.json の status を "passing" に更新
    ↓
次の機能へ
```

### セッション初期化プロトコル

新しいセッション開始時は `harness-guide` スキルが自動で案内する:

1. `pwd` で作業ディレクトリ確認
2. `claude-progress.txt` と `git log --oneline -20` を読む
3. `features.json` で次の優先タスク（status: `"failing"`）を特定
4. 開発サーバー起動
5. 既存機能の動作確認（リグレッション検出）
6. 新しい作業を開始

## 設計の背景

| 企業 | 核心の洞察 |
|---|---|
| **Anthropic** | 生成と評価の分離（GAN 着想） |
| **Manus** | KV キャッシュが全てを支配する |
| **LangChain** | ハーネスだけで +13.7pt 向上 |
| **OpenAI Codex** | 足場（scaffold）がプロダクト |
| **Stripe Minions** | 壁（制約）がモデルより重要 |

## 参考文献

- [Building effective agents — Anthropic](https://www.anthropic.com/engineering/building-effective-agents)
- [Context engineering for AI agents — Manus](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- [Harness Design in AI Coding Agents — LangChain](https://blog.langchain.dev/harness-design-in-ai-coding-agents-what-the-research-shows/)
- [Codex — OpenAI](https://openai.com/index/introducing-codex/)
- [How Stripe built an AI coding agent — Stripe](https://stripe.com/blog/how-stripe-built-an-ai-coding-agent)
