#!/usr/bin/env bats
# mise file tasks: executability, syntax, and task discovery.

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "every mise task is executable and has valid bash syntax" {
  for f in mise-tasks/*; do
    [ -x "$f" ] || {
      echo "not executable: $f"
      false
    }
    head -n1 "$f" | grep -q '^#!.*bash'
    bash -n "$f"
  done
}

@test "mise discovers the setup task and its dependencies" {
  command -v mise >/dev/null 2>&1 || skip "mise not available"

  run mise tasks ls
  [ "$status" -eq 0 ]
  for task in setup claude tpm yazi-plugins karabiner link settings; do
    grep -q "^$task " <<<"$output" || {
      echo "task not discovered: $task"
      false
    }
  done
}
