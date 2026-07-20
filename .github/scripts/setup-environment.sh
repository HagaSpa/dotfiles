#!/bin/bash

set -e

echo "Setting up test environment..."

# Create test directories
mkdir -p ~/.config/zsh
mkdir -p ~/.config/karabiner
mkdir -p ~/.config/ghostty

# Backup existing files if they exist
if [ -f ~/.zshrc ]; then
  cp ~/.zshrc ~/.zshrc.github-backup
  echo "✓ Backed up ~/.zshrc"
fi

echo "✓ Test environment setup completed"
