# ============================================================
# PATH hygiene
# ============================================================
# Every login shell re-runs this file and appends, so dedupe as we go.
typeset -U path PATH fpath FPATH


# ============================================================
# Telemetry
# ============================================================
export DOTNET_CLI_TELEMETRY_OPTOUT=1            # dotnet CLI
export AZURE_CORE_COLLECT_TELEMETRY=0           # azure-cli
export HOMEBREW_NO_ANALYTICS=1                  # Homebrew


# ============================================================
# Homebrew
# ============================================================
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Keg-only: a fresh install leaves these unlinked; node@24 must also shadow marp-cli's newer node.
[[ -d /opt/homebrew/opt/postgresql@17/bin ]] && path=(/opt/homebrew/opt/postgresql@17/bin $path)
[[ -d /opt/homebrew/opt/node@24/bin ]] && path=(/opt/homebrew/opt/node@24/bin $path)


# ============================================================
# JetBrains
# ============================================================
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"


# ============================================================
# .NET
# ============================================================
export DOTNET_NOLOGO=1

# /etc/paths.d/dotnet-cli-tools holds a literal "~" path_helper never expands.
export PATH="$PATH:$HOME/.dotnet/tools"


# ============================================================
# k9s
# ============================================================
export K9S_CONFIG_DIR=$HOME/.config/k9s  # macOS default is ~/Library/Application Support/k9s


# ============================================================
# OrbStack
# ============================================================
source ~/.orbstack/shell/init.zsh 2>/dev/null || :


# ============================================================
# Machine-local
# ============================================================
# Untracked, like ~/.ssh/config.local. `if`, not `[[ ]] &&`: a missing file must not leave $? at 1.
if [[ -r ~/.zprofile.local ]]; then source ~/.zprofile.local; fi
