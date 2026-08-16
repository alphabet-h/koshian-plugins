# Changelog

All notable changes to feature-ideation are documented here. Format: Keep a Changelog. Versioning: SemVer.

## [Unreleased]

## [0.1.4] - 2026-08-17

### Added
- `references/evaluation.md` に**範囲表記を単一値に倒すときの規則**を追加。
  旧 vault の `中〜大` `小〜中` を新形式へ写すときは **効果は下に、難易度は上に**倒す
  （期待値を膨らませない側で、「難易度は迷ったら 1 段上げる」と向きが揃う）。
  規則に反する向きへ倒した行は理由を残すこと、**同じ範囲表記が別方向に解決された箇所は必ず記録すること**を明記した。

  kb-mcp の移行レビューで「`A-8` と `A-9` が同じ `中〜大` から逆方向に倒れているのに、
  記録が無いのでどちらが誤りか判断できない」と指摘されたことによる。

## [0.1.3] - 2026-08-16

実運用 vault (78 ID / 台帳 29 行) を移行して見つかった 2 件の誤検出を修正。
どちらも台帳が育った vault でしか出ないため、合成 fixture では気づけなかった。

### Fixed
- **台帳にある ID を dangling と報告していた。** 既知 ID の集合を index の行からしか作っておらず、
  実装済み台帳・不採用の記録の ID が「index に存在しない ID」と判定されていた。
  台帳の ID は既に閉じており突合の必要が無いので、XREF にも DANGLING にも出さないようにした。
- **優先度ピックの改訂トリガ T4 が常に発火していた。** 「ピックに載っていない ID が実装済み台帳に入った」の
  判定が台帳全体を対象にしていたため、過去の完了項目まで数えて移行直後に 28 件を列挙していた。
  **前回ピックより後に完了した行だけ**を対象にした。

## [0.1.2] - 2026-08-16

### Added
- **`id_style: categorical`** — vault frontmatter に書くと `A-1` 形式のカテゴリ依存 ID を
  そのまま集計できる。既存 vault を **ID を付け替えずに**新フォーマットへ移すためのもの。
  詳細ファイル名の規約と外部参照の検出も同じ形式に追随する。
  新規 vault では使わない（カテゴリ再編で ID とカテゴリが食い違う問題は `FI-NNN` でしか解決しない）。

  実運用の vault で ID 付け替えコストを実測したところ、必須 156 箇所 / 12 ファイルだった。
  公開リポのソースコード doc コメント、CHANGELOG の過去リリース記録、crates.io に出る
  `Cargo.toml` の description を含み、さらに同じ `A-1` `D-11` という表記が 3 つの名前空間
  （vault の feature ID / spec の設計判断 ID / audit の指摘 ID）で使われていて機械置換が
  できなかった。スクリプト側を 9 箇所直すほうが安全で安く、移行税で利用者を弾かずに済む。

### Changed
- 宣言なしでカテゴリ依存 ID を見つけたときの警告に、`id_style: categorical` を宣言する
  という解決方法を含めた。
- 実装済み台帳の `証跡` / `知見` の空欄禁止は、**移行行には適用しない**旨をテンプレートに明記した。
  当時の記録に学びが残っていないことがあるため。

## [0.1.1] - 2026-08-16

v0.1.0 の E2E で見つかった 2 件の修正。

### Fixed
- `${CLAUDE_EFFORT}` は値に置換されるため、`feature-ideation` の SKILL.md 2 箇所が
  「xhigh が xhigh / max のときは」という壊れた文でロードされていた。
  値をデータとして読ませる書き方に変更した。
- `check` の SKILL.md に置いていた HTML コメントを削除した。本文としてロードされ、
  起動のたびにトークンを消費していた。内容は CONTRIBUTING.md へ移した。

## [0.1.0] - 2026-08-16

`~/.claude/skills/feature-ideation/` で運用していたローカルスキルをプラグイン化した初回リリース。
2 プロジェクトでの 4 ヶ月の実運用で判明した摩擦を潰し、現行の Claude Code Skills 仕様に追随した。

