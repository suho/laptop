#!/usr/bin/env bash
# setup.sh - Bootstrap a real macOS machine with the tools in this repo
# Usage: ./setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NONINTERACTIVE="${NONINTERACTIVE:-0}"
SUDO_PASSWORD="${SUDO_PASSWORD:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_step() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

require_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script only supports macOS"
        exit 1
    fi
}

detect_homebrew_prefix() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    else
        HOMEBREW_PREFIX="/usr/local"
    fi
}

append_line_if_missing() {
    local file_path="$1"
    local line="$2"

    touch "$file_path"
    if ! grep -Fqx "$line" "$file_path"; then
        printf '%s\n' "$line" >>"$file_path"
    fi
}

sudo_run() {
    if [[ -n "$SUDO_PASSWORD" ]]; then
        printf '%s\n' "$SUDO_PASSWORD" | sudo -S -p '' "$@"
    else
        sudo "$@"
    fi
}

sudo_validate() {
    if [[ -n "$SUDO_PASSWORD" ]]; then
        printf '%s\n' "$SUDO_PASSWORD" | sudo -S -v -p ''
    else
        sudo -v
    fi
}

keep_sudo_alive() {
    if [[ -n "$SUDO_PASSWORD" ]]; then
        return 0
    fi

    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

install_xcode_clt_noninteractive() {
    local placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    local label=""

    touch "$placeholder"
    label="$(softwareupdate --list 2>/dev/null | awk -F'* Label: ' '/\* Label: .*Command Line Tools/ {print $2}' | tail -n 1)"

    if [[ -z "$label" ]]; then
        rm -f "$placeholder"
        print_error "Unable to find a Command Line Tools package from softwareupdate"
        exit 1
    fi

    print_status "Installing Command Line Tools package: $label"
    sudo_run softwareupdate --install "$label" --verbose
    sudo_run xcode-select --switch /Library/Developer/CommandLineTools
    rm -f "$placeholder"
}

install_xcode_clt() {
    print_step "Installing Xcode Command Line Tools"

    if xcode-select -p >/dev/null 2>&1; then
        print_success "Xcode Command Line Tools already installed"
        return 0
    fi

    print_status "Installing Xcode Command Line Tools"
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        install_xcode_clt_noninteractive
    else
        xcode-select --install || true

        until xcode-select -p >/dev/null 2>&1; do
            print_warning "Finish the Command Line Tools installer, then press Enter to continue"
            read -r
        done
    fi

    print_success "Xcode Command Line Tools installed"
}

refresh_homebrew_env() {
    eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
}

install_homebrew() {
    print_step "Installing Homebrew"

    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew already installed"
    else
        print_status "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    refresh_homebrew_env
    print_status "Updating Homebrew"
    brew update
    print_success "Homebrew ready"
}

install_brew_bundle() {
    print_step "Installing Brewfile packages"

    if [[ ! -f "$SCRIPT_DIR/Brewfile" ]]; then
        print_error "Brewfile not found: $SCRIPT_DIR/Brewfile"
        exit 1
    fi

    if brew bundle --file="$SCRIPT_DIR/Brewfile"; then
        print_success "Brewfile packages installed"
    else
        print_error "brew bundle failed"
        exit 1
    fi
}

ensure_directories() {
    print_step "Creating application directories"

    mkdir -p "$HOME/.config/fish/functions"
    mkdir -p "$HOME/.config/fish"

    print_success "Application directories ready"
}

setup_fish() {
    print_step "Configuring Fish shell"

    if ! command -v fish >/dev/null 2>&1; then
        print_error "Fish is not installed even after Brewfile setup"
        exit 1
    fi

    local fish_path
    fish_path="$(command -v fish)"

    if ! grep -qx "$fish_path" /etc/shells; then
        print_status "Adding Fish to /etc/shells"
        printf '%s\n' "$fish_path" | sudo_run tee -a /etc/shells >/dev/null
    fi

    local current_shell
    current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
    if [[ "$current_shell" != "$fish_path" ]]; then
        print_status "Setting Fish as the default shell"
        if ! chsh -s "$fish_path"; then
            print_warning "Unable to change shell automatically; run: chsh -s $fish_path"
        else
            print_success "Fish set as the default shell"
        fi
    else
        print_success "Fish already set as the default shell"
    fi

    if [[ ! -f "$HOME/.config/fish/functions/fisher.fish" ]]; then
        print_status "Installing Fisher"
        fish -c "curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher"
        print_success "Fisher installed"
    else
        print_success "Fisher already installed"
    fi

    print_status "Installing Fish plugins"
    fish -c "fisher install jethrokuan/z"
    print_success "Fish plugins installed"
}

configure_fish_init() {
    print_step "Writing Fish shell initialization"

    local config_file="$HOME/.config/fish/config.fish"

    append_line_if_missing "$config_file" 'if test -x '"$HOMEBREW_PREFIX"'/bin/brew'
    append_line_if_missing "$config_file" '    eval ('"$HOMEBREW_PREFIX"'/bin/brew shellenv)'
    append_line_if_missing "$config_file" 'end'
    append_line_if_missing "$config_file" ''
    append_line_if_missing "$config_file" 'if command -sq mise'
    append_line_if_missing "$config_file" '    mise activate fish | source'
    append_line_if_missing "$config_file" 'end'
    append_line_if_missing "$config_file" ''
    append_line_if_missing "$config_file" 'if command -sq starship'
    append_line_if_missing "$config_file" '    starship init fish | source'
    append_line_if_missing "$config_file" 'end'

    print_success "Fish initialization updated"
}

configure_macos_defaults() {
    print_step "Applying macOS defaults"

    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0

    print_success "macOS defaults applied"
    print_warning "Log out or restart apps like Finder and Dock to pick up every change"
}

print_summary() {
    print_step "Setup complete"

    print_success "Real-machine bootstrap finished"
    echo "Manual follow-up:"
    echo "  1. Sign in to apps: 1Password, Slack, Telegram, Obsidian, Raycast"
    echo "  2. Restore SSH keys into ~/.ssh and set permissions"
    echo "  3. Import your GPG key if needed: gpg --import <keyfile>"
    echo "  4. Restart the terminal or run: exec fish"
}

main() {
    require_macos
    detect_homebrew_prefix

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║             Real MacBook Setup Script                    ║"
    echo "║        Installs apps, CLIs, and base preferences        ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    echo "Architecture: $(uname -m)"
    echo "Homebrew prefix: $HOMEBREW_PREFIX"
    echo ""

    sudo_validate
    keep_sudo_alive

    install_xcode_clt
    install_homebrew
    install_brew_bundle
    ensure_directories
    setup_fish
    configure_fish_init
    configure_macos_defaults
    print_status "Cleaning up Homebrew caches and old versions"
    brew cleanup
    print_summary
}

main "$@"
