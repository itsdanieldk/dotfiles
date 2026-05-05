eval "$(/opt/homebrew/bin/brew shellenv zsh)"
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# .NET
export DOTNET_CLI_TELEMETRY_OPTOUT=1
if [[ -d /usr/local/share/dotnet ]]; then
    export DOTNET_ROOT=/usr/local/share/dotnet
    export PATH="$DOTNET_ROOT:$PATH"
fi
export PATH="$PATH:$HOME/.dotnet/tools"
