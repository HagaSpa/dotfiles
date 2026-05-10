# Home Row Mods (HRM) Cheatsheet

source: `.config/karabiner/karabiner.ts` / `.config/zsh/command.sh` / `.config/tmux/tmux.conf`

## Modifier mappings

| Key             | Hold → Modifier | Scope                                 |
| --------------- | --------------- | ------------------------------------- |
| F (left index)  | Shift           | All apps                              |
| S (left ring)   | Option          | All apps                              |
| D (left middle) | Control         | All apps                              |
| J (right index) | Shift           | All except Helix / Terminal / Chrome  |
| ; (right pinky) | Opt + Shift     | All apps                              |

- A pinky には HRM を載せない (左手首腱鞘炎対策)
- Cmd は物理キーのまま (HRM 化しない)

## Cmd tap → IME

| Key       | Tap          | Hold |
| --------- | ------------ | ---- |
| Left Cmd  | 英数 (eisuu) | Cmd  |
| Right Cmd | かな (kana)  | Cmd  |

## Ctrl navigation (D ホールドで発火)

| Combo                     | Action                                       |
| ------------------------- | -------------------------------------------- |
| Ctrl + h / j / k / l      | ← / ↓ / ↑ / →                                |
| Ctrl + , / .              | Option + ← / →  (word jump)                  |
| Ctrl + w                  | Page Up                                      |
| Ctrl + v                  | Page Down                                    |
| Ctrl + b  (terminal)      | 英数 → Ctrl+b  (tmux prefix の前に IME 抜け) |
| Ctrl + g  (zsh)           | clear-screen  (Ctrl+L が → に潰れる代替)     |
| Ctrl + P, Ctrl + O  (zsh) | 現在行を pbcopy                              |

## tmux prefix

`Ctrl + Space` = D (Ctrl) + 右親指 Space の bilateral chord。
Ctrl+B は左 D + 左 B の同手チョードで打ちにくいため変更。

## Timing

- `to_if_alone_timeout`: 200ms
- `to_if_held_down_threshold`: 200ms
- bilateral roll window: 180ms (この時間内の反対側ロールはリテラル扱い)

意図的な modifier + letter は 180ms より長く HRM キーをホールドしてから他キーを叩く。
