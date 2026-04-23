# Brewfile - Homebrew bundle manifest
# Source of truth for packages installed by setup.sh

# Taps
tap "nikitabobko/tap"

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
cask "codex"
cask "codex-app" unless File.directory?("/Applications/Codex.app")

# =============================================================================
# Terminal & Window Management
# =============================================================================
cask "ghostty@tip" unless File.directory?("/Applications/Ghostty.app")
cask "nikitabobko/tap/aerospace" unless File.directory?("/Applications/AeroSpace.app")

# =============================================================================
# Containers
# =============================================================================
cask "orbstack" unless File.directory?("/Applications/OrbStack.app")

# =============================================================================
# Editor & LLM
# =============================================================================
cask "lm-studio" unless File.directory?("/Applications/LM Studio.app")

# =============================================================================
# iOS Development
# =============================================================================
cask "xcodes-app" unless File.directory?("/Applications/Xcodes.app")

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
cask "obsidian" unless File.directory?("/Applications/Obsidian.app")
cask "meetingbar" unless File.directory?("/Applications/MeetingBar.app")
cask "itsycal" unless File.directory?("/Applications/Itsycal.app")
cask "1password" unless File.directory?("/Applications/1Password.app")
cask "raycast" unless File.directory?("/Applications/Raycast.app")
cask "shottr" unless File.directory?("/Applications/Shottr.app")
cask "the-unarchiver" unless File.directory?("/Applications/The Unarchiver.app")

# =============================================================================
# Communication
# =============================================================================
cask "slack" unless File.directory?("/Applications/Slack.app")
cask "telegram" unless File.directory?("/Applications/Telegram.app")

# =============================================================================
# Browser
# =============================================================================
cask "google-chrome" unless File.directory?("/Applications/Google Chrome.app")
