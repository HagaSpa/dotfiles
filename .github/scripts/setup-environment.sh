#!/bin/bash

set -e

echo "Setting up test environment..."

# Create test directories
mkdir -p ~/.config/zsh
mkdir -p ~/.config/karabiner/assets/complex_modifications
mkdir -p ~/.config/ghostty

# Backup existing files if they exist
for file in ~/.zshrc ~/.vimrc; do
  if [ -f "$file" ]; then
    cp "$file" "${file}.github-backup"
    echo "✓ Backed up $file"
  fi
done

echo "✓ Test environment setup completed"