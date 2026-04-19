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
