# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup Commands

```bash
./install.sh   # Install Homebrew, brew packages, mise, Claude Code, vim-plug, TPM, yazi plugins, Karabiner build
./link.sh      # Create symlinks from repo to system locations (backs up existing)
./settings.sh  # Configure macOS system settings (requires restart)
```

## Testing

Tests run automatically via GitHub Actions on PRs and pushes to main. To run locally:

```bash
./.github/scripts/test-install.sh          # Test install script
./.github/scripts/test-link.sh             # Test symlink creation
./.github/scripts/test-config.sh           # Validate config file syntax
./.github/scripts/test-brewfile.sh         # Validate Brewfile syntax
./.github/scripts/test-settings.sh         # Test macOS settings script
./.github/scripts/test-karabiner-build.sh  # Verify karabiner.ts build output matches karabiner.json
```

Lint (run by the CI `lint` job; tools come from the Brewfile):

```bash
shellcheck install.sh link.sh settings.sh .config/tmux/yazi-picker.sh .github/scripts/*.sh
shfmt -i 2 -d install.sh link.sh settings.sh .config/tmux/yazi-picker.sh .github/scripts/*.sh  # -w to format
actionlint
zsh -n <file>   # zsh configs (.zshrc / .zshenv / .config/zsh/**/*.sh); shellcheck does not support zsh
```

## Architecture

### Core Scripts
- `install.sh` - Installs: Homebrew → Brewfile packages → mise runtimes → Claude Code → vim-plug → TPM → yazi plugins → Karabiner config build (bun)
- `link.sh` - Declarative symlink management via `entries` array. Source path only = `~/{source}`, `source:destination` for custom paths. `--list` outputs all entries as `source:destination`
- `settings.sh` - macOS defaults configuration (key repeat, trackpad, Ctrl+Space free-up for tmux prefix, Kotoeri predictive candidates off)

### Configuration Files
- **Shell**: `.zshrc` / `.zshenv` (main) + `.config/zsh/` (alias.sh, command.sh, tasks.sh, hosts/)
- **Runtime**: `.mise.toml` (Node.js LTS, bun, gcloud, terraform, biome, rust + rust-analyzer)
- **Git**: `.gitconfig` (personal) + `.gitconfig-olta` (work, includeIf)
- **Terminal**: `.config/ghostty/config`, `.config/tmux/tmux.conf` (→ `~/.tmux.conf`)
- **Editor**: `.vimrc` (vim-plug), `.config/nvim/init.lua` (Neovim), `.config/zed/settings.json` (Zed)
- **Prompt/Plugins**: `.config/starship/starship.toml` (→ `~/.config/starship.toml`), `.config/sheldon/plugins.toml`
- **File Manager**: `.config/yazi/` (yazi config + projects plugin)
- **Search**: `.config/fd/` (fd defaults)
- **Input**: `.config/karabiner/` (keyboard remapping, TypeScript-based — see below)
- **Claude Code**: `.config/claude/` (settings.json + commands/, symlinked to `~/.claude/`)

### Karabiner (TypeScript build)
`karabiner.json` is generated from `karabiner.ts` using the karabiner.ts library. Never edit `karabiner.json` directly — edit `karabiner.ts` and build:

```bash
cd .config/karabiner && bun run build  # generate → sync repo copy → reload profile
```

`build` regenerates the config, copies `~/.config/karabiner/karabiner.json` back into the repo (Karabiner's atomic writes break symlinks), and reloads the profile via `karabiner_cli`.

### Docs
`docs/` holds decision records and troubleshooting notes (terminal-workflow cheatsheet, cmux-vs-tmux, karabiner-vs-nix, brew-vs-nix, raycast-dotfiles, secure-input-hotkey-outage) and the tooling-roadmap (planned improvements with adopt/reject status). The terminal-workflow cheatsheet is symlinked for the tmux Prefix+M popup.

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
