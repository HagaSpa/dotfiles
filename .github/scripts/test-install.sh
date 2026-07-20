#!/bin/bash

set -e

echo "Testing install.sh with actual execution..."

# Check if script is executable
if test -x ./install.sh; then
  echo "✓ install.sh is executable"
else
  echo "✗ install.sh is not executable"
  exit 1
fi

# Validate script syntax
if bash -n ./install.sh; then
  echo "✓ install.sh syntax is valid"
else
  echo "✗ install.sh has syntax errors"
  exit 1
fi

# CI tailoring is injected via environment variables set in the workflow,
# so the real install.sh runs unmodified. These are native interfaces of
# brew bundle (man brew) and mise (settings overridable as MISE_* env vars),
# not something implemented in this repo:
#   HOMEBREW_BUNDLE_CASK_SKIP  - skip GUI casks (large downloads, nothing to verify in CI)
#   MISE_DISABLE_TOOLS         - skip heavy runtimes (gcloud, terraform, rust)
#   MISE_TRUSTED_CONFIG_PATHS  - trust the repo .mise.toml non-interactively

# On a real machine Karabiner-Elements creates ~/.config/karabiner/karabiner.json
# on first launch, and karabiner.ts writeToProfile requires it to exist. The cask
# is skipped in CI, so seed it with the repo copy for the Karabiner build step.
mkdir -p ~/.config/karabiner
cp .config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json

echo "Executing install.sh..."
./install.sh

# Verify brew formulas from the Brewfile
echo "Verifying installed CLI tools..."
exit_code=0
for tool in fzf gh zoxide lsd bat starship sheldon tmux mise; do
  if command -v "$tool" &>/dev/null; then
    echo "✓ CLI tool successfully installed: $tool"
  else
    echo "✗ CLI tool not available: $tool"
    exit_code=1
  fi
done

# Verify mise-managed runtimes (gcloud/terraform/rust are disabled in CI)
echo "Verifying mise-managed runtimes..."
for tool in node bun; do
  if mise which "$tool" &>/dev/null; then
    echo "✓ mise runtime installed: $tool ($(mise which "$tool"))"
  else
    echo "✗ mise runtime not available: $tool"
    exit_code=1
  fi
done

# Verify Claude Code (native installer puts the binary in ~/.local/bin)
if [ -x "$HOME/.local/bin/claude" ] || command -v claude &>/dev/null; then
  echo "✓ Claude Code successfully installed"
else
  echo "✗ Claude Code not available"
  exit_code=1
fi

# Verify TPM
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "✓ TPM installed"
else
  echo "✗ TPM not installed"
  exit_code=1
fi

# Test that brew bundle check now passes (informational: casks are skipped in CI)
echo "Testing brew bundle check after installation..."
if brew bundle check --file=./Brewfile; then
  echo "✓ All Brewfile dependencies are now satisfied"
else
  echo "ℹ️  Some dependencies still missing (expected in CI: casks are skipped)"
fi

if [ $exit_code -eq 0 ]; then
  echo "✓ install.sh actual execution test completed successfully"
else
  echo "✗ install.sh test failed - some required tools are missing"
  exit 1
fi
