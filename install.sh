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

# Install nvm (Node Version Manager)
if [ -d "$HOME/.nvm" ]; then
  log_skip "nvm is already installed"
else
  log_info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
fi

# Source nvm to make it available in the current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install the latest LTS version of Node.js if not already installed
if command -v nvm >/dev/null 2>&1; then
  if nvm ls --lts >/dev/null 2>&1; then
    log_skip "Node.js LTS is already installed"
  else
    log_info "Installing Node.js LTS..."
    nvm install --lts
    nvm use --lts
  fi
else
  log_info "Installing Node.js LTS..."
  nvm install --lts
  nvm use --lts
fi

# Install Claude Code if not already installed
if npm list -g @anthropic-ai/claude-code >/dev/null 2>&1; then
  log_skip "Claude Code is already installed"
else
  log_info "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi

# Install gemini cli if not already installed
if npm list -g @google/gemini-cli >/dev/null 2>&1; then
  log_skip "Gemini CLI is already installed"
else
  log_info "Installing Gemini CLI..."
  npm install -g @google/gemini-cli
fi

# Install vim-plug for vim plugin management
if [ -f "$HOME/.vim/autoload/plug.vim" ]; then
  log_skip "vim-plug is already installed"
else
  log_info "Installing vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install Google Cloud CLI
if [ -d "$HOME/google-cloud-sdk" ] && [ -f "$HOME/google-cloud-sdk/bin/gcloud" ]; then
  log_skip "Google Cloud CLI is already installed"
else
  log_info "Installing Google Cloud CLI..."
  cd "$HOME"
  
  # Download only if the tar.gz doesn't exist
  if [ ! -f "google-cloud-cli-454.0.0-darwin-arm.tar.gz" ]; then
    curl -OL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-454.0.0-darwin-arm.tar.gz
  fi
  
  # Extract
  tar -xzf google-cloud-cli-454.0.0-darwin-arm.tar.gz
  
  # Install
  cd google-cloud-sdk
  yes | ./install.sh
  
  # Clean up the tar.gz file
  rm -f "$HOME/google-cloud-cli-454.0.0-darwin-arm.tar.gz"
fi

log_info "Installation complete!"