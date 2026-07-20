#!/bin/bash

set -e

echo "Testing karabiner.ts build idempotency..."

if ! command -v bun >/dev/null 2>&1; then
  echo "✗ bun not available — workflow must install it before this step"
  exit 1
fi

# karabiner.ts writes to ~/.config/karabiner/karabiner.json (hardcoded in the lib).
# Symlink that path to the in-tree file so the build updates the repo copy,
# allowing 'git diff' to detect drift between karabiner.ts and karabiner.json.
mkdir -p ~/.config/karabiner
ln -sf "$(pwd)/.config/karabiner/karabiner.json" ~/.config/karabiner/karabiner.json

(cd .config/karabiner && bun install --frozen-lockfile && bun run build)

if git diff --exit-code -- .config/karabiner/karabiner.json; then
  echo "✓ karabiner.json is in sync with karabiner.ts"
else
  echo "✗ karabiner.json drifted from karabiner.ts source"
  echo "   Run: (cd .config/karabiner && bun install && bun run build)"
  echo "   Then commit the updated karabiner.json."
  exit 1
fi
