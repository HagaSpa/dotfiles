# cmux 移行検討結果 (2026-06)

iterm + tmux から cmux に移行した友人をきっかけに、現在の ghostty + tmux 環境を cmux に乗り換える価値があるかを検討した結果。**結論: 当面 cmux に移行しない。ghostty + tmux を継続する。**

## 背景

- ターミナルに求める要件は **「軽い」「キーボードのみで操作できる」** の 2 点
- 現状は **ghostty（ターミナルエミュレータ）+ tmux（多重化）** の構成
- tmux は prefix を `Ctrl+Space` に変更し、HRM・vim キーバインド・resurrect/continuum・yazi popup 連携などかなり作り込んでいる（→ [terminal-workflow.md](terminal-workflow.md)）
- 友人が「iterm + tmux → cmux」へ移行したため、同じ価値が自分にもあるかを確認

## cmux とは

「cmux」は同名プロジェクトが複数あるため注意。今回の文脈（iterm + tmux からの移行）に合致するのは **manaflow-ai/cmux**（2026-02 リリース）。

| 名前 | 正体 | 今回との関連 |
|---|---|---|
| **manaflow-ai/cmux** | AI コーディングエージェント向け macOS ネイティブターミナル | ✅ これが検討対象 |
| soheilhy/cmux | Go の接続マルチプレクサ（同一ポートで gRPC/HTTP 等を多重化） | ❌ 無関係 |
| craigsc/cmux | Claude Code 用 git worktree ライフサイクル管理ツール | △ 用途次第で別途検討余地 |

manaflow-ai/cmux の特徴:

- **主目的は「複数の AI コーディングエージェント（Claude Code, Codex 等）を並列で回す」こと**。公式も *"The terminal built for coding agents, multitasking"* / *"specifically targeted towards people who use a ton of terminal-based agentic workflows"* と明言
- 中核機能: vertical tabs サイドバー（git ブランチ・PR ステータス・ポート・通知を表示）、エージェント hook 連携の通知システム（OSC 9/99/777 + `cmux notify` CLI）、split panes、embedded browser、socket API、session restore
- 技術: **Swift + AppKit ネイティブ（Electron 不使用）+ libghostty**。これは ghostty とまったく同じレンダリングエンジン
- インストール: `brew tap manaflow-ai/cmux && brew install --cask cmux`（ghostty config を読み込むのでテーマ/フォントは流用される）

## 結論

要件 2 点に対する評価:

| 要件 | cmux の実力 | 評価 |
|---|---|---|
| **軽い** | native Swift + libghostty で *"Fast startup, low memory"*。Warp 等の Electron 系より軽い | △ 既に libghostty 本体（ghostty）を使用中。cmux は embedded browser・通知システム等を載せる分、**ghostty 単体より軽くはならない**（機能増で重い方向） |
| **キーボードのみ** | `⌘N/⌘T/⌘D` 等のショートカット豊富、prefix キー不要 | △ 操作自体は可能だが vertical tabs・notification rings・embedded browser など **GUI 前提の「ハイブリッド設計」**。完全キーボード完結を狙う tmux とは思想が異なる |

→ **「軽い」「キーボードのみ」のどちらも cmux の差別化ポイントではない。** cmux の旨味は AI エージェント並列管理であり、その用途を抜くと移行の動機が消える。友人の移行はおそらくエージェント並列ワークフローを持っているためで、要件が異なる。

## 移行コスト（失うもの）

現状の tmux 資産は cmux に引き継げない:

| 失う機能 | 内容 | cmux での扱い |
|---|---|---|
| HRM 連携の prefix 設計 | `Ctrl+Space` を「左手 D=Ctrl ホールド + 右親指 Space」の bilateral chord で打つ（左手首腱鞘炎対策の核） | ❌ `⌘` ベースショートカットで別物。再設計が必要 |
| tmux-resurrect + continuum | プロセス込みのセッション自動保存/復元 | ❌ cmux の session restore は **UI レイアウトのみ**。*"tmux, vim, shells reopen as normal terminals"* と明記 |
| detach / reattach | SSH 切断後もセッション存続・別マシンから再アタッチ | ❌ **cmux には存在しない**。リモート作業では結局 tmux 併用が必要 |
| vim キーバインド移動 / yazi・HRM popup 連携 | tmux.conf で作り込み済み | ❌ 作り直し |

調査ソースが口を揃えるのは、**cmux と tmux は「代替」ではなく「補完」** だという点。乗り換えても tmux は手放せない。

## 学び

- **ツールの「主目的（誰向けか）」を要件と突き合わせる。** cmux はベンチマーク的な「軽さ・速さ」は満たすが、本質は AI エージェントオーケストレーション。自分の要件（軽い・キーボード）はその副次的性質にすぎず、移行の決め手にならない
- **同じレンダリングエンジン（libghostty）でも、上に載る機能量で「軽さ」は変わる。** ghostty 単体 < cmux（embedded browser 等を内包）
- **「友人が移行した」は移行理由にならない。** 友人と自分でワークフロー（エージェント並列の有無）が違えば、最適なツールも違う

## 再検討のトリガー

以下が発生したら再検討する:

- **Claude Code / Codex を複数 worktree で同時に走らせて並列オーケストレーションしたくなったとき** → cmux 本体、または worktree 特化の craigsc/cmux が刺さる
- 逆に言えば、そのニーズが無いうちは移行不要

## 関連

- [terminal-workflow.md](terminal-workflow.md) — 現状の ghostty + tmux ワークフロー（移行で失う資産の一覧でもある）
- [karabiner-vs-nix.md](karabiner-vs-nix.md) — 同様に「移行コストが ROI に見合わず見送り」となった検討
- [raycast-dotfiles.md](raycast-dotfiles.md) — 同上。「友人/世間が使っている ≠ 自分の要件に合う」の先例

## 出典

- [cmux 公式サイト](https://cmux.com/)
- [GitHub - manaflow-ai/cmux](https://github.com/manaflow-ai/cmux)
- [cmux vs tmux — Agent Terminal vs Terminal Multiplexer (soloterm.com)](https://soloterm.com/cmux-vs-tmux)
- [tmux vs cmux — Battle-Tested Multiplexer vs the AI Agent Terminal (ice-ice-bear)](https://ice-ice-bear.github.io/posts/2026-03-23-tmux-cmux/)
