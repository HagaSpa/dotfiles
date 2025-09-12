#!/bin/bash

# macOS System Settings Configuration

echo "Configuring macOS system settings..."

# Disable press-and-hold for keys in favor of key repeat
# This allows holding down a key to repeat it instead of showing accent menu
defaults write -g ApplePressAndHoldEnabled -bool false

echo "macOS settings applied. Please restart your system for all changes to take effect."
echo ""
echo -e "\033[1;33m⚠️  RESTART REQUIRED\033[0m"
echo -e "\033[1;33mSome settings will not take effect until you restart your Mac.\033[0m"
echo -e "\033[1;33mPlease save your work and restart your system now.\033[0m"