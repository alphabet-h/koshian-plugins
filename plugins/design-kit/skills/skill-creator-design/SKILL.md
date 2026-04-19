---
name: skill-creator-design
description: 「デザインスキルを作って」「UI 生成スキルを作って」「ブランドボイスをスキル化したい」「監査スキル作って」「Claude にデザイン専門家になってほしい」等で起動。3 テンプレ（UI Component / Brand Voice / Audit）または自作テンプレから対話で選んで scaffold する。skill-creator が入っていれば eval ループも提案する。
---

# skill-creator-design (kit)

テンプレート駆動でデザイン用エージェントスキルを生成する。**ガイド + テンプレ scaffold + (検出時) eval ループ**のハイブリッド型。

## 全体ワークフロー

```
[1] テンプレ列挙 → [2] テンプレ選択 → [3] テンプレ固有質問
    → [4] 出力先選択 → [5] (plugin 時) scaffold 範囲選択
    → [6] ファイル生成 → [7] skill-creator 検出 → [8] (検出時) eval 提案
    → [9] サマリー
```

詳細ロジックは references/ に分離している。Step 4-5 と 7-8 の詳細処理はそれぞれ `references/output-targets.md` と `references/eval-integration.md` を参照すること。

## Step 1: テンプレ列挙

以下の 2 箇所から `metadata.yaml` を Glob で集める:

```
${CLAUDE_PLUGIN_ROOT}/skills/skill-creator-design/references/templates/*/metadata.yaml
~/.claude/design-skill-templates/*/metadata.yaml
```

両者をマージ。同名がある場合は user override（後者）を優先。

各 `metadata.yaml` から `name`, `description`, `use_case` を抽出して候補リストを作成。

## Step 2: テンプレ選択 (AskUserQuestion)

```
Question: 使うテンプレートを選んでください
Options:
  - ui-component (UI コンポーネント生成スキル)
  - brand-voice (ブランドボイス適用スキル)
  - audit (監査型スキル — v0.1 では stub)
  - <user override で見つかったもの>
```

選ばれたテンプレの `metadata.yaml` をロードする。

## Step 3: テンプレ固有質問

`metadata.yaml` の `questions[]` を順次 AskUserQuestion で提示:

- `type: text` → 自由入力
- `type: choice` → `choices` から選択（「自由入力」が含まれていれば、選択時に追加質問でテキスト取得）

回答を `placeholders` の各キーに対応する辞書に格納。

## Step 4: 出力先選択

`references/output-targets.md` の手順に従って AskUserQuestion を出す:

- project-local
- user-global
- plugin

選ばれた出力先に応じた事前チェックを実行。

## Step 5: (plugin 選択時のみ) scaffold 範囲選択

`references/output-targets.md` の plugin セクションに従って:

- standard: plugin.json + LICENSE + README + CHANGELOG だけ生成
- with-marketplace: standard + 親リポの marketplace.json に追記

with-marketplace 選択時は `find_marketplace_root` ヘルパで上方向探索。見つからなければ standard にフォールバックして警告。

## Step 6: ファイル生成

`template.md` を読み、`{{placeholder}}` を Step 3 の回答で置換:

```python
# 概念的な擬似コード（実際は Read + Write tool で実装）
template_content = read("templates/<chosen>/template.md")
for key, value in answers.items():
    template_content = template_content.replace("{{" + key + "}}", value)
write(output_path / "SKILL.md", template_content)
```

ディレクトリ構造（出力先共通）:

```
<output_root>/<skill_name>/
├── SKILL.md
├── references/      # 雛形のみ作成（空ディレクトリ + .gitkeep）
└── scripts/         # 雛形のみ作成（空ディレクトリ + .gitkeep）
```

plugin 出力時は加えて `${CLAUDE_PLUGIN_ROOT}/skills/skill-creator-design/scripts/scaffold-plugin.sh` を Bash ツールで実行:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/skill-creator-design/scripts/scaffold-plugin.sh \
  --output-dir "<cwd>/plugins/<plugin-name>" \
  --plugin-name "<plugin-name>" \
  --description "<plugin-description>" \
  --author "<from git config user.name or default 'unknown'>"
```

with-marketplace 選択時は続けて update-marketplace.sh を**必ず 2 段階**で呼ぶ:

1. `--yes` なしで実行 → dry-run モードで追記内容をプレビュー（ファイルは変更しない）
2. プレビューを AskUserQuestion でユーザに見せて承認を取る
3. 承認されたら `--yes` を付けて再実行 → 書き込み

`update-marketplace.sh` は `read -p` のような対話確認を持たない（Claude Code の Bash tool は非 TTY）。必ずこの 3 ステップ（dry-run → AskUserQuestion → --yes）を踏むこと。ユーザ確認を経ずにいきなり `--yes` を付けて呼ぶのは禁止。

## Step 7: skill-creator 検出

`references/eval-integration.md` の手順で Glob 検出:

```
~/.claude/plugins/cache/**/skill-creator/**/SKILL.md
```

## Step 8: (検出時のみ) eval 提案

`references/eval-integration.md` の AskUserQuestion 3 択を提示:

- run-now → サブエージェントとして `Skill(skill-creator:skill-creator)` を invoke
- show-command → コマンド表示のみ
- skip → 何もしない

未検出時は eval を提案せず、サマリ末尾に install ヒントを 1 行追加。

## Step 9: サマリー

パス記法:
- `<plugin_root>` = `<cwd>/plugins/<plugin-name>/`（plugin 出力時のみ）
- `<output_path>` = スキル本体の置き場所
    - project-local: `<cwd>/.claude/skills/<skill-name>/`
    - user-global:   `~/.claude/skills/<skill-name>/`
    - plugin:        `<plugin_root>/skills/<skill-name>/`  ← plugin_root 直下ではなく、必ず `skills/<skill-name>/` サブディレクトリ

最後に以下を表示:

```
✓ デザインスキル作成完了

作成ファイル:
  - <output_path>/SKILL.md
  - <output_path>/references/.gitkeep
  - <output_path>/scripts/.gitkeep
  (plugin 時)
  - <plugin_root>/.claude-plugin/plugin.json
  - <plugin_root>/LICENSE
  - <plugin_root>/README.md
  - <plugin_root>/CHANGELOG.md
  (with-marketplace 選択時)
  - <marketplace_root>/.claude-plugin/marketplace.json (updated)

次のアクション:
  1. SKILL.md を読んで意図通りの記述か確認
  2. references/ に補助資料を追加
  3. (任意) /plugin install で動作確認
  4. (skill-creator 入っていれば) eval ループで品質測定
```

## 中断時のリカバリ

ユーザが途中で AskUserQuestion を中断した場合:

- Step 1-3 で中断 → 何も作らずに終了
- Step 4-5 で中断 → 出力先未確定のためファイル生成しない
- Step 6 中で中断 → 部分的に作成されたファイルパスを表示し、削除コマンドを提示
- Step 7-9 で中断 → ファイル自体は作成済みなので、その旨表示して終了

## 関連 references

- `references/output-targets.md` — 出力先選択と各々の処理詳細
- `references/eval-integration.md` — skill-creator 検出と eval 提案
- `references/templates/<name>/` — 各テンプレートの定義
- `scripts/scaffold-plugin.sh` — プラグインフォルダ scaffold
- `scripts/update-marketplace.sh` — marketplace.json 追記
