---
name: {{skill_name}}
description: {{brand_name}} のブランドボイスを {{target_media}} に一貫適用する。色・フォント・トーンを統一。
---

# {{skill_name}} — {{brand_name}} Brand Voice

{{brand_name}} のブランド規定を成果物に自動適用する。対象媒体: {{target_media}}。

## ブランド規定

### カラー
- 主要色: {{primary_colors}}
- 上記以外の色を使う場合は、CSS カスタムプロパティとして宣言してから使用すること

### タイポグラフィ
- 見出し: **{{heading_font}}**
- 本文: **{{body_font}}**
- 上記 2 種以外のフォントを使うのは禁止（強調が必要な場合は太字・斜体・サイズで対応）

### トーン
**{{tone}}** で統一する。

#### 避ける表現

{{forbidden}}

## ワークフロー

1. ユーザから「何を作りたいか」を聞き取る
2. 対象媒体（{{target_media}} のいずれか）を確認
3. 上記ブランド規定を**全項目**満たす成果物を生成
4. 出力時に「ブランド規定チェック」を末尾に付ける:
   ```
   ✓ 色: {{primary_colors}} のみ使用
   ✓ フォント: {{heading_font}} / {{body_font}}
   ✓ トーン: {{tone}}
   ✓ 禁止表現の不使用を確認
   ```

## references/

- `references/brand-assets/` — ロゴ画像、テンプレ PDF 等を配置（任意）
- `references/voice-examples/` — 過去の良い成果物を「steal this」注釈付きで保存（推奨）
- `references/competitor-analysis.md` — 似たブランドとの差別化メモ（任意）

## 失敗パターン

- AI ジェネリックなフォントスタックに退化する（Inter / Roboto をデフォルト選択）
- 主要色以外を「アクセント」として勝手に追加する
- {{tone}} と矛盾する表現を混ぜる（例: friendly なのに「お問い合わせいただけますと幸甚です」）
- 禁止表現を忘れる

## 業種非依存

このスキルは Web に限らず、PDF / 印刷物 / スライド / メール / SNS 投稿でも使える。各媒体での具体的な実装は references/ に蓄積する。
