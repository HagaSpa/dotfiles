# ウィンドウマネージャ選定 (2026-07)

首肩の負担を減らすため、家では外部モニタ（LG ULTRAGEAR / 3440x1440）を使うことにした。内蔵ディスプレイとの往復でアプリのウィンドウ位置が毎回崩れるため、その解決策として AeroSpace と Amethyst を比較した。**結論: Amethyst を採用。AeroSpace は実機検証の上で不採用。**

## 要件

| # | 要件 | 理由 |
|---|---|---|
| 1 | アプリ切り替えは Raycast の per-app hotkey を維持する | 既に定着している主動線。ここを捨てる移行はしない |
| 2 | LG では中央 2040px、内蔵では全画面 | 3440px の全幅は視線移動が大きく、首肩対策と逆行する |
| 3 | モニタ着脱で崩れない | これが元の課題 |
| 4 | 設定が dotfiles に載る | GUI に閉じる設定は管理外になる（→ [raycast-dotfiles.md](raycast-dotfiles.md)） |

## AeroSpace を落とした理由

要件 2・3・4 は満たせた。1 だけが構造的に満たせない。

AeroSpace は native の macOS Space を使わず、**非表示 workspace のウィンドウを画面外へ退避させる方式**で workspace をエミュレートしている。この方式では Raycast でアプリを activate したとき、

1. macOS が「まだ画面外にある」ウィンドウを前面に上げる
2. AeroSpace がフォーカス変化を検知して workspace を入れ替える

という 2 段階になり、その隙間が目に見えてちらつく。バンドルされた `default-config.toml` の全キーを確認したが、これを抑制するオプションは存在しない。AeroSpace 自身のキーバインドで切り替えれば軽減する可能性はあるが、それは要件 1 を捨てることになる。

同じ画面外退避方式の yabai も同じ問題を持つ。

検証中に判明した副次的な事実:

- ドキュメントサイトは `if = 'test %{app-bundle-id} = ...'` という記法を載せているが、リリース版 0.21.3 では従来の `if.app-id` が正しい。ドキュメントが main 追従で先行しているため、**記法は `aerospace reload-config --dry-run` で確かめる**のが確実

## Amethyst の構成

Amethyst は **native の macOS Space をそのまま使う**。ウィンドウを画面外へ退避させないので、Raycast の activate は純粋な raise で完結しちらつかない（実機確認済み）。

`fullscreen` レイアウトのみを有効にし、フォーカス中のウィンドウが padding 後の領域全体を取る形にしている。

```yaml
layouts: [fullscreen]
screen-padding-left: 700
screen-padding-right: 700
disable-padding-on-builtin-display: true
```

- **padding の単位は px。** LG は HiDPI なし（`UI Looks like: 3440 x 1440`）なので px = pt として扱える。700 で中央 2040px が残る
- **`disable-padding-on-builtin-display: true` が必須。** 内蔵は Retina（2x）で論理幅が 2040px より狭いため、同じ px 値を共有できない。このキーで内蔵だけ padding 対象から外し、全画面のまま使う
- モニタを買い替えたら `700` は再計算が必要（`system_profiler SPDisplaysDataType` の `UI Looks like` を見る）
- 当初は 860（中央 1720px）だったが、ターミナルと Chrome が狭かったため 2026-08 に 2040px へ広げた

`mod1`（既定 `option + shift`）と `mod2` は、修飾キーを盛って事実上無効化している。Karabiner の HRM で `S` ホールドが Opt を出すため、既定のままだとタイプ中に暴発する（→ [../.config/karabiner/HRM.md](../.config/karabiner/HRM.md)）。ウィンドウの切り替え自体は Raycast に任せるので、移動・フォーカス系のバインドは使わない。

例外として、一時的に fullscreen レイアウトから外したいときに次の 2 つを使う。

- `toggle-float`（`mod1 + t` = ⌥⇧⌃⌘+T） — フォーカス中のウィンドウだけをタイル管理から外す。もう一度押すとタイルに復帰する
- `toggle-tiling`（`mod2 + t` = ⇧⌃⌘+T） — タイリング自体を停止する

`;` ホールドは ⌘⌥⌃ 止まり（中国語変換サービスとの衝突回避）なので、`mod1` は `;` ホールド + Shift で出す。**`;` は 200ms 以上ホールドしてから T を叩く**（`basic.to_if_held_down_threshold_milliseconds`）。速く叩くと `;` がリテラルとして出るだけで何も起きない。

