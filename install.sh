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
  # Leading \n keeps a blank separator line before the appended entry.
  # shellcheck disable=SC2016 # the literal string (unexpanded) is what .zprofile needs
  printf '\n%s\n' 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
fi

# Source brew environment if it exists
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install packages via brew
log_info "Installing packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

# Everything past this point runs as mise tasks (see mise-tasks/).
# This script only bootstraps what mise itself needs: Homebrew and Brewfile
# packages (which include mise), plus the mise-managed runtimes.
if command -v mise >/dev/null 2>&1; then
  log_info "Installing tools via mise..."
  eval "$(mise activate bash)"
  mise trust "$SCRIPT_DIR/.mise.toml" >/dev/null
  mise install

  log_info "Running setup tasks via mise (claude, tpm, yazi-plugins, karabiner)..."
  (cd "$SCRIPT_DIR" && mise run setup)
else
  log_skip "mise not found, skipping mise install and setup tasks"
fi

log_info "Installation complete!"
