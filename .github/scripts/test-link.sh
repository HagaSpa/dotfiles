#!/bin/bash

set -e

echo "Testing link.sh..."

# Check if script is executable
if test -x ./link.sh; then
  echo "✓ link.sh is executable"
else
  echo "✗ link.sh is not executable"
  exit 1
fi

# Validate script syntax
if bash -n ./link.sh; then
  echo "✓ link.sh syntax is valid"
else
  echo "✗ link.sh has syntax errors"
  exit 1
fi

# Test symbolic link creation (actual execution)
echo "Creating temporary HOME for testing..."
export TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"
echo "Using temporary HOME: $TEST_HOME"

echo "Executing link.sh in test environment..."
./link.sh

echo "Verifying symbolic links were created..."
links_created=0
while IFS=':' read -r source target; do
  # Expand ~ in target path
  expanded_target=$(eval echo "$target")
  if [ -L "$expanded_target" ]; then
    echo "✓ Symbolic link created: $expanded_target -> $(readlink "$expanded_target")"
    links_created=$((links_created + 1))
  else
    echo "✗ Symbolic link not created: $expanded_target"
  fi
done <<< "$(grep -E '^\s*"[^"]+:[^"]+"\s*$' link.sh | sed 's/[" ]//g')"

if [ $links_created -gt 0 ]; then
  echo "✓ Successfully created $links_created symbolic links"
else
  echo "✗ No symbolic links were created"
  exit 1
fi

# Cleanup test environment
echo "Cleaning up test environment..."
rm -rf "$TEST_HOME"

# Verify all source files exist
echo "Verifying source files exist..."
exit_code=0
while IFS=':' read -r source target; do
  if [ -f "$source" ]; then
    echo "✓ Source file exists: $source"
  else
    echo "✗ Missing source file: $source"
    exit_code=1
  fi
done <<< "$(grep -E '^\s*"[^"]+:[^"]+"\s*$' link.sh | sed 's/[" ]//g')"

if [ $exit_code -eq 0 ]; then
  echo "✓ link.sh test completed successfully"
else
  echo "✗ link.sh test failed - some source files are missing"
  exit 1
fi