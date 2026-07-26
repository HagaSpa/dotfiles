#!/usr/bin/env bats
# settings.sh: syntax and actual execution against macOS defaults.
# Running this locally re-applies your own settings (idempotent).

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "settings.sh is executable, has valid syntax and a bash shebang" {
  [ -x ./settings.sh ]
  bash -n ./settings.sh
  head -n 1 settings.sh | grep -q "#!/bin/bash"
}

@test "settings.sh applies ApplePressAndHoldEnabled=false" {
  command -v defaults >/dev/null 2>&1 || skip "defaults not available (not macOS)"

  ./settings.sh

  run defaults read -g ApplePressAndHoldEnabled
  [ "$status" -eq 0 ]
  [ "$output" = "0" ]
}

@test "settings.sh disables Ctrl+Space input source switching with a real boolean" {
  command -v plutil >/dev/null 2>&1 || skip "plutil not available (not macOS)"

  ./settings.sh

  # A string "0" here reads as enabled by macOS, so assert the type too.
  run plutil -extract AppleSymbolicHotKeys.60.enabled raw -o - \
    "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
  [ "$status" -eq 0 ]
  [ "$output" = "false" ]
}
