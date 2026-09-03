# ZMK Configuration (Go60)

[MoErgo Go60](https://www.moergo.com/pages/go60-support) のキーマップ。ファームウェアは ZMK (MoErgo のフォーク [moergo-sc/zmk](https://github.com/moergo-sc/zmk))。`config/` は公式テンプレート [moergo-keyboards/go60-zmk-config](https://github.com/moergo-keyboards/go60-zmk-config) の `config/` と同じ構成で、`go60.keymap` だけがこのリポジトリの独自物。`default.nix` / `info.json` はテンプレートから持ってきたもの (MIT)。

## 方針

**Go60 の親指クラスタとレイヤーをフルに使う独自設計。** 7sPro (`../qmk/`) や MacBook 内蔵 (Karabiner) に揃えることは目的にしない (2026-09-03 に決定。それ以前は「ホームローの tap-hold だけは揃える」方針だった)。

判断の軸は 2 つ。

- **記号・数字・F キー・矢印はレイヤーで打つ。** ホームポジションから指を動かさない
- **数字行と両端列は Base に残す。** レイヤーが体に入るまでの退路であり、万一の保険。使わなくなっても消さない

## レイヤー

`Base` / `Sym` / `Num` / `Nav` / `Fn` / `Magic` / `Factory` の 7 枚。既定にあった `Keypad` は `Num` と役割が重複するので削除した。

図で確認するときは [Layout Editor](https://my.moergo.com/go60) に `go60-layout.json` を import する (下記「Layout Editor で見る」)。

### 親指クラスタ

親指の到達性は T1 (手に近い) > T2 > T3 (中央へ伸ばす) の順。**tap を持つキーを手前に、`&mo` 単独を T3 に**置いた。

| | 左 | 右 |
|---|---|---|
| T1 | tap `Esc` / hold **Num** | `Space` (`spc_ime`) |
| T2 | tap `Tab` | tap `Enter` / hold **Sym** |
| T3 | **Nav** (`&mo` 単独) | **Fn** (`&mo` 単独) |

`Space` に hold を載せていないのは、最頻出キーから tap-hold の判定を外すため。

**レイヤー入口を親指に置いたので `hold-trigger-key-positions` が要らない。** 親指と他の 4 指は独立に動くので、レイヤー中は左右 10 指すべてが使える。ホームローの tap-hold にある「入口と同じ手の文字が打てない」制約がここにはない。

### R5 行 (親指を畳んで押す)

| 位置 | 割当 |
|---|---|
| `L_C3R5` / `R_C3R5` | 英数 (`LANG2`) / かな (`LANG1`) |
| `L_C2R5` | `BSpc` |
| `R_C2R5` | `Cmd` (`&kp RGUI` 単独) |
| `L_C4R5` / `R_C4R5` | 親指が届かないので使わない (既定のキーを残置) |

IME 切替を Cmd から分離したことで、**Cmd が単独キーになった**。以前は かな との tap-hold で `hold-preferred` を要したが、その調整ごと不要になっている。

### ホームロー (HRM)

```
左  A=Cmd  S=Opt  D=Ctrl  F=Shift
右  J=Shift  K=Ctrl  L=Opt  ;=⌘⌥⌃
```

左右対称なので修飾は常に逆手で押せる。`;` の ⌘⌥⌃ は Raycast 用で、Secure Input 固着時にもホットキーが生きるよう Cmd を含める。Raycast のホットキーは左右どちらの手の文字も使うので、`;` だけは位置制限を付けない。

### Sym (右親指 `R_T2` ホールド / 両手)

```
       C5   C4   C3   C2   C1        C1   C2   C3   C4   C5
行2     ~    @    #    $    %         ^    (    )    -    ?
行3     `    '    "    ;    :         &    {    }    =    +
行4     |    \    ,    .    /         *    [    ]    !    _

親指   L_T2 = <    L_T3 = >
```

**US 配列の記号 32 個すべてがこのレイヤーにある。** Shift との併用は要らない。当初は左手だけに収めて `_` `+` `|` `:` などを `J`(Shift) との合成で出す設計だったが、`@` を打とうとして無いことに気づく、という形で破綻した (2026-09-03)。

- **右手が括弧と演算子。** `C2` 列が開き `( { [`、`C3` 列が閉じ `) } ]` で縦に整列する。`{}` を中段 (ホームロー) に置くのはブロックが最頻出だから。開きが左・閉じが右なので `(` → `)` の運指が読み順と揃う
- **`C1` 列は `^ & *`** で、数字 6 / 7 / 8 の shift 記号が縦に並ぶ。**左手の行 2 が `~ @ # $ %`** で、こちらは 2 / 3 / 4 / 5 の shift 記号。`!` だけ右手 `C4` に離れている
- 左手の行 3 はクォートと区切り (`` ` `` `'` `"` `;` `:`)、行 4 はスラッシュ系 (`|` `\` `,` `.` `/`)
- R5 行の `Cmd` が透けているので、`Cmd+[` `Cmd+/` のような組み合わせは Sym を抱えたまま打てる。**Sym は両手が記号で埋まっていてホームローの HRM が効かないので、これが Sym 中の唯一の修飾キー**

配置は [Gentleman v3.3](https://my.moergo.com/go60) の Programming レイヤーを土台にした。括弧の縦整列と、shift 記号を数字キーの左右に振り分ける考え方はそこから来ている。

### Num (左親指 `L_T1` ホールド / 右手)

```
   C1   C2   C3   C4   C5
    -    7    8    9    -
    -    4    5    6    0
    -    1    2    3    -
```

左手はホームローの 4 キーだけ `&trans` で、Base の HRM が透ける (`Cmd+1`〜`Cmd+9` でタブ切替)。それ以外は `&none`。

### Sym と Num の重なり (廃止)

かつては両親指をホールドすると「左手に記号・右手に数字」が同時に立ち、`x = 1 + 2` を一息で打てた。これは成立しなくなった。理由は 2 つ。

- `=` `+` `-` が Sym の右手へ移った (全記号を 1 枚に載せた副作用)
- Num の左手を `&none` で潰したので、Sym の記号に降りられない (ホームロー行の 4 キーだけ HRM のために `&trans` が残る)

記号と数字を混ぜるときはレイヤーを持ち替える。

### Nav (左親指 `L_T3` ホールド / 右手)

| 入力 | 出力 |
|---|---|
| `h` `j` `k` `l` | ← ↓ ↑ → |
| `u` / `n` | PgUp / PgDn |
| `,` / `.` | Opt+← / Opt+→ |
| `BSpc` (`L_C2R5`) | Del |

矢印は vim の hjkl に合わせてある (miryoku 系の十字配置は採らない)。

### Fn (右親指 `R_T3` ホールド / 左手)

```
     C5    C4   C3   C2
    F12    F7   F8   F9
    F11    F4   F5   F6
    F10    F1   F2   F3
```

Num / Sym と同じ 789/456/123 の並び。**旧 FN レイヤ (S ホールド) は数字行に F1〜F12 を並べていたが、F1〜F5 は左手にあって `hold-trigger-key-positions` に弾かれ、実際には打てなかった。** 入口を右親指に移したことでこの穴も塞がっている。

### tap-hold のパラメータ

| behavior | 対象 | tapping-term | 位置制限 |
|---|---|---|---|
| `hrm_l` / `hrm_r` | 人差し指・中指・薬指の HRM | 180ms | 逆手 + 親指 |
| `hrm_lp` | 左小指 (`A` = Cmd) | 220ms | 逆手 + 親指 |
| `mt_hyper` | `;` の ⌘⌥⌃ | 180ms | なし |
| `lt_thumb` | 親指のレイヤー入口 | 180ms | なし |

共通して `flavor = "balanced"` (QMK の `PERMISSIVE_HOLD` 相当)、`quick-tap-ms = <200>`、HRM には `require-prior-idle-ms = <150>`。

**`hold-trigger-on-release` は左右対称 HRM に必須。** これがないと `hold-trigger-key-positions` を持つ HRM は 2 つ同時に押せず、2 つ目が tap に落ちる (= `Cmd+Shift+P` が打てない)。判定を「次のキーを離すまで」遅らせることで修飾を重ねられる。小指だけ 220ms と長いのは、ローマ字入力で `a` が頻出で誤爆しやすいため。

キー位置番号は `keymap` の並び順そのもの: 0〜47 が上 4 行 (各行 左 6 → 右 6)、48〜50 が左 R5、51〜53 が右 R5、54〜56 が L_T1〜T3、57〜59 が R_T3〜T1。`KEYS_L` / `KEYS_R` / `KEYS_T` がこれに対応する。

### `&trans` と `&none` の使い分け

**意図して下のレイヤーを透かす位置だけ `&trans`、使わない位置は `&none`。** 図を見たときにどちらの意図か読めるようにするための規則 (2026-09-03)。

| `&trans` を置く場所 | 透けるもの | なぜ要るか |
|---|---|---|
| ホームローの 8 キー | Base の HRM | Nav 中の `Shift+←` (選択) / `Cmd+←` (行頭)、Num 中の `Cmd+1`〜`9`、Fn 中の `Shift+F3` |
| R5 の内側 4 キー | 英数 / かな / BSpc / Cmd | **Sym 中の唯一の修飾キー**。IME 切替と訂正はどのレイヤーでも要る |
| `L_C6R4` | Magic 入口 | BT 切替・RGB・`&bootloader` への唯一の入口 |
| 親指 6 キー | 他のレイヤー入口 / Space / Enter | レイヤーを抱えたままスペースや改行を打つ |

それ以外はすべて `&none`。**`&none` は「無効」ではなく「下を隠す」指定**で、押しても何も起きない代わりに Base の文字が漏れない。以前は未使用位置を `&trans` のままにしていたため、Num 中に `n` を押して `N` が出て混乱した。

Base の数字行と両端列も同じ理由で `&none` にした (`L_C6R4` の Magic だけ残す)。`Tab` / `Esc` は親指、`= - \ '` は Sym にあるので失うものはない。**`Cmd+1`〜`9` の打ち方も変わらない** — 左手の `1`〜`5` は元々 HRM の位置制限に弾かれて打てず、Num 経由が正規ルートだった。Magic レイヤーの `&bootloader` は Magic 側が独自の binding を持つので Base とは無関係に生きている。

### Ctrl+Space (tmux prefix)

Space (`R_T1`) は mod-morph で、Ctrl を押しながらだと 英数 を先送りしてから Ctrl+Space を送る。**Ctrl が `D` / `K` の HRM に移っても動く** — `KEYS_T` に右親指 (57〜59) が入っているので、`D` ホールド + 右親指 Space が位置制限を通過する。

mod-morph はトリガーの Ctrl をレポートからマスクするので、マクロ側は `&kp LC(SPACE)` の implicit modifier で Ctrl を付け直す (implicit はマスクを通る。`app/src/hid.c` の `SET_MODIFIERS`)。

## Build

ローカルにツールチェーンは入れない。`.config/zmk/**` を変えて push すると `.github/workflows/zmk-go60.yml` が nix でビルドし、artifact `go60.uf2` を出す。Actions の該当 run から落とす (`gh run download` でもよい)。

ファームは `moergo-sc/zmk` をタグ固定 (`ZMK_REF`、ワークフローの `env`)。上げるときはタグを書き換えて push し、ビルドが通るのを見る。公式テンプレートは `main` 追随だが、7sPro の `QMK_FIRMWARE_REF` と同じ理由で固定している。

`default.nix` の `firmware ? import ../src {}` が `src/` を `config/` の隣に期待するので、CI では `.config/zmk/src` に checkout する (`.gitignore` 済み)。

CI ができる前 (2026-09-02) は手元の Podman で同じ nix ビルドを回した。`docker.io/nixpkgs/nix` に cachix を入れて `nix-build ./config --arg firmware 'import /src/default.nix {}'`。20 分弱かかり、ストアはコンテナごと消えるので常用しない。

## Flash

同じ `go60.uf2` を**左右それぞれ**に入れる。[公式手順](https://docs.moergo.com/go60-user-guide/customizing-key-layout/)は右 → 左の順。

1. 右半分を USB-C で繋ぎ、ブートローダに入れる (下記)。赤 LED がゆっくり点滅する
2. 現れた `GO60RHBOOT` に `go60.uf2` をコピーする
3. 左半分で同じことをする。ドライブ名は `GO60LHBOOT`

### ブートローダに入る

- **キーマップから** (既定と同じ): Magic (`Z` の左) を押しながら、左は Tab、右は `\`。`&bootloader` は押したキーがある側の半分にだけ効く
- **電源投入で** (キーマップが壊れていても使える): T3 と C3R3 (左は D、右は K の位置) を押しながら電源を入れる

書き込まずに抜けるには電源を切って入れ直す。

### 業務 Mac では書き込めない

業務 Mac は Defender for Endpoint の device control が `block` で、ブートローダのドライブは認識されるがマウントされない (`mdatp health` の `device_control_enforcement_level`)。書き込みは別の端末 (別 Mac、Raspberry Pi、スマートフォンのファイルアプリ) で行う。`go60.uf2` は Slack などで運べばよい。恒常的に業務 Mac で書きたければ IT に vendor ID `0x239A` / product ID (右 `0x0029`) の許可を申請する。

## Layout Editor で見る

[MoErgo Layout Editor](https://my.moergo.com/go60) にレイアウトを取り込むと、ブラウザ上で全レイヤーを見られる。**正はあくまで `go60.keymap`** で、Layout Editor 側は閲覧専用。あちらで編集しても手元には戻ってこない。

```bash
mise run zmk-layout   # go60.keymap → go60-layout.json
```

1. Layout Editor の **Settings → `Local Backup and Restore` を有効化** (これがないと import のメニューが出ない)
2. エディタ画面の左下 **Import** から `go60-layout.json` を選ぶ

`keymap2layout.py` が `.keymap` から JSON を組み立てる。やっていることは 3 つ。

- `keymap` ブロックの各レイヤーを 60 個の binding オブジェクトに変換し、`LAYER_*` をレイヤー番号へ、`KEYS_*` をキー位置の数値列へ展開する
- 独自に定義した behavior / macro (`hrm_*` `mt_hyper` `lt_thumb` `spc_ime` `tmux_prefix`) を `custom_defined_behaviors` に丸ごと入れる。`magic` や `bt_0`〜`bt_3`、`rgb_ug_status_macro` は Layout Editor が自前で定義するので**除外しないと二重定義になる**
- `&cirque_*_listener` を `inputListeners` に写す

**JSON 形式は MoErgo 側で変わりうる。** 公式が「[将来 import できる保証はない](https://docs.moergo.com/layout-editor-guide/advanced-usage-export-import/)」と明記しているので、import が壊れたら `keymap2layout.py` を直す。生成物なので捨てて作り直せばよく、キーマップ本体には影響しない。形式を調べ直すときは、Layout Editor から適当なレイアウトを JSON で export して構造を突き合わせる。

以前は keymap-drawer で `keymap.svg` を描いていたが、Layout Editor で足りるので 2026-09-03 に削除した (`mise-tasks/zmk-keymap` と `keymap-drawer.yaml` / `keymap-notes.yaml` も同時に撤去)。
