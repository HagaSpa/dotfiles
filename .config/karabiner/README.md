# Karabiner Configuration

`karabiner.json` is generated from `karabiner.ts` using [karabiner.ts](https://github.com/evan-liu/karabiner.ts). Never edit `karabiner.json` by hand — edit `karabiner.ts` and rebuild:

```bash
cd .config/karabiner
bun run build   # generate karabiner.json, sync back to repo, reload profile
```

`build` regenerates the config, copies `~/.config/karabiner/karabiner.json` back into the repo (Karabiner's atomic writes break the symlink otherwise), and reloads the profile via `karabiner_cli`.

## Simple Modifications

Complex modifications だけでなく Simple Modifications (`caps_lock` → `left_control`) も `karabiner.ts` の `SIMPLE_MODIFICATIONS` から生成される (`writeToProfile` の第 4 引数)。**GUI の Simple Modifications 画面で追加しない** — `karabiner.ts` に書く。GUI で追加すると `profiles[].devices[].simple_modifications` に入り、`writeToProfile` が上書きしないためソースが二重化する。

See `HRM.md` for the Home Row Mods design notes.
