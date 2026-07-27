# Terminal Workflow Guide

現在導入済みのツールとショートカットで実現できるユースケース一覧。

> キーボード操作（HRM・Ctrl ナビ・tmux prefix）の一次情報源は [`.config/karabiner/HRM.md`](../.config/karabiner/HRM.md)。tmux 内なら `Prefix` → `m` でいつでも表示できる。本ファイルはツール横断の早見表。

## Directory Navigation / ディレクトリ移動

| ユースケース | コマンド | ツール |
|---|---|---|
| よく行くディレクトリに一発移動 | `z foo` | zoxide |
| 候補を fzf で選んで移動 | `zi` | zoxide + fzf |
| 前のディレクトリに戻る | `z-` | zoxide (alias) |
| 親ディレクトリに移動 | `z..` | zoxide (alias) |
| hagaspa workspace に移動 | `haga` | alias → `z ~/workspaces/hagaspa` |
| OLTA workspace に移動 | `olta` | alias → `z ~/workspaces/OLTAInc` |
| fzf でディレクトリ選んで cd | `Alt+C` | fzf |

## File Search / ファイル検索

| ユースケース | コマンド | ツール |
|---|---|---|
| カレントディレクトリ配下のファイルを検索してパスを挿入 (bat プレビュー付き) | `Ctrl+T` | fzf + fd + bat |
| ファイルを選んで bat で全体表示 | `bat` → `Ctrl+T` | fzf + bat |
| ファイル名で検索 | `fd パターン` | fd |
| ファイル内容で検索 (grep) | `rg パターン` | ripgrep |

**典型的なファイルを開く流れ:**
1. `zi` でプロジェクトに移動
2. `Ctrl+T` でファイルを検索 → `nvim` で開く
   - 例: `nvim ` → `Ctrl+T` → ファイル選択 → Enter

## Neovim / エディタ

**Leader は `Space`**。プラグインは `.config/nvim/lua/plugins/`、エディタ素のキーマップは `lua/config/keymaps.lua`。

### 探す

| ユースケース | キー | 備考 |
|---|---|---|
| ファイル名で開く | `Space` → `ff` | snacks picker。隠しファイル表示・gitignore 除外 |
| 内容で grep | `Space` → `fg` | |
| バッファ切替 | `Space` → `fb` | |
| プロジェクト切替 | `Space` → `fp` / `fP` | 一覧 / 履歴。`~/workspaces` と `~/worktrees` を走査 |
| ファイラを開く | `-` または `Space` → `e` | oil。バッファとして編集し保存で反映 |
| キーマップを検索 | `Space` → `fk` | この config が定義したマップのみ（後述の注意点） |
| ヘルプを検索 | `Space` → `fh` | 組み込みコマンドを調べる入口 |
| 押せるキーを見る | `Space` 単独 | which-key。`g` / `z` / `[` / `]` / `Ctrl+W` では組み込みキーの説明も出る |

### 移動・ジャンプ

| ユースケース | キー | 備考 |
|---|---|---|
| ジャンプ元に戻る | `Ctrl+O` | jumplist。`gd` で定義に飛んだ後もこれで戻る |
| ジャンプ先に進む | `Ctrl+I` | `Tab` と同じ |
| ジャンプリストを表示 | `:jumps` | |
| 直前の位置に戻る | `''` | バッククォート 2 つなら列も復元 |

### LSP

| ユースケース | キー | 備考 |
|---|---|---|
| 定義へ移動 | `gd` | 戻るのは `Ctrl+O` |
| 参照一覧 | `grr` | 実装は `gri`、型定義は `grt`、シンボルは `gO` |
| ドキュメント表示 | `K` | |
| リネーム | `Space` → `rn` | |
| コードアクション | `Space` → `ca` | |
| 診断を表示 | `Space` → `d` | 一覧は `Space` → `fd` |

サーバーは brew / mise で入れて PATH から起動（mason 不使用）。定義は `lua/config/lsp.lua`。

### Git

