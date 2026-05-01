# Enable Powerlevel10k instant prompt (must stay at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
[[ -d "$HOME/.aspire/bin" ]] && export PATH="$HOME/.aspire/bin:$PATH"

export DOTNET_CLI_TELEMETRY_OPTOUT=1
if [ -d "/usr/local/share/dotnet" ]; then
    export DOTNET_ROOT="/usr/local/share/dotnet"
    export PATH="$DOTNET_ROOT:$PATH"
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
# Docker CLI completions (fpath must be set before compinit/OMZ source)
fpath=("$HOME/.docker/completions" $fpath)

source $ZSH/oh-my-zsh.sh

# History
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE

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

# History search
alias hs='history 1 | grep --color=auto'

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window up:3:hidden:wrap --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header 'Press CTRL-Y to copy command to clipboard'"

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# direnv (per-directory env)
eval "$(direnv hook zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# p10k sets noaliases inside its config; re-enable alias expansion
setopt aliases