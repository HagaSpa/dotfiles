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

@test "atuin-clean normalizes whitespace and drops failed commands" {
  command -v sqlite3 >/dev/null 2>&1 || skip "sqlite3 not available"
  command -v perl >/dev/null 2>&1 || skip "perl not available"

  db="$BATS_TEST_TMPDIR/history.db"
  sqlite3 "$db" <<'SQL'
CREATE TABLE history (id text primary key, exit integer not null, command text not null);
INSERT INTO history VALUES
  ('1', 0, 'echo x '),
  ('2', 0, 'echo x'),
  ('3', 0, 'ls  -la'),
  ('4', 0, 'print "a  b"'),
  ('5', 127, 'eixt'),
  ('6', 255, 'ssh nope'),
  ('7', 2, 'gh pr crate');
SQL

  run env ATUIN_DB="$db" mise-tasks/atuin-clean
  [ "$status" -eq 0 ]

  [ "$(sqlite3 "$db" 'select count(*) from history;')" -eq 4 ]
  [ "$(sqlite3 "$db" 'select count(distinct command) from history;')" -eq 3 ]
  [ "$(sqlite3 "$db" "select command from history where id='3';")" = 'ls -la' ]
  [ "$(sqlite3 "$db" "select command from history where id='4';")" = 'print "a  b"' ]
}