| ユースケース | キー | 備考 |
|---|---|---|
| 変更 hunk 一覧（repo 全体） | `Space` → `gg` | staged / unstaged 両方。`Tab` で stage |
| 変更ファイル一覧 | `Space` → `gf` | untracked もここに出る |
| lazygit を開く | `Space` → `gG` | float。`e` で親 nvim にファイルが開く |
| 次 / 前の hunk | `]c` / `[c` | |
| hunk を stage / 戻す | `Space` → `gs` / `gr` | visual で選択した行だけにも効く |
| hunk の中身を見る | `Space` → `gi` | その場に inline 展開 |
| blame | `Space` → `gb` | 行末常時表示のトグルは `Space` → `gB` |

gutter のバーは太い `┃` が unstaged、細い `│` が staged。

> **`Space` → `fk` に出ないキーがある**（ハマりやすい点）: このピッカーの情報源は `nvim_get_keymap` で、**`vim.keymap.set` で定義したマップしか一覧できない**。`Ctrl+O` / `dd` / `gg` / `%` のような Neovim 組み込みコマンドは原理的に出てこない。which-key のポップアップにも出ない（`Ctrl+O` は 1 キーで完結するため、プレフィックス待ちが発生せず表示の機会がない）。組み込みを調べたいときは `Space` → `fh` でヘルプタグを検索するか `:help normal-index` を見る。逆に `Ctrl+D` / `n` / `N` が一覧に出るのは、centering (`zz`) 付きで再マップしているため。

## Tmux / ターミナル多重化

**Prefix: `Ctrl+Space`**（D=Ctrl ホールド + 右親指 Space の bilateral chord。`Ctrl+B` は左手同手チョードで打ちにくいため変更。詳細は [HRM.md](../.config/karabiner/HRM.md)）

| ユースケース | キー | 備考 |
|---|---|---|
| 新しいウィンドウ作成 | `Prefix` → `c` | カレントパスを引き継ぐ |
| 直前のウィンドウに切替 | `Prefix` → `Space` | |
| ウィンドウ番号で切替 | `Prefix` → `0-9` | |
| ペイン移動 (左/下/上/右) | `Prefix` → `h/j/k/l` | vim 風 |
| yazi をポップアップで開く | `Prefix` → `y` | Helix 連携あり |
| HRM チートシート表示 | `Prefix` → `m` | HRM.md を bat でポップアップ |
| セッション一覧 | `Prefix` → `s` | |
| ウィンドウ一覧 | `Prefix` → `w` | |
| ペインを水平分割 | `Prefix` → `"` | |
| ペインを垂直分割 | `Prefix` → `%` | |
| コピーモード (vi) | `Prefix` → `[` | vi キーバインドで操作 |
| デタッチ | `Prefix` → `d` | |

**tmux-resurrect / continuum:**
- セッションは自動保存・自動復元される（`@continuum-restore 'on'`）
- 手動保存: `Prefix` → `Ctrl+S`
- 手動復元: `Prefix` → `Ctrl+R`

## Yazi / ファイルマネージャ

tmux 内から `Prefix` → `y` でポップアップ起動。呼び出したペインで nvim が動いていれば、選択したファイルが `:args` で渡される（それ以外は `nvim <paths>` を送る）。

| ユースケース | キー | 備考 |
|---|---|---|
| プロジェクト保存 | `Ctrl+P` → `s` | |
| プロジェクト読込 | `Ctrl+P` → `l` | |
| 前回のプロジェクト | `Ctrl+P` → `p` | |
| プロジェクト削除 | `Ctrl+P` → `d` | |
| 隠しファイル表示 | デフォルトで表示 | show_hidden = true |

## History / コマンド履歴

| ユースケース | コマンド | ツール |
|---|---|---|
| 履歴をインクリメンタル検索 | `Ctrl+R` | atuin |
| コマンド入力中に補完候補表示 | (自動) | zsh-autosuggestions |
| 補完候補を確定 | `→` (右矢印) | zsh-autosuggestions |

