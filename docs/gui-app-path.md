# GUI アプリ起動時の PATH 欠落と mise shims (2026-07)

Neovide で `.rs` を開いても rust-analyzer が起動しない事象を調べた結果、**GUI から起動したアプリが `.zshrc` を読まないため mise 管理のツールが PATH から消えていた**ことが原因だった。**対応: `.zshenv` に mise の shims ディレクトリを追加した。nvim 側（mason 等）には寄せない。**

## 症状と切り分け

Neovide 内の nvim で `rust_analyzer` の LSP クライアントが 0 件。一方で `ts_ls` / `yamlls` は動いていた。

Neovide が起動している nvim の実プロセス:

```
/usr/bin/login -fpq haga /bin/zsh -c exec nvim --embed -p
```

`login` を挟むのは Neovide が意図的にやっていること（[FAQ の "macOS Login Shells"](https://neovide.dev/faq.html) — GUI ログインは `.zprofile` を実行しないため）。ただし `zsh -c` は**非対話**なので、そこから先の `.zshrc` は読まれない。本リポジトリでは `mise activate zsh` が `.zshrc` にしかないため、mise 管理ツールのパスが一切生えない。

`ps eww` で見た当時の nvim の PATH（mise 系ゼロ）:

```
/opt/homebrew/bin, /usr/local/bin, /usr/bin, /bin, ... , ~/.cargo/bin, ~/.local/bin
```

| 起動経路 | シェル | `.zprofile` | `.zshrc` | mise パス |
|---|---|---|---|---|
| ghostty の nvim | 対話 | ✅ | ✅ | ✅ |
| Zed | 起動時に対話ログインシェルで env を捕捉 | ✅ | ✅ | ✅ |
| Neovide（Dock / Raycast） | `login` + `zsh -c`（非対話） | ✅ | ❌ | ❌ |

分岐点は「brew か mise か」ではなく「**PATH の生え方が `.zshrc` に依存しているか**」。brew のサーバーは `/opt/homebrew/bin` に実体があり `.zprofile` の `brew shellenv` で解決できるので無事だった。Zed は起動時に対話ログインシェルを走らせて環境変数を取り込む実装を持つため影響を受けない（実測: Zed が起動した rust-analyzer は mise の `installs/` から起動していた）。

## 対応

`.zshenv`（非対話でも読まれる）に shims を追加する。

```sh
export PATH="$HOME/.local/share/mise/shims:$PATH"
```

- mise の公式ドキュメントも [IDE やスクリプトなど非対話環境では shims を使う](https://mise.jdx.dev/dev-tools/shims.html)ことを推奨している（対話シェルは `mise activate` 推奨）
- 対話シェルでは後から `.zshrc` の `mise activate` が `installs/` を PATH 先頭に置くため、shims は事実上使われない。ghostty / Zed の解決先は変更前と同じ（検証済み）
- `~/.cargo/bin`（rustup）より後ろに置いてあるので、`cargo` / `rustc` の解決先も従来どおり変わらない
- shims は**実行時のカレントディレクトリで版を解決する**ので、プロジェクトごとのバージョン固定は保たれる

shims の既知の制約は「`mise.toml` の `[env]` が mise 管理ツールにしか渡らない」「`cd` / `enter` / `leave` フックが効かない」「`which` が shim のパスを返す」の 3 点。`.mise.toml` は `[settings]` と `[tools]` だけで `[env]` もフックも使っていないため、実害はない。

## なぜ nvim 側（mason）に寄せないか

「nvim で使うものは nvim の中で完結させたほうがいいのでは」という設計案は検討した上で不採用。

- **mason では塞ぎきれない**: mason は自前の bin を `vim.env.PATH` に前置するので LSP バイナリは動くようになるが、mason が入れる node 系サーバー（ts_ls / yaml-language-server / eslint 等）は実行に `node` を要求し、その `node` は mise 管理なので PATH が壊れたままでは動かない。formatter、`tree-sitter` CLI、`:!` で叩く外部コマンドも同じ穴に落ちる。**PATH を直せば mason は要らず、直さなければ mason でも足りない**
- **mise の主要価値を失う**: mason はグローバル 1 バージョンで、プロジェクトごとの版固定ができない
- **パッケージマネージャが 3 つになる**: brew first / 必要なものだけ mise、という本リポジトリの方針（CLAUDE.md）と衝突する。LazyVim を見送った理由（→ [editor-strategy.md](editor-strategy.md)）とも同じ

採用した設計境界は次のとおり:

> 実行ファイルの供給はシェル層（brew / mise）の責務。nvim は PATH を消費するだけ。GUI 起動時の env 欠落は入口（`.zshenv`）で一度だけ直す。

nvim 側（`init.lua` で `vim.env.PATH` に前置）で塞ぐ案もあるが、Neovide からしか使わないツールは存在しないため二重管理になるだけと判断した。

## 検証手順

Neovide の環境を再現して LSP の attach を確認する。

```sh
SIM=$(env -i HOME=$HOME TERM=xterm /bin/zsh -l -c 'echo $PATH')   # login + 非対話 = Neovide 相当
cd ~/workspaces/hagaspa/csvtool
env -i HOME=$HOME TERM=xterm PATH="$SIM" nvim --headless src/main.rs \
  -c 'sleep 8' \
  -c 'lua print(#vim.lsp.get_clients({bufnr=0}), vim.fn.exepath("rust-analyzer"))' -c 'qa'
```

修正前は `0`（`exepath` が空）、修正後は `1 /Users/<user>/.local/share/mise/shims/rust-analyzer`。

起動中の GUI アプリの実効 PATH を直接見る場合:

```sh
pgrep -fl "nvim --embed"        # Neovide 配下の nvim を特定
ps eww -p <pid> | tr ' ' '\n' | grep '^PATH='
```

なお、ターミナルから `neovide` と打って起動した場合は親シェルの環境を継承するのでこの症状は出ない。**Dock / Raycast 起動でのみ再現する**点が切り分けを紛らわしくする。

## 再検討のトリガー

1. `.mise.toml` に `[env]` やディレクトリフックを使い始めた（shims の制約が実害になる。`.zshenv` 側で `mise activate` を呼ぶ構成への変更を検討する）
2. Neovide が対話シェル経由の env 取り込みを実装した（shims 追加が不要になる可能性）
3. mise 管理ツールを新規追加したのに GUI から見えない（`mise reshim` が要るケース。shim の有無を `ls ~/.local/share/mise/shims` で確認する）

## 参考リンク

- [mise: Shims](https://mise.jdx.dev/dev-tools/shims.html) — 非対話環境では shims、対話シェルでは activate
- [Neovide FAQ: macOS Login Shells](https://neovide.dev/faq.html) — GUI ログインが `.zprofile` を実行しない件
- [editor-strategy.md](editor-strategy.md) — nvim / Zed の役割分担と LazyVim 見送りの判断
