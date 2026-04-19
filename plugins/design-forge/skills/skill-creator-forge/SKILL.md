---
name: skill-creator-forge
description: 「デザインスキルをフリー入力から作って」「テンプレに収まらないスキルを組み立てたい」「新ドメインや業界向けのスキルを試作したい」「このフリー入力から SKILL.md を組み立てて」等で起動。ペルソナ分類 → 動的質問 → 構造提案 → 生成 の順で、design-kit のテンプレに縛られず**業種を問わず**デザインスキルを作る。skill-creator が入っていれば eval ループも提案する。
---

# skill-creator-forge (design-forge)

フリー入力 + Q&A 駆動でデザイン用エージェントスキルを生成する。**design-kit の補完**として、テンプレに収まらない新ドメイン、業種を問わない用途、試作用途で使う。姉妹プラグイン `design-kit` と並列配布して A/B 比較の素材になる設計。

## 全体ワークフロー

```
[0] プラグインルート解決 → [1] ペルソナ抽出 → [2] 自動分類 + 確認 → [3] 動的質問生成
    → [4] 構造提案 + 調整 → [5] 出力先選択 → [6] (plugin 時) scaffold 範囲選択
    → [7] ファイル生成 → [8] skill-creator 検出 → [9] (検出時) eval 提案
    → [10] サマリー
```

詳細ロジックは references/ に分離:
- `references/persona-categories.md` — Step 2 の分類基準（IT / 非 IT の例を併記）
- `references/question-bank.md` — Step 3 の質問パターン集（業種別補足あり）
- `references/output-targets.md` — Step 5-6 の処理（design-kit と共通）
- `references/eval-integration.md` — Step 8-9 の処理（design-kit と共通）

## Step 0: プラグインルートの解決

以下のフローで `<PLUGIN_ROOT>` と書かれている箇所はすべて、このプラグインのインストール絶対パス（この SKILL.md から見て `../../..` にあたる）に**テキスト置換して使う**。シェル変数 (`$PLUGIN_ROOT` や `${CLAUDE_PLUGIN_ROOT}`) として扱ってはいけない（Bash tool のサブプロセスには env var が export されないので空展開になる）。

解決手順（design-kit の SKILL.md Step 0 と同じ）:
1. このスキルの絶対パスから `.../plugins/design-forge/` までを plugin root として抽出
2. 以降のすべての bash コマンド / Glob で `<PLUGIN_ROOT>` をこの絶対パスに置換してから実行

例: SKILL.md 上の `bash <PLUGIN_ROOT>/skills/skill-creator-forge/scripts/scaffold-plugin.sh` は、実際には以下のように実行する（パスはインストール環境によって変わる）:

```bash
bash "C:/Users/you/.claude/plugins/cache/.../design-forge/skills/skill-creator-forge/scripts/scaffold-plugin.sh"
```

## Step 1: ペルソナ抽出（フリー入力）

AskUserQuestion ではなく**普通の会話ターン**でユーザに尋ねる:

> 「どんなデザインタスクを Claude に任せたいか、1-3 文で教えてください。**業種は問いません**。例:
>   - IT: 『Brutalism 美学のコンポーネント生成』『既存アプリのアクセシビリティ監査』『CI 完了通知 + issue 自動作成』
>   - 非 IT: 『建築確認申請書のテンプレ生成』『契約書の条項チェック』『月次請求書の発行〜送付フロー』」

ユーザの回答（以降「ペルソナ文」）を全文保持して Step 2 に渡す。業種固有の用語はそのまま受け入れ、判定時に **動詞 / 目的のパターン**にフォーカスする。

## Step 2: 自動分類 + 確認

`references/persona-categories.md` の 4 カテゴリ (Generator / Auditor / Process / Hybrid) のうちどれかをペルソナ文から**推測**し、AskUserQuestion で確認:

```
Question: 入力内容から「{推測カテゴリ}」と判定しました。これで進めますか？
Options:
  - {推測カテゴリ} で進める (Recommended)
  - 別カテゴリを選ぶ (Generator / Auditor / Process / Hybrid)
  - ペルソナ抽出をやり直す (Step 1 に戻る)
```

分類ロジック（`persona-categories.md` 参照）:
- 動詞「作って / 生成して / 書いて / 下書きして」→ Generator
- 動詞「評価して / 監査して / 採点して / 添削して / レビューして」→ Auditor
- 動詞「手順 / ステップ / ルーティン / フロー通り」→ Process
- 複数動詞が混在 → Hybrid
- 判定不能なら追加で 1 問「主な動詞は？」と聞いて再判定、それでも不明なら Hybrid

## Step 3: 動的質問生成

