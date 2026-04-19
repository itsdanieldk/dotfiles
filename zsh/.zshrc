# Enable Powerlevel10k instant prompt (must stay at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
[[ -d "$HOME/.aspire/bin" ]] && export PATH="$HOME/.aspire/bin:$PATH"

export DOTNET_CLI_TELEMETRY_OPTOUT=1
if command -v brew >/dev/null 2>&1; then
    DOTNET_ROOT_CANDIDATE="$(brew --prefix)/share/dotnet"
    if [ -d "$DOTNET_ROOT_CANDIDATE" ]; then
        export DOTNET_ROOT="$DOTNET_ROOT_CANDIDATE"
    fi
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="dd.mm.yyyy"

plugins=(
    git
    macos
    sudo
    extract
    copypath
    copyfile
    colored-man-pages
    docker
    dotnet
    aliases
    zsh-autosuggestions
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

alias v="nvim"
alias vim="nvim"

# Docker (v2 compose syntax)
alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias dps="docker ps"
alias dcb="docker compose build"
alias dcr="docker compose restart"

# Modern CLI aliases
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza --tree --icons --level=2"
alias cat="bat --paging=never"
alias lg="lazygit"
alias ld="lazydocker"

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# direnv (per-directory env)
eval "$(direnv hook zsh)"

# Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# p10k sets noaliases inside its config; re-enable alias expansion
setopt aliases
