---
title: "Design Skill Creator プラグイン v0.1 設計仕様"
date: 2026-04-19
status: design-approved
target-repo: "../claude-plugins"
plugins:
  - koshian-design-kit
  - koshian-design-forge
note: "本 spec は最終的に ../claude-plugins リポへ移管予定。移管後は本リポからは削除される。本リポ内の参照ドキュメント（knowledge-base/deep-dive/design-agent-skills/ 配下）へのリンクは移管時に解決不能になるため、このファイルでは記述ベースで残す。"
---

# Design Skill Creator プラグイン v0.1 設計仕様

## 1. 背景と目的

`knowledge-base/deep-dive/design-agent-skills/overview.md` で 12 カテゴリのデザイン用エージェントスキルを整理した結果、「**新規デザインスキルを作る専用のメタスキル**」が空白カテゴリだと判明。汎用 `skill-creator-max` / `skill-creator:skill-creator` は存在するが、デザイン特化観点（並列サブエージェント / show-don't-tell / brand トークン管理 / favicon 検証 等）が組み込まれていない。

本プラグインは「**デザインスキルを作るためのスキル**」を 2 アプローチで提供し、配布物として `../claude-plugins` リポにマージしてマーケットプレース経由で公開する。**両者を並列配布して使い勝手を A/B テスト**する目的を兼ねる。

## 2. 採択した方針（ブレインストーミングの結論）

| 決定事項 | 採用案 | 根拠 |
|---|---|---|
| **形態** | D（ガイド + eval ループ）+ skill-creator 未検出時は C（ガイド + テンプレ）にフォールバック | 配布スキルとしての完成度確保。skill-creator が無い環境でも動作 |
| **v0.1 のテンプレ範囲（kit 用）** | D（ハイブリッド: UI Component / Brand Voice / Audit） | 公式 Brand Voice ユースケースと差別化（既存の劣化版にしない） |
| **配布構成** | B（2 プラグイン並列） | マーケットプレース統計が自然な A/B テスト指標になる |
| **出力先** | D（ランタイムで AskUserQuestion） | `.claude/rules/skill-placement.md` の project-local デフォルト方針と整合 |
| **plugin 出力時の scope** | B/C をランタイム選択 | 標準 scaffold か marketplace 連携まで含むかをユーザに委ねる |
| **テンプレ拡張** | プラガブル（`templates/<name>/{template.md, metadata.yaml}` 規約 + user override） | フォーク不要で拡張可能、OSS として広がる |
| **プラグイン名** | `koshian-design-forge` / `koshian-design-kit`（統一プレフィックス） | 既存マーケットプレースとの命名衝突回避 |
| **スラッシュコマンド** | 両プラグイン共に `/create-design-skill`（`<plugin>:<command>` で名前空間分離） | `/create-skill` のサジェストでデザイン専用版に気付ける |
| **実装順序** | A（kit → forge） | 簡単な方を先に。共通部品を kit で作り forge で再利用 |
| **ライセンス** | MIT | 既存 `claude-nfd` / `harness-kit` に揃える |
| **非 IT 業種対応** | forge の `question-bank.md` に non-IT 例 2-3 件含める。kit は v0.1 では web 寄り（テンプレ自作で対応可能と README に明示） | 拡張性を残しつつ v0.1 のスコープを保つ |

## 3. アーキテクチャ全体

