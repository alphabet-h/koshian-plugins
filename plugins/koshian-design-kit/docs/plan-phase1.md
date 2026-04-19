# koshian-design-kit プラグイン v0.1.0 Implementation Plan (Phase 1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Claude Code 配布用プラグイン `koshian-design-kit` v0.1.0 を `../claude-plugins/plugins/koshian-design-kit/` に実装し、マーケットプレース登録まで完了させる。`/create-design-skill` で 3 テンプレ（UI Component / Brand Voice / Audit）から選んでデザインスキルを生成できる状態にする。

**Architecture:** Claude Code プラグイン形式（`.claude-plugin/plugin.json` + `commands/` + `skills/`）。SKILL.md がワークフローのオーケストレータとして templates/ から候補を Glob 列挙 → AskUserQuestion で対話 → 出力先決定 → ファイル生成 → skill-creator 検出時のみ eval 提案。共通部品（output-targets / eval-integration / scaffold-plugin / update-marketplace）は kit で完成させ、Phase 2 で forge に物理コピー再利用する。

**Tech Stack:** Markdown (SKILL.md, references/, templates/), Bash (scripts/), JSON (plugin.json, marketplace.json), YAML (metadata.yaml frontmatter)

**Spec:** `feature-idea/2026-04-19-design-skill-creator.md`

**Phase scope:** 本 plan は Phase 1（koshian-design-kit のみ）を扱う。Phase 2（koshian-design-forge）は kit 完成・動作確認後に別 plan として作成する。

---

## File Structure

新規作成:

```
../claude-plugins/plugins/koshian-design-kit/
├── .claude-plugin/
│   └── plugin.json                                # マニフェスト
├── LICENSE                                         # MIT
├── README.md                                       # 利用ガイド
├── CHANGELOG.md                                    # v0.1.0 リリースノート
├── commands/
│   └── create-design-skill.md                     # スラッシュコマンド起動
└── skills/create-design-skill/
    ├── SKILL.md                                    # メインワークフロー
    ├── references/
    │   ├── output-targets.md                      # 出力先選択ロジック
    │   ├── eval-integration.md                    # skill-creator 連携
    │   └── templates/
    │       ├── ui-component/
    │       │   ├── template.md                    # SKILL.md 雛形（プレースホルダ付き）
    │       │   └── metadata.yaml                  # 質問項目定義
    │       ├── brand-voice/
    │       │   ├── template.md
    │       │   └── metadata.yaml
    │       └── audit/
    │           ├── template.md                    # 雛形 + TODO（v0.2 拡充）
    │           └── metadata.yaml
    └── scripts/
        ├── scaffold-plugin.sh                     # plugin.json + LICENSE + README + CHANGELOG 自動生成
        ├── update-marketplace.sh                  # marketplace.json 追記（diff 確認付き）
        └── tests/
            ├── test-scaffold-plugin.sh            # bash アサーション
            └── test-update-marketplace.sh         # bash アサーション
```

修正:

```
../claude-plugins/.claude-plugin/marketplace.json    # plugins[] に koshian-design-kit を追加
../claude-plugins/README.md                          # 表に koshian-design-kit 行追加
```

**設計境界**:
- `SKILL.md` は薄いオーケストレータ（~150 行）。詳細ロジックは references/ に逃がす（progressive disclosure）
- `output-targets.md` と `eval-integration.md` は **Phase 2 で forge にコピーされる前提**で、kit 固有の文脈に依存させない
- `scripts/` は決定的処理（ファイル生成・JSON 操作）の外出し。SKILL.md からは `Bash` ツールで呼ぶ

---

## Task 1: プラグインマニフェスト (`plugin.json`)

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/.claude-plugin/plugin.json`

- [ ] **Step 1: ディレクトリを作成**

```bash
mkdir -p ../claude-plugins/plugins/koshian-design-kit/.claude-plugin
```

- [ ] **Step 2: plugin.json を書く**

ファイル内容:

```json
{
  "name": "koshian-design-kit",
  "version": "0.1.0",
  "description": "Template-driven creator for design-focused Claude Code skills (UI Component / Brand Voice / Audit). Sister plugin: koshian-design-forge for free-form Q&A driven creation.",
  "author": {
    "name": "koshian"
  },
  "repository": "https://github.com/alphabet-h/koshian-plugins",
  "keywords": ["skill-creator", "design", "ui-component", "brand-voice", "template"]
}
```

- [ ] **Step 3: JSON 構文チェック**

```bash
python -c "import json; json.load(open('../claude-plugins/plugins/koshian-design-kit/.claude-plugin/plugin.json'))" && echo OK
```

Expected output: `OK`

- [ ] **Step 4: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/.claude-plugin/plugin.json
git commit -m "feat(koshian-design-kit): add plugin manifest"
```

---

## Task 2: LICENSE と CHANGELOG

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/LICENSE`
- Create: `../claude-plugins/plugins/koshian-design-kit/CHANGELOG.md`

- [ ] **Step 1: LICENSE を書く（MIT）**

ファイル内容（`{YEAR}` は今年に置換）:

```
MIT License

Copyright (c) 2026 koshian

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 2: CHANGELOG.md を書く**

ファイル内容:

