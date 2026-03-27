export ZSH="$HOME/.oh-my-zsh"
[[ -d "$HOME/.aspire/bin" ]] && export PATH="$HOME/.aspire/bin:$PATH"

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_ROOT="$(brew --prefix)/share/dotnet"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

ZSH_THEME="awesomepanda"
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