**`toggle-float` は見た目を変えない。** ウィンドウを管理対象から外すだけで、サイズも位置も動かさない。効いたかどうかは「その後リサイズして維持されるか」でしか分からないので、無反応に見えても失敗とは限らない。

`mod1`/`mod2` は Amethyst が起動時に UserDefaults へ移行する（`migrated-toggle-float` 等）。yml を直したのに効かないときは `defaults read com.amethyst.Amethyst | grep KeyboardShortcuts_` で実際の登録内容を見る（`carbonModifiers` は `⌘256 / ⇧512 / ⌥2048 / ⌃4096` の和）。

## LG より狭い外部モニタでは破綻する

`screen-padding-*` は**内蔵以外のすべての外部ディスプレイに同じ px 値が一律で適用される**。`Screen.swift` の `adjustedFrame` は下限をクランプしないため、幅から常に 1400px（700 × 2）が引かれるだけになる。

```swift
frame.origin.x += paddingLeft
frame.size.width -= (paddingRight + paddingLeft)
```

判定に使われるのは**論理幅（`UI Looks like`）**で物理解像度ではない。4K を既定スケールで繋ぐと論理 1920 になるため、ここが罠になる。

| 論理幅 | ウィンドウ幅 |
|---|---|
| 3440（LG） | 2040 |
| 2560（WQHD、HiDPI なし） | 1160 |
| 1920（FHD / 4K の既定スケール） | 520 |
| 1400 以下 | 0 または負（ガードなし） |

**一時的に別のモニタへ繋ぐだけなら `toggle-tiling`（⇧⌃⌘+T）で止める。** タイリングごと止まるので padding も効かなくなり、yml を触らずに macOS 通常のウィンドウ操作へ戻れる。常用するモニタが増えたときだけ値を書き換える。

`window-minimum-width` で下限を守れる可能性はあるが**未検証**（2 台目の外部モニタで実機確認していない）。

## 触っていない設定

**「ディスプレイごとに個別の操作スペース」は ON のまま。** AeroSpace の公式は OFF を推奨していたが、その根拠は主に native フルスクリーンとマルチモニタのフォーカス不具合で、Space 1 枚・native フルスクリーン未使用の構成では効く場面が限られる。しかも OFF にするとメニューバーが片方の画面にしか出なくなり、今より不便になる。フォーカスの不具合が実際に出たら `defaults write com.apple.spaces spans-displays` を `settings.sh` に追加する（再ログインが必要）。

## 学び

- **「タイル型 WM」で括ると選定を誤る。** AeroSpace と Amethyst の決定的な差はレイアウト機能ではなく、workspace の実装方式（画面外退避 vs native Space）だった。既存の切り替え動線を残したい場合、ここが唯一の判断軸になる
- **ドキュメントよりインストール版が正。** AeroSpace の設定記法はドキュメントとリリース版でズレていた。dry-run で検証できるツールなら、まず dry-run に通す
- **per-display の差異は「専用の除外スイッチ」があるかで実現可否が決まる。** Amethyst の padding はグローバル値だが `disable-padding-on-builtin-display` があるおかげで要件を満たせた

## 再検討のトリガー

- 外部モニタを買い替えたとき → `screen-padding-*` の再計算
- LG より狭い外部モニタを常用するようになったとき → padding はグローバル値なので両立できない。`window-minimum-width` の検証か、片方を諦める判断が必要
- native フルスクリーンを使い始めたとき → Amethyst と衝突するため設計を見直す
- 内蔵と外部の両方に別のアプリを常時出したくなったとき → 現構成は「全アプリを1画面に集約」前提

## 関連

- [raycast-dotfiles.md](raycast-dotfiles.md) — GUI に閉じる設定を管理対象外とした先例（要件 4 の根拠）
- [gui-app-path.md](gui-app-path.md) — GUI アプリ起点の PATH 問題

## 出典

- [Amethyst 公式サイト](https://ianyh.com/amethyst/)
- [Amethyst - Configuration Files](https://github.com/ianyh/Amethyst/blob/development/docs/configuration-files.md)
- [Amethyst - Screen.swift](https://github.com/ianyh/Amethyst/blob/development/Amethyst/Model/Screen.swift) — `adjustedFrame` の padding 適用箇所
- [AeroSpace Guide](https://nikitabobko.github.io/AeroSpace/guide)
