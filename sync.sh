#!/usr/bin/env bash
# sync.sh - Sync configs between Macs via this repository
# Usage: ./sync.sh [push|pull]
#   push - Export current configs to dotfiles/
#   pull - Import configs from dotfiles/ to local system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

safe_copy() {
    local src="$1"
    local dest="$2"
    if [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp -R "$src" "$dest"
        return 0
    fi
    return 1
}

safe_copy_dir() {
    local src="$1"
    local dest="$2"
    if [[ -d "$src" ]]; then
        mkdir -p "$dest"
        rsync -a --delete "$src"/ "$dest"/
        return 0
    fi
    return 1
}

# ============================================================================
# PUSH - Export configs to dotfiles/
# ============================================================================
do_push() {
    print_status "Pushing configs to repository..."

    # Fish
    safe_copy_dir ~/.config/fish "$DOTFILES_DIR/fish" && print_success "Fish"

    # Git
    safe_copy ~/.gitconfig "$DOTFILES_DIR/git/.gitconfig" && print_success ".gitconfig"
    if safe_copy ~/.gitignore_global "$DOTFILES_DIR/git/.gitignore_global"; then print_success ".gitignore_global"; fi
    if safe_copy ~/.stCommitMsg "$DOTFILES_DIR/git/.stCommitMsg"; then print_success ".stCommitMsg"; fi

    # SSH config only
    safe_copy ~/.ssh/config "$DOTFILES_DIR/ssh/config" && print_success "SSH config"

    # Terminal
    safe_copy ~/.config/ghostty/config "$DOTFILES_DIR/terminal/ghostty/config" && print_success "Ghostty"
    safe_copy ~/.config/starship.toml "$DOTFILES_DIR/terminal/starship.toml" && print_success "Starship"

    # Editor (LazyVim / Neovim)
    safe_copy_dir ~/.config/nvim "$DOTFILES_DIR/editors/nvim" && print_success "LazyVim"

    # CLI tools
    safe_copy ~/.config/gh/config.yml "$DOTFILES_DIR/cli/gh/config.yml" && print_success "GitHub CLI"
    safe_copy_dir ~/.config/lazygit "$DOTFILES_DIR/cli/lazygit" && print_success "LazyGit"
    safe_copy_dir ~/.config/btop "$DOTFILES_DIR/cli/btop" && print_success "btop"
    safe_copy ~/.config/aerospace/aerospace.toml "$DOTFILES_DIR/cli/aerospace/aerospace.toml" && print_success "AeroSpace"

    # mise
    safe_copy ~/.config/mise/config.toml "$DOTFILES_DIR/mise/config.toml" && print_success "mise"
    if safe_copy ~/.tool-versions "$DOTFILES_DIR/mise/.tool-versions"; then print_success ".tool-versions"; fi
    if safe_copy ~/.default-gems "$DOTFILES_DIR/mise/.default-gems"; then print_success ".default-gems"; fi

    # Update Brewfile
    if command -v brew &> /dev/null; then
        brew bundle dump --force --file="$SCRIPT_DIR/Brewfile"
        print_success "Brewfile"
    fi

    echo ""
    print_success "Push complete!"
    print_status "Review changes with: git diff"
    print_status "Commit with: git add -A && git commit -m 'Sync configs'"
}

# ============================================================================
# PULL - Import configs from dotfiles/
# ============================================================================
do_pull() {
    print_status "Pulling configs from repository..."

    # Fish
    [[ -d "$DOTFILES_DIR/fish" ]] && safe_copy_dir "$DOTFILES_DIR/fish" ~/.config/fish && print_success "Fish"

    # Git
    safe_copy "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig && print_success ".gitconfig"
    if safe_copy "$DOTFILES_DIR/git/.gitignore_global" ~/.gitignore_global; then print_success ".gitignore_global"; fi
    if safe_copy "$DOTFILES_DIR/git/.stCommitMsg" ~/.stCommitMsg; then print_success ".stCommitMsg"; fi

    # SSH config only
    safe_copy "$DOTFILES_DIR/ssh/config" ~/.ssh/config && chmod 644 ~/.ssh/config && print_success "SSH config"

    # Terminal
    mkdir -p ~/.config/ghostty
    safe_copy "$DOTFILES_DIR/terminal/ghostty/config" ~/.config/ghostty/config && print_success "Ghostty"
    safe_copy "$DOTFILES_DIR/terminal/starship.toml" ~/.config/starship.toml && print_success "Starship"

    # Editor (LazyVim / Neovim)
    mkdir -p ~/.config/nvim
    [[ -d "$DOTFILES_DIR/editors/nvim" ]] && safe_copy_dir "$DOTFILES_DIR/editors/nvim" ~/.config/nvim && print_success "LazyVim"

    # CLI tools
    mkdir -p ~/.config/gh ~/.config/lazygit ~/.config/btop ~/.config/aerospace
    safe_copy "$DOTFILES_DIR/cli/gh/config.yml" ~/.config/gh/config.yml && print_success "GitHub CLI"
    [[ -d "$DOTFILES_DIR/cli/lazygit" ]] && safe_copy_dir "$DOTFILES_DIR/cli/lazygit" ~/.config/lazygit && print_success "LazyGit"
    [[ -d "$DOTFILES_DIR/cli/btop" ]] && safe_copy_dir "$DOTFILES_DIR/cli/btop" ~/.config/btop && print_success "btop"
    safe_copy "$DOTFILES_DIR/cli/aerospace/aerospace.toml" ~/.config/aerospace/aerospace.toml && print_success "AeroSpace"

    # mise
    mkdir -p ~/.config/mise
    safe_copy "$DOTFILES_DIR/mise/config.toml" ~/.config/mise/config.toml && print_success "mise"
    if safe_copy "$DOTFILES_DIR/mise/.tool-versions" ~/.tool-versions; then print_success ".tool-versions"; fi
    if safe_copy "$DOTFILES_DIR/mise/.default-gems" ~/.default-gems; then print_success ".default-gems"; fi

    echo ""
    print_success "Pull complete!"
    print_warning "Restart your shell to apply changes: exec fish"
}

# ============================================================================
# Main
# ============================================================================
usage() {
    echo "Usage: $0 [push|pull]"
    echo ""
    echo "  push  - Export current configs to dotfiles/ directory"
    echo "  pull  - Import configs from dotfiles/ to local system"
    echo ""
    exit 1
}

case "${1:-}" in
    push)
        do_push
        ;;
    pull)
        do_pull
        ;;
    *)
        usage
        ;;
esac
