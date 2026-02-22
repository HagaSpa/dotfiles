#!/bin/sh

set -e

# Get the script directory to ensure correct paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
  echo "${GREEN}[INFO]${NC} $1"
}

log_skip() {
  echo "${YELLOW}[SKIP]${NC} $1"
}

# Install Homebrew
if command -v brew >/dev/null 2>&1; then
  log_skip "Homebrew is already installed"
else
  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for this session
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Add brew shellenv to .zprofile if not already present
if [ -f "$HOME/.zprofile" ] && grep -q '/opt/homebrew/bin/brew shellenv' "$HOME/.zprofile"; then
  log_skip "Homebrew shellenv already in .zprofile"
else
  log_info "Adding Homebrew shellenv to .zprofile..."
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> "$HOME/.zprofile"
fi

# Source brew environment if it exists
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install packages via brew
log_info "Installing packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

# Activate mise and install tools
if command -v mise >/dev/null 2>&1; then
  log_info "Installing tools via mise..."
  eval "$(mise activate bash)"
  mise install
else
  log_skip "mise not found, skipping mise install"
fi

# Install Claude Code via native installer
if command -v claude >/dev/null 2>&1; then
  log_skip "Claude Code is already installed"
else
  log_info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Install vim-plug for vim plugin management
if [ -f "$HOME/.vim/autoload/plug.vim" ]; then
  log_skip "vim-plug is already installed"
else
  log_info "Installing vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install yazi plugins
if command -v ya >/dev/null 2>&1; then
  log_info "Installing yazi plugins..."
  ya pkg install
else
  log_skip "ya not found, skipping yazi plugin install"
fi

log_info "Installation complete!"
