#!/usr/bin/env bats
# karabiner.ts build idempotency: the committed karabiner.json must match
# what karabiner.ts generates.
#
# karabiner.ts writes to ~/.config/karabiner/karabiner.json (hardcoded in the
# lib), so that path is symlinked to the in-tree file. This lets `git diff`
# detect drift between karabiner.ts and karabiner.json. On a real machine this
# matches the normal `bun run build` flow (build + sync back to the repo).

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "karabiner.json is in sync with karabiner.ts" {
  command -v bun >/dev/null 2>&1 || skip "bun not available"

  mkdir -p ~/.config/karabiner
  ln -sf "$(pwd)/.config/karabiner/karabiner.json" ~/.config/karabiner/karabiner.json

  (cd .config/karabiner && bun install --frozen-lockfile && bun run build)

  git diff --exit-code -- .config/karabiner/karabiner.json
}