```markdown
# Changelog

## [0.1.0] - 2026-04-19

### Added
- Initial release of `koshian-design-kit` plugin
- `/create-design-skill` slash command for template-driven design skill creation
- 3 templates: `ui-component` (full), `brand-voice` (full, industry-agnostic), `audit` (stub for v0.2)
- Pluggable template mechanism: drop a template in `~/.claude/design-skill-templates/<name>/` to add custom templates
- Three output destinations: project-local, user-global, plugin (with optional marketplace.json registration)
- Optional integration with `skill-creator:skill-creator` eval loop when detected
- Common scripts: `scaffold-plugin.sh`, `update-marketplace.sh` (shared with future `koshian-design-forge`)
```

- [ ] **Step 3: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/LICENSE plugins/koshian-design-kit/CHANGELOG.md
git commit -m "docs(koshian-design-kit): add LICENSE (MIT) and CHANGELOG"
```

---

## Task 3: README.md

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/README.md`

- [ ] **Step 1: README.md を書く**

ファイル内容:

````markdown
# koshian-design-kit

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
/plugin install koshian-design-kit@koshian-plugins
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

`koshian-design-forge` — テンプレートに縛られず、フリー入力 + Q&A で動的にデザインスキルを構築するプラグイン。テンプレ化しにくい用途や、新ドメインのスキルを試作したい時に。

## ライセンス

MIT
````

- [ ] **Step 2: Markdown lint（任意、目視レビュー）**

ファイルを開いて見出し階層・コードブロックの言語指定・リンク切れを目視確認。

- [ ] **Step 3: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/README.md
git commit -m "docs(koshian-design-kit): add README"
```

---

## Task 4: スラッシュコマンド (`commands/create-design-skill.md`)

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/commands/create-design-skill.md`

- [ ] **Step 1: ディレクトリ作成**

```bash
mkdir -p ../claude-plugins/plugins/koshian-design-kit/commands
```

- [ ] **Step 2: スラッシュコマンドファイルを書く**

ファイル内容:

```markdown
---
description: テンプレート駆動でデザイン用エージェントスキルを作成する。UI Component / Brand Voice / Audit から選択、または自作テンプレを使用。
allowed-tools: [Bash, Read, Write, Edit, Glob, AskUserQuestion]
---

# /create-design-skill

`koshian-design-kit` プラグインの `create-design-skill` スキルを起動する。

スキルが対話形式で以下を進める:
1. テンプレート列挙（同梱 + ユーザ override）
2. テンプレ選択 (AskUserQuestion)
3. テンプレ固有質問
4. 出力先選択 (project-local / user-global / plugin)
5. ファイル生成
6. skill-creator 検出時、eval ループ実行確認

詳細は `${CLAUDE_PLUGIN_ROOT}/skills/create-design-skill/SKILL.md` を参照。
```

- [ ] **Step 3: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/commands/create-design-skill.md
git commit -m "feat(koshian-design-kit): add /create-design-skill command"
```

---

## Task 5: `scripts/scaffold-plugin.sh` とテスト

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/scaffold-plugin.sh`
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-scaffold-plugin.sh`

- [ ] **Step 1: ディレクトリ作成**

```bash
mkdir -p ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests
```

- [ ] **Step 2: テストファイルを先に書く（TDD）**

`scripts/tests/test-scaffold-plugin.sh`:

```bash
#!/bin/bash
# test-scaffold-plugin.sh — verify scaffold-plugin.sh produces correct file structure

set -euo pipefail

SCRIPT="$(dirname "$0")/../scaffold-plugin.sh"
TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

# Invoke the script with required args
bash "$SCRIPT" \
  --output-dir "$TMP/test-plugin" \
  --plugin-name "test-plugin" \
  --description "Test plugin description" \
  --author "test-author"

# Assertions
assert_file() {
  if [ ! -f "$1" ]; then
    echo "FAIL: missing $1"
    exit 1
  fi
}

assert_contains() {
  if ! grep -q "$2" "$1"; then
    echo "FAIL: $1 does not contain '$2'"
    exit 1
  fi
}

assert_file "$TMP/test-plugin/.claude-plugin/plugin.json"
assert_file "$TMP/test-plugin/LICENSE"
assert_file "$TMP/test-plugin/README.md"
assert_file "$TMP/test-plugin/CHANGELOG.md"

assert_contains "$TMP/test-plugin/.claude-plugin/plugin.json" '"name": "test-plugin"'
assert_contains "$TMP/test-plugin/.claude-plugin/plugin.json" '"description": "Test plugin description"'
assert_contains "$TMP/test-plugin/.claude-plugin/plugin.json" '"name": "test-author"'
assert_contains "$TMP/test-plugin/LICENSE" "MIT License"
assert_contains "$TMP/test-plugin/CHANGELOG.md" "## [0.1.0]"

# Validate JSON syntax
python -c "import json; json.load(open('$TMP/test-plugin/.claude-plugin/plugin.json'))"

echo "PASS: scaffold-plugin.sh creates valid plugin structure"
```

- [ ] **Step 3: テストが失敗することを確認**

```bash
bash ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-scaffold-plugin.sh 2>&1 | tail -3
```

Expected: エラー (`scaffold-plugin.sh` がまだ無い)

- [ ] **Step 4: `scaffold-plugin.sh` を実装**

`scripts/scaffold-plugin.sh`:

```bash
#!/bin/bash
# scaffold-plugin.sh — create plugin scaffold (plugin.json + LICENSE + README + CHANGELOG)

