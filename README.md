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

# Trust mise configuration (required for runtime management)
mise trust ~/.mise.toml

# Install runtimes via mise
mise install

# Configure macOS system settings
./settings.sh
```

## What's Included

### Tools & Applications
- **fzf** - Command-line fuzzy finder
- **lsd** - Modern replacement for ls
- **sheldon** - Fast zsh plugin manager
- **starship** - Cross-shell prompt
- **atuin** - Shell history management
- **gh** - GitHub CLI
- **git-delta** - Syntax-highlighting pager for git
- **zoxide** - Smart cd command
- **bat** - Cat clone with syntax highlighting
- **yazi** - Terminal file manager
- **fd** - Simple, fast alternative to find
- **helix** - Post-modern text editor
- **tmux** - Terminal multiplexer for managing multiple sessions
- **mise** - Runtime version manager (manages Node.js, gcloud, etc.)
- **ghostty** - Terminal emulator
- **cursor** - AI-powered code editor

### Runtime Management (via mise)
- **Node.js** - LTS version
- **Google Cloud CLI** - Cloud development tools

### Configuration Files
- `.zshrc` - Zsh shell configuration
- `.vimrc` - Vim editor configuration
- `.mise.toml` - mise runtime configuration
- `.config/zsh/alias.sh` - Custom shell aliases
- `.config/zsh/command.sh` - Custom shell commands
- `.config/ghostty/config` - Ghostty terminal configuration
- `.config/tmux/tmux.conf` - Tmux configuration with vim key bindings
- `.config/karabiner/` - Karabiner-Elements key mapping
- `.config/helix/config.toml` - Helix editor configuration
- `.config/yazi/` - Yazi file manager configuration (with projects plugin)
- `.config/fd/config` - fd default options
- `.config/cursor/settings.json` - Cursor editor settings
- `.claude/` - Claude Code configuration and custom commands

## Scripts

### `install.sh`
Installs Homebrew, all brew packages from Brewfile, runtimes via mise, Claude Code, and yazi plugins.

### `link.sh`
Creates symbolic links for configuration files from this repository to their expected locations in your home directory. Existing files are backed up with a `.bak` extension.

### `settings.sh`
Configures macOS system settings for optimal development experience. Currently includes:
- Disables press-and-hold for keys in favor of key repeat (allows holding keys to repeat instead of showing accent menu)
- Requires system restart for changes to take effect

## Requirements

- macOS (Apple Silicon recommended)
- Internet connection for downloading dependencies

## Post-Installation

After running the installation scripts, you may need to:

1. **Restart your shell** or run `source ~/.zshrc` to apply changes
2. **Trust mise configuration** if you haven't already:
   ```bash
   mise trust ~/.mise.toml
   ```
3. **Verify installations**:
   ```bash
   node --version
   gcloud --version
   ```

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
- `hagaspa()` - Navigate to hagaspa workspace with intelligent path completion based on Git remote
- `OLTAInc()` - Navigate to OLTAInc workspace with intelligent path completion based on Git remote
- `olta` - Alias for OLTAInc() function
- `gw()` - Git worktree management with automatic organization
- `fzf-select-history*()` - Enhanced command history search

### Workspace Navigation Functions

#### hagaspa() Function
The `hagaspa()` function provides intelligent workspace navigation for hagaspa repositories:
- Automatically detects if you're in a HagaSpa Git repository and navigates to the matching workspace
- Supports path completion with prefix matching (e.g., `hagaspa dot` → `dotfiles` directory)
- Falls back to the main hagaspa workspace when called without arguments outside a Git repository
- Workspace structure: `~/workspaces/hagaspa/[repository-name]`

#### OLTAInc() Function and olta Alias
The `OLTAInc()` function and its alias `olta` provide intelligent workspace navigation for OLTAInc repositories:
- Automatically detects if you're in an OLTAInc Git repository and navigates to the matching workspace
- Supports path completion with prefix matching (e.g., `OLTAInc ba` or `olta ba` → `backend` directory)
- Falls back to the main OLTAInc workspace when called without arguments outside a Git repository
- Workspace structure: `~/workspaces/OLTAInc/[repository-name]`
- Both `OLTAInc` and `olta` commands work identically with full tab completion support

## Customization

Feel free to modify the configuration files to suit your preferences:
- Edit `Brewfile` to add/remove brew packages
- Edit `.mise.toml` to change runtime versions
- Customize shell aliases in `.config/zsh/alias.sh`
- Modify zsh configuration in `.zshrc`
- Add custom Claude Code commands in `.claude/commands/`