```
../claude-plugins/
├── .claude-plugin/
│   └── marketplace.json          # 既存に 2 行追記（forge, kit）
└── plugins/
    ├── koshian-design-kit/
    │   ├── .claude-plugin/plugin.json
    │   ├── README.md / LICENSE (MIT) / CHANGELOG.md
    │   ├── commands/
    │   │   └── create-design-skill.md
    │   └── skills/
    │       └── create-design-skill/
    │           ├── SKILL.md
    │           ├── references/
    │           │   ├── templates/
    │           │   │   ├── ui-component/{template.md, metadata.yaml}    # 完成度高
    │           │   │   ├── brand-voice/{template.md, metadata.yaml}     # 完成度高（業種非依存）
    │           │   │   └── audit/{template.md, metadata.yaml}           # 雛形 + TODO
    │           │   ├── output-targets.md
    │           │   └── eval-integration.md
    │           └── scripts/
    │               ├── scaffold-plugin.sh
    │               └── update-marketplace.sh
    └── koshian-design-forge/
        ├── .claude-plugin/plugin.json
        ├── README.md / LICENSE / CHANGELOG.md
        ├── commands/create-design-skill.md
        └── skills/create-design-skill/
            ├── SKILL.md
            └── references/
                ├── question-bank.md         # IT 中心 + non-IT 例 2-3 件
                ├── persona-categories.md
                ├── output-targets.md         # ★ kit から物理コピー
                ├── eval-integration.md       # ★ kit から物理コピー
                └── scripts/                  # ★ kit から物理コピー
                    ├── scaffold-plugin.sh
                    └── update-marketplace.sh
```

> 共通 references/scripts は **物理コピー**（プラグインは独立配布のため symlink 不可）。kit 完成時にそのままコピーして forge に組み込む。

## 4. kit のワークフロー（`/create-design-skill` 実行時）

```
[1] テンプレ列挙
    └─ Glob: ${CLAUDE_PLUGIN_ROOT}/skills/create-design-skill/references/templates/*/metadata.yaml
    └─ Glob: ~/.claude/design-skill-templates/*/metadata.yaml  (user override)
    └─ 両者をマージ（user 側で同名上書き）

[2] AskUserQuestion: テンプレ選択
    候補: UI Component / Brand Voice / Audit / [user 追加分...]

[3] テンプレ固有質問（metadata.yaml の questions[] を順次提示）

[4] AskUserQuestion: 出力先
    候補: project-local / user-global / plugin

[5] (plugin 選択時のみ) AskUserQuestion: scaffold 範囲
    候補: B (標準セット) / C (marketplace.json 連携込み)

[6] ファイル生成
    └─ template.md のプレースホルダ ({{name}}, {{trigger_phrases}} 等) を置換 → SKILL.md
    └─ references/, scripts/, assets/ の雛形ディレクトリ作成
    └─ (plugin 時) plugin.json + LICENSE + README + CHANGELOG (scaffold-plugin.sh)
    └─ (C 選択時) marketplace.json への追記 diff 提示 → 確認 → 反映

[7] skill-creator 検出
    └─ Glob: ~/.claude/plugins/cache/**/skill-creator/**/SKILL.md

[8] (検出時のみ) AskUserQuestion: eval 走らせる？
    候補: 今すぐ走らせる / 後で自分で走らせる（コマンド表示）/ スキップ

[9] サマリー表示
    └─ 作成されたファイル一覧 + 次のアクション提案
```

### 4.1 テンプレ規約（`templates/<name>/`）

- `template.md` — `{{placeholder}}` 形式の SKILL.md 雛形（mustache 風、依存ライブラリなし）
- `metadata.yaml` — name / description / use-case / questions[] / placeholders[]

### 4.2 v0.1 同梱テンプレ

| テンプレ | 完成度 | 質問項目（例） |
|---|---|---|
| **UI Component** | 高 | スキル名 / 対象スタック (Tailwind / shadcn / Vue) / デザイン哲学 / 必須コンポーネント領域 (Button, Modal, ...) |
| **Brand Voice** | 高（業種非依存） | スキル名 / 対象媒体 (PDF / Slide / メール / Web) / 主要色 (3 色 max) / フォント (見出し+本文) / トーン (formal / friendly / playful) |
| **Audit** | 雛形 + TODO（v0.2 拡充） | スキル名 / 監査対象 (Web / Code / Animation) / 採点方式 (S-F tier / 0-100 / pass-fail) |

