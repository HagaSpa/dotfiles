# Karabiner Configuration

`karabiner.json` is generated from `karabiner.ts` using [karabiner.ts](https://github.com/evan-liu/karabiner.ts). Never edit `karabiner.json` by hand — edit `karabiner.ts` and rebuild:

```bash
cd .config/karabiner
bun run build   # generate karabiner.json, sync back to repo, reload profile
```

`build` regenerates the config, copies `~/.config/karabiner/karabiner.json` back into the repo (Karabiner's atomic writes break the symlink otherwise), and reloads the profile via `karabiner_cli`.

## Scope: 内蔵キーボードのみ

Complex modifications の全 rule に `ifBuiltIn` (`device_if: is_built_in_keyboard`) を付けている。外付けキーボード (7sPro) は QMK でキーマップを組むため、Karabiner 側と二重に適用させない。**rule を追加するときも必ず付ける。**

Simple Modifications (`caps_lock` → `left_control`) はデバイス条件を持てない (Karabiner のスキーマ上 profile 全体に効く。per-device 版は `profiles[].devices[].simple_modifications` だが `writeToProfile` は書き込まない)。外付け側では `caps_lock` を送らない (QMK で直接 Ctrl に割り当てる) ことで回避する。

## Simple Modifications

Complex modifications だけでなく Simple Modifications (`caps_lock` → `left_control`) も `karabiner.ts` の `SIMPLE_MODIFICATIONS` から生成される (`writeToProfile` の第 4 引数)。**GUI の Simple Modifications 画面で追加しない** — `karabiner.ts` に書く。GUI で追加すると `profiles[].devices[].simple_modifications` に入り、`writeToProfile` が上書きしないためソースが二重化する。

See `HRM.md` for the Home Row Mods design notes.
