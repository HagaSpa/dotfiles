# エディタ戦略: Zed 主力・nvim は小道具・レビューは crit (2026-07)

nvim を主力エディタに育てるか（lazy.nvim + プラグイン群で IDE 化）を検討し、実際に最小スターターを組んで検証した。**結論: nvim を主力にはしない。主力エディタは Zed に確定。nvim は「ターミナル内の即席編集 / 稀な ssh 先編集」用の最小ツール（built-ins only）に留める。PR レビュー / AI 成果物レビューは crit を層として残し、Zed を編集・閲覧のサーフェスとして合成する。**

## 背景（判断を規定した制約）

作業スタイルが editor 選定を強く規定している。

- **打鍵最速・トラックパッド一切不使用**。これを満たせる GUI エディタは実質 Zed のみ（VS Code / Cursor はこの理由で不採用）
- **MacBook 15" 単一画面のみ・外部ディスプレイ不使用**。全アプリを maximize し、Raycast でアプリを切り替える。画面に余計な情報を出したくない
- 上記から **Claude Code をエディタに組み込まない**。画面が狭くなるため。Claude Code は ghostty かネイティブアプリで動かす
- **k8s クラスタにほぼログインしない**（GKE マネージド・GitOps デプロイ・本番ログイン回避）。クラスタ内に入るのは趣味の bons8i（kubeadm）で稀にある程度
- 最近は**コードを書くより PR レビュー・Notion 資料作成が中心**。crit を多用
- 業務コードは **SQL・dbt などデータ基盤**がほとんど（重量級 IDE 機能の需要が薄い）
- ディレクトリ移動は ghostty、git 操作も以前は ghostty だが最近は **Claude Code skill** に寄っている

## 検討した問い

1. 中長期の操作速度で見て、nvim に寄せる方がレバレッジが効くか
2. AI にコードを書かせる時代、「エディタ＝ビューワー」化する中でどちらが合理的か
3. 直近、シニア以上のエンジニアは nvim を使う側が多いのか

## 調査結果（2025〜2026）

| 指標 | 数値 | 出典 |
|---|---|---|
| エディタシェア (SO Survey 2025) | VS Code ~76% / Vim ~24% / **Neovim ~12–14%** / **Zed 7.3%** / Cursor 18% / Claude Code ~10% | Stack Overflow Developer Survey 2025 |
| Neovim の満足度 | **most admired** エディタ（2024: 83%、2025 も1位）。継続利用意向 81%（VS Code 77%） | 同上 / programming.dev |
| Zed の到達点 | 2026-04 に **Zed 1.0**、デイリーユーザー数十万規模。ACP で Claude Code / Codex / Gemini CLI をネイティブ統合、並列エージェント対応 | zed.dev |

- Neovim は「**使う人の満足度・定着率が突出して高いニッチ**」。熟練層に偏る傾向はあるが、絶対数ではシニアでも VS Code が最多で、「直近シニアが続々 nvim へ移行」という事実はない。直近の主流トレンドは AI ネイティブエディタ（Cursor / Claude Code / Zed）の台頭
- Zed 自身の nvim 比較でも、nvim の優位を「**ターミナルネイティブ（SSH・コンテナ・リモートで動く）**」「Lua の拡張性」と認め、Zed の優位を「設定不要で即戦力」「AI・LSP・協調編集が**組み込み**」としている

## 制約の当てはめ（決め手）

一般論では「Platform Engineer ＝ リモート/ターミナル ubiquity が効くので nvim にも地位が残る」と考えられる。しかし**本人の実運用**を当てると崩れる。

| 前提 | 効き方 |
|---|---|
| トラックパッド不使用の GUI は Zed だけ | **Zed 確定**の直接理由 |
| 単一画面・maximize・Raycast 切替・Claude Code 非組み込み | Zed の **ACP/組み込みエージェント**の強みは**使わない**前提 → 選定理由にならない |
| クラスタにほぼ入らない | **nvim 最大の固有レバレッジ（リモート/ターミナル ubiquity）がほぼ無効化** ← 判断の分岐点 |
| レビュー・資料作成中心、crit 多用 | 読む/レビューの GUI 品質が効く（Zed 寄り） |
| SQL・dbt 中心 | 重量級 IDE 機能不要。nvim を作り込む旨味が薄い |
| 移動は ghostty、git は Claude Code skill | ターミナル側は ghostty + Claude Code で完結。nvim の常用面がない |