## 5. forge のワークフロー（`/create-design-skill` 実行時）

```
[1] スキルの「ペルソナ」抽出 — フリー入力
    「どんなデザインタスクを Claude に任せたい？ 1-3 文で」

[2] 自動分類 + 確認 — AskUserQuestion
    候補: Generator / Auditor / Process / Hybrid

[3] 動的質問生成（question-bank.md 駆動）
    └─ ペルソナ + カテゴリで関連質問を 3-7 件抽出
    └─ AskUserQuestion で 1 件ずつ提示
    └─ 質問例:
       - トリガになる自然語フレーズ
       - 入力の典型例（user 発話サンプル 2-3 件）
       - 出力フォーマット（HTML / Markdown / SVG / PNG / その他）
       - 並列サブエージェント使う？
       - reference に置きたい資料（URL / 画像 / 既存スタイル）
       - 失敗パターン

[4] 構造提案
    └─ 集めた回答から SKILL.md の見出し構造を提案
    └─ 「以下の構造で作ろうと思いますが、調整しますか？」

[5] SKILL.md 生成
    └─ 構造に従って各セクションを埋める
    └─ references/ には [3] で URL 提示があれば WebFetch → ローカル保存

[6] 出力先 → scaffold → eval（kit と共通の references/scripts を使用）
```

### 5.1 question-bank.md の構造

カテゴリ毎に質問パターンを保持。v0.1 では:
- **IT 系**: Generator / Auditor / Process / Hybrid 各 5-10 質問
- **non-IT 例**: 建築の仕様書 / 法律の引用ルール / 教育の教材 — 各 3-5 質問（インスピレーション目的）

### 5.2 persona-categories.md

Generator / Auditor / Process / Hybrid の定義と判定ヒント。

## 6. 共通部品仕様（kit と forge で共有）

### 6.1 `output-targets.md`

3 出力先の AskUserQuestion + 各々の書き出しロジック:

| 出力先 | 書き出し先 | 補足処理 |
|---|---|---|
| **project-local** | `<cwd>/.claude/skills/<name>/` | `<cwd>` が git リポか確認、無ければ警告 |
| **user-global** | `~/.claude/skills/<name>/` | 全プロジェクト横断で利用可能になる旨を表示 |
| **plugin** | `<cwd>/plugins/<name>/skills/<name>/` | 続けて scaffold 範囲（B / C）を AskUserQuestion |

### 6.2 `eval-integration.md`

`Glob` で skill-creator 検出 → 検出時のみ eval 提案 → 未検出なら `/plugin install skill-creator@anthropic-skills` を促すヒント表示。

### 6.3 `scripts/scaffold-plugin.sh`

plugin.json + LICENSE (MIT) + README.md + CHANGELOG.md を生成。テンプレートはスクリプト内に embed。

### 6.4 `scripts/update-marketplace.sh`

出力先から親方向に `.claude-plugin/marketplace.json` を探索 → 見つかれば追記 diff を表示 → ユーザ確認 → 反映。見つからなければ警告して B 相当（plugin フォルダだけ作成）に fallback。

## 7. 実装計画

### Phase 1: kit 完成

1. `koshian-design-kit/.claude-plugin/plugin.json` + `LICENSE` (MIT) + `README.md` + `CHANGELOG.md`
2. `commands/create-design-skill.md`
3. `skills/create-design-skill/SKILL.md`（Section 4 のワークフロー）
4. 共通 references: `output-targets.md` / `eval-integration.md`
5. 共通 scripts: `scaffold-plugin.sh` / `update-marketplace.sh`
6. 3 テンプレ: `ui-component`（高）/ `brand-voice`（高）/ `audit`（雛形 + TODO）
7. `marketplace.json` への追記
8. CHANGELOG v0.1.0 リリースノート

### Phase 2: forge 着手（kit 完成後）

