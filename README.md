# dotfiles

Personal dotfiles configuration for macOS development environment.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/hagaspa/dotfiles.git ~/workspaces/hagaspa/dotfiles
cd ~/workspaces/hagaspa/dotfiles

# Install dependencies and tools
./install.sh

# Create symbolic links for configuration files
./link.sh
```

## What's Included

### Tools & Applications
- **fzf** - Command-line fuzzy finder
- **lsd** - Modern replacement for ls
- **sheldon** - Fast zsh plugin manager
- **starship** - Cross-shell prompt
- **gh** - GitHub CLI
- **zoxide** - Smart cd command
- **bat** - Cat clone with syntax highlighting
- **ghostty** - Terminal emulator
- **cursor** - AI-powered code editor
- **Google Cloud CLI** - Cloud development tools

### Configuration Files
- `.zshrc` - Zsh shell configuration
- `.vimrc` - Vim editor configuration
- `.config/zsh/alias.sh` - Custom shell aliases
- `.config/zsh/command.sh` - Custom shell commands
- `.config/ghostty/config` - Ghostty terminal configuration
- `.config/karabiner/` - Karabiner-Elements key mapping
- `.config/cursor/settings.json` - Cursor editor settings
- `.claude/` - Claude Code configuration and custom commands

## Scripts

### `install.sh`
Installs Homebrew, all brew packages from Brewfile, and Google Cloud CLI.

### `link.sh`
Creates symbolic links for configuration files from this repository to their expected locations in your home directory. Existing files are backed up with a `.bak` extension.

## Requirements

- macOS (Apple Silicon recommended)
- Internet connection for downloading dependencies

## Claude Code Integration

This repository includes Claude Code configuration:
- `.claude/settings.json` - Permission settings for Claude Code
- `.claude/commands/` - Custom slash commands for common workflows
- `CLAUDE.md` - Repository-specific instructions for Claude Code

## GitHub Actions

- **test-scripts.yml** - Runs automated tests for installation and configuration scripts
- **claude.yml** - Claude Code GitHub integration workflow
- **claude-code-review.yml** - Automated code review with Claude

## Custom Commands

The `.config/zsh/command.sh` includes powerful custom functions:
- `hagaspa()` - Smart workspace navigation with Git context awareness
- `gw()` - Git worktree management with automatic organization
- `fzf-select-history*()` - Enhanced command history search

## Customization

Feel free to modify the configuration files to suit your preferences:
- Edit `Brewfile` to add/remove brew packages
- Customize shell aliases in `.config/zsh/alias.sh`
- Modify zsh configuration in `.zshrc`
- Add custom Claude Code commands in `.claude/commands/`
