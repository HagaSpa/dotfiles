# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup Commands

```bash
./install.sh   # Install Homebrew, brew packages, mise, Claude Code, vim-plug
./link.sh      # Create symlinks from repo to system locations (backs up existing)
./settings.sh  # Configure macOS system settings (requires restart)
```

## Testing

Tests run automatically via GitHub Actions on PRs and pushes to main. To run locally:

```bash
./.github/scripts/test-install.sh   # Test install script
./.github/scripts/test-link.sh      # Test symlink creation
./.github/scripts/test-config.sh    # Validate config file syntax
./.github/scripts/test-brewfile.sh  # Validate Brewfile syntax
./.github/scripts/test-settings.sh  # Test macOS settings script
```

## Architecture

### Core Scripts
- `install.sh` - Installs: Homebrew → Brewfile packages → mise runtimes → Claude Code → vim-plug → yazi plugins
- `link.sh` - Declarative symlink management via `files_and_paths` array (source:destination format)
- `settings.sh` - macOS defaults configuration (key repeat, trackpad settings)

### Configuration Files
- **Shell**: `.zshrc` (main) + `.config/zsh/alias.sh` (aliases) + `.config/zsh/command.sh` (functions)
- **Runtime**: `.mise.toml` (Node.js LTS, gcloud via mise)
- **Terminal**: `.config/ghostty/config`
- **Editor**: `.vimrc` (vim-plug), `.config/helix/` (Helix), `.config/cursor/` (Cursor IDE settings)
- **File Manager**: `.config/yazi/` (yazi config + projects plugin)
- **Search**: `.config/fd/` (fd defaults)
- **Input**: `.config/karabiner/` (keyboard remapping)

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
2. Add entry to `files_and_paths` array in `link.sh` (format: `"source:destination"`)
3. Run `./link.sh` to create symlink
 