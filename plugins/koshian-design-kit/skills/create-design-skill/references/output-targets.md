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

`find_marketplace_root` 相当の処理は SKILL.md 内で次のように行う。`cd && pwd` は Windows/Git Bash でのパス canonicalisation が不安定なので、Python の `os.path.realpath` を使う:

```bash
DIR="$(python -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1")"
while [ "$DIR" != "/" ] && [ -n "$DIR" ]; do
  if [ -f "$DIR/.claude-plugin/marketplace.json" ]; then
    echo "$DIR"
    return 0
  fi
  PARENT="$(dirname "$DIR")"
  [ "$PARENT" = "$DIR" ] && break   # reached filesystem root (handles Windows drive roots like C:/)
  DIR="$PARENT"
done
return 1
```

見つからなかった場合は警告を出して B-standard 相当（marketplace 追記スキップ）に fallback する。
