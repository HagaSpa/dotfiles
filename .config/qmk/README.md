# QMK Configuration

7sPro のキーマップを [External Userspace](https://docs.qmk.fm/newbs_external_userspace) として管理する。このディレクトリが overlay_dir で、`qmk_firmware` 本体とツールチェーンはリポジトリ外に置く。

7sPro は QMK 上 **`salicylic_acid3/7skb/rev1`** (63 キー分割 / Pro Micro / ATmega32U4)。`7spro` という keyboard 定義は QMK 本家に存在しない。実機との照合は VID/PID = `0x04D8` / `0xEB5F`。

## Setup

```bash
mise run qmk   # toolchain + qmk_firmware clone + overlay_dir 登録
```

初回は数百 MB のダウンロードが走る。`mise run setup` には含めていない (7sPro を使うマシンでだけ必要なため)。

タスクが用意するもの:

| 場所 | 中身 |
|---|---|
| `~/workspaces/hagaspa/qmk_firmware` | firmware 本体 (tag 固定) |
| `~/Library/Application Support/qmk` | toolchain (avr-gcc) + flashutils (avrdude) |
| `~/.local/bin/qmk` | CLI (uv tool 経由) |
| `~/Library/Application Support/qmk/qmk.ini` | CLI 設定 (`user.qmk_home` / `user.overlay_dir`) |

## キーマップ

MacBook 内蔵キーボードでは Karabiner が同等の機能を提供している (`../karabiner/HRM.md`)。持ち替えたときの操作感を揃えるため、同じものを QMK 側に実装している。

### Home Row Mods

| キー | ホールド |
|---|---|
| F | Shift |
| S | Option |
| D | Control |
| ; | ⌘⌥⌃ (Raycast 用) |

`A` には載せない (左手首腱鞘炎対策)。`J` にも載せない — Karabiner 側は vim 系アプリで無効化しているが、**QMK はホストのアプリを知らないため同じ切り分けができない**。7sPro では右 Shift は物理キーを使う。

`CHORDAL_HOLD` が同手のロールをタップ扱いにするので、`fa` のような同手ロールで Shift が誤爆しない。**ただし効くのは `TAPPING_TERM` (180ms) 以内**で、意図的に同手で修飾子を使いたいときは長めにホールドしてから相方を叩く (Karabiner 側も同じ運用)。加えて `FLOW_TAP_TERM` が高速タイプ中のホールド判定を止める。

### Cmd 単押しで IME

左 Cmd = 英数 (`KC_LNG2`)、右 Cmd = かな (`KC_LNG1`)。Karabiner の `japanese_eisuu` / `japanese_kana` と同一の HID usage。

`get_hold_on_other_key_press()` で Cmd だけ「他キー押下で即ホールド確定」にしている。`TAPPING_TERM` を待つと `Cmd+C` が鈍く感じるため。

### 最下段

```
[MO(FN)][ Ctrl ][ Alt  ][Cmd/英数] │ [Space][ Cmd/かな ][ BS  ][Return]
  1u      1.5u    1.5u    1.25u       1.25u     2u        1.5u    1u
                         ^^^^^^^^      ^^^^^^^
                      左親指ホーム    右親指ホーム
```

**左手は MacBook の `cmd` から左をそのまま並べている** (`fn` `ctrl` `opt` `cmd`)。Cmd が最頻出かつ IME 切替も兼ねるので、MacBook と同じ「親指の定位置のすぐ内側」に置くことを最優先した。`fn` は Apple 独自実装で QMK から送れないため、その枠を `MO(_FN)` に充てている。

Home Row Mods のリファレンス実装 ([Miryoku](https://github.com/manna-harbour/miryoku)) は GUI を小指 (`A`) に載せる (GACS) ので最下段の Cmd を議論しない。ここでは `A` に HRM を載せない方針 (左手首腱鞘炎対策) を優先した結果、Cmd を物理キーとして親指に置く必要がある。

Space は右親指のみ。左手側は修飾キーで埋まるが、実際に Space を打つのは右親指だけなので支障はない (左手が Ctrl / D / Cmd と組む側だから)。tmux prefix (`D` ホールド + Space = Ctrl+Space) もこの位置で成立する。

BS と Return を親指に置いたのは、素の配置では BS が右上・Return が右手小指 (2.25u) で遠いため。`[9,3]` `[9,4]` は親指ホームから 2〜3 つ外側なので、指を伸ばす必要はある。

## Build & Flash

```bash
qmk userspace-compile        # .hex は .config/qmk/ の直下に出る
qmk flash -kb salicylic_acid3/7skb/rev1 -km 7spro
```

`overlay_dir` は設定に入っているので、どのディレクトリからでも動く。

ATmega32U4 なので UF2 のドラッグ&ドロップではなく avrdude 書き込み。`qmk flash` はビルド後にブートローダを待つので、その間に下記の操作でブートローダへ入れる。

分割キーボードなので**左右それぞれに書き込む**。片方が終わったら USB ケーブルを反対側の Pro Micro に挿し替えて、同じ手順を繰り返す。左右の判別は基板のピン (`split.handedness.pin`) で行われるため、焼くファームは共通。

### ブートローダに入る

キーマップから入れる。物理リセットは不要。

1. `MO(_FN)` を押しながら — 左親指ホーム、または最下段の 1 つ上の右端
2. **左上 Esc の位置**を押す — `_FN` レイヤーの `TG(_ADJUST)` に当たる
3. `MO(_FN)` を離す
4. **右上 Grave (`~`) の位置**を押す — `_ADJUST` レイヤーの `QK_BOOT`

`_ADJUST` はトグルなので、2 の操作でレイヤーが ON のまま維持される。USB が一度切れる音がすればブートローダに入っている (Caterina は約 8 秒でアプリに戻るので、`qmk flash` を先に走らせておくこと)。

キーマップが壊れて上記が使えない場合は、基板裏のタクトスイッチを 2 回押す。ケース越しに押せない場合は Pro Micro の RST と GND をピンセットでショートさせる ([ビルドガイド](https://salicylic-acid3.hatenablog.com/entry/7spro-build-guide))。

フラッシュは 32KB しかなく、`7skb` は `lto: true` + rgblight 有効で既に余裕がない。機能を足すときはビルド後のサイズを見る。

## 購入時ファームへの復帰

`stock/7spro-stock-2026-08-05.hex` は、QMK に焼き替える前に吸い出した購入時のファーム (VIA 対応)。**この定義は Remap のカタログ側にのみ存在し、GitHub のどこにも公開されていない**ため、これを失うと元の状態に戻せない。

```bash
avrdude -c avr109 -p m32u4 -P <port> -U flash:w:stock/7spro-stock-2026-08-05.hex:i
```

`avrdude` は `~/Library/Application Support/qmk/bin/avrdude`。`<port>` はブートローダに入った直後に現れる `/dev/cu.usbmodem*`。左右で同じファームなので 1 ファイルで足りる。

戻すと VID/PID が `0x04D8`/`0xEB5F` から `0x3265`/`0x000A` に変わり、Remap から開けるようになる。

## Pin の更新

`mise-tasks/qmk` の `QMK_FIRMWARE_REF` を上げて `mise run qmk`。

固定できるのは `qmk_firmware` のリビジョンだけで、toolchain / flashutils は `releases/latest`、Python 依存も master の `requirements.txt` を直接見に行く。ここは追随を受け入れる前提なので、**壊れたことに気づく手段はビルドを通すことだけ**。

## symlink しない

`.config/qmk/` は `link.sh` に登録していない。overlay_dir はリポジトリ内の実パスを直接指すので、symlink しても何も解決しない。

QMK CLI の設定は `~/.config/qmk/` ではなく `~/Library/Application Support/qmk/qmk.ini` (platformdirs 由来) に書かれるため、`~/.config/qmk/` は QMK からは触られない。

## Karabiner との責務分割

Complex modifications は `ifBuiltIn` で内蔵キーボードに限定してあるので、7sPro には効かない。HRM と IME 切替は上記のとおり QMK 側で実装済み。

Simple Modifications (`caps_lock` → `left_control`) だけは profile 全体に効くが、このキーマップは caps lock を送らず該当位置に直接 `KC_LCTL` を置いているので衝突しない。詳細は `../karabiner/README.md`。

### QMK では実現できないもの

アプリごとに挙動を変える必要があるものは、QMK にホストのアプリを知る手段がないため移植できない:

- ターミナルでの Ctrl tap-hold
- ターミナルでの Ctrl+Space → 英数 (tmux prefix と同時に IME を抜ける)

これらを 7sPro でも使いたい場合は Karabiner 側のルールに 7sPro のデバイス条件を足すことになる (未対応)。

## VIA / Remap

使わない。`rules.mk` を置かず `VIA_ENABLE` も有効にしていない。有効にすると EEPROM 側のキーマップが優先され、このディレクトリのソースと二重管理になる。
