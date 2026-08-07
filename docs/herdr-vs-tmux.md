# herdr のキーバインドを tmux に揃える (2026-08)

herdr 0.8.0 を導入し、`.config/tmux/tmux.conf` のキーバインドを `.config/herdr/config.toml` に移植した記録。**結論: 押すキーはほぼ完全に一致させられた。再現できないのは 4 つだけ。**

herdr は tmux と同じ prefix モデルを持つ多重化ツール（Rust + Ratatui）で、pane / tab / session に加えて「AI エージェントの状態（working / blocked / done / idle）をサイドバーに出す」層が乗っている。`herdr --default-config` が全設定項目の注釈付きリストを出す。

## 一致させたもの

prefix を `ctrl+space` にした上で、herdr の既定が tmux とズレていた箇所だけを上書きしている。既定のまま一致するもの（`prefix+c` / `n` / `p` / `x` / `z` / `?` / `[` / `h j k l` / `1..9`、vi 風コピーモード、マウス操作）は書いていない。

| tmux | herdr | 対応 |
|---|---|---|
| `prefix Ctrl+Space` (prefix 自体) | `prefix = "ctrl+space"` | ✅ |
| `prefix d` detach | `detach` の既定は `prefix+q` | ✅ 上書き |
| `prefix u` copy-mode (自前 bind) | `copy_mode = ["prefix+[", "prefix+u"]` | ✅ tmux 既定の `[` も残した |
| `prefix %` / `prefix "` 分割 | `split_vertical` / `split_horizontal` の既定は `prefix+v` / `prefix+minus` | ✅ 両方受ける |
| `prefix ,` rename-window | `rename_tab` の既定は `prefix+shift+t` | ✅ 両方受ける |
| `prefix &` kill-window | `close_tab` の既定は `prefix+shift+x` | ✅ 両方受ける |
| `prefix ;` last-pane | `last_pane` は既定で未割当 | ✅ 割当 |
| `prefix o` 次のペイン | `cycle_pane_next` の既定は `prefix+tab` | ✅ 両方受ける |
| `prefix {` / `}` swap-pane | `swap_pane_left` / `_right` の既定は `prefix+shift+h` / `+l` | ✅ 両方受ける |
| `prefix w` / `prefix s` ツリー選択 | `workspace_picker` (既定 `prefix+w`) | ✅ `prefix+s` も割当。既定でここにあった `settings` は `prefix+shift+s` に退避 |
| `prefix y` yazi popup | `[[keys.command]] type = "popup"` | ✅ スクリプトは要移植（下記） |
| `prefix m` / `prefix M` チートシート popup | 同上 | ✅ |
| `bind c new-window -c '#{pane_current_path}'` | `[terminal] new_cwd = "follow"` が既定 | ✅ 設定不要 |
| `set -g default-shell /bin/zsh` | `[terminal] default_shell` | ✅ |
| `setw -g mode-keys vi` | herdr のコピーモードは元から vi 風 | ✅ 設定不要 |
| `set -g mouse on` | `[ui] mouse_capture = true` が既定 | ✅ 設定不要 |
| `set -g history-limit 10000` | `[advanced] scrollback_limit_bytes = 10000000` が既定 | ✅ tmux より広い |

## 再現できないもの

`herdr --default-config` に出る全アクション名（バイナリ側の一覧とも突き合わせた）に該当するものが無い。

