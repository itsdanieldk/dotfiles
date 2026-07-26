# ============================================================
# Powerlevel10k instant prompt
# ============================================================
# Must stay first — nothing may write to stdout before this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ============================================================
# Environment
# ============================================================
export ZSH="$HOME/.oh-my-zsh"
[[ -d "$HOME/.aspire/bin" ]] && export PATH="$HOME/.aspire/bin:$PATH"

# LANG only — LC_ALL would override every LC_* category and block per-category
# overrides (LC_TIME, LC_COLLATE, ...) from ever taking effect.
export LANG=en_US.UTF-8


# ============================================================
# Oh My Zsh
# ============================================================
ZSH_THEME="robbyrussell"
HIST_STAMPS="dd.mm.yyyy"

# Docker CLI completions. fpath must be extended before oh-my-zsh.sh is
# sourced, since OMZ runs compinit during that source.
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

# Order matters: fzf-tab wraps the completion widget, so it must come before
# the two plugins that wrap the line editor.
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
    fzf-tab
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# ============================================================
# Completion
# ============================================================
zstyle ':completion:*' menu no                                                  # required by fzf-tab
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*' # case-insensitive

# fzf-tab colors and previews. Must come after compinit, which the OMZ source
# above runs.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview \
    'bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null \
     || eza -1 --color=always --icons $realpath 2>/dev/null'


# ============================================================
# History
# ============================================================
# Set after the OMZ source so these win over OMZ's own defaults.
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE


# ============================================================
# Editor
# ============================================================
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi


# ============================================================
# Aliases
# ============================================================
alias v="nvim"
alias vim="nvim"

# Inside kitty, TERM=xterm-kitty is unknown to most remote hosts. 'kitten ssh'
# ships the terminfo over on connect; outside kitty this stays plain ssh.
if [[ $TERM == xterm-kitty ]] && command -v kitten >/dev/null; then
    alias ssh="kitten ssh"
fi

# Docker (v2 compose syntax)
alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias dps="docker ps"
alias dcb="docker compose build"
alias dcr="docker compose restart"

# Modern CLI replacements
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza --tree --icons --level=2"
alias cat="bat --paging=never --style=plain"
alias lg="lazygit"
alias ld="lazydocker"

# History search
alias hs='history 1 | grep --color=auto'


# ============================================================
# Shell tools
# ============================================================
# fzf
command -v fzf >/dev/null && source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window up:3:hidden:wrap --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header 'Press CTRL-Y to copy command to clipboard'"
# Catppuccin Frappe palette for fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
--color=selected-bg:#51576d \
--color=border:#414559,label:#c6d0f5"

# zoxide (smart cd)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# direnv (per-directory env)
command -v direnv >/dev/null && eval "$(direnv hook zsh)"


# ============================================================
# Toolchain paths
# ============================================================
# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


# ============================================================
# Prompt
# ============================================================
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Must stay last: p10k's config leaks 'noaliases', which would otherwise
# disable every alias defined above.
setopt aliases
