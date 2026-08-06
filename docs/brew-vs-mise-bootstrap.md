# brew → mise bootstrap 移行 検討結果 (2026-08)

mise の [`mise bootstrap`](https://mise.jdx.dev/bootstrap.html)（v2026.7.4 で GA）が、システムパッケージ・dotfiles・macOS 設定・ログインシェルまで宣言的に扱えるようになったため、**Brewfile + install.sh + link.sh + settings.sh をまとめて mise に寄せられないか**を検討した。**結論: 見送り。現構成（Brewfile + mise + link.sh + settings.sh）を継続する。**

動機は「brew に不満がある」ではなく「mise に統一した方がモダン」だったが、**その統一が原理的に成立しない**ことが見送りの主因。

## 検討時の環境

- mise 2026.8.1 (macos-arm64)
- 現構成: Brewfile（formula 約 30 + cask 4）+ `.mise.toml`（tools 8 個）+ link.sh（symlink 28 本）+ settings.sh（`defaults write` 5 項目）+ mise-tasks/ + CI（bats + install.sh 実行テスト）

## 1. mise bootstrap は brew を置き換えない（最大の理由）

`[bootstrap.packages]` は brew の代替ではなく**ラッパー**。公式ドキュメントは対象を「OS packages from apk, apt, dnf, pacman, **brew**, flatpak, or mas」と定義しており、CLI にも brew 前提のサブコマンドがある。

```
$ mise bootstrap packages --help
Commands:
  brew     Manage Homebrew taps used by bootstrap packages
  import   Import installed system packages into [bootstrap.packages]
           Currently supports Homebrew formulae only.
           By default, imports linked formulae whose active keg receipt says
           they were installed on request.
```

移行後の姿は「Brewfile の内容が mise.toml に移り、インストール実行者は brew のまま」。**brew は消えず、mise が上に乗って層が増える。** これは [brew-vs-nix.md](brew-vs-nix.md) の見送り理由 3「パッケージマネージャが減らずに増える」と同じ構図で、「mise に統一」という当初の動機がそもそも満たされない。

## 2. settings.sh はほぼ丸ごと移せない

[`[bootstrap.macos.defaults]`](https://mise.jdx.dev/bootstrap/macos-defaults.html) が扱える値は **bool / int / float / string のみ**。配列・辞書・日付・data といった plist 形式は未対応で、**該当エントリはパースされたうえで警告付きでスキップされる**。ユーザースコープ限定で `-currentHost` も非対応。

現行 settings.sh との照合:

| 設定 | mise で書けるか |
|---|---|
| `ApplePressAndHoldEnabled` -bool | ✅ |
| `com.apple.trackpad.scaling` -float | ✅ |
| `Clicking` -bool（2 ドメイン） | ✅ |
| `-currentHost write NSGlobalDomain com.apple.mouse.tapBehavior` | ❌ `-currentHost` 未対応 |
| `symbolichotkeys -dict-add 60 <XML plist>`（Ctrl+Space 解放） | ❌ dict 未対応 |
| `activateSettings -u` | ❌ 該当機能なし |

symbolichotkeys は plist の型が落ちると**次のログインまで症状が出ない**（→ 過去に同種の事故あり。`defaults write '{enabled = 0; ...}'` の旧形式で型が文字列に落ちた件）。「警告付きでスキップ」は最悪の失敗モードで、Ctrl+Space が数日後に静かに死ぬ。

結果として settings.sh は `bootstrap` タスクから呼ぶ形で残り、宣言化されない。

## 3. `.mise.toml` を `~/.mise.toml` に symlink している構造と衝突する

本リポジトリは `.mise.toml` をグローバル config として symlink しているため、**タスクを `.mise.toml` に置かない**（全プロジェクトに漏れるため `mise-tasks/` の file task にする）という設計を採っている。`[bootstrap.*]` / `[dotfiles]` も同じ問題を踏む。

repo-local に別 `mise.toml` を置けば回避できるが、リポジトリ内に mise config が 2 枚になり設計の一貫性が崩れる。加えて `[dotfiles]` の相対パス解決が symlink 先基準になるかは未検証。

## 4. karabiner.json は `[dotfiles]` でも同じ地雷を踏む

[`[dotfiles]`](https://mise.jdx.dev/dotfiles.html) の symlink モードは link.sh の代替になりうるが、Karabiner 本体の atomic write が symlink を実ファイル化する問題（→ [karabiner-vs-nix.md](karabiner-vs-nix.md)）は mise でも変わらない。さらに mise は**リンク先に実ファイルが存在する場合 `--force` を要求する**ため、`mise bootstrap` の再実行ごとに引っかかる。現行の `bun run build` → `cmp -s || cp` の sync 運用は移行後も残る。

`.claude/settings.json`（Claude Code が実行時に更新）も同種の mutable config で、[brew-vs-nix.md](brew-vs-nix.md) の見送り理由 2 と同じ論点。

## 5. その他のコスト

- **`import` は formula のみで cask 非対応** — cask 4 つは手書き。cask / mas は状態管理が独自仕様で、既存導入済みマシンで再インストール扱いになる可能性がある（→ 参考記事の制約節）
- **CI が全面書き直し** — bats テスト（link / config / Brewfile / settings）と `.github/scripts/test-install.sh` は現構成前提
- **GA 直後** — v2026.7.4 は 2026-07。参考記事自身が「実装の荒さが残る」と書いている

## 差し引き（公平な記録）

得られるのは「`install.sh` + `link.sh` + `settings.sh` + `mise-tasks/` が `mise bootstrap` 1 コマンドに集約される」こと。宣言が TOML 1 箇所に集まる見通しの良さと、Nix より圧倒的に低い学習コストは実際に魅力がある。

ただし上記のとおり **brew も settings.sh も karabiner の sync も残る**ため、実際に消えるのは link.sh（28 エントリの symlink 実装）程度。CI 書き直しのコストと釣り合わない。

なお `mise bootstrap packages import --dry-run` は config を書かずに「Brewfile が mise.toml でどう表現されるか」だけ出力するので、感触を掴むだけなら無害に試せる。

## 再検討のトリガー

1. `[bootstrap.macos.defaults]` が dict 値と `-currentHost` に対応した（settings.sh が消えるようになる）
2. cask / mas の状態管理が安定し、`import` が cask にも対応した
3. 複数の Mac を日常的に使い回す運用に変わった（[brew-vs-nix.md](brew-vs-nix.md) と同じトリガー）

## 参考リンク

- [mise bootstrap で環境構築を完結するようにした（DevelopersIO, 2026-07-16）](https://dev.classmethod.jp/articles/setup-machine-with-mise-bootstrap/)
- [mise bootstrap 公式ドキュメント](https://mise.jdx.dev/bootstrap.html)
- [mise dotfiles](https://mise.jdx.dev/dotfiles.html) / [mise macOS defaults](https://mise.jdx.dev/bootstrap/macos-defaults.html)
- [brew-vs-nix.md](brew-vs-nix.md) — 同じ「宣言的管理に寄せたい」動機で 2026-07 に見送った記録
