# tmux で遡れなくなった件 (2026-08)

tmux のコピーモードでスクロールバックを遡れなくなった事象の調査記録。**結論: 独立した 2 つの原因が重なっていた。① Ghostty が `Ctrl+U` を pty に渡さない ② Claude Code の `tui: "fullscreen"` で会話が tmux の履歴に残らない。tmux・Karabiner・QMK・7sPro は全て無実。**

どちらも数か月前から続いていた状態で、最近の変化ではない。

## 症状シグネチャ

| 症状 | 原因 |
|---|---|
| コピーモードで `Ctrl+U` だけ無反応。`u` など他のキーは効く | ① Ghostty |
| Claude Code のペインだけ、表示中の画面より上に行けない | ② fullscreen |
| シェルのペインでは遡れる | ② のみなら正常 |

切り分けの決め手は **同じコピーモードの中で `Ctrl+U` 以外が効くか**。効くなら tmux は正常で、キーが届いていない。

## ① Ghostty が Ctrl+U を渡さない

`Ctrl+Y` / `Ctrl+G` は届くのに `Ctrl+U` だけ 0 バイト。Ghostty 1.3.1 (2026-03-14 ビルド) で確認。Ghostty 側に `ctrl+u` の既定バインドは無く、`~/Library/KeyBindings/` も未作成。

`.config/ghostty/config` で送り直して回避する。

```
keybind = ctrl+u=text:\x15
```

### 測り方

端末を raw モードにして生バイトを見る。**カノニカルモード (`cat -v` 等) で測ってはいけない** — `stty` の `kill = ^U` によりライン discipline が `Ctrl+U` を消費するので、Ghostty が渡していても 0 バイトに見える。この誤診を一度やっている。

```python
import os, select, sys, termios, time, tty
fd = sys.stdin.fileno(); old = termios.tcgetattr(fd)
try:
    tty.setraw(fd)
    end = time.time() + 15
    while time.time() < end:
        if select.select([fd], [], [], 0.2)[0]:
            d = os.read(fd, 64)
            sys.stdout.write(f"{d!r}\r\n"); sys.stdout.flush()
            if d == b"q": break
finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, old)
```

`Ctrl+U` = `b'\x15'`、`Ctrl+Y` = `b'\x19'`、`Ctrl+G` = `b'\x07'`。tmux の外で走らせれば tmux も除外できる。

## ② Claude Code の tui: fullscreen

`tui: "fullscreen"` は代替画面 (alternate screen) に描画するモード。**macOS のフルスクリーン表示とは無関係。** 代替画面の内容は tmux のスクロールバックに積まれないため、コピーモードで遡る対象が存在しない。

```bash
tmux list-panes -a -F '#{pane_current_command} alt=#{alternate_on} hist=#{history_size}'
# claude  alt=1 hist=1     ← 会話は代替画面にあり、履歴に残っていない
# zsh     alt=0 hist=219
```

`.config/claude/settings.json` を `"tui": "default"` にすると通常画面に描画され、コピーモードで遡る・検索する・コピーするが全て使える。`/tui <fullscreen|default>` でも切り替わる (設定ファイルに書き戻される)。

fullscreen のまま使う場合、スクロールは Claude Code 自身の機能になる (`PageUp` / `PageDown`、`ctrl+home` / `ctrl+end`)。PageUp / PageDown は 7sPro では `Fn+L` / `Fn+.`、内蔵キーボードでは `Fn+↑` / `Fn+↓`。ただしそれは tmux のコピーモードではないので、範囲選択してコピーする用途には tmux 側の機能を使えない。

### 誤診しやすい点

`alternate_on=1` でも tmux は**通常画面の履歴を保持している** (`capture-pane -p` は履歴に届き、`-a` を付けると代替画面を見る)。Claude Code のペインで `history_size` が 1〜4 しかないのは履歴が消されたからではなく、**通常画面に何も書かないまま代替画面へ移る**ため。

## 検証時の注意

- `tmux send-keys` はペインのプロセスに直接届くので**キーテーブルを通らない**。`bind -n` の検証には使えない。外側にもう 1 つ tmux サーバーを立て、その中で `tmux -L <socket> attach` して実クライアントとしてキーを送る
- 稼働中のサーバーを触らずに試すときは `tmux -L <socket> -f <conf>` で別ソケットに立てる。**終わったら `kill-server` する** (残した bind が後日の別事象の真因になったことがある)
