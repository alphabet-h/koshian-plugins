# design-forge

> フリー入力 + Q&A で動的にデザイン用エージェントスキルを生成する Claude Code プラグイン。**業種を問わず使えます**（IT も非 IT も）。

## 何ができるか

`/skill-creator-forge` を実行すると、テンプレートに縛られず、以下の対話フローでスキルを組み立てます:

1. **ペルソナ抽出** — 「どんなデザインタスクを任せたい？ 1-3 文で」フリー入力
2. **自動分類** — Generator / Auditor / Process / Hybrid のいずれかに分類 → ユーザ確認
3. **動的質問生成** — `question-bank.md` からペルソナ × カテゴリで 3-7 件の質問を抽出
4. **構造提案** — 回答から SKILL.md の見出し構造を提案 → ユーザ調整
5. **ファイル生成** — 構造に従ってセクションを埋め、references/ 雛形を作成

`skill-creator:skill-creator` プラグインがインストール済みなら、生成後に eval ループ実行を提案します。

## 姉妹プラグインとの使い分け

| プラグイン | 向いているケース |
|---|---|
| [`design-kit`](../design-kit/) | 定型パターン（UI Component / Brand Voice / Audit）で素早く作りたい。v0.1 では Web/IT 寄りのテンプレが中心 |
| **`design-forge`**（本プラグイン） | テンプレに収まらない新ドメイン、試作的なスキル、業種を問わずフリーフォームで組み立てたいとき |

両方インストールして用途で使い分けるのが推奨。同じ要件を両方で試して比較することで、どちらのアプローチが自分の用途に合うかが分かります（作者側も v0.1 時点ではマーケットプレースの利用統計を A/B 比較データとして活用する想定）。

## 対応業種のイメージ

v0.1 の `question-bank.md` は以下を想定してパターンを用意しています（あくまで例示、実際は自然語入力から動的に組み立てます）:

**IT / ソフトウェア系**:
- UI コンポーネント生成（Web / モバイル / デスクトップ）
- アニメーション / モーション監査
- アクセシビリティ / ブランド整合性チェック
- デプロイ / リリース手順の自動化

**IT 以外**:
- 建築事務所の確認申請書テンプレ
- 法律事務所の引用チェッカ
- 教育機関の教材テンプレート
- その他、設計知識を Claude に任せたい業務全般

業種専用のテンプレを同梱する代わりに、**フリー入力 + 動的質問** で柔軟に対応します。

## インストール

```
/plugin marketplace add alphabet-h/koshian-plugins
/plugin install design-forge@koshian-plugins
```

## 前提 (Requirements)

`design-kit` と同じく Python 3.6+ が必要（scaffold / marketplace 書き換えスクリプトで使用）。詳細は [design-kit の README](../design-kit/README.md#前提-requirements) を参照。

## question-bank の拡張

`references/question-bank.md` は IT / 非 IT 両方のサンプルを含む v0.1 スタートキットです。独自ドメイン向けに追加したい場合は、v0.1 では同ファイルに追記してプラグインを再ビルドする運用。v0.2 以降で `~/.claude/design-forge-questions/` からの user override を予定。

## ライセンス

MIT
