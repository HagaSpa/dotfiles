# エディタ戦略: nvim (Neovide) へ主力移行中・Zed 併用・レビューは crit (2026-07)

2026-07 前半に「主力は Zed、nvim は built-ins only の小道具」と一度結論したが、**2026-07-22 に本人判断で nvim 主力化を再トライアル**し、現在も継続中。**現状: 日常の編集を nvim (Neovide) に寄せる移行期間で、Zed は併用。PR / AI 成果物レビューは crit を層として残す（当初判断から不変）。** トライアルの成否判定軸は設けていない（期限や judge 基準を決めずに訓練期間として続ける）。

## 現在地 (2026-07-27)

| 項目 | 状態 |
|---|---|
| GUI フロントエンド | **Neovide**（#175）。`frame = "none"`、フォントは SF Mono 15pt（→ [.config/neovide/config.toml](../.config/neovide/config.toml)） |
| プラグイン管理 | lazy.nvim。`lazy-lock.json` 11 エントリ（lazy.nvim 自身を含む） |
| 構成 | `init.lua` は bootstrap のみ。`lua/config/`（options / keymaps / autocmds / lsp）+ `lua/plugins/`（git / editor / picker / treesitter / ui）に分割（#189） |
| LSP | nvim-native `vim.lsp.config` + `vim.lsp.enable`。yamlls / rust_analyzer / ts_ls。**mason 不使用の PATH ベース運用** |
| picker | snacks.nvim（telescope から置換, #182）。LSP のジャンプ系も snacks に集約（#186） |
| git | gitsigns + snacks.picker (git_diff / git_status) + lazygit フロート（#187） |
| その他 | oil.nvim（#179）、which-key（#184）、neovim-project + session-manager、treesitter、kanagawa (wave) |

派生して解決した問題: GUI から起動した Neovide は `.zshrc` を読まず mise 管理ツールが PATH から消える（rust-analyzer が起動しない）。`.zshenv` に mise shims を追加して解消 → [gui-app-path.md](gui-app-path.md)。

## 当初の判断（2026-07 前半）とその根拠

以下は再トライアル前の分析。**前提の多くは今も有効**なので、判断の土台として残す。

### 背景（判断を規定した制約）

- **打鍵最速・トラックパッド一切不使用**（VS Code / Cursor はこの理由で不採用）
- **MacBook 15" 単一画面のみ・外部ディスプレイ不使用**。全アプリを maximize し、Raycast で切り替える
- 上記から **Claude Code をエディタに組み込まない**。Claude Code は ghostty かネイティブアプリで動かす
- **k8s クラスタにほぼログインしない**（GKE マネージド・GitOps・本番ログイン回避）
- **PR レビュー・Notion 資料作成が中心**で crit を多用。業務コードは **SQL・dbt** がほとんど
- ディレクトリ移動は ghostty、git 操作は Claude Code skill に寄っている

### 調査結果（2025〜2026）

| 指標 | 数値 | 出典 |
|---|---|---|
| エディタシェア (SO Survey 2025) | VS Code ~76% / Vim ~24% / **Neovim ~12–14%** / **Zed 7.3%** / Cursor 18% / Claude Code ~10% | Stack Overflow Developer Survey 2025 |
| Neovim の満足度 | **most admired** エディタ（2024: 83%、2025 も1位）。継続利用意向 81%（VS Code 77%） | 同上 / programming.dev |
| Zed の到達点 | 2026-04 に **Zed 1.0**。ACP で Claude Code / Codex / Gemini CLI をネイティブ統合、並列エージェント対応 | zed.dev |

Neovim は「使う人の満足度・定着率が突出して高いニッチ」。ただし「直近シニアが続々 nvim へ移行」という事実はない。Zed 自身の比較でも nvim の優位は「ターミナルネイティブ（SSH・コンテナ・リモート）」「Lua の拡張性」とされる。

### 当時の結論

「クラスタにほぼ入らない → **nvim 最大の固有レバレッジ（リモート/ターミナル ubiquity）が無効化**」を分岐点として、Zed を主力に確定し、nvim は built-ins only に留めると決めた。同時に、lazy.nvim + telescope + mason で組んだ IDE 構成を一度全破棄している。

## 再トライアルで変わったこと・変わっていないこと

