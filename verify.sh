#!/usr/bin/env bash
# verify.sh - Verify that the tools from this repository are installed
# Usage: ./verify.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

failures=0

record_failure() {
    print_error "$1"
    failures=$((failures + 1))
}

assert_file_contains() {
    local file_path="$1"
    local expected_text="$2"
    local description="$3"

    if [[ -f "$file_path" ]] && grep -Fqx "$expected_text" "$file_path"; then
        print_success "$description"
    else
        record_failure "$description"
    fi
}

assert_command() {
    local command_name="$1"
    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "Command available: $command_name"
    else
        record_failure "Command missing: $command_name"
    fi
}

assert_cask() {
    local cask_name="$1"
    if brew list --cask "$cask_name" >/dev/null 2>&1; then
        print_success "Cask installed: $cask_name"
    else
        record_failure "Cask missing: $cask_name"
    fi
}

print_status "Checking platform"

if [[ "$(uname)" != "Darwin" ]]; then
    record_failure "This verification script must run on macOS"
fi

if xcode-select -p >/dev/null 2>&1; then
    print_success "Xcode Command Line Tools are available"
else
    record_failure "Xcode Command Line Tools are not configured"
fi

print_status "Checking Homebrew"

if command -v brew >/dev/null 2>&1; then
    print_success "Homebrew is installed"
else
    record_failure "Homebrew is not installed"
fi

if [[ ! -f "$BREWFILE" ]]; then
    record_failure "Brewfile not found: $BREWFILE"
fi

if command -v brew >/dev/null 2>&1 && [[ -f "$BREWFILE" ]]; then
    if brew bundle check --file="$BREWFILE"; then
        print_success "Brewfile dependencies are installed"
    else
        record_failure "Brewfile dependencies are missing"
    fi
fi

print_status "Checking CLI tools"

for command_name in \
    fish starship git git-lfs gh lazygit btop mise \
    opencode claude ffmpeg openssl gpg pinentry-mac
do
    assert_command "$command_name"
done

print_status "Checking installed casks"

for cask_name in \
    claude-code claude codex codex-app ghostty@tip \
    orbstack lm-studio xcodes-app obsidian \
    meetingbar itsycal 1password raycast shottr slack telegram \
    google-chrome
do
    assert_cask "$cask_name"
done

print_status "Checking Fish shell state"

if command -v fish >/dev/null 2>&1; then
    expected_shell="$(command -v fish)"
    current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
    if [[ "$current_shell" == "$expected_shell" ]]; then
        print_success "Default shell is Fish"
    else
        record_failure "Default shell is not Fish ($current_shell)"
    fi
fi

print_status "Checking Fish bootstrap configuration"

fish_config="$HOME/.config/fish/config.fish"
if [[ "$(uname -m)" == "arm64" ]]; then
    expected_brew_init='if test -x /opt/homebrew/bin/brew'
else
    expected_brew_init='if test -x /usr/local/bin/brew'
fi

assert_file_contains "$fish_config" "$expected_brew_init" "Fish config contains Homebrew init"
assert_file_contains "$fish_config" '    mise activate fish | source' "Fish config contains mise activation"
assert_file_contains "$fish_config" '    starship init fish | source' "Fish config contains starship initialization"

if [[ -f "$HOME/.config/fish/functions/fisher.fish" ]]; then
    print_success "Fisher is installed"
else
    record_failure "Fisher is not installed"
fi

if command -v fish >/dev/null 2>&1; then
    if fish -c "fisher list | grep -Fxq jethrokuan/z"; then
        print_success "Fish plugin installed: jethrokuan/z"
    else
        record_failure "Fish plugin missing: jethrokuan/z"
    fi
fi

print_status "Checking personal configurations"

config_pairs=(
    "$SCRIPT_DIR/configs/starship.toml:$HOME/.config/starship.toml"
    "$SCRIPT_DIR/configs/ghostty/config:$HOME/.config/ghostty/config"
)

for entry in "${config_pairs[@]}"; do
    src="${entry%%:*}"
    dst="${entry#*:}"
    name="$(basename "$dst")"

    if [[ ! -f "$dst" ]]; then
        record_failure "Config missing: $dst"
    elif diff -q "$src" "$dst" >/dev/null 2>&1; then
        print_success "Config up to date: $name"
    else
        print_warning "Config differs from repo: $name"
    fi
done

echo ""
if (( failures == 0 )); then
    print_success "Verification passed"
else
    print_error "Verification failed with $failures issue(s)"
    exit 1
fi
