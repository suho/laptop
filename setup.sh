#!/usr/bin/env bash
# setup.sh - Bootstrap a real macOS machine with the tools in this repo
# Usage:
#   ./setup.sh            Full bootstrap (brew, core bundle, prompts, configs)
#   ./setup.sh --ai       Only run the AI tools installer
#   ./setup.sh --web      Only run the Web tools installer (OrbStack)
#   ./setup.sh --ios      Only run the iOS dev bundle installer
#   ./setup.sh --terminal Only run the terminal picker (Warp or Ghostty)
#   ./setup.sh --lazyvim  Only install LazyVim and its requirements
#   Flags can be combined, e.g. ./setup.sh --ai --ios

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

install_cask_if_missing() {
    local cask_name="$1"
    local app_path="${2:-}"

    if [[ -n "$app_path" && -d "$app_path" ]]; then
        print_success "$cask_name already present ($app_path)"
        return 0
    fi

    if brew list --cask "$cask_name" >/dev/null 2>&1; then
        print_success "$cask_name already installed"
        return 0
    fi

    print_status "Installing $cask_name"
    brew install --cask "$cask_name"
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local reply hint

    if [[ "$default" == "y" ]]; then
        hint="[Y/n]"
    else
        hint="[y/N]"
    fi

    while true; do
        read -r -p "$prompt $hint " reply || reply=""
        reply="${reply:-$default}"
        case "$reply" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

install_ai_tools() {
    local selection="${INSTALL_AI:-}"

    if [[ "$NONINTERACTIVE" != "1" && -z "$selection" ]]; then
        echo ""
        echo "AI tools (multi-select, space-separated numbers; empty to skip):"
        echo "  1) claude-code (+ Claude desktop)"
        echo "  2) codex (+ Codex desktop)"
        echo "  3) lm-studio"
        read -r -p "Select [e.g. '1 3', 'all', or blank]: " selection || selection=""
    fi

    [[ -z "$selection" || "$selection" == "none" ]] && { print_status "Skipping AI tools"; return 0; }

    if [[ "$selection" == "all" ]]; then
        selection="1 2 3"
    fi

    for choice in $selection; do
        case "$choice" in
            1|claude)
                install_cask_if_missing "claude-code"
                install_cask_if_missing "claude" "/Applications/Claude.app"
                ;;
            2|codex)
                install_cask_if_missing "codex"
                install_cask_if_missing "codex-app" "/Applications/Codex.app"
                ;;
            3|lm-studio|lmstudio)
                install_cask_if_missing "lm-studio" "/Applications/LM Studio.app"
                ;;
            *)
                print_warning "Unknown AI choice: $choice"
                ;;
        esac
    done
}

install_web_tools() {
    local want="${INSTALL_WEB_ORBSTACK:-}"

    if [[ -z "$want" ]]; then
        if [[ "$NONINTERACTIVE" == "1" ]]; then
            want="0"
        else
            prompt_yes_no "Install OrbStack (containers)?" "n" && want="1" || want="0"
        fi
    fi

    if [[ "$want" == "1" || "$want" == "y" || "$want" == "yes" ]]; then
        install_cask_if_missing "orbstack" "/Applications/OrbStack.app"
    else
        print_status "Skipping OrbStack"
    fi
}

install_ios_tools() {
    local want="${INSTALL_IOS:-}"

    if [[ -z "$want" ]]; then
        if [[ "$NONINTERACTIVE" == "1" ]]; then
            want="0"
        else
            prompt_yes_no "Install iOS dev bundle (Xcodes, Proxyman, Postman, Fork)?" "n" && want="1" || want="0"
        fi
    fi

    if [[ "$want" == "1" || "$want" == "y" || "$want" == "yes" ]]; then
        install_cask_if_missing "xcodes-app" "/Applications/Xcodes.app"
        install_cask_if_missing "proxyman" "/Applications/Proxyman.app"
        install_cask_if_missing "postman" "/Applications/Postman.app"
        install_cask_if_missing "fork" "/Applications/Fork.app"
    else
        print_status "Skipping iOS dev bundle"
    fi
}