set -euo pipefail

# Parse args
OUTPUT_DIR=""
PLUGIN_NAME=""
DESCRIPTION=""
AUTHOR=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --plugin-name) PLUGIN_NAME="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --author) AUTHOR="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

# Validate
for var in OUTPUT_DIR PLUGIN_NAME DESCRIPTION AUTHOR; do
  if [ -z "${!var}" ]; then
    echo "Error: --${var,,} is required (use kebab-case)"
    exit 2
  fi
done

YEAR=$(date +%Y)
DATE=$(date +%Y-%m-%d)

mkdir -p "$OUTPUT_DIR/.claude-plugin"

# plugin.json
cat > "$OUTPUT_DIR/.claude-plugin/plugin.json" <<EOF
{
  "name": "${PLUGIN_NAME}",
  "version": "0.1.0",
  "description": "${DESCRIPTION}",
  "author": {
    "name": "${AUTHOR}"
  }
}
EOF

# LICENSE (MIT)
cat > "$OUTPUT_DIR/LICENSE" <<EOF
MIT License

Copyright (c) ${YEAR} ${AUTHOR}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# README.md (placeholder; user is expected to flesh out)
cat > "$OUTPUT_DIR/README.md" <<EOF
# ${PLUGIN_NAME}

${DESCRIPTION}

## Installation

\`\`\`
/plugin install ${PLUGIN_NAME}
\`\`\`

## License

MIT
EOF

# CHANGELOG.md
cat > "$OUTPUT_DIR/CHANGELOG.md" <<EOF
# Changelog

## [0.1.0] - ${DATE}

### Added
- Initial release of \`${PLUGIN_NAME}\` plugin
EOF

echo "Scaffolded plugin at: $OUTPUT_DIR"
```

- [ ] **Step 5: 実行権限を付与してテストを再実行**

```bash
chmod +x ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/scaffold-plugin.sh
chmod +x ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-scaffold-plugin.sh
bash ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-scaffold-plugin.sh
```

Expected: `PASS: scaffold-plugin.sh creates valid plugin structure`

- [ ] **Step 6: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/scripts/
git commit -m "feat(koshian-design-kit): add scaffold-plugin.sh with bash tests"
```

---

## Task 6: `scripts/update-marketplace.sh` とテスト

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/update-marketplace.sh`
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-update-marketplace.sh`

- [ ] **Step 1: テストファイルを先に書く（TDD）**

`scripts/tests/test-update-marketplace.sh`:

```bash
#!/bin/bash
# test-update-marketplace.sh — verify update-marketplace.sh appends correctly

set -euo pipefail

SCRIPT="$(dirname "$0")/../update-marketplace.sh"
TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

# Setup: fake marketplace.json
mkdir -p "$TMP/.claude-plugin"
cat > "$TMP/.claude-plugin/marketplace.json" <<'EOF'
{
  "name": "test-marketplace",
  "owner": {"name": "tester"},
  "metadata": {"description": "Test"},
  "plugins": [
    {
      "name": "existing-plugin",
      "source": "./plugins/existing-plugin",
      "description": "Existing"
    }
  ]
}
EOF

# Invoke (auto-confirm via env var to bypass interactive prompt)
DRY_RUN_AUTO_CONFIRM=1 bash "$SCRIPT" \
  --marketplace-root "$TMP" \
  --plugin-name "new-plugin" \
  --plugin-source "./plugins/new-plugin" \
  --plugin-description "New plugin description"

# Assertions
assert_contains() {
  if ! grep -q "$2" "$1"; then
    echo "FAIL: $1 does not contain '$2'"
    cat "$1"
    exit 1
  fi
}

assert_contains "$TMP/.claude-plugin/marketplace.json" '"name": "new-plugin"'
assert_contains "$TMP/.claude-plugin/marketplace.json" '"name": "existing-plugin"'

# Validate JSON syntax
python -c "import json; data = json.load(open('$TMP/.claude-plugin/marketplace.json')); assert len(data['plugins']) == 2"

echo "PASS: update-marketplace.sh appends new plugin entry"
```

- [ ] **Step 2: テストが失敗することを確認**

```bash
bash ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-update-marketplace.sh 2>&1 | tail -3
```

Expected: エラー (`update-marketplace.sh` がまだ無い)

- [ ] **Step 3: `update-marketplace.sh` を実装**

`scripts/update-marketplace.sh`:

```bash
#!/bin/bash
# update-marketplace.sh — append a new plugin entry to .claude-plugin/marketplace.json

set -euo pipefail

MARKETPLACE_ROOT=""
PLUGIN_NAME=""
PLUGIN_SOURCE=""
PLUGIN_DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --marketplace-root) MARKETPLACE_ROOT="$2"; shift 2 ;;
    --plugin-name) PLUGIN_NAME="$2"; shift 2 ;;
    --plugin-source) PLUGIN_SOURCE="$2"; shift 2 ;;
    --plugin-description) PLUGIN_DESCRIPTION="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