確定したカテゴリと Step 1 のペルソナ文から、`references/question-bank.md` の「選抜アルゴリズム」に従って 3-7 件の質問を選抜:

1. 該当カテゴリの **必須 3 件** を先頭に
2. ペルソナ文の具体性に応じて任意 0-4 件を追加
3. 既にペルソナ文で答えられている項目は削除
4. ペルソナ文のドメイン（Web / 建築 / 法律 / 教育 / 経理 / 医療 など）が question-bank の「業種別の補足例」に該当するなら、そこから 1-2 件を**追加で**選抜候補の上位に

選抜後、AskUserQuestion で **1 件ずつ**提示する（1 画面に詰め込まず、認知負荷を下げる）。

回答は key-value 辞書として `answers` に蓄積（key は question-bank の項目 ID、value は回答）。

## Step 4: 構造提案 + 調整

収集した `answers` から **SKILL.md の見出し構造**を提案する。

### Generator の場合の典型構造

```
# {{skill_name}}
## 起動条件（trigger_phrases から）
## 入力（入力の典型例 から）
## 出力フォーマット（output_format から）
## ワークフロー
## 失敗パターン
## references/ の使い方
```

### Auditor の場合

```
# {{skill_name}}
## 起動条件
## 監査対象と採点方式
## ルール集（ルール集ソース から）
## ワークフロー（監査 → 採点 → レポート）
## 違反例と修正案
## レポートフォーマット
```

### Process の場合

```
# {{skill_name}}
## 起動条件
## ステップ一覧
## 各ステップの I/O
## 副作用と承認フロー
## 中断時のリカバリ
## ログ / 監査証跡
```

### Hybrid の場合

各サブ動作ごとにセクションを分離 + 「実行順序」セクションで依存関係を明記。

### 業種特有の追加セクション

ペルソナ文 / answers から業種ヒントが読み取れる場合、該当業種で一般的なセクションを追加提案する:

- 建築系: 「対象構造 / 対象自治体」「法改正追随」
- 法律系: 「引用フォーマット」「判例ステータス」
- 教育系: 「学年・教科」「著作権配慮」
- 経理系: 「法定保存期間」「税区分」
- 医療系: 「匿名化」「用語規格」

### 調整ステップ

提案構造を **markdown の見出しリスト**として表示し、AskUserQuestion:

```
Question: 以下の構造で SKILL.md を作成します。調整しますか？
Options:
  - この構造で進める (Recommended)
  - 見出しを追加 / 削除したい（どう変えたいか次ターンで入力）
  - 既存のテンプレ参考を見たい（design-kit の該当テンプレを表示）
  - もういい、とにかく作って（構造調整スキップ、Step 5 へ）
```

## Step 5: 出力先選択

`references/output-targets.md` の手順に従い AskUserQuestion:
- project-local
- user-global
- plugin

design-kit と完全共通の処理。

## Step 6: (plugin 時のみ) scaffold 範囲選択

`standard` / `with-marketplace` を AskUserQuestion。with-marketplace 選択時は `find_marketplace_root` で marketplace.json を上方向探索。

design-kit と完全共通。詳細は `references/output-targets.md`。

## Step 7: ファイル生成

Step 4 で確定した構造に従い、各セクションを **answers を使って**埋める。Claude が直接 Write tool で書き出すので、以下は生成するテキストの **literal なひな形**（ヘルパ関数呼び出しではなく、プレースホルダ位置と書くべき内容の指示）:

```
---
name: {answers.skill_name}
description: {answers.skill_name} と persona_text から導出した 1-2 文の説明。
              persona_text の語彙（業界用語含む）を可能な限り保ちつつ、
              trigger_phrases / output_format / 監査対象 / ステップ列 等の
              カテゴリ固有要素を簡潔に含める。80 字前後推奨。
---

# {answers.skill_name}

## 起動条件

ユーザの発話に以下が含まれたら起動:
- {answers.trigger_phrases}

## 入力

典型的な入力:
- {answers.input_examples}

## 出力フォーマット

{answers.output_format} 形式で返す。

## ワークフロー

category と answers から 4-6 ステップを列挙。ひな形例:
- Generator: 要件受領 → バリエーション検討 → 実装 → 自己点検 → 出力
- Auditor:   対象読み取り → ルール照合 → 採点計算 → 修正案添付 → レポート出力
- Process:   副作用前の確認 → 各ステップ実行 → 中断時のリカバリ分岐 → 完了報告
- Hybrid:    構成サブスキルごとにセクションを分け、最後に「実行順序」セクション
industry_hint があれば該当業種の補足セクション（建築=法改正追随 / 法律=引用フォーマット 等）を 1 つ差し込む。

## 失敗パターン

{answers.anti_patterns があればそれをリスト化。無ければ
 '（ユーザ入力から特定できず — ユーザが後で追記推奨）' と note。}
```

