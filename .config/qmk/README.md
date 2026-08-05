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

## Build & Flash

```bash
qmk userspace-compile        # .hex は .config/qmk/ の直下に出る
qmk flash -kb salicylic_acid3/7skb/rev1 -km 7spro
```

`overlay_dir` は設定に入っているので、どのディレクトリからでも動く。

ATmega32U4 なので UF2 のドラッグ&ドロップではなく avrdude 書き込み。**リセットを 2 回押して**書き込みモードに入れる。分割キーボードなので**左右それぞれに書き込む**。

フラッシュは 32KB しかなく、`7skb` は `lto: true` + rgblight 有効で既に余裕がない。機能を足すときはビルド後のサイズを見る。

## Pin の更新

`mise-tasks/qmk` の `QMK_FIRMWARE_REF` を上げて `mise run qmk`。

固定できるのは `qmk_firmware` のリビジョンだけで、toolchain / flashutils は `releases/latest`、Python 依存も master の `requirements.txt` を直接見に行く。ここは追随を受け入れる前提なので、**壊れたことに気づく手段はビルドを通すことだけ**。

## symlink しない

`.config/qmk/` は `link.sh` に登録していない。overlay_dir はリポジトリ内の実パスを直接指すので、symlink しても何も解決しない。

QMK CLI の設定は `~/.config/qmk/` ではなく `~/Library/Application Support/qmk/qmk.ini` (platformdirs 由来) に書かれるため、`~/.config/qmk/` は QMK からは触られない。

## Karabiner との責務分割

Complex modifications は `ifBuiltIn` で内蔵キーボードに限定してあるので、7sPro には効かない。Home Row Mods を 7sPro でも使うなら QMK 側に実装する。

Simple Modifications (`caps_lock` → `left_control`) だけは profile 全体に効くが、このキーマップは caps lock を送らず該当位置に直接 `KC_LCTL` を置いているので衝突しない。詳細は `../karabiner/README.md`。

## VIA / Remap

使わない。`rules.mk` を置かず `VIA_ENABLE` も有効にしていない。有効にすると EEPROM 側のキーマップが優先され、このディレクトリのソースと二重管理になる。
