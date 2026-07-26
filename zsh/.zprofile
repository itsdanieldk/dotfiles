# ============================================================
# PATH hygiene
# ============================================================
# Dedupe PATH. This file appends unconditionally and gets sourced by every
# login shell, so without -U the same entries accumulate (kitty, VS Code and
# terminal logins each add another copy). Setting it first means every
# addition below — and in .zshrc — is deduped as it happens.
typeset -U path PATH


# ============================================================
# Telemetry
# ============================================================
# Every opt-out in one place, so the privacy posture is auditable at a glance.
# Must stay ahead of the Homebrew block below, which runs `brew shellenv` —
# HOMEBREW_NO_ANALYTICS has to be exported before brew is first invoked.
export DOTNET_CLI_TELEMETRY_OPTOUT=1            # dotnet CLI
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1  # Azure Functions Core Tools
export AZURE_CORE_COLLECT_TELEMETRY=0           # azure-cli
export AZURE_DEV_COLLECT_TELEMETRY=no           # azd
export HOMEBREW_NO_ANALYTICS=1                  # Homebrew


# ============================================================
# Homebrew
# ============================================================
# Apple Silicon installs to /opt/homebrew, Intel to /usr/local.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $brew_bin ]] && { eval "$($brew_bin shellenv zsh)"; break }
done
unset brew_bin


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

# Global dotnet tools. Note macOS's own /etc/paths.d/dotnet-cli-tools contains
# a literal "~/.dotnet/tools", which path_helper does not expand — that entry
# is dead. This is the one that actually works.
export PATH="$PATH:$HOME/.dotnet/tools"
