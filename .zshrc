export LANG=es_US.UTF-8

# Completions
autoload -Uz compinit && compinit
zstyle ":completion:*:commands" rehash 1
zstyle ':completion:*' menu select=2

# source
source ~/.config/zsh/alias.sh
source ~/.config/zsh/command.sh

HISTSIZE=100000
SAVEHIST=100000
LISTMAX=1000

setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
unsetopt beep

# App Config
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(sheldon source)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hagaspa/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/hagaspa/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hagaspa/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/hagaspa/google-cloud-sdk/completion.zsh.inc'; fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.local/bin:$PATH"
