# design-kit

> テンプレート駆動でデザイン用エージェントスキルを作成する Claude Code プラグイン。

## 何ができるか

`/create-design-skill` を実行すると、対話形式で以下を聞かれ、デザインスキルを scaffold します:

1. 使うテンプレート（`ui-component` / `brand-voice` / `audit` / 自作テンプレ）
2. テンプレ固有の設定（スキル名、対象スタック、デザイン哲学など）
3. 出力先（プロジェクトローカル / ユーザーグローバル / プラグイン）
4. プラグイン出力時のスコープ（標準セット / マーケットプレース連携込み）

`skill-creator:skill-creator` プラグインがインストール済みなら、生成後に eval ループ実行を提案します。

## 同梱テンプレート（v0.1.0）

| テンプレ | 完成度 | 用途 |
|---|---|---|
| `ui-component` | 完成 | Tailwind / shadcn / Vue 等で UI コンポーネント生成スキルを作る |
| `brand-voice` | 完成（業種非依存） | PDF / スライド / メールに自社ブランドを適用するスキル |
| `audit` | 雛形 | 既存コード/デザインを採点するスキル（v0.2 で完成度向上） |

## インストール

```
/plugin marketplace add alphabet-h/koshian-plugins
/plugin install design-kit@koshian-plugins
```

## 自作テンプレートを追加する

`~/.claude/design-skill-templates/<your-template-name>/` に以下 2 ファイルを置けば、次回起動時にテンプレ候補に自動的に追加されます:

```
~/.claude/design-skill-templates/architecture-spec/
├── template.md       # SKILL.md 雛形（{{name}}, {{trigger_phrases}} 等のプレースホルダ付き）
└── metadata.yaml     # 質問項目定義
```

`metadata.yaml` の構造:

```yaml
name: architecture-spec
description: 建築の確認申請書テンプレを生成する
use_case: 建築事務所のデザインスキル
questions:
  - id: skill_name
    prompt: スキル名（kebab-case）
    type: text
  - id: target_office
    prompt: 設計事務所の特化分野（住宅 / 商業 / 公共 / 自由入力）
    type: choice
    choices: [住宅, 商業, 公共, 自由入力]
placeholders:
  - name
  - target_office
```

`template.md` 内で `{{name}}` `{{target_office}}` のように参照すると、実行時に置換されます。

## 姉妹プラグイン

`design-forge` — テンプレートに縛られず、フリー入力 + Q&A で動的にデザインスキルを構築するプラグイン。テンプレ化しにくい用途や、新ドメインのスキルを試作したい時に。

## ライセンス

MIT
