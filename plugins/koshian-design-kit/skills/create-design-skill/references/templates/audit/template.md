---
name: {{skill_name}}
description: {{target}} を {{scoring_method}} で採点する監査スキル。「{{trigger_phrases}}」で起動。
---

# {{skill_name}} — {{target}} Audit

> ⚠️ **このテンプレは v0.1 では stub です。**
> 採点ルールの定義部が骨組みのみ。Vercel agent-skills や Motion AI Kit を参考に、references/ に**監査ルール集**を追加してから本格運用してください。
> v0.2 で本格的な audit エンジンの雛形を提供予定。

## 監査対象

{{target}}

## 採点方式

{{scoring_method}}

## ワークフロー（雛形）

1. ユーザが指定したターゲット（ファイル / ディレクトリ / コードスニペット）を読む
2. `references/audit-rules.md` のルールを 1 つずつ照合
3. 違反を {{scoring_method}} で採点
4. レポート形式で出力:
   ```
   📊 Audit Report
   - 総項目: N
   - 違反: M (各項目の重大度別)
   - スコア: <{{scoring_method}} 形式の総合点>
   ```
5. 各違反に**修正案**を必ず添える

## 起動条件

{{trigger_phrases}}

## TODO（v0.2 拡充項目）

- [ ] `references/audit-rules.md` のルールテンプレート追加
- [ ] `references/scoring-rubric.md` で {{scoring_method}} の閾値を明文化
- [ ] `references/fix-patterns.md` で典型的修正パターン集
- [ ] サンプル audit レポート出力

## 既存の参考スキル

- **Vercel Web Design Guidelines** — 100+ ルールでの Web UI 監査の好例
- **Motion AI Kit `/motion-audit`** — S-F tier 分類で animation 性能採点
- **AccessLint** — WCAG 準拠性の自動監査