1. **`bind C-Space send-prefix`** — prefix そのものをペインに送るアクションが無い。入れ子（herdr の中で tmux を動かす等）で prefix を透過させられない。
2. **`bind Space last-window`** — `last_pane` はあるが「直前の tab」に相当するアクションが無い。CLI の `herdr tab` にも直前 tab の状態は出ないので、シェルスクリプトで状態ファイルを持つ手はあるが、`prefix+n` やクリックで tab を移ると値が腐る（tmux は全ての切り替えを追跡する）。plugin の `[[events]]` に tab フォーカスイベントがあれば正しく作れるが、v1 で公開されているのは `worktree.created` だけ。
3. **`bind -n PPage ...`** — `PageUp` がそもそもバインド可能なキーではない（`pageup` / `page_up` / `pgup` いずれも `invalid keybinding`。通るのは `backspace` / `space` / `esc` / `enter` / `tab` と英数字・記号）。加えて herdr には `if-shell -F '#{alternate_on}'` に相当する条件分岐が無いので、「代替画面のアプリには素通し、それ以外はコピーモード」という振り分けも書けない。**修飾キー無しスクロールは `prefix+u` 側だけが残る。**
4. **コピーモード内のキー再割当** — `[keys]` にあるのは「コピーモードに入る」`copy_mode` だけで、モード内のキー（herdr は `ctrl+u` / `ctrl+d` で半ページ）は設定に出てこない。`.config/tmux/tmux.conf` が `copy-mode-vi` の `u` / `d` を半ページに割り当てているのは真似できない。ghostty 側に `keybind = ctrl+u=text:\x15` があるので `ctrl+u` は herdr には届く。

## tmux 側にあって herdr では別の仕組みになるもの

キーバインドではないが、移植時に引っかかった点。

- **ステータスライン** — `status-style` / `window-status-current-format` の `λ #I` のような書式文字列は無い。herdr はテーマ（`[theme] name`、11 種の組み込み）とサイドバー行レイアウト（`[ui.sidebar.*] rows`）で見た目を決める。
- **tmux-resurrect / tmux-continuum** — herdr はサーバー常駐でペインが生き続けるので日常的な復元は不要。マシン再起動を挟む復元は `[session] resume_agents_on_restore`（エージェントの会話セッション復帰）と `[experimental] pane_history` が担当し、resurrect のような「ペインのコマンドラインを保存して再実行」とは別物。
- **`allow-passthrough on`** — yazi の画像プレビューに使っていたパススルーは `[experimental] kitty_graphics` に相当するが既定 off。
- **`automatic-rename off`** — 自動リネーム自体が無く、`[ui] prompt_new_tab_name = true`（既定）が tab 作成時に名前を訊く。
- **`prefix 0`** — `switch_tab` は `prefix+1..9` 固定（`prefix+0..9` は `invalid keybinding`）。tmux は window 0 から始まるのでここだけ 1 つずれる。

## yazi popup の移植

`.config/tmux/yazi-picker.sh` の herdr 版が `.config/herdr/yazi-picker.sh`。置き換えたのは 3 箇所。

| tmux | herdr |
|---|---|
| `$1`（popup 起動時に `#{pane_id}` を渡す） | 環境変数 `HERDR_ACTIVE_PANE_ID` |
| `tmux display-message -p '#{pane_current_command}'` | `herdr pane process-info --pane <id>` の `foreground_processes[0].name` |
| `tmux send-keys` | nvim なら `herdr pane send-keys`、シェルなら `herdr pane run` |

**`herdr pane run` / `send-text` を nvim に向けて使ってはいけない。** どちらも bracketed paste で送るため、nvim はモードに関係なくバッファへの挿入として扱う（`:args ...` がそのまま本文に入る）。`herdr pane send-keys` は生のキー入力になるが、引数は 1 トークン 1 キーで、複数文字のトークンはキー名として解釈される（`:args!` は `unsupported key`）。そのため 1 文字ずつ配列に展開して渡している。

また、tmux 版が `tmux new-session` で yazi を包んでいたのは popup がパススルー非対応で画像プレビューが壊れるからだったが、herdr 版は popup で直接 yazi を起動している（`kitty_graphics` が既定 off なので画像プレビューはどちらでも出ない）。

## 検証に使ったコマンド

`herdr config check` は構文しか見ないが、無効なバインドは名前付きで落としてくれるので、キー名の可否はこれで潰せる。設定パスは `HERDR_CONFIG_PATH` で差し替えられるので、本番の `~/.config/herdr/config.toml` を触らずに試せる。

```bash
HERDR_CONFIG_PATH=/tmp/probe.toml herdr config check   # 構文 + キー名の検証
herdr server reload-config                             # 稼働中サーバーに反映（diagnostics が空なら OK）
herdr api snapshot                                     # 稼働中の状態を JSON で見る
```
