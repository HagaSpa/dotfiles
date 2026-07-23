# dotfiles

This is my personal configuration for macos.

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
