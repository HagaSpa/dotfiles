# Karabiner Configuration

`karabiner.json` is generated from `karabiner.ts` using [karabiner.ts](https://github.com/evan-liu/karabiner.ts). Never edit `karabiner.json` by hand — edit `karabiner.ts` and rebuild:

```bash
cd .config/karabiner
bun run build   # generate karabiner.json, sync back to repo, reload profile
```

`build` regenerates the config, copies `~/.config/karabiner/karabiner.json` back into the repo (Karabiner's atomic writes break the symlink otherwise), and reloads the profile via `karabiner_cli`.

See `HRM.md` for the Home Row Mods design notes.