1. `koshian-design-forge/.claude-plugin/plugin.json` + 同梱 4 ファイル
2. `commands/create-design-skill.md`
3. `skills/create-design-skill/SKILL.md`（Section 5 のワークフロー）
4. 共通 references / scripts を kit から物理コピー
5. forge 固有: `question-bank.md` / `persona-categories.md`
6. `marketplace.json` への追記
7. CHANGELOG v0.1.0 リリースノート

### Phase 3: 動作確認

1. kit: UI Component を 1 個作って trigger 確認
2. forge: フリー入力から 1 個作って構造確認
3. eval ループ確認（skill-creator 入っている前提）
4. `claude-plugins/README.md` の表に 2 行追加

## 8. v0.1 でやらないこと（明示）

- `audit` テンプレの完成度高い実装（雛形 + TODO のみ）
- 非 IT 専用テンプレの同梱（forge の question-bank に例だけ）
- forge の question-bank の網羅（v0.1 は 10-15 件、v0.2 で 30+ に拡充）
- スキル間の自動相互参照（forge ⇔ kit）
- 国際化（README は日本語のみ、英語版は v0.2）
- Audit テンプレの本格実装（Vercel agent-skills 並みの監査エンジンは v0.2+）

## 9. 成功基準

- [ ] 両プラグインが `/plugin install` で正常インストールされる
- [ ] kit で UI Component スキルを生成し、生成された SKILL.md が trigger される
- [ ] kit で plugin 出力 + marketplace 連携を実行し、`marketplace.json` が正しく更新される
- [ ] forge でフリー入力から 1 つスキルを生成し、構造が妥当（≧ 70% のセクションが意味ある内容）
- [ ] skill-creator 未インストール環境でもクラッシュせず C 相当で完結
- [ ] テンプレ自作（user override）が動作（`~/.claude/design-skill-templates/<name>/` を置けば候補に出る）

## 10. リスクと緩和策

| リスク | 影響 | 緩和策 |
|---|---|---|
| **共通部の物理コピー by ハンド** で kit/forge 間の drift | バグ修正の二重作業 | v0.1.x で運用、v0.2 で sync スクリプトを検討 |
| **marketplace.json の自動書き換え**でユーザのカスタム編集を破壊 | 配布全体が壊れる | 必ず diff 表示 + 確認、2-way merge ではなく append のみ、JSON validate |
| **3 テンプレが既存スキルの劣化版**になる懸念 | v0.1 が学習教材以上の価値を持たない | Brand Voice を業種非依存設計にすることで差別化、Audit は v0.2 で本格化 |
| **forge の Q&A が長すぎてユーザ離脱** | 完成スキルが少ない | [4] の構造提案ステップで「もう作って」と離脱できるパスを設ける |
| **skill-creator 検出 Glob のパス変動**（プラグインキャッシュの構造変化） | eval 連携が動かない | パスパターンを設定可能に、検出失敗時は親切に説明 |

## 11. 次のステップ

設計承認後、`writing-plans` スキルで実装計画書を作成。実装は別セッションで `executing-plans` スキルを使って進める。

## 関連調査（移管前のローカル参照、移管時に剥離）

設計時に参照した本リポ `knowledge-base/deep-dive/design-agent-skills/` 配下の調査ノート:

- `overview.md` — デザインスキル全 12 カテゴリの整理。本プラグインが空白カテゴリ「メタスキル」を埋めることの根拠
- `skill-creator-tools.md` — `skill-creator-max` / `skill-creator:skill-creator` 等の既存メタスキル一覧と差別化ポイント
- `logo-designer-parallel-subagents.md` — Task tool で 3-5 サブエージェント並列起動のパターン（forge の question-bank に取り込む観点）
- `frontend-slides.md` — progressive disclosure 設計（kit の `references/templates/` 階層構造のモデル）

これらは ../claude-plugins へ移管後は外部参照不可になるため、本 spec 内に必要な要約を取り込んでいる。