日常は「**ghostty（移動＋Claude Code）↔ Zed（編集・閲覧・レビュー）↔ ブラウザ/Notion**」を Raycast で切り替える構成。この中で nvim が担う固有の仕事はほぼ残らない。

## レビュー体験の事実確認（期待と現実のズレ）

「crit でやってることを Zed でやる」を Zed 単体で満たせるかを確認した。**結論: 近い将来は不可。crit は手放さない。**

- **ローカルの git 差分レビューは Zed が得意**（ファイル単位 diff タブ、ハンク単位 stage/restore、diff 統計、multibuffer）。Claude Code が書いた未コミット変更を Zed で差分レビューするのは快適
- **GitHub の PR レビュー（PR ファイル閲覧・コメントスレッド・viewed マーク）は Zed にまだ無い**（2026 時点で要望多数・未実装。`git: create pull request` が入った程度）
- **AI 変更のハンク accept/reject は crit の代替ではない**。あれは「AI の編集を取り込むか捨てるか」の**承認ゲート**であって、コメント/批評を残す crit とは目的が違う。しかも **Zed 内でエージェントを動かしているときだけ**現れる UI で、ghostty/ネイティブで Claude Code を動かす本運用では**そもそも表示されない**（Zed 側は通常の git 差分として見えるだけ）

→ Zed = 差分の**閲覧・編集サーフェス**、crit = **レビューコメント層**（エディタ非依存・GitHub PR 同期）。両者は競合ではなく**合成**する。

## 意思決定

1. **主力エディタは Zed に確定**。全制約（no-trackpad GUI・単一画面・レビュー中心・SQL/dbt）に最も噛み合い、設定保守コストがゼロ
2. **nvim は主力候補から降格**し、**bons8i の ssh 編集 / ghostty 内の即席編集用の最小ツール**に位置づける。**built-ins only（プラグインマネージャなし）を維持し、これ以上プラグインを足して育てない**（常用面がない以上、保守税を回収できない）
3. **レビューは crit + Zed の合成**で運用。Zed のネイティブ PR レビューは当面期待しない
4. **muscle memory は Zed の Vim mode で共有**し、no-trackpad の打鍵資産を二重投資にしない

## nvim をどう残すか（今回の実装判断）

このセッションで一度 lazy.nvim + telescope + neovim-project + treesitter + mason で IDE 化を試したが、**上記の意思決定に伴い全て破棄し、元の built-ins-only の `init.lua` に戻した**。

破棄の副次的な裏付けとして、nvim 0.12.4（本環境）では **固定タグ/旧ブランチがことごとく非互換**だった（nvim-treesitter master、telescope 0.1.8、加えて main ブランチは tree-sitter CLI 依存）。1 セッションで版非互換を 3 件踏んだ事実は、「常用面のないツールにプラグイン保守税を払う」ことの割に合わなさを裏付けている。最小構成（native LSP + 組み込み補完 + `:find`/`netrw`）は ssh/即席編集の役割に必要十分。

## 再検討のトリガー

1. クラスタ/コンテナ/リモートに**日常的に入る**運用に変わった（nvim の ubiquity が効き始める）
2. Zed が **GitHub PR レビュー（コメントスレッド）をネイティブ実装**した（crit との合成を見直す契機）
3. Zed が no-trackpad 運用や単一画面ワークフローを破壊する変更を入れた（GUI 主力の前提が崩れる）
4. コードを書く比率が大きく戻り、SQL/dbt を超える重量級言語が主戦場になった

## 参考リンク

- [Stack Overflow Dev Survey: VS Code Holds Off AI IDEs (Visual Studio Magazine)](https://visualstudiomagazine.com/articles/2025/08/01/stack-overflow-dev-survey-visual-studio-vs-code-hold-of-ai-ides-to-remain-on-top.aspx)
- [Neovim is highly Admired — Stack Overflow Developer Survey](https://programming.dev/post/85088)
- [Zed vs. Neovim: An Honest Comparison for 2026 (zed.dev)](https://zed.dev/compare/neovim)
- [Zed — Git integration docs](https://zed.dev/docs/git)
- [GitHub integration for reviewing PRs directly inside Zed — Discussion #34759](https://github.com/zed-industries/zed/discussions/34759)
- [Support for PR reviews inside the editor — Discussion #40786](https://github.com/zed-industries/zed/discussions/40786)
- [Zed — The AI Code Editor Built for Speed (Terminal Threads / Parallel Agents)](https://zed.dev/ai)
