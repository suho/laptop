# Brewfile - Homebrew bundle manifest
# Source of truth for packages installed by setup.sh

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
# AI Tools
# =============================================================================
cask "claude-code"
cask "claude" unless File.directory?("/Applications/Claude.app")

# =============================================================================
# Terminal
# =============================================================================
cask "warp" unless File.directory?("/Applications/Warp.app")

# =============================================================================
# Editor
# =============================================================================
cask "zed" unless File.directory?("/Applications/Zed.app")

# =============================================================================
# iOS Development
# =============================================================================
cask "xcodes-app" unless File.directory?("/Applications/Xcodes.app")

# =============================================================================
# API & Network Tools
# =============================================================================
cask "proxyman" unless File.directory?("/Applications/Proxyman.app")
cask "postman" unless File.directory?("/Applications/Postman.app")

# =============================================================================
# Git Client
# =============================================================================
cask "fork" unless File.directory?("/Applications/Fork.app")

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
