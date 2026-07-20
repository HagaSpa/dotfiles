# brew vs Nix 再検討結果 (2026-07)

2026-04 の検討（→ [karabiner-vs-nix.md](karabiner-vs-nix.md)）では「OS 設定だけ Nix に委譲できないか」を見て見送った。今回は条件を広げ、**brew 自体を Nix（nix-darwin + home-manager）に移行することも含めて**再検討した。**結論: 今回も見送り。brew + mise + link.sh の現構成を継続する。**

## 背景

- Karabiner Elements は引き続き使う前提（Nix で代替しない）
- セットアップ未実施の 2 台目の Mac はあるが、**プライベート開発も業務 PC 上で行っており、複数の MacBook を使い回すシーンがない**。そのため Nix 最大の強み（複数マシンの厳密同期・新マシンの完全再現）が効く運用実態ではない
- 現構成: Brewfile（formula 約 30 + cask 4）+ mise（PJ ごと版差対応のランタイム）+ link.sh（symlink 27 本）+ settings.sh（`defaults write` 3 項目）+ CI テスト

## 2026-04 から変わっていた点

| 項目 | 状況 |
|---|---|
| macOS アップデートで Nix が壊れる問題 | ✅ ほぼ解決。[Determinate Systems インストーラ](https://discourse.nixos.org/t/nix-survival-mode-macos-upgrades-wont-break-nix-anymore-when-you-install-nix-using-the-determinate-nix-installer/34593)が macOS アップグレード耐性を持つ |
| brew 自体の宣言的管理 | ✅ 成熟。[nix-homebrew](https://github.com/zhaofengli/nix-homebrew) が brew 本体・tap を固定、nix-darwin の `homebrew.*` が Brewfile 相当（cask 含む）を宣言管理 |
| Ghostty の nixpkgs 対応 | △ `ghostty-bin`（公式 dmg 再パッケージ）あり。macOS ではソースビルド不可（Swift ツールチェーン等の制約、[Discussion #2824](https://github.com/ghostty-org/ghostty/discussions/2824)） |

## 見送りの理由

### 1. Karabiner が Nix の外に残り続ける（構造問題、前回と同じ）

nix-darwin の `services.karabiner-elements` は **Karabiner v15 以降のファイル配置変更に追従できておらず破損報告が続いている**（[#1041](https://github.com/LnL7/nix-darwin/issues/1041), [#1132](https://github.com/nix-darwin/nix-darwin/issues/1132), [#1092](https://github.com/nix-darwin/nix-darwin/issues/1092)）。v16 を使う本環境では brew cask か公式インストーラ継続が現実解。つまり「brew を Nix に移行」しても brew（か手動管理）は消えない。

### 2. home-manager の symlink 管理が本環境のワークフローと両立しない

home-manager の `home.file` は **Nix store 内の読み取り専用ファイルへの symlink** を張る方式。本環境には「実行時に書き換わる設定ファイル」が複数ある:

- `karabiner.json` — Karabiner 本体が atomic write で書き換え、`bun run build` の sync で repo に書き戻す運用（→ [karabiner-vs-nix.md](karabiner-vs-nix.md) の経緯も参照）。読み取り専用 symlink とは根本的に両立しない
- `.config/claude/settings.json` — Claude Code が実行時に更新する

回避策の [`mkOutOfStoreSymlink`](https://jeancharles.quillet.org/posts/2023-02-07-The-home-manager-function-that-changes-everything.html) は書き込み可能になるが、**実質 link.sh の再実装**（flakes 併用時は store パスを指す罠もある）で、現行 link.sh に対する上積みがない。

### 3. パッケージマネージャが減らずに増える

- mise は「PJ ごとの版差を尊重する」という本リポジトリの方針上残る。Nix 流の代替（per-project flake + direnv）は働き方の大改造
- terraform は BUSL ライセンスのため nixpkgs では `allowUnfree` が必要
- `crit` などニッチな formula は nixpkgs に見当たらず、overlay 自作か brew 残し
- 結果として **Nix + brew（Karabiner/cask 用に残存）+ mise の 3 層**になり、2026-04 に見送った「並存で複雑化するだけ」がむしろ悪化する

### 4. 実質 1 台運用なのでリターンが薄い

複数マシンの厳密同期という Nix の主要ユースケースが運用実態にない（上記背景）。仮に新マシンをセットアップする場合も、本環境の規模（formula 約 30・defaults 3 項目・symlink 27 本）では **`install.sh` + `link.sh` + `settings.sh` の現構成で十分再現できる**。CI が install.sh の実行テストまで持っているため、セットアップ手順の腐敗リスクも低い。移行記事（[Homebrew から Nix に移行する](https://mizunashi-mana.github.io/blog/posts/2025/06/migrate-homebrew-to-nix/) 等）で定番の不満（brew 併用の非冪等性、Nix 管理 GUI アプリが Spotlight に出ない、学習コスト）を引き受けてまで得るものがない。

## 導入した場合に得られたもの（公平な記録）

- 世代スナップショットとロールバック（`brew upgrade` 事故からの即時復旧）
- flake ひとつで「パッケージ + macOS defaults + launchd + symlink」を単一コマンド適用
- nix-homebrew による brew 本体・tap の固定（auto-update 由来の非再現性の封殺）
- **設定をプログラミング言語（Nix 言語）で書ける**: 変数・関数・モジュール分割で共通値（フォント名・色・パス等）を一元化し、条件分岐や抽象化で運用保守をやりやすくできる。生 JSON を嫌って TypeScript 化した `karabiner.ts` と同種の動機。home-manager の options システムは型チェック付きで、ツール横断の設定を 1 箇所から導出できるのは shell script + 個別 config ファイルの現構成にはない強み。ただし Nix 言語は汎用言語ではなく独自の遅延評価・関数型 DSL であり、学習コストとエラーメッセージの難解さがそのまま保守コストとして跳ね返る両刃でもある

## 再検討のトリガー

1. per-project 開発環境を direnv + flake で管理したくなった（mise 代替まで踏み込む動機が出たとき）
2. `defaults write` や launchd 常駐の宣言管理対象が 20 項目を超えた
3. `services.karabiner-elements` が v15+ 対応で安定した
4. **複数の Mac を日常的に使い回す運用に変わった**（現状はプライベート開発も業務 PC 上で完結しており該当しない）

※ Mac をセットアップする機会があれば、それ自体が現構成（install.sh / link.sh / settings.sh）の再現性テストになる。穴が見つかったら本ドキュメントに追記する。

## 参考リンク

- [Homebrew から Nix に移行する（続くといいな日記, 2025-06）](https://mizunashi-mana.github.io/blog/posts/2025/06/migrate-homebrew-to-nix/)
- [zhaofengli/nix-homebrew](https://github.com/zhaofengli/nix-homebrew)
- [nix-darwin homebrew module](https://github.com/LnL7/nix-darwin/blob/master/modules/homebrew.nix)
- [You don't have to use Nix to manage your dotfiles](https://jade.fyi/blog/use-nix-less/)
- [Nix on MacOS - The Good, the Bad and the Ugly](https://drakerossman.com/blog/nix-on-macos-the-good-the-bad-and-the-ugly)
