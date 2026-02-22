# Environment variables (loaded for all shell sessions)

export EDITOR="hx"
export LANG=en_US.UTF-8
export LESSCHARSET=utf-8

# Add user-local binaries to PATH
export PATH="$HOME/.local/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
