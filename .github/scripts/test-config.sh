#!/bin/bash

set -e

echo "Testing configuration files..."

exit_code=0

# Check shell configurations
if test -f .zshrc; then
  echo "✓ .zshrc exists"
else
  echo "✗ .zshrc missing"
  exit_code=1
fi

if test -f .config/zsh/alias.sh; then
  echo "✓ .config/zsh/alias.sh exists"
else
  echo "✗ .config/zsh/alias.sh missing"
  exit_code=1
fi

if test -f .config/zsh/command.sh; then
  echo "✓ .config/zsh/command.sh exists"
else
  echo "✗ .config/zsh/command.sh missing"
  exit_code=1
fi

# Check vim configuration
if test -f .vimrc; then
  echo "✓ .vimrc exists"
else
  echo "✗ .vimrc missing"
  exit_code=1
fi

# Check Karabiner configuration
if test -f .config/karabiner/assets/complex_modifications/personal_hagaspa.json; then
  echo "✓ Karabiner configuration exists"
else
  echo "✗ Karabiner configuration missing"
  exit_code=1
fi

# Check Ghostty configuration
if test -f .config/ghostty/config; then
  echo "✓ Ghostty configuration exists"
else
  echo "✗ Ghostty configuration missing"
  exit_code=1
fi

# Check Sheldon configuration
if test -f .config/sheldon/plugins.toml; then
  echo "✓ Sheldon plugins.toml exists"
else
  echo "✗ Sheldon plugins.toml missing"
  exit_code=1
fi

# Validate JSON files
echo "Validating JSON files..."
if python3 -m json.tool .config/karabiner/assets/complex_modifications/personal_hagaspa.json > /dev/null 2>&1; then
  echo "✓ Karabiner JSON is valid"
else
  echo "✗ Karabiner JSON is invalid"
  exit_code=1
fi

if [ $exit_code -eq 0 ]; then
  echo "✓ Configuration files test completed successfully"
else
  echo "✗ Configuration files test failed - some files are missing or invalid"
  exit 1
fi