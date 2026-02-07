export ZSH="$HOME/.oh-my-zsh"

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
    docker-compose
    aliases
    zsh-autosuggestions
    zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

alias v="nvim"
alias vim="nvim"
