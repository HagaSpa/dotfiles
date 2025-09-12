#!/bin/bash

# macOS System Settings Configuration

echo "Configuring macOS system settings..."

# Disable press-and-hold for keys in favor of key repeat
# This allows holding down a key to repeat it instead of showing accent menu
defaults write -g ApplePressAndHoldEnabled -bool false

echo "macOS settings applied. Please restart your system for all changes to take effect."