# Contributing to feature-ideation

## 開発環境

- **OS**: Linux / macOS / Windows（Git Bash または WSL）。PowerShell は v0.1.0 では非対応
- **Shell**: bash 3.2 以降。bash 4 固有機能（連想配列 / `${x^^}`）は使わない（macOS 標準の bash が 3.2 のため）
- **依存**: `bats-core`。`jq` / `perl` / `python` には依存しない

## テストの実行

```bash
cd plugins/feature-ideation
bats tests/
```

## `lib/vault-digest.sh` を触るときの約束

1. **絶対に非 0 で終了させない。** このスクリプトの出力は `skills/check/SKILL.md` が
   コンテキスト注入（`` !`...` ``）で受け取る。注入コマンドが失敗するとスキル起動ごと abort し、
   モデルは本文を一切見られなくなる。よってリポジトリ内の他のスクリプトと違い
   `set -euo pipefail` を**使わない**。新しい経路を足したら「その入力で exit 0 になるか」を必ずテストする
2. **日付演算に `date(1)` を使わない。** GNU の `date -d` と BSD の `date -v` は非互換。
   スクリプト内の awk 日付ライブラリ（`dfc` / `civ`）を通す
3. **`--today` を壊さない。** テストは `FEATURE_IDEATION_TODAY` で時間を止めている。
   これが無いと fixture の期限を毎年書き換えることになり、テスト自体が腐る
   （このプラグインが戦っている問題そのもの）
4. **列位置を固定しない。** テーブルはヘッダ行の列名から位置を解決する。
   `依存` 列の有無などプロジェクトごとの差を吸収するため
5. **ID の形式をハードコードしない。** `id_style` から導出した `ID_RE_AWK` / `ID_RE_ERE` /
   `LINK_RE_AWK` / `XREF_RE_AWK` / `XREF_TAIL_AWK` / `NAME_RE_ERE` を使う。
   awk へ渡す正規表現は**動的正規表現として解釈される**ので、バックスラッシュは二重にする
   （`'\\]\\([^)]*'` と書くと awk は `\]\([^)]*` として受け取る）。
   新しい形式を足すときは `legacy-declared` と同型の fixture もセットで用意すること

## fixture の追加

`tests/fixtures/vaults/<name>/` にプロジェクトのディレクトリ構造ごと置く。
既存の fixture が担保している性質は次のとおり。新しい検出を足すときは、
**誤検出しないことの fixture もセットで用意する**（このスクリプトの価値は精度にある）。

| fixture | 担保していること |
|---|---|
| `normal` | 標準的な vault の件数・期限・台帳・ピックトリガ |
| `empty` | 行が 0 件でも壊れない |
| `no-vault` | vault 不在でも exit 0 で案内を返す |
| `overdue` | 期限超過の検出と、`- [x]` / 完了語を含む行を**誤検出しない**こと |
| `broken` | 列数不一致・区切り行なし・語彙外の状態・墓標行 |
| `foreign` | 異物の分類、1 hop 参照されるファイルを**孤児にしない**こと |
| `xref` | `feature-idea` 修飾つきの言及を拾い、修飾のない素の ID を**拾わない**こと |
| `crlf` | CRLF でも LF と同一の出力になること |
| `legacy` | カテゴリ依存 ID を宣言なしで置いたとき、0 件ではなく理由とヒントを返すこと |
| `legacy-declared` | `id_style: categorical` を宣言したとき、カテゴリ依存 ID が全機能で扱えること |

## スキル本文を触るときの約束

- `description` に山括弧 `<` `>` を入れない。Agent Skills のバリデータが拒否する
- `description` は短く保つ。スキル一覧の予算は context window の 1% で、登録スキルが多い環境では
  切り詰められる。実測: 46 スキル登録済みの環境では、新規インストール直後の
  feature-ideation は description ごと listing から落とされ、自動発火しなかった
- `references/` へのリンクは SKILL.md から 1 階層に留める。参照の参照は読まれないことがある
- **`${CLAUDE_EFFORT}` は値に置換される。** 「`${CLAUDE_EFFORT}` が xhigh のとき」と書くと
  「xhigh が xhigh のとき」になる。値をデータとして読ませる書き方
  （「現在の effort は `${CLAUDE_EFFORT}`。これが xhigh か max なら…」）にする
- **SKILL.md に HTML コメントで注記を書かない。** 本文としてロードされ、毎回トークンを消費する。
  実装上の注意はこのファイルか、スクリプト側のコメントに書く

### `check` の注入行に付いている `|| true` について

スクリプト自身は必ず exit 0 を返すので、このガードが効くのは「ファイルが無い / 実行できない」
ケースだけ。注入コマンドが非 0 を返すとスキル起動ごと abort し、モデルは本文もフォールバック手順も
一切見られなくなる。`shell: bash` を宣言しているので `||` は常に bash が解釈する。外さないこと。
