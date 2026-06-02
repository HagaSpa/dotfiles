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

## Troubleshooting

### 「設定は正しいのに特定キーだけ挙動が古い」(例: helix で j だけ単発になりリピートしない)

`karabiner.json` は正しいのに、実機では古いルールセットで動いている状態。Karabiner のデーモン(core_service)と user プロセスの認証 (shared secret) が食い違うと、設定リロードが grabber/デーモンに伝わらず発生する。

切り分けの決め手: `j` だけ単発で `h/k/l` はリピートする場合、`J→Shift` tap-hold (`unlessVimApp` で除外済みのはず) が live で生きている = 設定が反映されていない証拠。

```bash
# 1. shared secret エラーが連続発生しているか確認
tail /var/log/karabiner/core_service.log   # "invalid shared secret" が約0.5秒おきに出ていれば該当
```

2. メニューバーから Karabiner-Elements を Quit → 再起動（最小侵襲）。ダメなら macOS 再起動で DriverKit デーモンまで再同期。
3. 復旧サインは同ログの `Load .../karabiner.json...` → `core_configuration is updated.` → `verified peer connected`。
4. この症状では `karabiner.ts` は触らない（設計は正しい。原因は Karabiner の状態異常）。
