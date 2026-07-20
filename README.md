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

### Tools & Applications (via Brewfile)
- **fzf** - Command-line fuzzy finder
- **zoxide** - Smart cd command
- **bat** - Cat clone with syntax highlighting
- **lsd** - Modern replacement for ls
- **yazi** - Terminal file manager
- **fd** - Simple, fast alternative to find
- **sheldon** - Fast zsh plugin manager
- **starship** - Cross-shell prompt
- **atuin** - Shell history management
- **neovim** - Vim-based editor (minimal config)
- **gh** - GitHub CLI
- **git-delta** - Syntax-highlighting pager for git
- **tmux** - Terminal multiplexer
- **crit** - Code review tool
- **typescript-language-server** / **yaml-language-server** - LSP servers
- **yq** / **stern** - Kubernetes / YAML tooling
- **ghostty** - Terminal emulator
- **zed** - Code editor

### Runtimes & Tools (via mise)
- **Node.js** (LTS) / **Bun**
- **Google Cloud CLI**
- **Terraform**
- **Biome**
- **Rust** / **rust-analyzer**

### Configuration Files
- `.zshrc` / `.zshenv` - Zsh shell configuration
- `.config/zsh/` - Aliases, custom functions, tasks, host-specific settings
- `.vimrc` - Vim editor configuration
- `.config/nvim/init.lua` - Neovim configuration
- `.mise.toml` - mise runtime configuration
- `.gitconfig` / `.gitconfig-olta` - Git configuration (personal / work)
- `.config/ghostty/config` - Ghostty terminal configuration
- `.config/tmux/tmux.conf` - Tmux configuration with vim key bindings
- `.config/karabiner/` - Karabiner-Elements key mapping, built from TypeScript (`karabiner.ts`)
- `.config/yazi/` - Yazi file manager configuration (with projects plugin)
- `.config/fd/config` - fd default options
- `.config/sheldon/plugins.toml` - Zsh plugin definitions
- `.config/starship/starship.toml` - Prompt configuration
- `.config/zed/settings.json` - Zed editor settings
- `.config/claude/` - Claude Code configuration (`~/.claude` settings and custom commands)

### Docs
The `docs/` directory keeps decision records and troubleshooting notes (e.g. terminal workflow cheatsheet, cmux vs tmux, Karabiner vs Nix, secure input hotkey outage postmortem).

## Scripts

### `install.sh`
Installs Homebrew → Brewfile packages → mise runtimes → Claude Code → vim-plug → TPM (Tmux Plugin Manager) → yazi plugins → Karabiner config build (via bun).

### `link.sh`
Creates symbolic links for configuration files from this repository to their expected locations. Existing files are backed up with a `.bak` extension. Run `./link.sh --list` to print all entries as `source:destination`.

### `settings.sh`
Configures macOS system settings (requires restart):
- Disables press-and-hold in favor of key repeat
- Trackpad: maximum tracking speed, tap to click
- Frees up Ctrl+Space for the tmux prefix (disables input source switching)
- Japanese IME (Kotoeri): disables predictive candidates and live conversion

## Karabiner Configuration

`karabiner.json` is generated from `karabiner.ts` using [karabiner.ts](https://github.com/evan-liu/karabiner.ts):

```bash
cd .config/karabiner
bun run build   # generate karabiner.json, sync back to repo, reload profile
```

## Requirements

- macOS (Apple Silicon recommended)
- Internet connection for downloading dependencies

## Post-Installation

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

- `.config/claude/settings.json` - Claude Code settings (symlinked to `~/.claude/settings.json`)
- `.config/claude/commands/` - Custom slash commands (symlinked to `~/.claude/commands`)
- `CLAUDE.md` - Repository-specific instructions for Claude Code

Note: `.claude/` at the repository root is reserved for this repository's own Claude Code project settings.

## GitHub Actions

- **test-scripts.yml** - Runs automated tests for installation and configuration scripts (including Karabiner build verification)
- **claude.yml** - Claude Code GitHub integration workflow
- **claude-code-review.yml** - Automated code review with Claude

## Customization

- Edit `Brewfile` to add/remove brew packages
- Edit `.mise.toml` to change runtime versions
- Customize shell aliases in `.config/zsh/alias.sh`
- Modify zsh configuration in `.zshrc`
- Add custom Claude Code commands in `.config/claude/commands/`
