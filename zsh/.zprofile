# ============================================================
# PATH hygiene
# ============================================================
# Every login shell re-runs this file and appends, so dedupe as we go.
typeset -U path PATH


# ============================================================
# Telemetry
# ============================================================
export DOTNET_CLI_TELEMETRY_OPTOUT=1            # dotnet CLI
export AZURE_CORE_COLLECT_TELEMETRY=0           # azure-cli
export HOMEBREW_NO_ANALYTICS=1                  # Homebrew
export GH_TELEMETRY=0                           # gh


# ============================================================
# Homebrew
# ============================================================
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Keg-only: a fresh install leaves psql/pg_dump unlinked.
[[ -d /opt/homebrew/opt/postgresql@17/bin ]] && path=(/opt/homebrew/opt/postgresql@17/bin $path)


# ============================================================
# JetBrains
# ============================================================
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"


# ============================================================
# .NET
# ============================================================
export DOTNET_NOLOGO=1
if [[ -d /usr/local/share/dotnet ]]; then
    export DOTNET_ROOT=/usr/local/share/dotnet
    export PATH="$DOTNET_ROOT:$PATH"
fi

# /etc/paths.d/dotnet-cli-tools holds a literal "~" path_helper never expands.
export PATH="$PATH:$HOME/.dotnet/tools"


# ============================================================
# OrbStack
# ============================================================
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