install_terminal_tools() {
    local selection="${INSTALL_TERMINAL:-}"

    if [[ "$NONINTERACTIVE" != "1" && -z "$selection" ]]; then
        echo ""
        echo "Terminal (multi-select, space-separated numbers; empty to skip):"
        echo "  1) warp"
        echo "  2) ghostty"
        read -r -p "Select [e.g. '1', '2', 'all', or blank]: " selection || selection=""
    fi

    [[ -z "$selection" || "$selection" == "none" ]] && { print_status "Skipping terminal install"; return 0; }

    if [[ "$selection" == "all" ]]; then
        selection="1 2"
    fi

    for choice in $selection; do
        case "$choice" in
            1|warp)
                install_cask_if_missing "warp" "/Applications/Warp.app"
                ;;
            2|ghostty)
                install_cask_if_missing "ghostty@tip" "/Applications/Ghostty.app"
                install_cask_if_missing "font-jetbrains-mono-nerd-font"
                ;;
            *)
                print_warning "Unknown terminal choice: $choice"
                ;;
        esac
    done
}

install_brew_if_missing() {
    local formula="$1"
    if brew list --formula "$formula" >/dev/null 2>&1; then
        print_success "$formula already installed"
    else
        print_status "Installing $formula"
        brew install "$formula"
    fi
}

install_lazyvim_tools() {
    local want="${INSTALL_LAZYVIM:-}"

    if [[ -z "$want" ]]; then
        if [[ "$NONINTERACTIVE" == "1" ]]; then
            want="0"
        else
            prompt_yes_no "Install LazyVim (Neovim + fd, ripgrep, Nerd Font)?" "n" && want="1" || want="0"
        fi
    fi

    if [[ "$want" != "1" && "$want" != "y" && "$want" != "yes" ]]; then
        print_status "Skipping LazyVim"
        return 0
    fi

    print_status "Installing LazyVim requirements"
    install_brew_if_missing "neovim"
    install_brew_if_missing "fd"
    install_brew_if_missing "ripgrep"
    install_cask_if_missing "font-jetbrains-mono-nerd-font"

    local nvim_config="$HOME/.config/nvim"
    if [[ -e "$nvim_config" ]]; then
        print_success "Existing Neovim config detected at $nvim_config; leaving it untouched"
    else
        print_status "Cloning LazyVim starter into $nvim_config"
        git clone https://github.com/LazyVim/starter "$nvim_config"
        rm -rf "$nvim_config/.git"
        print_success "LazyVim starter installed; launch with: nvim"
    fi
}

install_optional_tools() {
    print_step "Installing optional tools"
    install_terminal_tools
    install_ai_tools
    install_web_tools
    install_ios_tools
    install_lazyvim_tools
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

    if fish -c "fisher list" 2>/dev/null | grep -qx "jethrokuan/z"; then
        print_success "Fish plugins already installed"
    else
        print_status "Installing Fish plugins"
        fish -c "fisher install jethrokuan/z"
        print_success "Fish plugins installed"
    fi
}

configure_fish_init() {
    print_step "Writing Fish shell initialization"

    local config_file="$HOME/.config/fish/config.fish"
    local marker="# --- laptop/setup.sh managed block ---"

    if grep -Fq "$marker" "$config_file" 2>/dev/null; then
        print_success "Fish initialization already configured"
        return 0
    fi

    cat >>"$config_file" <<EOF

$marker
if test -x $HOMEBREW_PREFIX/bin/brew
    eval ($HOMEBREW_PREFIX/bin/brew shellenv)
end

if command -sq mise
    mise activate fish | source
end

if command -sq starship
    starship init fish | source
end
EOF

    print_success "Fish initialization updated"
}

