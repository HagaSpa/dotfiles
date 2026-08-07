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

![7sPro keymap](keymap.svg)

MacBook 内蔵キーボードでは Karabiner が近い機能を提供している (`../karabiner/HRM.md`)。整合を取るのは**ホームローの tap-hold だけ**で、最下段は 7sPro 独自 (親指の到達性を優先。2026-08-07 に方針変更)。**レイヤ方式への移行はまだ Karabiner に追随させていない** — 内蔵側は S=Opt / D=Ctrl+変換のまま。

### ホームローの tap-hold

| キー | ホールド |
|---|---|
| S | `_FN` レイヤ (F1–F12) |
| D | `_NAV` レイヤ (矢印ほか、下記) |
| F | Shift (右手の文字用) |
| Enter (右親指) | Shift (左手の文字用) |
| ; | ⌘⌥⌃ (Raycast 用) |

修飾キーの mod-tap (S=Opt, D=Ctrl) からレイヤ方式に移行した (2026-08-07)。D=Ctrl だった頃は **`Ctrl+D` が原理的に作れず** (D 自身が Ctrl)、同手の `Ctrl+G` / `Ctrl+B` も `CHORDAL_HOLD` がタップに倒していた。Ctrl を左親指の専用キーに出したことで、この制約ごと消えている。

Shift が 2 箇所あるのも `CHORDAL_HOLD` の帰結 — F ホールドは同手 (左手) の文字に効かないので、左手の大文字は右親指の Enter ホールドで打つ。`A` には載せない (左手首腱鞘炎対策)。`J` にも載せない — vim の j/k 長押しスクロールが死ぬため (Karabiner 側は vim 系アプリで無効化しているが、QMK はホストのアプリを知らない)。

`CHORDAL_HOLD` が同手のロールをタップ扱いにするので、`fa` や `ds` のような同手ロールで誤爆しない。**ただし効くのは `TAPPING_TERM` (180ms) 以内**で、意図的に同手で使いたいときは長めにホールドしてから相方を叩く。加えて `FLOW_TAP_TERM` (150ms) が高速タイプ中のホールド判定を止める — **文字入力の直後はホールドがタップに倒れる**ので、タイプ直後の矢印や Shift は一呼吸置く。

### Cmd 単押しで IME

左 Cmd = 英数 (`KC_LNG2`)、右 Cmd = かな (`KC_LNG1`)。Karabiner の `japanese_eisuu` / `japanese_kana` と同一の HID usage。

`get_hold_on_other_key_press()` で Cmd だけ「他キー押下で即ホールド確定」にしている。`TAPPING_TERM` を待つと `Cmd+C` が鈍く感じるため。

### NAV レイヤ (D ホールド)

| 入力 | 出力 |
|---|---|
| D + h / j / k / l | ← / ↓ / ↑ / → |
| D + , / . | Opt + ← / → (word jump) |
| D + u / n | PgUp / PgDn |
| D + 左親指 BS | Del (forward delete) |

以前は Key Overrides で `Ctrl+hjkl` → 矢印に変換していた (トリガは物理 Ctrl か D=Ctrl の HRM)。指の動きは D ホールド + hjkl のまま、経路から Ctrl を外した形。矢印はレイヤが直接発行するので、選択を伸ばすときは Enter 親指か物理 Shift を重ねる。

`CHORDAL_HOLD` の逆手ルールと相性がよい — D は左手、対象キーはすべて右手なので同手ロールで誤爆しない。唯一の例外が左親指 BS で、これだけ chordal_hold_layout で `'*'` (除外) にして同手チョードを許可している。

Ctrl+hjkl の変換が消えたので、**素の `Ctrl+h/j/k/l` がアプリまで届くようになった** (ターミナルの Ctrl+L = clear などが復活)。nvim のウィンドウ移動 (`<C-w>hjkl` の別名) は、内蔵キーボード側の Karabiner がまだ同じ変換をしているため `.config/nvim/lua/config/keymaps.lua` では無効のまま。

### tmux prefix と IME

`Ctrl+Space` (左親指 Ctrl + 右親指 Space) は、先に 英数 (`KC_LNG2`) を送ってから `Ctrl+Space` を送る。日本語入力中でも prefix を打つだけで IME から抜けられる。左右対称の親指チョードなので小指もタイミング調整も要らない (herdr も同じ prefix)。

