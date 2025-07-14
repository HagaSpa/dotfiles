# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup Commands

```bash
# Initial setup - installs Homebrew, brew packages, and Google Cloud CLI
./install.sh

# Create symbolic links for all configuration files
./link.sh
```

## Repository Architecture

This is a personal dotfiles repository for macOS development environment setup. The architecture follows a modular approach:

### Core Scripts
- `install.sh` - Handles dependency installation (Homebrew, packages from Brewfile, Google Cloud CLI)
- `link.sh` - Creates symbolic links from repository files to expected system locations with automatic backup

### Configuration Structure
- **Shell Environment**: Split across `.zshrc` (main config), `.config/zsh/alias.sh` (aliases), and `.config/zsh/command.sh` (custom functions)
- **Terminal**: Ghostty terminal configuration in `.config/ghostty/config`
- **Editor**: Vim configuration with plugin management via vim-plug
- **Input**: Karabiner-Elements key mapping for enhanced keyboard shortcuts

### Key Custom Functions
The `.config/zsh/command.sh` contains sophisticated custom functions:

- `hagaspa()` - Workspace navigation that detects Git context and provides intelligent path completion
- `gw()` - Git worktree management with automatic worktree creation and organization under `~/worktrees/owner/repo/` structure
- `fzf-select-history*()` - Enhanced command history search with fzf integration

### Development Tools Included
The Brewfile defines a curated set of modern CLI tools:
- **Navigation**: zoxide (smart cd), fzf (fuzzy finder)
- **File Operations**: lsd (modern ls), bat (enhanced cat)
- **Shell Enhancement**: starship (prompt), sheldon (plugin manager)
- **Development**: gh (GitHub CLI), Google Cloud CLI

## Important Patterns

### Symbolic Link Strategy
The `link.sh` script uses a declarative approach with `files_and_paths` array mapping source files to destinations. It automatically backs up existing files with `.bak` extension before creating links.

### Workspace Organization
The custom functions assume a specific workspace structure:
- Main workspace: `~/workspaces/hagaspa/`
- Git worktrees: `~/worktrees/owner/repo/branch/`
- Organization detection via Git remote URL parsing

### Shell Integration
The configuration prioritizes shell productivity with:
- Custom key bindings (Ctrl+R for history, Ctrl+T for selection)
- Intelligent completion systems for custom functions
- History management with deduplication and search capabilities


## Pull Request Templates
### Japanese/English PR Template
```markdown

## Background / 背景

[English description]
[日本語の説明]

## Changes / 変更内容

[English changes]
[日本語の変更内容]

## Impact scope / 影響範囲

[English impact]
[日本語の影響範囲]

## Testing / 動作確認

- [x] Test item 1 / テスト項目1
- [x] Test item 2 / テスト項目2
```

### Conventional Commits

```bash
<type>[optional scope]: <description>
```
type: feat, fix, refactor, ci, perf, docs, chore
 