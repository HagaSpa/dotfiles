# Terminal Workflow Guide

現在導入済みのツールとショートカットで実現できるユースケース一覧。

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
2. `Ctrl+T` でファイルを検索 → `hx` で開く
   - 例: `hx ` → `Ctrl+T` → ファイル選択 → Enter

## Git Operations / Git 操作

| ユースケース | コマンド | alias |
|---|---|---|
| ステータス確認 | `gs` | `git status --short --branch` |
| 差分確認 (未追跡含む) | `gd` | `git add -N . && git diff` |
| ログ確認 | `gl` | `git log --graph --decorate --oneline` |
| ファイルを追加 | `ga ファイル` / `ga.` | `git add` / `git add .` |
| コミット (インライン) | `gc "message"` | `git commit -m` |
| コミット (エディタ) | `gcm` | `git commit` |
| 直前のコミットに追加 | `gca` | `git commit --amend --no-edit` |
| プッシュ | `gp` | `git push` |
| プル | `gpl` | `git pull` |
| main に切替 + pull | `gbm` | `git switch main && git pull` |
| 直前のブランチに切替 | `gb` | `git switch -` |
| 新ブランチ作成 | `gbc ブランチ名` | `git switch -c` |
| soft reset | `grs コミット` | `git reset --soft` |
| 変更を全取消 | `gnah` | `git nah` |
| PR をブラウザで開く | `vg` | `gh pr view --web` |

## Tmux / ターミナル多重化

**Prefix: `Ctrl+B`**

| ユースケース | キー | 備考 |
|---|---|---|
| 新しいウィンドウ作成 | `Prefix` → `c` | カレントパスを引き継ぐ |
| 直前のウィンドウに切替 | `Prefix` → `Space` | |
| ウィンドウ番号で切替 | `Prefix` → `0-9` | |
| ペイン移動 (左/下/上/右) | `Prefix` → `h/j/k/l` | vim 風 |
| yazi をポップアップで開く | `Prefix` → `y` | Helix 連携あり |
| セッション一覧 | `Prefix` → `s` | |
| ウィンドウ一覧 | `Prefix` → `w` | |
| ペインを水平分割 | `Prefix` → `"` | |
| ペインを垂直分割 | `Prefix` → `%` | |
| コピーモード (vi) | `Prefix` → `[` | vi キーバインドで操作 |
| デタッチ | `Prefix` → `d` | |

**tmux-resurrect / continuum:**
- セッションは自動保存・自動復元される
- 手動保存: `Prefix` → `Ctrl+S`
- 手動復元: `Prefix` → `Ctrl+R`

## Yazi / ファイルマネージャ

tmux 内から `Prefix` → `y` でポップアップ起動。Helix で開いているときはファイル選択が `:open` に連携される。

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
| 現在のコマンドラインをコピー | `Ctrl+P` → `Ctrl+O` | pbcopy (custom) |
| 画面クリア | `Ctrl+G` | clear-screen |

## Keyboard Shortcuts (Karabiner) / ターミナル内キーボード

ターミナルアプリ内でのみ有効な Karabiner リマップ:

| キー | 動作 | 備考 |
|---|---|---|
| `Ctrl+H/J/K/L` | 矢印キー (左/下/上/右) | vim 風カーソル移動 |
| `Ctrl+,` | 単語単位で左移動 | Alt+Left |
| `Ctrl+.` | 単語単位で右移動 | Alt+Right |
| `Ctrl+W` | Page Up | |
| `Ctrl+V` | Page Down | |
| `Ctrl+B` | IME off → Ctrl+B | tmux prefix の IME 誤入力防止 |

## Helix Editor / エディタ

| ユースケース | キー | 備考 |
|---|---|---|
| 行を上に移動 | `Alt+Up` | |
| 行を下に移動 | `Alt+Down` | |
| Inlay hints 切替 | `Space` → `I` | |
| ファイルピッカー | `Space` → `f` | 隠しファイルも表示 |
| バッファピッカー | `Space` → `b` | 開いているファイル一覧 |

## Typical Workflows / よくある作業フロー

### 別プロジェクトのファイルを素早く開く
```
zi          # fzf でプロジェクト選択 → cd
hx Ctrl+T   # fzf でファイル選択 → Helix で開く
```

### コードを書いて PR を出す
```
gbc feat/my-feature   # ブランチ作成
# ... 編集 ...
gd                     # 差分確認
ga.                    # 全ファイルステージ
gc "feat: add feature" # コミット
gp                     # プッシュ
# gh pr create ...
vg                     # PR をブラウザで開く
```

### 作業中にmainの変更を取り込む
```
gbm        # main に切替 + pull
gb         # 元のブランチに戻る
# git rebase main or git merge main
```

### tmux で複数プロジェクトを並行作業
```
Prefix c           # 新ウィンドウ作成
zi                 # プロジェクトに移動
# ウィンドウ番号 (Prefix 0-9) で切替
Prefix Space       # 直前のウィンドウに素早く戻る
```
