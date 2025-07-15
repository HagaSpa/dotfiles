#!/bin/bash

echo "Cleaning up test environment..."

# Restore backed up files
for file in ~/.zshrc ~/.vimrc; do
  if [ -f "${file}.github-backup" ]; then
    mv "${file}.github-backup" "$file"
    echo "✓ Restored $file"
  fi
done

# Remove any test symlinks that might have been created
for link in ~/.zshrc ~/.vimrc ~/.config/zsh/alias.sh ~/.config/zsh/command.sh; do
  if [ -L "$link" ]; then
    rm "$link"
    echo "✓ Removed test symlink: $link"
  fi
done

echo "✓ Test environment cleanup completed"