for var in MARKETPLACE_ROOT PLUGIN_NAME PLUGIN_SOURCE PLUGIN_DESCRIPTION; do
  if [ -z "${!var}" ]; then
    echo "Error: --${var,,} is required"
    exit 2
  fi
done

MARKETPLACE_FILE="$MARKETPLACE_ROOT/.claude-plugin/marketplace.json"

if [ ! -f "$MARKETPLACE_FILE" ]; then
  echo "Error: marketplace.json not found at $MARKETPLACE_FILE"
  echo "Hint: ensure --marketplace-root points to the marketplace repo root."
  exit 3
fi

# Check if plugin already registered
if python -c "
import json, sys
data = json.load(open('$MARKETPLACE_FILE'))
names = [p['name'] for p in data.get('plugins', [])]
sys.exit(0 if '$PLUGIN_NAME' in names else 1)
" 2>/dev/null; then
  echo "Plugin '$PLUGIN_NAME' is already registered in marketplace.json. No changes."
  exit 0
fi

# Show diff preview
NEW_ENTRY=$(python -c "
import json
entry = {
    'name': '$PLUGIN_NAME',
    'source': '$PLUGIN_SOURCE',
    'description': '$PLUGIN_DESCRIPTION'
}
print(json.dumps(entry, indent=2))
")

echo "About to append the following entry to $MARKETPLACE_FILE:"
echo "---"
echo "$NEW_ENTRY"
echo "---"

# Confirm (skip if DRY_RUN_AUTO_CONFIRM env var is set, used by tests)
if [ -z "${DRY_RUN_AUTO_CONFIRM:-}" ]; then
  read -p "Proceed? [y/N] " ANSWER
  if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "Aborted by user."
    exit 1
  fi
fi

# Append using python (preserves JSON formatting)
python -c "
import json
with open('$MARKETPLACE_FILE') as f:
    data = json.load(f)
data['plugins'].append({
    'name': '$PLUGIN_NAME',
    'source': '$PLUGIN_SOURCE',
    'description': '$PLUGIN_DESCRIPTION'
})
with open('$MARKETPLACE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
"

echo "Updated $MARKETPLACE_FILE"
```

- [ ] **Step 4: 実行権限を付与してテストを再実行**

```bash
chmod +x ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/update-marketplace.sh
chmod +x ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-update-marketplace.sh
bash ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/tests/test-update-marketplace.sh
```

Expected: `PASS: update-marketplace.sh appends new plugin entry`

- [ ] **Step 5: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/scripts/
git commit -m "feat(koshian-design-kit): add update-marketplace.sh with bash tests"
```

---

## Task 7: References — `output-targets.md`

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/output-targets.md`

- [ ] **Step 1: ディレクトリ作成**

```bash
mkdir -p ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references
```

- [ ] **Step 2: `output-targets.md` を書く**

ファイル内容:

````markdown
# Output Targets

スキル生成時の出力先を 3 択から選ばせる手順とロジック。SKILL.md からこのファイルを参照してフロー実行する。

## AskUserQuestion で 3 択提示

```
Question: 生成したスキルをどこに置きますか？
Options:
  - project-local (現在のプロジェクトの .claude/skills/ に配置、git 管理対象)
  - user-global (~/.claude/skills/ に配置、全プロジェクトで利用可)
  - plugin (./plugins/<name>/ にプラグインとして scaffold、配布用)
```

## 各出力先の処理

### project-local

書き出し先: `<cwd>/.claude/skills/<skill-name>/`

事前チェック:
1. `<cwd>` が git リポジトリか確認: `git -C <cwd> rev-parse --git-dir`
2. 失敗したら警告: 「git 管理外なのでバージョン管理されません。続行しますか？」と AskUserQuestion で確認

ディレクトリ構造:
```
<cwd>/.claude/skills/<skill-name>/
├── SKILL.md           # template.md のプレースホルダ置換結果
├── references/        # 雛形（ユーザが必要に応じて追加）
└── scripts/           # 雛形（ユーザが必要に応じて追加）
```

### user-global

書き出し先: `~/.claude/skills/<skill-name>/`

事前チェック:
1. 既存のスキル名と衝突していないか: `[ -d ~/.claude/skills/<skill-name> ]`
2. 衝突していたら AskUserQuestion で確認: 「同名スキルが既に存在します。上書き / 別名で作成 / 中止 ?」

完了後に表示: 「`~/.claude/skills/<skill-name>/` に作成しました。次回 Claude Code 起動時から全プロジェクトで利用可能です。」

### plugin

書き出し先: `<cwd>/plugins/<plugin-name>/`

追加質問:
1. AskUserQuestion で plugin-name を聞く（kebab-case、デフォルトは skill-name と同じ）
2. AskUserQuestion で description を聞く（plugin.json に入る）
3. AskUserQuestion で scaffold 範囲を聞く:
   - `B-standard` (plugin.json + LICENSE + README + CHANGELOG だけ生成、marketplace.json は触らない)
   - `C-with-marketplace` (B + 親リポの .claude-plugin/marketplace.json に追記)

実行手順:

```bash
# 1. plugin scaffold
bash ${CLAUDE_PLUGIN_ROOT}/skills/create-design-skill/scripts/scaffold-plugin.sh \
  --output-dir "<cwd>/plugins/<plugin-name>" \
  --plugin-name "<plugin-name>" \
  --description "<description>" \
  --author "<author from git config user.name or 'unknown'>"

# 2. skills/ 内に SKILL.md を生成（template.md 置換）
mkdir -p "<cwd>/plugins/<plugin-name>/skills/<skill-name>"
# ... (Write tool で SKILL.md を書き出す)

# 3. C-with-marketplace 選択時のみ:
#    親リポを上方向に探索して .claude-plugin/marketplace.json を見つける
MARKETPLACE_ROOT=$(find_marketplace_root "<cwd>")  # 後述ヘルパ
if [ -n "$MARKETPLACE_ROOT" ]; then
  bash ${CLAUDE_PLUGIN_ROOT}/skills/create-design-skill/scripts/update-marketplace.sh \
    --marketplace-root "$MARKETPLACE_ROOT" \
    --plugin-name "<plugin-name>" \
    --plugin-source "./plugins/<plugin-name>" \
    --plugin-description "<description>"
else
  echo "marketplace.json が見つかりませんでした。配布する場合は手動で登録してください。"
fi
```

## ヘルパ: marketplace 探索

`find_marketplace_root` 相当の処理は SKILL.md 内で次のように行う:

```bash
DIR="$(cd "$1" && pwd)"
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/.claude-plugin/marketplace.json" ]; then
    echo "$DIR"
    return 0
  fi
  DIR=$(dirname "$DIR")
done
return 1
```

見つからなかった場合は警告を出して B-standard 相当（marketplace 追記スキップ）に fallback する。
````

- [ ] **Step 3: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/references/output-targets.md
git commit -m "docs(koshian-design-kit): add output-targets reference"
```

---

## Task 8: References — `eval-integration.md`

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/eval-integration.md`

- [ ] **Step 1: `eval-integration.md` を書く**

ファイル内容:

```markdown
# Eval Integration

`skill-creator:skill-creator` プラグインがインストール済みなら、生成スキルの eval ループ実行を提案する。SKILL.md からこのファイルを参照する。

## 検出

Glob で skill-creator プラグインのインストールを確認:

```
~/.claude/plugins/cache/**/skill-creator/**/SKILL.md
```

または OS 別のパス:
- Linux/macOS: `~/.claude/plugins/cache/**/skill-creator/**/SKILL.md`
- Windows: `~/.claude/plugins/cache/**/skill-creator/**/SKILL.md` (Git Bash 経由)

検出されればフラグ立てる。

## 検出時のフロー

AskUserQuestion で 3 択:

```
Question: skill-creator が検出されました。生成スキルの eval ループを実行しますか？
Options:
  - run-now (今すぐ skill-creator:skill-creator スキルを invoke して eval を走らせる)
  - show-command (eval 実行コマンドを表示するだけ。後で自分で走らせる)
  - skip (eval は走らせない)
```

### run-now 選択時

サブエージェントとして `Skill(skill-creator:skill-creator)` を invoke。引数として:
- 生成スキルの絶対パス
- eval test cases の数（デフォルト 3）

run-now の中身は skill-creator 側に委譲する。本スキルは結果サマリだけ受け取って表示。

### show-command 選択時

以下のコマンドを表示してユーザに渡す:

```
Skill(skill-creator:skill-creator) でスキルパス '<生成スキルの絶対パス>' を指定し、
'eval ループを 3 ケースで実行してください' と依頼してください。
```

### skip 選択時

何もしない。

## 未検出時のフロー

eval は提案せず、サマリ表示の最後に次のヒントを 1 行追加:

```
Tip: skill-creator プラグインを入れると eval ループで自動採点できます:
     /plugin install skill-creator@anthropic-skills
```

## 注意

- skill-creator のスキル名は `skill-creator:skill-creator` (プラグイン名:スキル名 形式)。`skill-creator-max` とは別物
- 検出 Glob のパスは Claude Code のプラグインキャッシュ仕様に依存。仕様が変われば本ファイルを更新
- run-now は skill-creator 側のセッションに委譲するため、本スキルの context は消費しない
```

- [ ] **Step 2: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/references/eval-integration.md
git commit -m "docs(koshian-design-kit): add eval-integration reference"
```

---

## Task 9: Template — `ui-component`

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/ui-component/template.md`
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/ui-component/metadata.yaml`

- [ ] **Step 1: ディレクトリ作成**

```bash
mkdir -p ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/ui-component
```

- [ ] **Step 2: `metadata.yaml` を書く**

ファイル内容:

```yaml
name: ui-component
description: UI コンポーネント生成に特化したデザインスキルを作る
use_case: Tailwind / shadcn / Vue / React 等の UI コンポーネント生成スキル
questions:
  - id: skill_name
    prompt: スキル名（kebab-case、例: bold-button-generator）
    type: text
  - id: stack
    prompt: 対象スタック
    type: choice
    choices: [Tailwind CSS, shadcn/ui, React, Vue, Svelte, vanilla HTML/CSS, その他（自由入力）]
  - id: design_philosophy
    prompt: デザイン哲学
    type: choice
    choices: [Brutalism, Minimalism, Glassmorphism, Neumorphism, Maximalism, Bento Grid, Skeuomorphism, その他（自由入力）]
  - id: components
    prompt: 必須コンポーネント領域（複数選択可、コンマ区切り）
    type: text
    placeholder: "Button, Modal, Form, Card, Navigation"
  - id: trigger_phrases
    prompt: ユーザがどう発話したらこのスキルが起動すべきか（2-3 例）
    type: text
    placeholder: "ボタン作って、モーダル設計して、ヒーローセクション作成"
placeholders:
  - skill_name
  - stack
  - design_philosophy
  - components
  - trigger_phrases
```

- [ ] **Step 3: `template.md` を書く**

ファイル内容:

````markdown
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
````

- [ ] **Step 4: YAML 構文チェック**

```bash
python -c "
import yaml
with open('../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/ui-component/metadata.yaml') as f:
    data = yaml.safe_load(f)
assert 'questions' in data and len(data['questions']) >= 3
print('PASS: ui-component metadata.yaml is valid')
"
```

Expected: `PASS: ui-component metadata.yaml is valid`

- [ ] **Step 5: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/references/templates/ui-component/
git commit -m "feat(koshian-design-kit): add ui-component template"
```

---

## Task 10: Template — `brand-voice`

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/brand-voice/template.md`
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/brand-voice/metadata.yaml`

- [ ] **Step 1: ディレクトリ作成**

```bash
mkdir -p ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/brand-voice
```

- [ ] **Step 2: `metadata.yaml` を書く**

```yaml
name: brand-voice
description: 自社/個人ブランドの voice を成果物（PDF / スライド / メール / Web）に一貫適用するスキルを作る
use_case: あらゆる成果物を on-brand に揃えたい個人・企業
questions:
  - id: skill_name
    prompt: スキル名（kebab-case、例: acme-brand-voice）
    type: text
  - id: brand_name
    prompt: ブランド名 / 個人名
    type: text
  - id: target_media
    prompt: 対象媒体（複数選択可、コンマ区切り）
    type: text
    placeholder: "PDF レポート, スライド, メール, Web 記事, SNS 投稿"
  - id: primary_colors
    prompt: 主要色（最大 3 色、HEX 形式、コンマ区切り）
    type: text
    placeholder: "#FF6B6B, #4ECDC4, #1A1A2E"
  - id: heading_font
    prompt: 見出しフォント
    type: text
    placeholder: "Playfair Display"
  - id: body_font
    prompt: 本文フォント
    type: text
    placeholder: "Inter"
  - id: tone
    prompt: トーン
    type: choice
    choices: [formal, friendly, playful, technical, journalistic, conversational, その他（自由入力）]
  - id: forbidden
    prompt: 「これだけはやってほしくない」表現や用語（任意、コンマ区切り）
    type: text
    placeholder: "顧客様, 弊社では, 〜させていただきます"
placeholders:
  - skill_name
  - brand_name
  - target_media
  - primary_colors
  - heading_font
  - body_font
  - tone
  - forbidden
```

- [ ] **Step 3: `template.md` を書く**

````markdown
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
````

- [ ] **Step 4: YAML 構文チェック**

```bash
python -c "
import yaml
with open('../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/brand-voice/metadata.yaml') as f:
    data = yaml.safe_load(f)
assert 'questions' in data and len(data['questions']) >= 5
print('PASS: brand-voice metadata.yaml is valid')
"
```

Expected: `PASS: brand-voice metadata.yaml is valid`

- [ ] **Step 5: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/references/templates/brand-voice/
git commit -m "feat(koshian-design-kit): add brand-voice template (industry-agnostic)"
```

---

## Task 11: Template — `audit` (stub)

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/audit/template.md`
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/audit/metadata.yaml`

- [ ] **Step 1: ディレクトリ作成**

```bash
mkdir -p ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/audit
```

- [ ] **Step 2: `metadata.yaml` を書く（stub レベル）**

```yaml
name: audit
description: 既存コード/デザインを採点する監査型スキルを作る（v0.1 では雛形のみ、v0.2 で完成度向上予定）
use_case: Web UI / アニメーション / アクセシビリティ等の audit スキル（Vercel agent-skills や Motion AI Kit のような）
status: stub
questions:
  - id: skill_name
    prompt: スキル名（kebab-case、例: animation-perf-audit）
    type: text
  - id: target
    prompt: 監査対象
    type: choice
    choices: [Web UI コード, CSS/JS アニメーション, アクセシビリティ, ブランド一貫性, その他（自由入力）]
  - id: scoring_method
    prompt: 採点方式
    type: choice
    choices: [S-F tier (Motion AI Kit 風), 0-100 score, pass-fail, 重大度ラベル (critical/warning/info)]
  - id: trigger_phrases
    prompt: 起動トリガフレーズ（2-3 例、コンマ区切り）
    type: text
    placeholder: "audit して, 監査して, パフォーマンス見て"
placeholders:
  - skill_name
  - target
  - scoring_method
  - trigger_phrases
```

- [ ] **Step 3: `template.md` を書く（stub レベル + TODO）**

````markdown
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
````

- [ ] **Step 4: YAML 構文チェック**

```bash
python -c "
import yaml
with open('../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/references/templates/audit/metadata.yaml') as f:
    data = yaml.safe_load(f)
assert data.get('status') == 'stub'
print('PASS: audit metadata.yaml is valid (stub)')
"
```

Expected: `PASS: audit metadata.yaml is valid (stub)`

- [ ] **Step 5: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/references/templates/audit/
git commit -m "feat(koshian-design-kit): add audit template stub (full impl in v0.2)"
```

---

## Task 12: メインの `SKILL.md`（オーケストレータ）

**Files:**
- Create: `../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/SKILL.md`

- [ ] **Step 1: `SKILL.md` を書く**

ファイル内容:

````markdown
---
name: create-design-skill
description: 「デザインスキルを作って」「UI 生成スキルを作って」「ブランドボイスをスキル化したい」「監査スキル作って」「Claude にデザイン専門家になってほしい」等で起動。3 テンプレ（UI Component / Brand Voice / Audit）または自作テンプレから対話で選んで scaffold する。skill-creator が入っていれば eval ループも提案する。
---

# create-design-skill (kit)

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
${CLAUDE_PLUGIN_ROOT}/skills/create-design-skill/references/templates/*/metadata.yaml
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

- B-standard: plugin.json + LICENSE + README + CHANGELOG だけ生成
- C-with-marketplace: B + 親リポの marketplace.json に追記

C 選択時は `find_marketplace_root` ヘルパで上方向探索。見つからなければ B にフォールバックして警告。

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

plugin 出力時は加えて `${CLAUDE_PLUGIN_ROOT}/skills/create-design-skill/scripts/scaffold-plugin.sh` を Bash ツールで実行:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/create-design-skill/scripts/scaffold-plugin.sh \
  --output-dir "<cwd>/plugins/<plugin-name>" \
  --plugin-name "<plugin-name>" \
  --description "<plugin-description>" \
  --author "<from git config user.name or default 'unknown'>"
```

C-with-marketplace 選択時は続けて update-marketplace.sh も呼ぶ（diff 確認 → 反映）。

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
  (C 選択時)
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
````

- [ ] **Step 2: SKILL.md の構造を目視レビュー**

ファイルを開いて以下を確認:
- frontmatter の `name`, `description` が `metadata.yaml` 規約と合っている
- 全 9 ステップが順序通り存在する
- references/ への参照リンクが正しい
- Step 6 の擬似コードが分かりやすい

- [ ] **Step 3: Commit**

```bash
cd ../claude-plugins
git add plugins/koshian-design-kit/skills/create-design-skill/SKILL.md
git commit -m "feat(koshian-design-kit): add main SKILL.md orchestrator"
```

---

## Task 13: marketplace.json への登録

**Files:**
- Modify: `../claude-plugins/.claude-plugin/marketplace.json`

- [ ] **Step 1: 現在の `marketplace.json` を確認**

```bash
cat ../claude-plugins/.claude-plugin/marketplace.json
```

期待: `plugins[]` に `claude-nfd` と `harness-kit` がある状態。

- [ ] **Step 2: 自分自身の `update-marketplace.sh` で追記**

```bash
DRY_RUN_AUTO_CONFIRM=1 bash ../claude-plugins/plugins/koshian-design-kit/skills/create-design-skill/scripts/update-marketplace.sh \
  --marketplace-root ../claude-plugins \
  --plugin-name koshian-design-kit \
  --plugin-source ./plugins/koshian-design-kit \
  --plugin-description "Template-driven creator for design-focused Claude Code skills (UI Component / Brand Voice / Audit)"
```

- [ ] **Step 3: 結果を確認**

```bash
cat ../claude-plugins/.claude-plugin/marketplace.json | python -m json.tool
```

期待: `plugins[]` に `koshian-design-kit` が追加されている。JSON 構文エラー無し。

- [ ] **Step 4: Commit**

```bash
cd ../claude-plugins
git add .claude-plugin/marketplace.json
git commit -m "chore(marketplace): register koshian-design-kit plugin"
```

---

## Task 14: 親 `README.md` の表に追加

**Files:**
- Modify: `../claude-plugins/README.md`

- [ ] **Step 1: 現在の README を確認**

```bash
cat ../claude-plugins/README.md
```

- [ ] **Step 2: 表に行を追加**

`Edit` ツールで以下を追記（既存表の最終行直後に追加）:

old_string:
```
| [harness-kit](plugins/harness-kit/) | Generator-Evaluator パターンによる長時間開発ハーネス — マルチエージェント品質保証ワークフロー |
```

new_string:
```
| [harness-kit](plugins/harness-kit/) | Generator-Evaluator パターンによる長時間開発ハーネス — マルチエージェント品質保証ワークフロー |
| [koshian-design-kit](plugins/koshian-design-kit/) | テンプレート駆動でデザイン用エージェントスキルを作成するメタスキル（UI Component / Brand Voice / Audit + 自作テンプレ対応） |
```

- [ ] **Step 3: Commit**

```bash
cd ../claude-plugins
git add README.md
git commit -m "docs: add koshian-design-kit to plugins table"
```

---

## Task 15: エンドツーエンド動作確認

このタスクは手動テストの手順書。すべて成功したら Phase 1 完了。

- [ ] **Step 1: marketplace 再読み込み**

Claude Code セッションで:

```
/plugin marketplace add ../claude-plugins
```

期待: 「Already added」または再読み込み成功

- [ ] **Step 2: プラグインインストール**

```
/plugin install koshian-design-kit@koshian-plugins
```

期待: インストール成功メッセージ

- [ ] **Step 3: スラッシュコマンド起動確認**

```
/create-design-skill
```

または `/koshian-design-kit:create-design-skill`

期待: スキルが起動し、Step 1 のテンプレ列挙メッセージが出る

- [ ] **Step 4: ui-component テンプレで test スキル生成**

対話に答える:
- テンプレート: `ui-component`
- skill_name: `test-button-generator`
- stack: `Tailwind CSS`
- design_philosophy: `Brutalism`
- components: `Button, Card`
- trigger_phrases: `ボタン作って, カード作って`
- 出力先: `project-local`

期待:
- `<cwd>/.claude/skills/test-button-generator/SKILL.md` が作成される
- frontmatter の name が `test-button-generator`
- description にプレースホルダ置換後の文字列が入る

- [ ] **Step 5: 生成スキルの起動確認**

新しいセッション（または `/reload-skills` 相当）で `ボタン作って` と発話。

期待: `test-button-generator` が trigger される（Skill ツールでロードされる）

- [ ] **Step 6: plugin 出力モードのテスト**

`/create-design-skill` を再度実行し、出力先で `plugin` を選択:

- plugin-name: `test-design-plugin`
- description: `Test plugin generated by koshian-design-kit`
- scaffold 範囲: `B-standard` (まずは marketplace 連携無しで確認)

期待:
- `<cwd>/plugins/test-design-plugin/.claude-plugin/plugin.json` 作成
- `<cwd>/plugins/test-design-plugin/LICENSE` 作成
- `<cwd>/plugins/test-design-plugin/README.md` 作成
- `<cwd>/plugins/test-design-plugin/CHANGELOG.md` 作成
- `<cwd>/plugins/test-design-plugin/skills/test-design-plugin/SKILL.md` 作成

- [ ] **Step 7: marketplace 連携モードのテスト**

`<cwd>` を一時的に `../claude-plugins` 上で実行（または別の marketplace 持ちリポで）し、scaffold 範囲で `C-with-marketplace` を選択。

期待:
- diff が表示される
- ユーザ確認後に marketplace.json に追記される
- JSON 構文エラー無し

- [ ] **Step 8: skill-creator 未インストール時の挙動確認**

`skill-creator` プラグインを一時的にアンインストールするか、Glob で見つからない状態で `/create-design-skill` を実行。

期待:
- eval 提案は出ない
- サマリ末尾に「`/plugin install skill-creator@anthropic-skills` でインストールできます」のヒントが 1 行表示

- [ ] **Step 9: 中断時のリカバリ確認**

`/create-design-skill` 起動後、Step 3（テンプレ固有質問）の途中で中断:

期待:
- 部分的なファイル作成が起きていない（Step 6 まで進んでいないため）
- エラーで落ちずに「中断されました」表示

- [ ] **Step 10: 動作確認結果を CHANGELOG に記録**

すべて成功なら、CHANGELOG.md に動作確認済みの旨を追記:

```bash
cd ../claude-plugins
# Edit plugins/koshian-design-kit/CHANGELOG.md
# Add under [0.1.0]:
#   ### Verified
#   - End-to-end manual verification 2026-04-DD: install, ui-component generation, plugin output, skill-creator integration
git add plugins/koshian-design-kit/CHANGELOG.md
git commit -m "chore(koshian-design-kit): mark v0.1.0 as verified after E2E testing"
```

---

## 完了基準（Phase 1）

- [ ] 全 15 タスクの全ステップ完了
- [ ] `bash test-scaffold-plugin.sh` PASS
- [ ] `bash test-update-marketplace.sh` PASS
- [ ] `/plugin install koshian-design-kit@koshian-plugins` 成功
- [ ] `/create-design-skill` で 1 つ実スキル生成成功
- [ ] 生成スキルが trigger 可能
- [ ] plugin 出力 + marketplace 連携の両モード動作確認

完了後の次アクション:
1. このセッション内で `git log --oneline -20` で commit 履歴を確認
2. 別セッションで Phase 2（forge）の plan を作成
3. Phase 1 で得た学び（Q&A の出し方、テンプレ構造の改善点等）を Phase 2 spec の改訂に反映

---

## Self-Review チェック結果（plan 完成時の自己確認）

- ✅ **Spec coverage**: spec の Section 7 Phase 1 の 8 項目をすべて Task 化済み
- ✅ **Placeholder scan**: TBD/TODO 表現は `audit` テンプレ内の意図的な拡充項目のみ（v0.2 で対応と明示）
- ✅ **Type consistency**: `scaffold-plugin.sh` / `update-marketplace.sh` の引数名（`--plugin-name`, `--plugin-source`, `--plugin-description`, `--marketplace-root`, `--output-dir`, `--description`, `--author`）は Task 5/6/13 で一貫
- ✅ **placeholder 命名**: 各 template の metadata.yaml の `placeholders[]` と template.md 内の `{{...}}` が対応している
- ✅ **依存順序**: Task 5/6 (scripts) を Task 12 (SKILL.md) と Task 13 (marketplace 自身)の前に配置済み