| 当初の前提 | 現在 |
|---|---|
| トラックパッド不使用の GUI は Zed だけ | ❌ **崩れた**。Neovide の採用で GUI 版 nvim が選択肢に入った（これが再トライアルを可能にした実質的な変化） |
| nvim には常用面がない | ❌ **崩れた**。日常編集を nvim に寄せる運用に変えた（本人の意思による転換で、外部条件の変化ではない） |
| クラスタにほぼ入らない | ⭕ 不変。ubiquity は依然として決め手にならない（＝ nvim を選ぶ理由は ubiquity ではなく打鍵体験と拡張性） |
| SQL / dbt 中心・重量級 IDE 機能は不要 | ⭕ 不変 |
| Claude Code をエディタに組み込まない | ⭕ 不変。ghostty / ネイティブで動かす |
| レビューは crit が必要 | ⭕ 不変（次節） |

## レビュー体験の事実確認（期待と現実のズレ）

「crit でやってることをエディタ単体で満たせるか」の確認結果。**結論: 不可。crit は手放さない。** これは Zed 主力を前提にした確認だが、nvim 主力化後も結論は変わらない（nvim にも PR コメントスレッド層はない）。

- **ローカルの git 差分レビュー**は Zed が得意（ファイル単位 diff タブ、ハンク単位 stage/restore、multibuffer）。nvim 側は gitsigns + snacks.picker + lazygit で代替する構成にした（#187）
- **GitHub の PR レビュー（コメントスレッド・viewed マーク）は Zed にまだ無い**（2026 時点で要望多数・未実装）
- **AI 変更のハンク accept/reject は crit の代替ではない**。あれは承認ゲートであり、批評を残す crit とは目的が違う。しかも Zed 内でエージェントを動かしているときだけ現れる UI で、ghostty で Claude Code を動かす本運用では表示されない

→ エディタ = 差分の**閲覧・編集サーフェス**、crit = **レビューコメント層**（エディタ非依存・GitHub PR 同期）。両者は競合ではなく**合成**する。

## 維持している判断

1. **Claude Code をエディタに組み込まない**（単一画面・maximize 運用のため）
2. **レビューは crit + エディタの合成**。エディタのネイティブ PR レビューを当てにしない
3. **LSP は PATH ベース（brew / mise）で mason を使わない**。理由と設計境界は [gui-app-path.md](gui-app-path.md)
4. **LazyVim へは移行しない**。mason 前提の LSP スタックが PATH ベース運用と衝突し、core だけでプラグインが 11 → 28 に増える（→ [tooling-roadmap.md](tooling-roadmap.md)）
5. **Zed は消さない**。移行期間中の併用先として残す

## 引き受けたコスト

nvim 主力化は、当初「常用面がないので割に合わない」と判断した**プラグイン保守税を引き受ける**という選択でもある。実際 2026-07 の一度目の構築では、nvim 0.12.4 に対して固定タグ / 旧ブランチの非互換を 1 セッションで 3 件踏んだ（nvim-treesitter master、telescope 0.1.8、main ブランチの tree-sitter CLI 依存）。常用面ができた以上この税は回収可能な見込みだが、**プラグインを増やすほど戻りにくくなる**点は意識して、追加は「最小構成 + 明確に便利なもの」に絞る。

## 再検討のトリガー

1. **保守税が回収できないと感じ始めた**（nvim 更新のたびに壊れて作業が止まる頻度が上がった）→ プラグイン削減か Zed 復帰を検討
2. Zed が **GitHub PR レビューをネイティブ実装**した（crit との合成を見直す契機。nvim 主力化とは独立の論点）
3. Neovide が no-trackpad 運用や単一画面ワークフローを破壊する変更を入れた
4. クラスタ / コンテナに**日常的に入る**運用に変わった（nvim の ubiquity が効き始め、判断がさらに補強される）
5. コードを書く比率が大きく戻り、SQL/dbt を超える重量級言語が主戦場になった

## 参考リンク

- [Neovide](https://neovide.dev/) / [Neovide FAQ: macOS Login Shells](https://neovide.dev/faq.html)
- [Stack Overflow Dev Survey: VS Code Holds Off AI IDEs (Visual Studio Magazine)](https://visualstudiomagazine.com/articles/2025/08/01/stack-overflow-dev-survey-visual-studio-vs-code-hold-of-ai-ides-to-remain-on-top.aspx)
- [Neovim is highly Admired — Stack Overflow Developer Survey](https://programming.dev/post/85088)
- [Zed vs. Neovim: An Honest Comparison for 2026 (zed.dev)](https://zed.dev/compare/neovim)
- [Zed — Git integration docs](https://zed.dev/docs/git)
- [GitHub integration for reviewing PRs directly inside Zed — Discussion #34759](https://github.com/zed-industries/zed/discussions/34759)
- [Support for PR reviews inside the editor — Discussion #40786](https://github.com/zed-industries/zed/discussions/40786)
