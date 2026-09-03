# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup Commands

```bash
./install.sh   # Bootstrap (Homebrew + Brewfile + mise runtimes), then runs `mise run setup`
./link.sh      # Create symlinks from repo to system locations (backs up existing)
./settings.sh  # Configure macOS system settings (requires restart)
```

Individual setup steps are mise file tasks under `mise-tasks/` (repo-scoped; they do not leak into other projects' `mise tasks` because they are file tasks, not entries in the global `.mise.toml`):

```bash
mise tasks            # list tasks
mise run setup        # claude / tpm / yazi-plugins / karabiner, independent tasks run in parallel
mise run karabiner    # full re-run of one step incl. deps (bun install + build)
mise run qmk          # QMK toolchain + firmware clone (not part of setup — see QMK section)
mise run qmk-keymap   # redraw .config/qmk/keymap.svg from keymap.c
mise run zmk-layout   # regenerate .config/zmk/go60-layout.json for the MoErgo Layout Editor
mise run atuin-clean  # tidy the atuin history DB (run by hand — see atuin section)
```

Note: `mise run karabiner` is for setup-style runs (installs bun deps first). For day-to-day karabiner.ts edits, `cd .config/karabiner && bun run build` remains the primary flow (see Karabiner section).

## Testing

Tests run automatically via GitHub Actions on PRs and pushes to main. To run locally:

```bash
bats tests                          # fast tests: link / config / Brewfile / settings / karabiner build
                                    # (brew install bats-core; settings.bats re-applies your macOS settings)
./.github/scripts/test-install.sh   # install.sh integration test (actual execution, slow)
```

Lint runs in the CI `lint` job, which installs its own pinned tools (not in the Brewfile). Targets are discovered by shebang: tracked `*.sh` with a sh/bash shebang go to shellcheck + shfmt; the rest (zsh configs, which shellcheck cannot parse) plus `.zshrc` / `.zshenv` get `zsh -n`. To reproduce locally, `brew install shellcheck shfmt actionlint` ad hoc and run:

```bash
git ls-files '*.sh' 'mise-tasks/*' | while read -r f; do head -n1 "$f" | grep -Eq '^#!.*/(env )?(ba)?sh( |$)' && echo "$f"; done > /tmp/targets
xargs shellcheck < /tmp/targets
xargs shfmt -i 2 -d < /tmp/targets   # -w to format
actionlint
zsh -n <file>   # zsh configs and .zshrc / .zshenv
```

## Architecture

### Core Scripts
- `install.sh` - Bootstrap only: Homebrew → Brewfile packages (installs mise) → mise runtimes → delegates the rest to `mise run setup`
- `mise-tasks/` - mise file tasks (plain bash scripts, name = task name): `setup` fans out to `claude` / `tpm` / `yazi-plugins` / `karabiner` via the dependency DAG; `link` / `settings` wrap the scripts below. Keep tasks OUT of `.mise.toml` — it is symlinked to `~/.mise.toml` (global), so tasks there would appear in every project
- `link.sh` - Declarative symlink management via `entries` array. Source path only = `~/{source}`, `source:destination` for custom paths. `--list` outputs all entries as `source:destination`
- `settings.sh` - macOS defaults configuration (key repeat, trackpad, Ctrl+Space free-up for tmux prefix, Kotoeri predictive candidates off)

### Configuration Files
- **Shell**: `.zshrc` / `.zshenv` (main) + `.config/zsh/` (alias.sh, command.sh, hosts/)
- **Runtime**: `.mise.toml` (Node.js LTS, bun, gcloud, terraform, biome, rust + rust-analyzer)
- **Git**: `.gitconfig` (personal) + `.gitconfig-olta` (work, includeIf), `.config/lazygit/config.yml` (delta pager; found via `LG_CONFIG_FILE` in `.zshenv`, since lazygit defaults to `~/Library/Application Support`)
- **Terminal**: `.config/ghostty/config`, `.config/tmux/tmux.conf` (→ `~/.tmux.conf`), `.config/herdr/` (herdr; keybindings mirror tmux.conf — see below)
- **Editor**: `.config/nvim/init.lua` (Neovim), `.config/zed/settings.json` (Zed)
- **Prompt/Plugins**: `.config/starship/starship.toml` (→ `~/.config/starship.toml`), `.config/sheldon/plugins.toml`
- **File Manager**: `.config/yazi/` (yazi config + projects plugin)
- **Search**: `.config/fd/` (fd defaults)
- **Input**: `.config/karabiner/` (keyboard remapping, TypeScript-based — see below), `.config/qmk/` (7sPro keymap as a QMK External Userspace; not symlinked — see below), `.config/zmk/` (Go60 keymap for ZMK; built by CI, not locally — see below)
- **Browser**: `.config/vimium/vimium-c.json` (Vimium C settings export; import-only, not symlinked — see `.config/vimium/README.md`)
- **Window Manager**: `.config/amethyst/amethyst.yml` (Amethyst; `screen-padding-*` is tied to the external monitor's logical width — see `docs/window-manager.md`)
- **Claude Code**: `.config/claude/` (settings.json + commands/, symlinked to `~/.claude/`)

### herdr (agent multiplexer)
`.config/herdr/config.toml` mirrors `.config/tmux/tmux.conf`'s keybindings so the two multiplexers are interchangeable by muscle memory — change one and change the other. Apply edits to a running server without restarting panes:

```bash
herdr config check          # validate config.toml (also a bats test)
herdr server reload-config  # apply to the running server
herdr --default-config      # full annotated default config
```

Four tmux bindings have no herdr equivalent in 0.8.0 and are deliberately absent: `send-prefix`, `last-window`, `PageUp` as a bindable key, and rebinding keys *inside* copy mode. See `docs/herdr-vs-tmux.md`.

`.config/herdr/yazi-picker.sh` is the herdr port of `.config/tmux/yazi-picker.sh`. It sends the chosen paths to nvim with `herdr pane send-keys` one character at a time, not `herdr pane run` — `run` pastes via bracketed paste, which nvim inserts into the buffer regardless of mode.

### atuin history (manual cleanup)
atuin records into its own SQLite DB (`~/.local/share/atuin/history.db`) via zsh `preexec`/`precmd` hooks — it never reads `~/.zsh_history`, so zsh's `setopt hist_*` options do not affect it. atuin dedupes by exact command string at search time, so entries differing only in whitespace show up as separate "duplicates", and failed commands stay in history because atuin has no exit-code filter.

`mise run atuin-clean` fixes both after the fact. It takes a timestamped backup, then:

- trims leading/trailing whitespace on every entry, and collapses runs of internal spaces **only** on entries containing no quote, backslash, or newline — a blanket `s/\s+/ /g` would corrupt multi-line commands (`gcloud logging read` filters, heredocs, `\` continuations)
- deletes entries whose exit code is 127 (command not found), 255 (ssh failure), or 2 (bad arguments)

`--dry-run` reports the counts without writing. Exit codes 1 / 130 / 101 / 145 / 128 are deliberately kept — they cover `go test`, `npm run dev`, `cargo build`, `fg`, `gp`. Exit code -1 means atuin's `history end` hook never fired (`exit`, `exec zsh`), not a failure, so it is kept too.

This is deliberately a manual task rather than a `precmd` hook, so nothing runs in the background. If whitespace duplicates start piling up between runs, the fix is to normalize at record time instead: `setopt hist_reduce_blanks` plus a `_atuin_preexec` wrapper passing `${history[$HISTCMD]}` (zsh's blank-reduced form, which is lexer-aware and preserves quoted content) in place of the raw `$1`.

### Karabiner (TypeScript build)
`karabiner.json` is generated from `karabiner.ts` using the karabiner.ts library. Never edit `karabiner.json` directly, and never add Simple Modifications from the Karabiner GUI (they live in `karabiner.ts`'s `SIMPLE_MODIFICATIONS` too) — edit `karabiner.ts` and build:

```bash
cd .config/karabiner && bun run build  # generate → sync repo copy → reload profile
```

`build` regenerates the config, copies `~/.config/karabiner/karabiner.json` back into the repo (Karabiner's atomic writes break symlinks), and reloads the profile via `karabiner_cli`.

### QMK (7sPro keymap)
`.config/qmk/` is a QMK [External Userspace](https://docs.qmk.fm/newbs_external_userspace) holding the keymap for the 7sPro — which QMK knows as `salicylic_acid3/7skb/rev1`, not `7spro`. Set up with `mise run qmk` (not part of `mise run setup`: it pulls down a few hundred MB and is only needed on a machine with the 7sPro).

```bash
qmk userspace-compile   # .hex lands in .config/qmk/; works from any directory
```

`keymap.svg` is the keymap reference, generated from `keymap.c` by `mise run qmk-keymap` (keymap-drawer). The `Ctrl 併用` layer in it is hand-written in `keymap-notes.yaml` — Key Overrides and the Ctrl+Space IME bypass live outside `keymaps[][][]`, so `qmk c2json` cannot see them.

Do NOT add `.config/qmk/` to `link.sh` — `overlay_dir` points at the in-repo path directly, so a symlink would accomplish nothing. The CLI's own config lives in `~/Library/Application Support/qmk/qmk.ini` (platformdirs), not `~/.config/qmk/`.

Karabiner's complex modifications are scoped to the built-in keyboard, so they never apply to the 7sPro; anything the 7sPro needs (Home Row Mods included) lives in the keymap. See `.config/qmk/README.md`.

### ZMK (Go60 keymap)
`.config/zmk/config/` mirrors the layout of MoErgo's `go60-zmk-config` template; only `go60.keymap` is ours. It is a layer-driven design of its own — every layer entry sits on the thumb cluster, the home row carries symmetric mods, and symbols / digits / F keys / arrows live on the Sym / Num / Fn / Nav layers. It is deliberately NOT aligned with the 7sPro or the built-in keyboard. See `.config/zmk/README.md`.

To read the keymap in a browser, `mise run zmk-layout` regenerates `go60-layout.json` and you import that into the [MoErgo Layout Editor](https://my.moergo.com/go60) (Settings → `Local Backup and Restore` must be on). `go60.keymap` stays the source of truth — the Layout Editor is view-only, and edits made there do not come back. The JSON format is undocumented and MoErgo warns it may change, so if import breaks, fix `keymap2layout.py` rather than moving the source of truth. The keymap-drawer SVG was dropped on 2026-09-03 in favour of this.

There is no local toolchain. `.github/workflows/zmk-go60.yml` builds `go60.uf2` with nix on every change under `.config/zmk/**` and uploads it as an artifact; `ZMK_REF` in that workflow pins the `moergo-sc/zmk` tag. Do NOT start a firmware build (Podman or CI push) while the keymap is being iterated — build only when asked.

The work Mac cannot flash the Go60: Defender device control blocks mounting the UF2 bootloader drive. Flashing happens on another device; the uf2 travels via Slack.

### Docs
`docs/` holds decision records and troubleshooting notes (terminal-workflow cheatsheet, cmux-vs-tmux, herdr-vs-tmux, karabiner-vs-nix, brew-vs-nix, brew-vs-mise-bootstrap, editor-strategy, raycast-dotfiles, secure-input-hotkey-outage, terminal-scrollback, gui-app-path, window-manager) and the tooling-roadmap (planned improvements with adopt/reject status). The terminal-workflow cheatsheet is symlinked for the tmux Prefix+M popup.

### Workspace Conventions
Custom shell functions assume this structure:
- Workspaces: `~/workspaces/{owner}/{repo}/`
- Git worktrees: `~/worktrees/{owner}/{repo}/{branch}/`

## Conventions

### Commits
Conventional Commits format: `<type>(scope): description`

Types: `feat`, `fix`, `refactor`, `ci`, `perf`, `docs`, `chore`

### Pull Requests
Use bilingual (English/Japanese) template. Merge with **squash and merge**:
```bash
gh pr merge <PR番号> --squash --delete-branch
```

### Branches
One branch per PR, named `<type>/<short-description>` with the same types as commits (lowercase, hyphens only). Never commit to main directly.

**Merged branches are not kept locally.** `--delete-branch` removes the remote one, which leaves the local branch marked `[gone]` in `git branch -vv` — that marker is the "already merged" signal. Clean them up with `/clean_gone` (deletes `[gone]` branches and their worktrees).

Squash merges rewrite history, so the branch tip is never an ancestor of main and `git branch -d` refuses. Before force-deleting, confirm the PRs really merged instead of reaching for `-D` blindly:
```bash
gh pr list --state all --limit 200 --json headRefName,state,number
```

### Adding New Dotfiles
1. Add file to repository
2. Add entry to `entries` array in `link.sh` (source path only, or `"source:destination"` if target differs)
3. Run `./link.sh` to create symlink

### Claude Code Paths
- `.config/claude/` - files managed under `~/.claude` (settings, commands)
- `.claude/` (repo root) - reserved for this repository's own Claude Code project settings; do not put `~/.claude` targets here

### Adding New Tools (brew vs mise)

Default to Brewfile. Escalate to `.mise.toml` when any of the following applies:

- Per-project version pinning matters (`.tool-version` / `.terraform-version` / `.node-version` 等を尊重したい)
- Not on Homebrew, or requires a curl/manual installer (avoid bloating `install.sh`)
- Schema URL or lockfile semantics make version pinning meaningful (e.g. `biome.json`'s `$schema`)

If per-project version variance is already expected, skip brew and put it in mise from the start (don't pay the migration cost later). Run `mise registry | grep <tool>` before proposing a new tool. Prefer mise registry-native backends (aqua / asdf / core) over `npm:` fallbacks. GUI (cask) and stable system CLIs (neovim, tmux, gh, fzf, etc.) stay on brew.