Karabiner 側はこれをターミナル限定にしているが、QMK はフロントのアプリを判定できないため **全アプリ対象**。`Ctrl+Space` に他の割り当てが無いので支障はない (macOS 自身の入力ソース切替は `settings.sh` で無効化済み)。

### 最下段

```
[MO(FN)][  BS  ][Cmd/英数][ Ctrl ] │ [Space][ Cmd/かな ][Enter/Shift][ Opt ]
  1u      1.5u    1.5u     1.25u     1.25u      2u         1.5u        1u
 小指/薬指 ギリ親指  親指ホーム  楽々     楽々     親指ホーム    ギリ親指    小指/薬指
```

当初は MacBook の `opt` `cmd` `Space` の並びを再現していたが、**頻度基準の並びに変更した** (2026-08-07)。7sPro は内蔵キーボードより横に広く、物理 Ctrl / Shift への左小指の伸びが痛みの原因になったため。MacBook と揃えるのはホームローだけとし、最下段は 7sPro 専用の体で慣らす。

配置原則は**到達性と頻度の一致**:

- **一番外 (1u)** は親指が届かない。低頻度キー (`MO(_FN)` / `Opt`) 専用にして、押すときはホームポジションを外して薬指で押す
- **外から 2 番目 (1.5u)** はギリ親指圏 — 手を少しスライドして親指をたたむと届く。キーキャップを上下逆に付けて凸面を親指側に向けると多少良くなる。ここに BS (左) と Enter/Shift (右)
- **親指ホーム** (左 1.5u / 右 2u) は Cmd ペア。**かな Cmd に 2u を充てているのは、最頻出ホールドのチョードアンカーだから** — Cmd+C/V のホールド中は親指の接地点がズレるので、面積がそのまま脱落防止になる。単発タップ (Space 等) は 1.25u で外さない
- **Ctrl は左親指** (旧・左 Space の位置。Space は右親指でしか打っていなかった)。tmux prefix が左右対称の親指チョードになり、ターミナルの Ctrl コードも親指起点になる

Enter ホールドの Shift は左手の文字専用 (chordal_hold_layout で `'R'` のまま)。右手文字との同手ロール (`l` → Enter など) が Shift に化けないための線引きで、右手の大文字は F ホールドが担当する。

BS と Enter は素の位置 (右上 / 右小指 2.25u) にも残っているので、遠いと感じる場面ではそちらも使える。物理 Ctrl (`A` の左) と物理 Shift (左下) は矯正期間の保険として残置。

### 図の再生成

```bash
mise run qmk-keymap   # keymap.c → keymap.svg
```

[keymap-drawer](https://github.com/caksoylar/keymap-drawer) が `qmk c2json` の出力を描画する。`keymap.c` を変えたら走らせる。SVG はテキストなので diff が読める。

図は 5 レイヤーで、うち 4 つは `keymaps[][][]` から自動生成される。**5 枚目の `Ctrl 併用` だけは `keymap-notes.yaml` に手で書いている** — `Ctrl+Space` の IME 先送りは `process_record_user()` にあり、`c2json` からは見えないため。`keymap.c` のこれを変えたら手で追随させる。

`keymap-drawer.yaml` はラベルの読み替え (`KC_LNG2` → 英数 など)。`parse_config.qmk_keycode_map` に書くと組み込みの対応表ごと置き換わってしまうので、`raw_binding_map` を使っている。

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

1. `MO(_FN)` を押しながら — 最下段の左端、または最下段の 1 つ上の右端
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

Complex modifications は `ifBuiltIn` で内蔵キーボードに限定してあるので、7sPro には効かない。ホームローの tap-hold と IME 切替は上記のとおり QMK 側で実装済み。

Simple Modifications (`caps_lock` → `left_control`) だけは profile 全体に効くが、このキーマップは caps lock を送らず該当位置に直接 `KC_LCTL` を置いているので衝突しない。詳細は `../karabiner/README.md`。

### 移していないもの

**`J` = Shift** だけ。Karabiner 側は vim 系アプリで無効化しているが、QMK はホストのアプリを知らないため同じ切り分けができない。7sPro では右 Shift は物理キーを使う。

## VIA / Remap

使わない。`VIA_ENABLE` は有効にしていない。有効にすると EEPROM 側のキーマップが優先され、このディレクトリのソースと二重管理になる (追加機能を有効にしていないので `rules.mk` 自体が無い)。