**注記**:
- `{...}` はテキストそのものではなく**埋めるべき内容の指示**。実装時にはプレースホルダの位置に answers から取った値 or 上記指示に従って合成した文字列を流し込む。
- 分類外の answers（`reference` / `brand_tokens` 等）はカテゴリ別構造の末尾に「補足情報」セクションとして追加する。
- プレースホルダ置換後、生成された SKILL.md は必ずユーザに**フルテキスト表示**してから書き出すこと（forge は LLM 推測が多いため、ユーザの目視機会を必ず挟む）。

**reference 処理**: Step 3 で URL / 画像パスが指定されていたら、WebFetch or Read でローカルに取り込んで `references/` ディレクトリに保存。PDF や画像等 WebFetch で取れないものはパスだけ記録してユーザに「手動で references/ に配置してください」と案内。

plugin 出力時は `scaffold-plugin.sh` + (with-marketplace なら `update-marketplace.sh` を **dry-run → AskUserQuestion → --yes** の 3 段階で) 実行。design-kit Step 6 と同じ手順。

## Step 8: skill-creator 検出

`references/eval-integration.md` の Glob 検出（design-kit と共通）。

## Step 9: (検出時のみ) eval 提案

AskUserQuestion で `run-now / show-command / skip` の 3 択（design-kit と共通）。

## Step 10: サマリー

design-kit の Step 9 と同じパス記法を使って作成ファイル一覧 + 次アクション提案を表示。

```
✓ デザインスキル作成完了（forge）

ペルソナ: {Step 1 のフリー入力（先頭 60 字）}
カテゴリ: {確定カテゴリ}
想定業種: {industry_hint があれば表示、無ければ「未指定」}

作成ファイル:
  - <output_path>/SKILL.md
  - <output_path>/references/.gitkeep
  - <output_path>/scripts/.gitkeep
  ...

次のアクション:
  1. SKILL.md を読んで意図通りの記述か確認（forge は LLM 推測が多いので**必ず目視レビュー推奨**）
  2. references/ に補助資料を追加（URL 未取得のものは手動配置）
  3. (任意) /plugin install で動作確認
  4. (skill-creator 入っていれば) eval ループで品質測定

💡 Tip: 同じ要件で `/skill-creator-design` (design-kit 側) も試して出力を比較すると、
   テンプレ駆動 vs フリーフォームのどちらが自分の用途に合うかがわかります。
```

## 中断時のリカバリ

- Step 1 中断 → 何も作らずに終了
- Step 2-4 中断 → ペルソナ / answers は context に残るがファイル生成はしない
- Step 5-6 中断 → 出力先未確定のためファイル生成しない
- Step 7 中断 → 部分的に作成されたファイルパスを表示し、削除コマンドを提示
- Step 8-10 中断 → ファイル自体は作成済みなので、その旨表示して終了

## design-kit との A/B 比較観点

本スキルは `design-kit` の姉妹として設計されており、以下の使い分けが想定される:

| 状況 | 推奨 | 理由 |
|---|---|---|
| UI コンポーネント / ブランドボイス / 監査スキルで定型通りでいい | `design-kit` | テンプレ選択 → 少数の設定質問で早い |
| 非 Web / 非 IT 業種向けのスキル | `design-forge` | フリー入力が自然、業種特有用語を引き継げる |
| テンプレ化できるか自信がない、まず試作 | `design-forge` | Step 1 フリー入力で思考整理しながら組み立てられる |
| 同じ要件で両アプローチを比較したい | 両方試す | 出力 SKILL.md の質を見比べて自分の好みで選ぶ |

質問 wording は `design-kit` のテンプレと意図的に一致させている項目があるので、**同じ入力で両方を試したときに出力が like-for-like で比較できる**ように設計されている（`references/question-bank.md` の「A/B 比較観点での配慮」参照）。

## 関連 references

- `references/persona-categories.md` — 4 カテゴリ定義 + IT/非 IT 例
- `references/question-bank.md` — 質問パターン集 + 選抜アルゴリズム + 業種別補足
- `references/output-targets.md` — 出力先選択（design-kit と共通）
- `references/eval-integration.md` — skill-creator 検出と eval 提案（design-kit と共通）
- `scripts/scaffold-plugin.sh` — プラグインフォルダ scaffold（design-kit と共通）
- `scripts/update-marketplace.sh` — marketplace.json 追記（design-kit と共通）
