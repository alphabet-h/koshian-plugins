---
title: "Legacy Declared"
id_style: categorical   # A-1 形式を許可
last_sweep: 2026-08-10
---

# Legacy Declared

## 検索精度の強化
_狙い。最終確認 2026-08-10_

| ID | 状態 | 名前 | 効果 | 難易度 | 制約 | 依存 | 備考 |
|---|:-:|---|:-:|:-:|:-:|---|---|
| A-5 | idea | Semantic chunking | 中 | 中 | ✅ | なし | 段落類似度で切る |
| A-9 | probing | LLM 生成 context のハイブリッド化 | 大 | 中 | ⚠️ | LLM | 条件: hook 経由なら ✅。詳細: [A-9](feature-ideas/A-9-hybrid-context.md) |

## UX 小粒
_狙い。最終確認 2026-08-10_

| ID | 状態 | 名前 | 効果 | 難易度 | 制約 | 依存 | 備考 |
|---|:-:|---|:-:|:-:|:-:|---|---|
| F-9 | frozen | Web UI redesign | 中 | 高 | ✅ | なし | 発火条件: Phase 2 の要望が出たら |

## 再評価キュー

| 期日 | ID | 何を判定するか | 判定材料 |
|---|---|---|---|
| 2026-08-01 | A-9 | 前処理を hook 経由にできるか | 2 週分の trial-log |

## 優先度ピック (2026-08-10 版)

1. **A-5 (Semantic chunking)** — 軽い

## 実装済み台帳

| ID | 名前 | 完了日 | 証跡 | 知見 |
|---|---|---|---|---|
| A-10 | FTS per-token phrase 分割 | 2026-08-12 | feature-48 / PR #134 / v0.16.0 | 実測で recall が想定の 2 倍動いた |

## 不採用の記録

| ID | 名前 | 判定日 | 理由 | 復活条件 |
|---|---|---|---|---|
| B-4 | MCP sampling で answer_question | 2026-08-10 | Claude Code が MCP sampling 非サポート | 主要クライアントが sampling に対応したら |
