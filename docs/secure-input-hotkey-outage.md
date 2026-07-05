# ショートカット全滅の真因が ghostty の Secure Input 固着だった件 (2026-07)

Raycast のショートカット（HRM で `;` → Opt+Shift 経由）が全滅した事象の調査記録。**結論: 真因は macOS の Secure Input（セキュア入力）を ghostty が有効化したまま解放しない固着。Karabiner・Raycast・CleanShot は全て無実。**

## 症状シグネチャ

この組み合わせが揃ったら Secure Input 固着をまず疑う。

| 症状 | Secure Input 固着での説明 |
|---|---|
| Cmd を**含まない**グローバルホットキー（Opt+Shift+X 等）が全アプリで死ぬ | Secure Input 中は非 Cmd ホットキーが無効化される |
| Cmd を**含む**ホットキー（Cmd+Opt+R 等）は生きている | Cmd 入りだけは生き残る仕様。**最大の識別点** |
| 通常のタイピングは完全に正常 | 入力自体はブロックせず、監視だけ禁止する |
| Karabiner-EventViewer のイベントログに何のキーも出ない | キーボード監視 API が全面遮断されるため。権限リセットと誤読しやすい |
| Karabiner / HRM 自体は正常動作 | HID レベルで動くので影響を受けない |
| PC 再起動で治るが、再発する | 保持プロセスが死ねば解放されるだけで、根本は直っていない |

## 診断（最初の10秒でやる）

```bash
# Secure Input を握っている PID を確認（何も出なければ解放済み＝別の原因）
ioreg -l -w 0 | grep -o 'kCGSSessionSecureInputPID"=[0-9]*'

# 保持プロセスの正体
ps -o pid,lstart,command -p <PID>
```

今回の事例では PID = ghostty 本体だった。パスワード待ちの sudo/ssh はどこにも存在せず（`ps -ef | grep sudo` で確認）、正当な理由のない純粋な固着。

## 復旧（再起動不要・ghostty 終了不要）

1. ghostty をアクティブにする
2. メニューバー「Ghostty」→「**Secure Keyboard Entry**」を **ON → OFF とトグル**
   - チェックが付いていなくても、一度 ON にしてから OFF にすると強制解放される
3. `ioreg` ワンライナーで消えたことを確認 → `;`+F 等で実機確認

## 切り分けの黄金手順

「ショートカットが効かない」報告に対して、この順で層を潰す。

1. **Secure Input の除外（10秒）** — 上記 `ioreg` ワンライナー。出たら即解決へ
2. **別アプリでも再現するか** — Chrome 等に同じ修飾のショートカットを割り当てて物理キーで試す。再現すれば Raycast 固有ではない
3. **別の修飾組み合わせは効くか** — Cmd+Opt+R 等。「Cmd 入りだけ効く」なら Secure Input 濃厚（手順 1 に戻る）
4. **イベント配送は正常か** — テキスト欄で物理 Opt+Shift+8 → `°` が入るか。入るなら「イベントは届いているが横取りされている」のではなく「監視だけ遮断」
5. **Karabiner 一時オフで再現するか** — EventViewer 右上「Temporarily turns off all Karabiner-Elements modifications」。再現すれば Karabiner は白
6. ここまで白なら Raycast 更新後のホットキー機構死亡等、アプリ個別の問題を疑う（過去事例: 2026-07-04 の Raycast 自動更新後の再初期化不全 → "Restart Raycast" で復旧）

## 調査で使った技

### イベントタップ列挙（誰がキーボードを握り潰せるか）

`CGGetEventTapList`（公開 API）で全イベントタップを列挙できる。**FILTER 型（改変可）の keyboard タップを張っているプロセスだけがイベントを消費できる**ので、容疑者リストが一発で出る。listen-only は握り潰せないので除外してよい。

```swift
// swift で CGGetEventTapList を呼び、tappingProcess / options / eventsOfInterest を表示
// mask bit 10=keyDown, 11=keyUp, 12=flagsChanged
```

今回の結果: FILTER 型は Raycast のみ、CleanShot はタップ自体なし（＝シロ証明）、Karabiner は HID レベルなのでここには現れない。

### CleanShot のホットキー全復号

CleanShot の設定は `defaults read` だと binary blob に見えるが、`defaults export pl.maketheweb.cleanshotx -` を plistlib で読むと全ホットキーが JSON で復号できる。carbonModifiers の値: `256=Cmd / 512=Shift / 2048=Opt / 4096=Ctrl`（例: 768 = Cmd+Shift）。

## 調査中に踏んだ罠（再発防止）

| 罠 | 内容 | 教訓 |
|---|---|---|
| 実在する異常≠症状の原因 | `core_service.log` に Karabiner v16.0.0 の DriverKit 仮想キーボードが数分おきに terminate/ungrab を繰り返すループが実在し、主犯と誤認した | 異常を見つけても、症状シグネチャと1項目ずつ整合検証してから結論する |
| Core-Service の kickstart | `launchctl kickstart -k gui/$UID/org.pqrs.service.agent.Karabiner-Core-Service-rev2` は root の正規 daemon を置き換えず**ユーザー権限の別インスタンスを増やして二重起動**させ、悪化した | Core-Service は kickstart 禁止。復旧は Karabiner メニューバーの "Restart Karabiner-Elements"（GUI）を使う |
| EventViewer 無反応の誤読 | 「アプデで入力監視権限がリセットされた」と誤読した | EventViewer が完全無反応なら Secure Input の動かぬ証拠 |
| カーソル `+` の誤読 | Opt+Shift ホールドでカーソルが `+` になるのをキャプチャツールの待ち受けと誤認 | ghostty 上では Option ホールド＝矩形選択カーソルで正常動作。どのアプリの上で起きるかを必ず確認 |
| 初期証言の軽視 | ユーザーの「Raycast 設定は問題ない」「スクショ後に発症」は最終的に全て正しかった | 症状の初期証言を安易に相関と切り捨てない |

## 関連

- Karabiner HRM 設計・Raycast ショートカットが全て Opt+Shift 経由である背景は Claude Code の project memory（`~/.claude/projects/-Users-haga-workspaces-hagaspa-dotfiles/memory/`）を参照
- 過去の類似事象: Raycast 自動更新後のホットキー機構死亡（2026-07-04）、Karabiner shared secret 不整合、Karabiner v16 の symlink 自動 reload 不全
