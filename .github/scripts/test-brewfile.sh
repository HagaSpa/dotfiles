#!/bin/bash

set -e

echo "Testing Brewfile validity..."

exit_code=0

# Check if Brewfile exists
if test -f ./Brewfile; then
  echo "✓ Brewfile found"
else
  echo "✗ Brewfile not found"
  exit 1
fi

# Validate Brewfile syntax by parsing it
echo "Checking Brewfile syntax..."
if grep -E '^(brew|cask|mas)' ./Brewfile > /dev/null; then
  echo "✓ Brewfile contains valid entries"
else
  echo "✗ Brewfile appears to be empty or invalid"
  exit 1
fi

# Check for essential tools in Brewfile
echo "Checking for essential CLI tools..."
essential_tools=("fzf" "gh" "zoxide" "tmux")
for tool in "${essential_tools[@]}"; do
  if grep -q "brew \"$tool\"" ./Brewfile; then
    echo "✓ Found essential CLI tool: $tool"
  else
    echo "✗ Essential CLI tool not found in Brewfile: $tool"
    exit_code=1
  fi
done

# Check for cask applications in Brewfile
echo "Checking for cask applications..."
cask_apps=("ghostty" "cursor")
for app in "${cask_apps[@]}"; do
  if grep -q "cask \"$app\"" ./Brewfile; then
    echo "✓ Found cask application: $app"
  else
    echo "✗ Cask application not found in Brewfile: $app"
    exit_code=1
  fi
done

# If brew is available, test bundle validation (but don't fail on missing packages)
if command -v brew &> /dev/null; then
  echo "Homebrew is available, testing bundle check..."
  if brew bundle check --file=./Brewfile; then
    echo "✓ All Brewfile dependencies are satisfied"
  else
    echo "ℹ️  Some packages not installed (expected in CI environment)"
    echo "   This is normal - CI doesn't pre-install all development tools"
  fi
else
  echo "ℹ️  Homebrew not available in this environment"
fi

if [ $exit_code -eq 0 ]; then
  echo "✓ Brewfile validation completed successfully"
else
  echo "✗ Brewfile validation failed - some essential tools are missing"
  exit 1
fi