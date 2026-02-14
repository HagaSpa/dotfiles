# Completions
autoload -Uz compinit && compinit
zstyle ":completion:*:commands" rehash 1
zstyle ':completion:*' menu select=2

# source
source ~/.config/zsh/alias.sh
source ~/.config/zsh/command.sh

LISTMAX=1000

unsetopt beep

# App Config
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(sheldon source)"
eval "$(atuin init zsh)"
eval "$(mise activate zsh)"

# host-specific config
local host_config="$HOME/.config/zsh/hosts/$(hostname -s).sh"
[[ -f "$host_config" ]] && source "$host_config"
