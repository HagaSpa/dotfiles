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
- **Google Cloud CLI** - Cloud development tools

### Configuration Files
- `.zshrc` - Zsh shell configuration
- `.vimrc` - Vim editor configuration
- `.config/zsh/alias.sh` - Custom shell aliases
- `.config/zsh/command.sh` - Custom shell commands
- `.config/ghostty/config` - Ghostty terminal configuration
- `.config/karabiner/` - Karabiner-Elements key mapping

## Scripts

### `install.sh`
Installs Homebrew, all brew packages from Brewfile, and Google Cloud CLI.

### `link.sh`
Creates symbolic links for configuration files from this repository to their expected locations in your home directory. Existing files are backed up with a `.bak` extension.

## Requirements

- macOS (Apple Silicon recommended)
- Internet connection for downloading dependencies

## Customization

Feel free to modify the configuration files to suit your preferences:
- Edit `Brewfile` to add/remove brew packages
- Customize shell aliases in `.config/zsh/alias.sh`
- Modify zsh configuration in `.zshrc`
