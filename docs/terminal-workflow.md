# Terminal Workflow Guide

現在導入済みのツールとショートカットで実現できるユースケース一覧。

> キー操作の一次情報源は [HRM.md](../.config/karabiner/HRM.md)（`Prefix` → `m`）。

## Directory Navigation / ディレクトリ移動

- よく行くディレクトリに一発移動 — `z foo`
- 候補を fzf で選んで移動 — `zi`
- 前のディレクトリに戻る — `z-`
- 親ディレクトリに移動 — `z..`
- hagaspa workspace に移動 — `haga`
- OLTA workspace に移動 — `olta`
- fzf でディレクトリ選んで cd — `Alt+C`

## File Search / ファイル検索

- ファイルを検索してパスを挿入 — `Ctrl+T`
- ファイルを選んで全体表示 — `bat` → `Ctrl+T`
- ファイル名で検索 — `fd パターン`
- ファイル内容で検索 — `rg パターン`
- 検索して nvim で開く — `nvim ` → `Ctrl+T` → Enter

## Neovim / エディタ

`Space` → `fk` で引けるのは自分で定義したマップだけ。以下は組み込み。

- ジャンプ元に戻る / 進む — `Ctrl+O` / `Ctrl+I`
- ジャンプリストを表示 — `:jumps`
- 直前の位置に戻る — `''`
- 直前のファイルに戻る — `Ctrl+^`
- 組み込みコマンドを調べる — `:help normal-index`

## Tmux / ターミナル多重化

**Prefix: `Ctrl+Space`**

- 新しいウィンドウ作成 — `Prefix` → `c`
- 直前のウィンドウに切替 — `Prefix` → `Space`
- ウィンドウ番号で切替 — `Prefix` → `0-9`
- ペイン移動（左/下/上/右）— `Prefix` → `h/j/k/l`
- ペインを水平/垂直分割 — `Prefix` → `"` / `%`
- yazi をポップアップで開く — `Prefix` → `y`
- HRM チートシート表示 — `Prefix` → `m`
- 本ファイルを表示 — `Prefix` → `M`
- セッション一覧 / ウィンドウ一覧 — `Prefix` → `s` / `w`
- コピーモード（vi）— `Prefix` → `[`
- デタッチ — `Prefix` → `d`
- セッション手動保存 / 復元 — `Prefix` → `Ctrl+S` / `Ctrl+R`

セッションは自動保存・自動復元される（tmux-continuum）。

## Yazi / ファイルマネージャ

`Prefix` → `y` で起動。nvim のペインから呼ぶと `:args` で渡る。

- プロジェクト保存 — `Ctrl+P` → `s`
- プロジェクト読込 — `Ctrl+P` → `l`
- 前回のプロジェクト — `Ctrl+P` → `p`
- プロジェクト削除 — `Ctrl+P` → `d`

隠しファイルはデフォルトで表示。

## History / コマンド履歴

- 履歴をインクリメンタル検索 — `Ctrl+R`
- 補完候補を確定 — `→`（右矢印）

## Text / テキスト操作

- ファイル内容を表示 — `bat ファイル`
- ファイル一覧 — `ls` / `l`
- 後方 / 前方へ単語移動 — `⌥+←` / `⌥+→`（`Ctrl+,` / `Ctrl+.` でも可）
- 後方へ単語削除 — `⌥+Backspace`
- 前方へ単語削除 — `⌥+D`
- 現在のコマンドラインをコピー — `Ctrl+P` → `Ctrl+O`
- 画面クリア — `Ctrl+G`

> **`Ctrl+W` は単語削除にならない**（Page Up に再マップ済み・末尾に `~` が残る）。
> 後方単語削除は `⌥+Backspace`。

## Keyboard Shortcuts (Karabiner / HRM)

一次情報源は [HRM.md](../.config/karabiner/HRM.md)（`Prefix` → `m`）。以下は要約。

ホールドで修飾キーになるキー:

- `F`（左人差し）— Shift / 全アプリ
- `S`（左薬指）— Option / 全アプリ
- `D`（左中指）— Control / 全アプリ
- `J`（右人差し）— Shift / ターミナル・Chrome・Zed を除く
- `;`（右小指）— ⌘⌥⌃（Raycast 用）/ 全アプリ
- `Cmd`（tap）— 英数（左）/ かな（右）、hold で Cmd

`A`（左小指）には HRM を載せない（左手首腱鞘炎対策）。Cmd は物理キーのまま。

Ctrl navigation（D ホールドで Ctrl を作って発火・全アプリ）:

- 矢印キー（左/下/上/右）— `Ctrl+H/J/K/L`
- 単語単位で左/右移動 — `Ctrl+,` / `Ctrl+.`
- Page Up / Page Down — `Ctrl+W` / `Ctrl+V`

ターミナル限定:

- tmux prefix の送出と同時に IME を抜く — `Ctrl+Space`

## Typical Workflows / よくある作業フロー

別プロジェクトのファイルを素早く開く:

```
zi          # fzf でプロジェクト選択 → cd
nvim Ctrl+T # fzf でファイル選択 → Neovim で開く
```

tmux で複数プロジェクトを並行作業:

```
Prefix c           # 新ウィンドウ作成
zi                 # プロジェクトに移動
Prefix Space       # 直前のウィンドウに素早く戻る
```
