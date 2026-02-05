# ┌───────────────────────────────────────────────────────────────────────────┐
# │                              Eitan's ZSH Config                           │
# └───────────────────────────────────────────────────────────────────────────┘

# Fastfetch on terminal start
fastfetch

# ─────────────────────────────────────────────────────────────────────────────
# History Configuration
# ─────────────────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups

# ─────────────────────────────────────────────────────────────────────────────
# Completions
# ─────────────────────────────────────────────────────────────────────────────
fpath=(/Users/eitanpod/.docker/completions $fpath)
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit
zstyle ':completion:*' menu select

# ─────────────────────────────────────────────────────────────────────────────
# Starship Prompt
# ─────────────────────────────────────────────────────────────────────────────
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# ─────────────────────────────────────────────────────────────────────────────
# Plugins (from Homebrew)
# ─────────────────────────────────────────────────────────────────────────────
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─────────────────────────────────────────────────────────────────────────────
# Aliases: SSH
# ─────────────────────────────────────────────────────────────────────────────
alias sshn='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

# ─────────────────────────────────────────────────────────────────────────────
# Aliases: Git
# ─────────────────────────────────────────────────────────────────────────────
alias ga="git add"
alias gch="git checkout"
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push"
alias gpl="git pull"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline -10"

# ─────────────────────────────────────────────────────────────────────────────
# Aliases: Terraform & Terragrunt
# ─────────────────────────────────────────────────────────────────────────────
alias tf='terraform'
alias tg='terragrunt'
alias tga='terragrunt apply'
alias tgd='terragrunt destroy'
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# ─────────────────────────────────────────────────────────────────────────────
# Kubernetes & OpenShift
# ─────────────────────────────────────────────────────────────────────────────
alias k=kubectl
source <(command kubectl completion zsh)
[[ -f ~/.oc-completion.zsh ]] && source ~/.oc-completion.zsh
compdef k=kubectl
compdef oc=kubectl

# ─────────────────────────────────────────────────────────────────────────────
# Modern CLI Tools
# ─────────────────────────────────────────────────────────────────────────────
# zoxide (smart cd)
eval "$(zoxide init zsh)"

# neovim as default editor
alias vim='nvim'
export EDITOR='nvim'
export VISUAL='nvim'

# eza (modern ls)
alias ls='eza --icons'
alias ll='eza -lh --icons'
alias la='eza -la --icons'
alias lt='eza --tree --level=2 --icons'

# bat (modern cat)
alias cat='bat --paging=never'

# ─────────────────────────────────────────────────────────────────────────────
# Utility Aliases
# ─────────────────────────────────────────────────────────────────────────────
alias pub='echo "$(<~/.ssh/id_ed25519.pub)"'
alias reload='source ~/.zshrc'
alias dotfiles='cd ~/.dotfiles'

# ─────────────────────────────────────────────────────────────────────────────
# PATH Configuration
# ─────────────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

# ─────────────────────────────────────────────────────────────────────────────
# Local Configuration (secrets, machine-specific settings)
# This file is gitignored - use it for API keys and local overrides
# ─────────────────────────────────────────────────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
