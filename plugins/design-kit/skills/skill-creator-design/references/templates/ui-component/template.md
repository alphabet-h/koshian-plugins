---
name: {{skill_name}}
description: {{stack}} で {{design_philosophy}} 美学の UI コンポーネントを生成する。「{{trigger_phrases}}」等で起動。
---

# {{skill_name}}

{{stack}} を使った UI コンポーネント生成に特化したスキル。**{{design_philosophy}}** 美学を一貫して適用する。

## 起動条件

ユーザの発話に以下が含まれたら起動:
- {{trigger_phrases}}

## 対象コンポーネント

{{components}}

## デザイン哲学: {{design_philosophy}}

このスキルは {{design_philosophy}} 美学を一貫して適用する。具体的には:

- **タイポグラフィ**: ジェネリックな Inter / Roboto を避け、{{design_philosophy}} に整合するフォントを選択
- **カラー**: 紫グラデーションのデフォルトを避け、意図ある色選択
- **レイアウト**: {{design_philosophy}} の特徴的な余白・配置パターンを守る
- **アニメーション**: 装飾でなく意図あるモーション

## 出力フォーマット

{{stack}} のシンタックスで完全動作するコンポーネントを返す。

- import 文を必ず含める
- アクセシビリティ属性 (aria-*) を必須
- レスポンシブ対応（モバイル 320px から確認）
- ダークモード対応（該当する場合）

## ワークフロー

1. ユーザの要件を聞き取る
2. {{design_philosophy}} の文脈で 2-3 のバリエーションをスケッチ（テキスト記述）
3. ユーザが選んだ方向で実装
4. **小さいサイズでの検証**を提案（モバイル幅・favicon 等、該当時）

## 失敗パターン（やらないこと）

- ジェネリックな AI デザインに退化する（Inter フォント + 紫グラデで安全策）
- アクセシビリティ属性を忘れる
- レスポンシブを考慮せずデスクトップ前提で書く
- {{design_philosophy}} と矛盾するスタイル選択（例: Brutalism なのにふわっとした影）

## references/

- `references/design-tokens.md` — 色・spacing・typography トークン定義（プロジェクトに合わせて編集）
- `references/component-examples/` — 実装例集（プロジェクトの既存コードから抜粋して追加）
