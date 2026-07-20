# dotfiles 改善ロードマップ (2026-07)

Nix 導入の見送り（→ [brew-vs-nix.md](brew-vs-nix.md)）を受けて、「Nix に期待していた性質を、Nix なしの個別ツールで回収できないか」という観点で改善候補を調査した結果と、その採否。

## 方針

Nix に期待していた性質を分解すると、それぞれ独立に回収できる:

| Nix に期待していた性質 | Nix なしでの回収手段 |
|---|---|
| パッケージバージョンの追跡・再現 | `Brewfile.lock.json` + 定期チェック → **実装途中で見送りに変更**（→ 3） |
| セットアップ手順の宣言化 | mise tasks（→ 4） |
| 構成の正しさの担保 | CI の近代化（→ 2、**2026-07 実装済み**） |
| 設定をプログラミング言語で書ける | `karabiner.ts` パターンの水平展開 → **調査の結果、保留に降格**（→ 1） |

## やる ✅

### 2. CI の近代化 — bats-core + shellcheck / shfmt + actionlint（2026-07 実装済み）

現在の `.github/scripts/test-*.sh` は自作のアドホックなテスト。以下に置き換え・追加する:

- [bats-core](https://github.com/bats-core/bats-core) でシェルテストを構造化（setup/teardown、アサーション、個別実行）
- shellcheck + shfmt を PR に適用 — install.sh / link.sh 等の静的解析と整形チェック
- [actionlint](https://github.com/rhysd/actionlint) で workflow 定義自体も検査

**実装メモ（#157 / #158）**: lint 対象はシェバンで方言判定して自動収集（sh/bash → shellcheck + shfmt、zsh config → `zsh -n`）。lint ツールは CI job が pin して自前インストールし、Brewfile には入れない。テストは `tests/*.bats`（21 テスト）、install.sh の統合テストのみ plain script を維持。

### 4. mise tasks への統合

mise 内蔵の[タスクランナー](https://mise.jdx.dev/tasks/)（依存関係・並列実行・last-modified スキップ付き）に、`install.sh` の手続き連鎖（vim-plug → TPM → yazi plugins → karabiner build）を移す。（当初対象に含めていた `.config/zsh/tasks.sh` は 2026-07 に不使用のため削除済み）

- 既に mise を使っているため追加ツール不要。Make / just 相当を 1 ツールで済ませられる
- 「brew first / mise 格上げ」の既存方針（→ [CLAUDE.md](../CLAUDE.md)）とも整合する

## やらない ❌

### 3. Brewfile のロックファイル運用（2026-07 実装途中で見送り）

`Brewfile.lock.json` をコミットし週次で outdated チェックを回す構想だったが、実装時（PR #159、マージせずクローズ）に前提が崩れた:

- `brew bundle` のネイティブ lockfile は Homebrew 6 で削除済み。旧 `Brewfile.lock.json` も pin 機構ではなくデバッグ用の記録だった（[homebrew-bundle #1509](https://github.com/Homebrew/homebrew-bundle/pull/1509)）
- [公式ドキュメント](https://docs.brew.sh/Brew-Bundle-and-Brewfile)が「lock file の概念は持たないし今後も持たない」と明言。brew はローリングリリース前提で、宣言的なバージョン固定は設計思想としてスコープ外
- 自前 lockfile（生成スクリプト + formulae.brew.sh API 比較の週次レポート）を試作したが、自前の仕組みを維持するコストに見合わないため不採用

代替: **バージョン固定が必要なツールは mise へ格上げ**（既存の「brew first / mise 格上げ」ポリシーで解決。`.mise.toml` が正確なバージョン宣言になる）。「いつ上がったか」の簡易フォレンジックは atuin のシェル履歴（`brew upgrade` の実行記録）と `/opt/homebrew/Cellar` のタイムスタンプで足りる。

### chezmoi への link.sh 移行

chezmoi の主要な強み（マシン間テンプレート・秘密情報の暗号化管理）は、複数マシンを使い回さない本環境の運用実態（→ [brew-vs-nix.md](brew-vs-nix.md) の背景と同じ）では効かない。symlink 27 本は link.sh で問題なく管理できており、移行コストに見合う上積みがない。Nix と同じ構造の結論。

### Codespaces / devcontainer 対応

GitHub は dotfiles リポジトリのネイティブ連携（`install.sh` 自動実行）を持つが、ローカル完結の現運用では実利が薄い。cloud 開発環境を常用するようになったら再検討。

## 保留 🤔

### 1. Config as Code の拡張 — 共通トークンの一元化（2026-07 調査で降格）

フォント名・カラーテーマ等のツール横断の共有値を TypeScript で一元定義し、各 config を生成する構想（`karabiner.ts` パターンの水平展開）だったが、**現状の config を横断調査した結果、共有値がほぼ存在しなかった**:

- フォント: ghostty は SF Mono、zed は family 未指定。重複なし
- カラーテーマ: tmux / zed / starship で各々独立、パレット共有ゼロ
- `$EDITOR`: `.zshenv` の 1 箇所定義で既に一元化済み

実在したのは共有値ではなく「ツール間の暗黙の契約」（tmux.conf が知る ghostty の TERM 名、karabiner の terminal bundle ID、tmux prefix と Karabiner IME bypass の対応）で、件数が少なく生成基盤を作る規模ではない。調査で見つかった不整合（prefix C-Space 化に対して IME bypass が旧 C-b のまま等）は手動で修正済み。**複数ツールでテーマ・フォントを統一したくなったタイミングで再検討する。**

### その他

- **nvim の lazy.nvim 化**: `init.lua` は意図的に最小構成のため、プラグイン管理を育てる需要が出てからで良い
- **README のアーキテクチャ図（mermaid）・docs 索引の整備**: 実害がないため優先度低。上記 1〜4 で構成が変わってから書く方が手戻りがない

## 実施順序の目安

2（CI 近代化、実装済み）→ ~~3（lockfile、見送り）~~ → 4（mise tasks）。残りは 4 のみ。

## 参考リンク

- [mise Tasks](https://mise.jdx.dev/tasks/) / [Make vs Just vs Mise vs go-task (2026)](https://mehdihadeli.com/blog/task-runners-comparison-2026) / [Replacing Makefile, direnv, asdf and more with Mise](https://andri.dk/blog/2025/mise-en-place/)
- [bats-core](https://github.com/bats-core/bats-core) / [action-sh-checker](https://github.com/luizm/action-sh-checker) / [actionlint](https://github.com/rhysd/actionlint) / [ShellCheck GitHub Actions wiki](https://www.shellcheck.net/wiki/GitHub-Actions)
- [Why use chezmoi?](https://www.chezmoi.io/why-use-chezmoi/) / [Exploring Tools For Managing Your Dotfiles](https://gbergatto.github.io/posts/tools-managing-dotfiles/)
- [GitHub Codespaces dotfiles 連携](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers)
