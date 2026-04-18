# Completions
autoload -Uz compinit && compinit -C
zstyle ":completion:*:commands" rehash 1
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# source
source ~/.config/zsh/alias.sh
source ~/.config/zsh/command.sh
source ~/.config/zsh/tasks.sh
source <(fzf --zsh)

LISTMAX=1000

unsetopt beep

# App Config
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(sheldon source)"
eval "$(atuin init zsh)"
eval "$(mise activate zsh)"

# zsh-syntax-highlighting: only highlight unknown commands in red
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[command]='none'
ZSH_HIGHLIGHT_STYLES[builtin]='none'
ZSH_HIGHLIGHT_STYLES[alias]='none'
ZSH_HIGHLIGHT_STYLES[function]='none'
ZSH_HIGHLIGHT_STYLES[precommand]='none'
ZSH_HIGHLIGHT_STYLES[reserved-word]='none'

# host-specific config
local host_config="$HOME/.config/zsh/hosts/$(hostname -s).sh"
[[ -f "$host_config" ]] && source "$host_config"
