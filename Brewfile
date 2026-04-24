# Brewfile - Homebrew bundle manifest
# Source of truth for packages installed by setup.sh
#
# Optional tools (AI apps, OrbStack, iOS bundle) are installed interactively
# by setup.sh, not listed here.

# =============================================================================
# Core CLI Tools
# =============================================================================
brew "fish"
brew "starship"
brew "git"
brew "git-lfs"
brew "gh"
brew "lazygit"
brew "btop"
brew "mise"

# =============================================================================
# Terminal
# =============================================================================
# Warp or Ghostty is installed interactively by setup.sh.

# =============================================================================
# Editor
# =============================================================================
cask "zed" unless File.directory?("/Applications/Zed.app")

# =============================================================================
# Media Processing
# =============================================================================
brew "ffmpeg"

# =============================================================================
# Security
# =============================================================================
brew "openssl"
brew "gnupg"
brew "pinentry-mac"

# =============================================================================
# Productivity Apps
# =============================================================================
cask "meetingbar" unless File.directory?("/Applications/MeetingBar.app")
cask "itsycal" unless File.directory?("/Applications/Itsycal.app")
cask "1password" unless File.directory?("/Applications/1Password.app")
cask "raycast" unless File.directory?("/Applications/Raycast.app")
cask "shottr" unless File.directory?("/Applications/Shottr.app")

# =============================================================================
# Communication
# =============================================================================
cask "slack" unless File.directory?("/Applications/Slack.app")
cask "telegram" unless File.directory?("/Applications/Telegram.app")

# =============================================================================
# Browser
# =============================================================================
cask "google-chrome" unless File.directory?("/Applications/Google Chrome.app")