## Text / テキスト操作

| ユースケース | コマンド | ツール |
|---|---|---|
| ファイル内容を表示 (シンタックスハイライト付き) | `bat ファイル` | bat |
| ファイル一覧 (カラー + アイコン) | `ls` / `l` | lsd (alias) |
| 後方へ単語移動 (カーソルを左の単語へ) | `⌥+←` | ghostty `esc:b` → zsh `backward-word`。`Ctrl+,` でも可 (Karabiner) |
| 前方へ単語移動 (カーソルを右の単語へ) | `⌥+→` | ghostty `esc:f` → zsh `forward-word`。`Ctrl+.` でも可 (Karabiner) |
| 後方へ単語削除 (カーソル左の単語) | `⌥+Backspace` | zsh: `backward-kill-word` |
| 前方へ単語削除 (カーソル右の単語) | `⌥+D` | zsh: `kill-word` |
| 現在のコマンドラインをコピー | `Ctrl+P` → `Ctrl+O` | pbcopy (command.sh) |
| 画面クリア | `Ctrl+G` | clrscr (command.sh) |

> **`Ctrl+W` は単語削除に使えない**（ハマりやすい点）: Karabiner の Ctrl navigation が `Ctrl+W` → Page Up（`Ctrl+V` → Page Down）に**全アプリで**再マップしているため、シェルに `Ctrl+W` (0x17) は届かない。端末では Page Up = `\e[5~` が zsh で未バインド（`undefined-key`）なので、末尾の `~` だけが残って入力されてしまう。後方単語削除は **`⌥+Backspace`** を使う。`.zshrc` の `WORDCHARS` は `/` を境界に保つよう調整済みで、パスを 1 セグメントずつ消せる（`backward-kill-word` の単語境界に効く）。

## Keyboard Shortcuts (Karabiner / HRM)

ホームロウmod (HRM) とターミナル向けリマップを Karabiner で定義。**詳細・最新は [HRM.md](../.config/karabiner/HRM.md)（tmux 内なら `Prefix` → `m`）が一次情報源**。設定は `.config/karabiner/karabiner.ts` から `karabiner.json` を生成。以下は要約。

### Home Row Mods（キーをホールドして修飾キーにする）

| キー | ホールド → 修飾 | スコープ |
|---|---|---|
| F (左人差し) | Shift | 全アプリ |
| S (左薬指) | Option | 全アプリ |
| D (左中指) | Control | 全アプリ |
| J (右人差し) | Shift | Helix / ターミナル / Chrome を除く |
| ; (右小指) | Opt + Shift | 全アプリ |
| Cmd (tap) | 英数 (左) / かな (右) | tap で IME 切替、hold で Cmd |

- A (左小指) には HRM を載せない（左手首腱鞘炎対策）／Cmd は物理キーのまま

### Ctrl navigation（D ホールドで Ctrl を作って発火・全アプリ）

| キー | 動作 |
|---|---|
| `Ctrl+H/J/K/L` | 矢印キー (左/下/上/右) |
| `Ctrl+,` / `Ctrl+.` | 単語単位で左/右移動 (Option+←/→) |
| `Ctrl+W` / `Ctrl+V` | Page Up / Page Down |

### ターミナル限定

| キー | 動作 | 備考 |
|---|---|---|
| `Ctrl+Space` | 英数 → `Ctrl+Space` | tmux prefix の送出と同時に IME を抜く |
| `Ctrl` 単押し | 短時間ホールド | 端末向け tap-hold 判定 |

## Typical Workflows / よくある作業フロー

### 別プロジェクトのファイルを素早く開く
```
zi          # fzf でプロジェクト選択 → cd
nvim Ctrl+T # fzf でファイル選択 → Neovim で開く
```

### tmux で複数プロジェクトを並行作業
```
Prefix c           # 新ウィンドウ作成
zi                 # プロジェクトに移動
# ウィンドウ番号 (Prefix 0-9) で切替
Prefix Space       # 直前のウィンドウに素早く戻る
```
