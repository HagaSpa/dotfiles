#!/usr/bin/env bats
# Configuration files: existence and syntax validation.

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "shell configurations exist" {
  [ -f .zshrc ]
  [ -f .config/zsh/alias.sh ]
  [ -f .config/zsh/command.sh ]
}

@test "karabiner source and generated profile exist" {
  [ -f .config/karabiner/karabiner.ts ]
  [ -f .config/karabiner/karabiner.json ]
}

@test "ghostty configuration exists" {
  [ -f .config/ghostty/config ]
}

@test "sheldon plugins.toml exists" {
  [ -f .config/sheldon/plugins.toml ]
}

@test "tmux configuration exists" {
  [ -f .config/tmux/tmux.conf ]
}

@test "tmux configuration syntax is valid" {
  command -v tmux >/dev/null 2>&1 || skip "tmux not available"
  tmux -f .config/tmux/tmux.conf list-keys >/dev/null 2>&1
}

@test "herdr configuration is valid" {
  command -v herdr >/dev/null 2>&1 || skip "herdr not available"
  HERDR_CONFIG_PATH="$PWD/.config/herdr/config.toml" herdr config check
}

@test "karabiner.json is valid JSON" {
  python3 -m json.tool .config/karabiner/karabiner.json >/dev/null
}

@test "vimium-c.json is valid JSON" {
  python3 -m json.tool .config/vimium/vimium-c.json >/dev/null
}

@test "amethyst configuration exists" {
  [ -f .config/amethyst/amethyst.yml ]
}

@test "amethyst.yml is valid YAML" {
  command -v yq >/dev/null 2>&1 || skip "yq not available"
  yq '.' .config/amethyst/amethyst.yml >/dev/null
}

@test "the hand-written keymap layer reaches keymap.svg" {
  # A name mismatch between the task and the notes file draws an empty layer
  # instead of failing, so the drawing silently loses the Key Overrides.
  layer=$(sed -n 's/^NOTES_LAYER="\(.*\)"$/\1/p' mise-tasks/qmk-keymap)
  [ -n "$layer" ]
  grep -qF "  $layer:" .config/qmk/keymap-notes.yaml
  grep -qF ">$layer<" .config/qmk/keymap.svg
}
