# ウィンドウマネージャ選定 (2026-07)

首肩の負担を減らすため、家では外部モニタ（LG ULTRAGEAR / 3440x1440）を使うことにした。内蔵ディスプレイとの往復でアプリのウィンドウ位置が毎回崩れるため、その解決策として AeroSpace と Amethyst を比較した。**結論: Amethyst を採用。AeroSpace は実機検証の上で不採用。**

## 要件

| # | 要件 | 理由 |
|---|---|---|
| 1 | アプリ切り替えは Raycast の per-app hotkey を維持する | 既に定着している主動線。ここを捨てる移行はしない |
| 2 | LG では中央 1720px、内蔵では全画面 | 3440px の全幅は視線移動が大きく、首肩対策と逆行する |
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
screen-padding-left: 860
screen-padding-right: 860
disable-padding-on-builtin-display: true
```

- **padding の単位は px。** LG は HiDPI なし（`UI Looks like: 3440 x 1440`）なので px = pt として扱える。860 で中央 1720px が残る
- **`disable-padding-on-builtin-display: true` が必須。** 内蔵は Retina（2x）で論理幅が 1720px より狭いため、同じ px 値を共有できない。このキーで内蔵だけ padding 対象から外し、全画面のまま使う
- モニタを買い替えたら `860` は再計算が必要（`system_profiler SPDisplaysDataType` の `UI Looks like` を見る）

`mod1`（既定 `option + shift`）と `mod2` は、修飾キーを盛って事実上無効化している。Karabiner の HRM で `S` ホールドが Opt を出すため、既定のままだとタイプ中に暴発する（→ [../.config/karabiner/HRM.md](../.config/karabiner/HRM.md)）。ウィンドウ操作は Raycast に任せるので、Amethyst 側のバインドは不要。

## 触っていない設定

**「ディスプレイごとに個別の操作スペース」は ON のまま。** AeroSpace の公式は OFF を推奨していたが、その根拠は主に native フルスクリーンとマルチモニタのフォーカス不具合で、Space 1 枚・native フルスクリーン未使用の構成では効く場面が限られる。しかも OFF にするとメニューバーが片方の画面にしか出なくなり、今より不便になる。フォーカスの不具合が実際に出たら `defaults write com.apple.spaces spans-displays` を `settings.sh` に追加する（再ログインが必要）。

## 学び

- **「タイル型 WM」で括ると選定を誤る。** AeroSpace と Amethyst の決定的な差はレイアウト機能ではなく、workspace の実装方式（画面外退避 vs native Space）だった。既存の切り替え動線を残したい場合、ここが唯一の判断軸になる
- **ドキュメントよりインストール版が正。** AeroSpace の設定記法はドキュメントとリリース版でズレていた。dry-run で検証できるツールなら、まず dry-run に通す
- **per-display の差異は「専用の除外スイッチ」があるかで実現可否が決まる。** Amethyst の padding はグローバル値だが `disable-padding-on-builtin-display` があるおかげで要件を満たせた

## 再検討のトリガー

- 外部モニタを買い替えたとき → `screen-padding-*` の再計算
- native フルスクリーンを使い始めたとき → Amethyst と衝突するため設計を見直す
- 内蔵と外部の両方に別のアプリを常時出したくなったとき → 現構成は「全アプリを1画面に集約」前提

## 関連

- [raycast-dotfiles.md](raycast-dotfiles.md) — GUI に閉じる設定を管理対象外とした先例（要件 4 の根拠）
- [gui-app-path.md](gui-app-path.md) — GUI アプリ起点の PATH 問題

## 出典

- [Amethyst 公式サイト](https://ianyh.com/amethyst/)
- [Amethyst - Configuration Files](https://github.com/ianyh/Amethyst/blob/development/docs/configuration-files.md)
- [AeroSpace Guide](https://nikitabobko.github.io/AeroSpace/guide)