### Added
- `feature-ideation` スキル — アイデア出しのデフォルトワークフロー + `discuss` / `archive` のルータ。
- `idea-check` スキル — vault の状態サマリと陳腐化検出。`vault-digest.sh` の出力をコンテキスト注入で受け取る。
- `scripts/vault-digest.sh` — vault を決定的に集計するシェルスクリプト。件数・期限超過・長期停滞・
  vault ディレクトリの異物・孤児ファイル・優先度ピックの改訂トリガを検出する。終了コードは常に 0。
- vault テンプレートに **再評価キュー**（日付期限の指定席）と **アーカイブ 2 表**（実装済み台帳 / 不採用の記録）を導入。
- `references/` を 4 本に分割（`discuss` / `archive` / `evaluation` / `template`）。
- bats テストと fixture（正常 / 空 / 期限超過 / 壊れたテーブル / 異物 / 孤児 / CRLF / vault 不在 / 旧形式 2 種）。

### Changed
- **ID 体系を `A-1`（カテゴリ + 連番）から `FI-001`（カテゴリ非依存の通し番号）へ変更。**
  カテゴリ再編で ID とカテゴリが恒久的に食い違う事象と、2 階層 ID の衝突が実運用で発生したため。
- **`起票日` カラムを index から削除。** 遡及付与されず、また一括ブレストでは 8 割が同一日になり
  停滞シグナルとして機能しなかった。停滞判定は `last_sweep` / カテゴリ最終確認 / 詳細ファイル mtime の 3 層に移行。
- **`closed.md` を廃止**し、アーカイブを vault 本体末尾の 2 表に内蔵。別ファイル方式は 2 プロジェクト・
  4 ヶ月で一度も生成されなかった。完了側は `証跡` / `知見` を空欄禁止とし、実装から vault への戻り導線を強制する。
- **日付にできない「発火条件つきの持ち越し」を vault の外へ隔離**するルールを追加。
- 優先度ピックの改訂トリガを「四半期・リリース節目」から、vault 内部で自己完結する 4 条件へ変更。
- `status` の語彙を `idea` / `probing` / `planned` / `frozen` + 終端 2 語に正規化（装飾表記を禁止）。
- SKILL.md をルータ化し 338 行から縮小。`check` は独立スキルへ分離。
- `description` を 604 → 約 240 文字に短縮し、山括弧を除去
  （Agent Skills の validator が description 中の `<` `>` を拒否するため）。
- `allowed-tools` を `feature-ideation` からは削除、`idea-check` では集計スクリプトのみに限定。
- `superpowers:writing-plans` への引き渡しを optional 化（未インストール環境でも動く）。
- ステップ 5 のユーザ確認を `AskUserQuestion` による選択式に変更。

### Requirements
- bash（Windows では Git Bash）。`idea-check` の集計スクリプトが依存する。

### Notes
- `check` の SKILL.md 本文では `${CLAUDE_PLUGIN_ROOT}` を使用している。design-kit で採った
  `<PLUGIN_ROOT>` プレースホルダ方式は、現行仕様では不要（skill 本文と `allowed-tools` の
  Bash ルールの両方で置換されることが公式に文書化されており、E2E で実際に展開を確認した）。
- v0.1 の期限検出は新形式の再評価キューのみを対象とする。旧 vault の散文期限は拾わない。

### Verified
2026-08-16、`koshian-plugins` からインストールして claude-plugins リポジトリ自身に対して E2E を実施。

- スキル 2 個（`feature-ideation` / `check`）が一覧に登録されること
- 引数なし起動で 6 ステップが走り、step 5 で `AskUserQuestion` が出ること
- 新テンプレートで vault が生成されること（29 件、PARSE WARNINGS 0）
- **`check` のコンテキスト注入が成立すること** — digest が本文に埋まり、`${CLAUDE_PLUGIN_ROOT}` が
  展開され、権限プロンプトが出ないこと
- 件数が実数と一致すること（カテゴリ別・状態別・効果別・制約別すべて整合）
- `frozen` を期限切れと混同せず別枠で報告すること

未達 1 件: **description による自動発火**。46 スキルが登録された環境では skill listing の予算を
超過し、新規インストール直後のスキルから description が落とされるため、自然な発話では発火しなかった。
リポジトリ側で取れる対策は description を短く保つことのみ。
