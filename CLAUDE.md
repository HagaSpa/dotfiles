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
- **Git**: `.gitconfig` (personal) + `.gitconfig-olta` (work, includeIf)
- **Terminal**: `.config/ghostty/config`, `.config/tmux/tmux.conf` (→ `~/.tmux.conf`)
- **Editor**: `.config/nvim/init.lua` (Neovim), `.config/zed/settings.json` (Zed)
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
