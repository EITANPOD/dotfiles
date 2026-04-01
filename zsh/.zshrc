# ┌───────────────────────────────────────────────────────────────────────────┐
# │                              Eitan's ZSH Config                           │
# └───────────────────────────────────────────────────────────────────────────┘

# ─────────────────────────────────────────────────────────────────────────────
# OS Detection
# ─────────────────────────────────────────────────────────────────────────────
case "$(uname -s)" in
    Darwin) _OS="macos" ;;
    Linux)  _OS="linux" ;;
esac

# Fastfetch on terminal start
command -v fastfetch &>/dev/null && fastfetch

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
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit
zstyle ':completion:*' menu select

# ─────────────────────────────────────────────────────────────────────────────
# Starship Prompt
# ─────────────────────────────────────────────────────────────────────────────
export STARSHIP_CONFIG=~/.config/starship/starship.toml
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ─────────────────────────────────────────────────────────────────────────────
# ZSH Plugins
# ─────────────────────────────────────────────────────────────────────────────
if [[ "$_OS" == "macos" ]]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ "$_OS" == "linux" ]]; then
    [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

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
if command -v terraform &>/dev/null; then
    complete -o nospace -C "$(command -v terraform)" terraform
fi

# ─────────────────────────────────────────────────────────────────────────────
# Kubernetes & OpenShift
# ─────────────────────────────────────────────────────────────────────────────
alias k=kubectl
if command -v kubectl &>/dev/null; then
    source <(command kubectl completion zsh)
    compdef k=kubectl
fi
[[ -f ~/.oc-completion.zsh ]] && source ~/.oc-completion.zsh
command -v oc &>/dev/null && compdef oc=kubectl

# ─────────────────────────────────────────────────────────────────────────────
# Modern CLI Tools
# ─────────────────────────────────────────────────────────────────────────────
# zoxide (smart cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

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
if [[ "$_OS" == "macos" ]]; then
    export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Local Configuration (secrets, machine-specific settings)
# This file is gitignored - use it for API keys and local overrides
# ─────────────────────────────────────────────────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
