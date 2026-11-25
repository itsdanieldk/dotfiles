# ============================================================
# Environment
# ============================================================
typeset -U path PATH fpath FPATH  # brew exports FPATH; nested shells' dupes rebuild the completion dump

export LANG=en_US.UTF-8  # /etc/zprofile falls back to C.UTF-8
export EDITOR=emacs VISUAL=emacs


# ============================================================
# Zsh
# ============================================================
# Before zim's init, as in its template .zshrc.
setopt HIST_IGNORE_ALL_DUPS NO_FLOW_CONTROL
bindkey -e
WORDCHARS=${WORDCHARS//[\/]}

ZSH_AUTOSUGGEST_MANUAL_REBIND=1


# ============================================================
# zimfw
# ============================================================
ZIM_HOME=${ZDOTDIR:-$HOME}/.zim

if [[ -r /opt/homebrew/opt/zimfw/share/zimfw.zsh ]]; then
    if [[ ! $ZIM_HOME/init.zsh -nt ${ZDOTDIR:-$HOME}/.zimrc ]]; then
        source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
    fi
    source $ZIM_HOME/init.zsh
else
    autoload -Uz compinit && compinit  # without zimfw, the only one
fi

# After init: environment and the Catppuccin theme set these unconditionally.
HISTSIZE=100000 SAVEHIST=100000
setopt EXTENDED_HISTORY
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)  # the theme sets (main cursor)


# ============================================================
# Completion
# ============================================================
# After init: the completion module sets these unconditionally.
zstyle ':completion:*' menu no                     # fzf-tab
zstyle ':completion:*:descriptions' format '[%d]'  # fzf-tab ignores escape sequences
zstyle -e ':completion:*' list-colors 'zstyle -a ":completion:*:default" list-colors reply'  # fzf-tab never reads :default

zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"


# ============================================================
# Aliases
# ============================================================
alias e="emacs"

# Modern CLI replacements
# Not under Claude Code: its shell snapshot keeps aliases, and agents parse ls and cat output.
if [[ -z ${CLAUDECODE-} ]]; then
    alias ls="eza --icons=auto"  # =WHEN required: a bare --icons swallows the next argument
    alias cat="bat --paging=never --style=plain"
fi
alias ll="eza -la --icons=auto --git"
alias lt="eza --tree --icons=auto --level=2"
alias lg="lazygit"
alias lzd="lazydocker"  # not ld: that shadows the system linker
alias hs='history 1 | grep'

# Sync this Mac with the repo: pull, then install whatever is new.
# The tip must be signed by allowed_signers; --no-rebase, since pull.rebase ignores --verify-signatures.
dotup() { git -C ~/dotfiles pull --no-rebase --ff-only --verify-signatures && ~/dotfiles/install "$@" }


# ============================================================
# Shell tools
# ============================================================
# fzf
command -v fzf >/dev/null && source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_R_OPTS="--reverse --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header 'Press CTRL-Y to copy command to clipboard'"

# Catppuccin Frappe palette for fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
--color=selected-bg:#51576d \
--color=border:#414559,label:#c6d0f5"

# zoxide (smart cd)
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"


# ============================================================
# Machine-local
# ============================================================
# Untracked, like ~/.ssh/config.local. `if`, not `[[ ]] &&`: Starship would show the missing file's ✘1.
if [[ -r ~/.zshrc.local ]]; then source ~/.zshrc.local; fi


# ============================================================
# Prompt
# ============================================================
command -v starship >/dev/null && eval "$(starship init zsh)"