setup_configs() {
    print_step "Copying personal configurations"

    local configs=(
        "$SCRIPT_DIR/configs/starship.toml:$HOME/.config/starship.toml"
    )

    if [[ -d "/Applications/Ghostty.app" ]]; then
        mkdir -p "$HOME/.config/ghostty"
        configs+=("$SCRIPT_DIR/configs/ghostty/config:$HOME/.config/ghostty/config")
    fi

    for entry in "${configs[@]}"; do
        local src="${entry%%:*}"
        local dst="${entry#*:}"

        mkdir -p "$(dirname "$dst")"

        if [[ -f "$dst" ]] && diff -q "$src" "$dst" >/dev/null 2>&1; then
            print_success "$(basename "$dst") already up to date"
        else
            if [[ -f "$dst" ]]; then
                mv "$dst" "$dst.backup"
                print_warning "Backed up existing $(basename "$dst") to $(basename "$dst").backup"
            fi
            cp "$src" "$dst"
            print_success "$(basename "$dst") copied"
        fi
    done
}

configure_macos_defaults() {
    print_step "Applying macOS defaults"

    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0

    killall Finder >/dev/null 2>&1 || true
    killall Dock >/dev/null 2>&1 || true

    print_success "macOS defaults applied"
    print_warning "Some changes (e.g. key repeat) only apply after logout"
}

print_summary() {
    print_step "Setup complete"

    print_success "Real-machine bootstrap finished"
    echo "Manual follow-up:"
    echo "  1. Sign in to apps: 1Password, Slack, Telegram, Nova Launcher"
    echo "  2. Restore SSH keys into ~/.ssh and set permissions"
    echo "  3. Import your GPG key if needed: gpg --import <keyfile>"
    echo "  4. Restart the terminal or run: exec fish"
}

require_brew_ready() {
    if ! command -v brew >/dev/null 2>&1; then
        refresh_homebrew_env 2>/dev/null || true
    fi

    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew is not installed. Run ./setup.sh (no flags) first."
        exit 1
    fi
}

run_partial() {
    local run_ai="$1"
    local run_web="$2"
    local run_ios="$3"
    local run_terminal="$4"
    local run_lazyvim="$5"

    require_macos
    detect_homebrew_prefix
    require_brew_ready

    print_step "Running selective install"
    [[ "$run_terminal" == "1" ]] && install_terminal_tools
    [[ "$run_ai" == "1" ]] && install_ai_tools
    [[ "$run_web" == "1" ]] && install_web_tools
    [[ "$run_ios" == "1" ]] && install_ios_tools
    [[ "$run_lazyvim" == "1" ]] && install_lazyvim_tools

    echo ""
    print_success "Selective install finished"
}

usage() {
    cat <<EOF
Usage:
  ./setup.sh            Full bootstrap
  ./setup.sh --terminal Install terminal (Warp or Ghostty)
  ./setup.sh --ai       Install AI tools (multi-select prompt)
  ./setup.sh --web      Install OrbStack
  ./setup.sh --ios      Install iOS dev bundle
  ./setup.sh --lazyvim  Install LazyVim (Neovim, fd, ripgrep, Nerd Font)
  ./setup.sh --help     Show this help

Flags can be combined (e.g. --ai --ios).
Env overrides: INSTALL_TERMINAL, INSTALL_AI, INSTALL_WEB_ORBSTACK, INSTALL_IOS, INSTALL_LAZYVIM, NONINTERACTIVE.
EOF
}

main() {
    local run_ai=0 run_web=0 run_ios=0 run_terminal=0 run_lazyvim=0 partial=0

    for arg in "$@"; do
        case "$arg" in
            --terminal) run_terminal=1; partial=1 ;;
            --ai) run_ai=1; partial=1 ;;
            --web) run_web=1; partial=1 ;;
            --ios) run_ios=1; partial=1 ;;
            --lazyvim) run_lazyvim=1; partial=1 ;;
            -h|--help) usage; exit 0 ;;
            *)
                print_error "Unknown argument: $arg"
                usage
                exit 1
                ;;
        esac
    done

    if [[ "$partial" == "1" ]]; then
        run_partial "$run_ai" "$run_web" "$run_ios" "$run_terminal" "$run_lazyvim"
        return 0
    fi

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
    install_optional_tools
    ensure_directories
    setup_fish
    configure_fish_init
    setup_configs
    configure_macos_defaults
    print_status "Cleaning up Homebrew caches and old versions"
    brew cleanup
    print_summary
}

main "$@"
