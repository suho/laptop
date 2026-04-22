#!/usr/bin/env bash
# setup.sh - Run on NEW Mac to install tools and import configs
# Usage: ./setup.sh
#
# Based on: https://github.com/nimblehq/laptop/blob/main/mac
# Customized for: Fish shell, mise, personal tool preferences

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_step() { echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; }

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           MacBook Setup Script                           ║"
echo "║      Run this on your NEW Mac after cloning this repo    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Architecture: $ARCH"
echo "Homebrew prefix: $HOMEBREW_PREFIX"
echo ""

# Ask for sudo upfront
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ============================================================================
# Xcode Command Line Tools
# ============================================================================
print_step "Installing Xcode Command Line Tools"

if ! xcode-select -p &> /dev/null; then
    print_status "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait for installation to complete
    print_warning "Please complete the Xcode Command Line Tools installation, then press Enter to continue..."
    read -r
else
    print_success "Xcode Command Line Tools already installed"
fi

# ============================================================================
# Homebrew
# ============================================================================
print_step "Installing Homebrew"

if ! command -v brew &> /dev/null; then
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_status "Updating Homebrew..."
brew update

# ============================================================================
# Homebrew Bundle (install all packages)
# ============================================================================
print_step "Installing Homebrew packages"

if [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
    print_status "Installing packages from Brewfile..."
    brew bundle --file="$SCRIPT_DIR/Brewfile" || true
    print_success "Homebrew packages installed"
else
    print_warning "Brewfile not found. Run export.sh on your old Mac first."
fi

# ============================================================================
# Create config directories
# ============================================================================
print_step "Creating config directories"

mkdir -p ~/.config/{fish,mise,ghostty,nvim,lazygit,btop,aerospace,gh}
mkdir -p ~/.ssh

print_success "Config directories created"

# ============================================================================
# Import Fish shell configs
# ============================================================================
print_step "Setting up Fish shell"

if [[ -d "$DOTFILES_DIR/fish" ]]; then
    print_status "Importing Fish configs..."
    cp -R "$DOTFILES_DIR/fish"/* ~/.config/fish/ 2>/dev/null || true
    print_success "Fish configs imported"
fi

# Set Fish as default shell
if command -v fish &> /dev/null; then
    FISH_PATH=$(which fish)
    if ! grep -q "$FISH_PATH" /etc/shells; then
        print_status "Adding Fish to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi

    if [[ "$SHELL" != "$FISH_PATH" ]]; then
        print_status "Setting Fish as default shell..."
        chsh -s "$FISH_PATH"
        print_success "Fish set as default shell"
    else
        print_success "Fish already set as default shell"
    fi

    # Install Fisher (Fish plugin manager)
    if [[ ! -f ~/.config/fish/functions/fisher.fish ]]; then
        print_status "Installing Fisher..."
        fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
    fi

    # Install Fish plugins if fish_plugins exists
    if [[ -f ~/.config/fish/fish_plugins ]]; then
        print_status "Installing Fish plugins..."
        fish -c "fisher update" || true
    fi
else
    print_warning "Fish not installed. Install with: brew install fish"
fi

# ============================================================================
# Import Git configs
# ============================================================================
print_step "Setting up Git"

if [[ -d "$DOTFILES_DIR/git" ]]; then
    print_status "Importing Git configs..."
    [[ -f "$DOTFILES_DIR/git/.gitconfig" ]] && cp "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig
    [[ -f "$DOTFILES_DIR/git/.gitignore_global" ]] && cp "$DOTFILES_DIR/git/.gitignore_global" ~/.gitignore_global
    [[ -f "$DOTFILES_DIR/git/.stCommitMsg" ]] && cp "$DOTFILES_DIR/git/.stCommitMsg" ~/.stCommitMsg
    print_success "Git configs imported"
fi

# Install git-lfs
if command -v git-lfs &> /dev/null; then
    git lfs install
    print_success "Git LFS configured"
fi

# ============================================================================
# Import SSH config
# ============================================================================
print_step "Setting up SSH"

if [[ -f "$DOTFILES_DIR/ssh/config" ]]; then
    print_status "Importing SSH config..."
    cp "$DOTFILES_DIR/ssh/config" ~/.ssh/config
    chmod 644 ~/.ssh/config
    print_success "SSH config imported"
fi

print_warning "Remember to copy your SSH keys manually and set permissions:"
echo "    chmod 600 ~/.ssh/github_suho ~/.ssh/id_ed25519_el"

# ============================================================================
# Import Terminal configs
# ============================================================================
print_step "Setting up Terminal (Ghostty)"

# Ghostty
if [[ -f "$DOTFILES_DIR/terminal/ghostty/config" ]]; then
    cp "$DOTFILES_DIR/terminal/ghostty/config" ~/.config/ghostty/config
    print_success "Ghostty config imported"
fi

# Starship
if [[ -f "$DOTFILES_DIR/terminal/starship.toml" ]]; then
    cp "$DOTFILES_DIR/terminal/starship.toml" ~/.config/starship.toml
    print_success "Starship config imported"
fi

# ============================================================================
# Import Editor configs
# ============================================================================
print_step "Setting up Neovim"

# Neovim
if [[ -d "$DOTFILES_DIR/editors/nvim" ]]; then
    cp -R "$DOTFILES_DIR/editors/nvim"/* ~/.config/nvim/ 2>/dev/null || true
    print_success "Neovim config imported"
fi

# ============================================================================
# Import CLI tool configs
# ============================================================================
print_step "Setting up CLI tools"

# GitHub CLI
if [[ -f "$DOTFILES_DIR/cli/gh/config.yml" ]]; then
    cp "$DOTFILES_DIR/cli/gh/config.yml" ~/.config/gh/config.yml
    print_success "GitHub CLI config imported (run 'gh auth login' to authenticate)"
fi

# LazyGit
if [[ -d "$DOTFILES_DIR/cli/lazygit" ]]; then
    cp -R "$DOTFILES_DIR/cli/lazygit"/* ~/.config/lazygit/ 2>/dev/null || true
    print_success "LazyGit config imported"
fi

# btop
if [[ -d "$DOTFILES_DIR/cli/btop" ]]; then
    cp -R "$DOTFILES_DIR/cli/btop"/* ~/.config/btop/ 2>/dev/null || true
    print_success "btop config imported"
fi

# AeroSpace
if [[ -f "$DOTFILES_DIR/cli/aerospace/aerospace.toml" ]]; then
    cp "$DOTFILES_DIR/cli/aerospace/aerospace.toml" ~/.config/aerospace/aerospace.toml
    print_success "AeroSpace config imported"
fi

# Other CLI configs
[[ -f "$DOTFILES_DIR/cli/.lldbinit" ]] && cp "$DOTFILES_DIR/cli/.lldbinit" ~/.lldbinit

# ============================================================================
# mise (runtime version manager)
# ============================================================================
print_step "Setting up mise"

if command -v mise &> /dev/null; then
    # Import mise config
    if [[ -f "$DOTFILES_DIR/mise/config.toml" ]]; then
        cp "$DOTFILES_DIR/mise/config.toml" ~/.config/mise/config.toml
        print_success "mise config imported"
    fi

    if [[ -f "$DOTFILES_DIR/mise/.tool-versions" ]]; then
        cp "$DOTFILES_DIR/mise/.tool-versions" ~/.tool-versions
        print_success "tool-versions imported"
    fi

    if [[ -f "$DOTFILES_DIR/mise/.default-gems" ]]; then
        cp "$DOTFILES_DIR/mise/.default-gems" ~/.default-gems
        print_success "default-gems imported"
    fi

    # Activate mise
    print_status "Activating mise..."
    eval "$(mise activate bash)"
    print_success "mise activated (install runtimes on demand with: mise use node@latest)"
else
    print_warning "mise not installed. Install with: brew install mise"
fi

# ============================================================================
# Claude Code
# ============================================================================
print_step "Setting up Claude Code"

if [[ -d "$DOTFILES_DIR/claude" ]]; then
    mkdir -p ~/.claude
    [[ -f "$DOTFILES_DIR/claude/settings.json" ]] && cp "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
    [[ -f "$DOTFILES_DIR/claude/keybindings.json" ]] && cp "$DOTFILES_DIR/claude/keybindings.json" ~/.claude/keybindings.json
    if [[ -d "$DOTFILES_DIR/claude/commands" ]]; then
        mkdir -p ~/.claude/commands
        cp -R "$DOTFILES_DIR/claude/commands"/* ~/.claude/commands/ 2>/dev/null || true
    fi
    print_success "Claude Code configs imported"
fi

# ============================================================================
# Raycast scripts
# ============================================================================
if [[ -d "$DOTFILES_DIR/cli/raycast" ]]; then
    print_step "Setting up Raycast scripts"
    mkdir -p ~/me/raycast
    cp -R "$DOTFILES_DIR/cli/raycast"/* ~/me/raycast/ 2>/dev/null || true
    print_success "Raycast scripts imported"
fi

# ============================================================================
# macOS System Preferences
# ============================================================================
print_step "Configuring macOS preferences"

# Keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Trackpad: enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Finder: show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Dock: auto-hide
defaults write com.apple.dock autohide -bool true

# Dock: remove delay
defaults write com.apple.dock autohide-delay -float 0

print_success "macOS preferences configured"
print_warning "Some changes require logout/restart to take effect"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    Setup Complete!                       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
print_success "Tools and configs have been installed!"
echo ""
print_warning "Manual steps remaining:"
echo ""
echo "  1. Copy SSH keys and set permissions:"
echo "     chmod 600 ~/.ssh/github_suho ~/.ssh/id_ed25519_el"
echo ""
echo "  2. Import GPG key:"
echo "     gpg --import gpg-key.asc"
echo ""
echo "  3. Authenticate CLI tools:"
echo "     gh auth login"
echo "     gcloud auth login"
echo "     aws configure"
echo ""
echo "  4. Sign in to apps:"
echo "     1Password, Slack, Telegram, Obsidian, Raycast"
echo ""
echo "  5. Review secrets-checklist.md for other items"
echo ""
echo "  6. Restart your terminal or run: exec fish"
echo ""
