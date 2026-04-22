#!/usr/bin/env bash
# verify-setup.sh - Validate the laptop setup on a target macOS machine
# Usage: ./scripts/verify-setup.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

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

assert_command() {
    local command_name="$1"
    if command -v "$command_name" >/dev/null 2>&1; then
        print_success "Command available: $command_name"
    else
        record_failure "Command missing: $command_name"
    fi
}

assert_path_exists() {
    local label="$1"
    local target="$2"
    if [[ -e "$target" ]]; then
        print_success "$label present: $target"
    else
        record_failure "$label missing: $target"
    fi
}

assert_synced_path() {
    local source_rel="$1"
    local target="$2"
    local source="$REPO_ROOT/$source_rel"

    if [[ -e "$source" ]]; then
        assert_path_exists "Synced path" "$target"
    else
        print_warning "Skipping optional path not tracked in repo: $source_rel"
    fi
}

print_status "Checking macOS prerequisites"

if [[ "$(uname)" != "Darwin" ]]; then
    record_failure "This verification script must run on macOS"
fi

if xcode-select -p >/dev/null 2>&1; then
    print_success "Xcode Command Line Tools are available"
else
    record_failure "Xcode Command Line Tools are not configured"
fi

print_status "Checking Homebrew bundle state"

if command -v brew >/dev/null 2>&1; then
    if brew bundle check --file="$REPO_ROOT/Brewfile"; then
        print_success "Brewfile dependencies are installed"
    else
        record_failure "Brewfile dependencies are missing"
    fi
else
    record_failure "Homebrew is not installed"
fi

print_status "Checking core CLI tools"

for command_name in \
    fish starship nvim git git-lfs gh lazygit btop fzf rg fd jq tree curl mise opencode ffmpeg gpg
do
    assert_command "$command_name"
done

print_status "Checking copied configuration files"

assert_synced_path "dotfiles/fish" "$HOME/.config/fish"
assert_synced_path "dotfiles/git/.gitconfig" "$HOME/.gitconfig"
assert_synced_path "dotfiles/git/.gitignore_global" "$HOME/.gitignore_global"
assert_synced_path "dotfiles/git/.stCommitMsg" "$HOME/.stCommitMsg"
assert_synced_path "dotfiles/ssh/config" "$HOME/.ssh/config"
assert_synced_path "dotfiles/terminal/ghostty/config" "$HOME/.config/ghostty/config"
assert_synced_path "dotfiles/terminal/starship.toml" "$HOME/.config/starship.toml"
assert_synced_path "dotfiles/editors/nvim" "$HOME/.config/nvim"
assert_synced_path "dotfiles/cli/gh/config.yml" "$HOME/.config/gh/config.yml"
assert_synced_path "dotfiles/cli/lazygit" "$HOME/.config/lazygit"
assert_synced_path "dotfiles/cli/btop" "$HOME/.config/btop"
assert_synced_path "dotfiles/cli/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
assert_synced_path "dotfiles/mise/config.toml" "$HOME/.config/mise/config.toml"
assert_synced_path "dotfiles/mise/.tool-versions" "$HOME/.tool-versions"
assert_synced_path "dotfiles/mise/.default-gems" "$HOME/.default-gems"
assert_synced_path "dotfiles/ai/claude" "$HOME/.claude"
assert_synced_path "dotfiles/ai/codex" "$HOME/.codex"
assert_synced_path "dotfiles/ai/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

print_status "Checking shell configuration"

if command -v fish >/dev/null 2>&1; then
    expected_shell="$(command -v fish)"
    current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
    if [[ "$current_shell" == "$expected_shell" ]]; then
        print_success "Default shell is Fish"
    else
        record_failure "Default shell is not Fish ($current_shell)"
    fi
fi

echo ""
if (( failures == 0 )); then
    print_success "Verification passed"
else
    print_error "Verification failed with $failures issue(s)"
    exit 1
fi
