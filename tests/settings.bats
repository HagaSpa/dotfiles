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
