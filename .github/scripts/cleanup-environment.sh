#!/bin/bash

echo "Cleaning up test environment..."

# Restore backed up files
if [ -f ~/.zshrc.github-backup ]; then
  mv ~/.zshrc.github-backup ~/.zshrc
  echo "✓ Restored ~/.zshrc"
fi

# Remove any test symlinks that might have been created
for link in ~/.zshrc ~/.config/zsh/alias.sh ~/.config/zsh/command.sh; do
  if [ -L "$link" ]; then
    rm "$link"
    echo "✓ Removed test symlink: $link"
  fi
done

echo "✓ Test environment cleanup completed"
