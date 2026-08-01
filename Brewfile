# ============================================================
# Taps
# ============================================================
# Must precede any formula or cask that comes from them. The install script
# walks this file top-to-bottom, so taps listed here are added first, and it
# also grants each one trust — Homebrew 6+ refuses to load from an untrusted
# third-party tap, and `brew tap` alone does not grant that.
#
# Keep this list minimal: every tap is a third party you're trusting to run
# install code. Prefer homebrew-core whenever it carries the package.
tap "isen-ng/dotnet-sdk-versions"   # provides dotnet-sdk10
tap "azure/functions"               # provides azure-functions-core-tools@4
tap "azure/bicep"                   # provides bicep
tap "azure/kubelogin"               # provides Azure's kubelogin (see note below)
tap "nikitabobko/tap"               # provides aerospace
tap "FelixKratz/formulae"           # provides borders (not in homebrew-core)


# ============================================================
# Formulae
# ============================================================

# --- Core ---
brew "stow"
brew "git"
brew "neovim"

# --- Modern CLI replacements ---
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "fzf"
brew "jq"
brew "zoxide"

# --- Utilities ---
brew "fastfetch"
brew "btop"
brew "dust"
brew "yq"
brew "tealdeer"
brew "tree"
brew "marp-cli"                     # Markdown -> slide decks

# --- Git & dev tools ---
brew "gh"
brew "git-delta"
brew "lazygit"
brew "lazydocker"

# --- Languages & runtimes ---
brew "direnv"
brew "node"
brew "pnpm"
brew "elixir"
brew "elm"
brew "powershell"

# --- Azure ---
brew "azure-cli"
brew "azd"
brew "azure-functions-core-tools@4"
brew "azurite"
brew "bicep"

# --- Containers & Kubernetes ---
# CLI only. The docker-desktop cask below supplies the daemon and GUI; its own
# CLI stays inside the app bundle, so these don't collide.
brew "docker"
brew "docker-compose"
brew "kubectl"                      # alias; the real formula is kubernetes-cli
brew "helm"
brew "k9s"
brew "azure/kubelogin/kubelogin"

# --- AI ---
brew "ollama"


# ============================================================
# Casks
# ============================================================

# --- Fonts ---
cask "font-fira-code-nerd-font"
cask "font-fira-sans"

# --- Terminal & editors ---
cask "kitty"
cask "visual-studio-code"
cask "jetbrains-toolbox"

# --- Dev tooling ---
cask "dotnet-sdk10"
cask "docker-desktop"
cask "yaak"

# --- AI ---
cask "claude"
cask "claude-code@latest"
cask "codex"
cask "copilot-cli"

# --- Notes & productivity ---
cask "obsidian"
cask "raycast"

# --- Browsers & media ---
cask "google-chrome"
cask "iina"
cask "discord"

# --- Remote access ---
cask "teamviewer"

# --- Window management ---
cask "aerospace"
brew "borders"
brew "sketchybar"
brew "ical-buddy"

# --- System & hardware ---
cask "macs-fan-control"
brew "macmon"
cask "monitorcontrol"
cask "logi-options+"
cask "focusrite-control-2"
cask "onyx"
cask "philips-hue-sync"

# --- Games ---
cask "steam"
