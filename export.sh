#!/usr/bin/env bash
# export.sh - Run on OLD Mac to export configs to this repository
# Usage: ./export.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Create directories if they don't exist
ensure_dir() {
    mkdir -p "$1"
}

# Safe copy - only if source exists
safe_copy() {
    local src="$1"
    local dest="$2"
    if [[ -e "$src" ]]; then
        ensure_dir "$(dirname "$dest")"
        cp -R "$src" "$dest"
        print_success "Copied: $src"
    else
        print_warning "Not found: $src"
    fi
}

# Safe copy directory contents
safe_copy_dir() {
    local src="$1"
    local dest="$2"
    if [[ -d "$src" ]]; then
        ensure_dir "$dest"
        rsync -a --delete "$src"/ "$dest"/
        print_success "Copied directory: $src"
    else
        print_warning "Directory not found: $src"
    fi
}

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           MacBook Config Export Script                   ║"
echo "║      Run this on your OLD Mac before migration           ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# Homebrew - Generate Brewfile
# ============================================================================
print_status "Generating Brewfile..."

if command -v brew &> /dev/null; then
    brew bundle dump --force --file="$SCRIPT_DIR/Brewfile"
    print_success "Generated Brewfile with $(grep -c '^' "$SCRIPT_DIR/Brewfile") entries"
else
    print_error "Homebrew not installed, skipping Brewfile generation"
fi

# ============================================================================
# Fish Shell
# ============================================================================
print_status "Exporting Fish shell configs..."

ensure_dir "$DOTFILES_DIR/fish"
safe_copy_dir ~/.config/fish "$DOTFILES_DIR/fish"

# ============================================================================
# Zsh configs (as backup)
# ============================================================================
print_status "Exporting Zsh configs..."

ensure_dir "$DOTFILES_DIR/zsh"
safe_copy ~/.zshrc "$DOTFILES_DIR/zsh/.zshrc"
safe_copy ~/.zprofile "$DOTFILES_DIR/zsh/.zprofile"
safe_copy ~/.profile "$DOTFILES_DIR/zsh/.profile"
# Note: .zsh_history intentionally excluded (large, contains sensitive commands)

# ============================================================================
# Git Configuration
# ============================================================================
print_status "Exporting Git configs..."

ensure_dir "$DOTFILES_DIR/git"
safe_copy ~/.gitconfig "$DOTFILES_DIR/git/.gitconfig"
safe_copy ~/.gitignore_global "$DOTFILES_DIR/git/.gitignore_global"
safe_copy ~/.stCommitMsg "$DOTFILES_DIR/git/.stCommitMsg"

# ============================================================================
# SSH Config (NOT private keys)
# ============================================================================
print_status "Exporting SSH config (excluding private keys)..."

ensure_dir "$DOTFILES_DIR/ssh"
safe_copy ~/.ssh/config "$DOTFILES_DIR/ssh/config"
# Note: Private keys and known_hosts excluded for security

# ============================================================================
# Terminal Emulators
# ============================================================================
print_status "Exporting terminal configs..."

# Ghostty
ensure_dir "$DOTFILES_DIR/terminal/ghostty"
safe_copy ~/.config/ghostty/config "$DOTFILES_DIR/terminal/ghostty/config"

# Starship prompt
safe_copy ~/.config/starship.toml "$DOTFILES_DIR/terminal/starship.toml"

# ============================================================================
# Editors
# ============================================================================
print_status "Exporting editor configs..."

# LazyVim / Neovim
ensure_dir "$DOTFILES_DIR/editors/nvim"
safe_copy_dir ~/.config/nvim "$DOTFILES_DIR/editors/nvim"

# ============================================================================
# CLI Tools
# ============================================================================
print_status "Exporting CLI tool configs..."

# GitHub CLI
ensure_dir "$DOTFILES_DIR/cli/gh"
if [[ -d ~/.config/gh ]]; then
    # Copy config but exclude hosts.yml (contains tokens)
    safe_copy ~/.config/gh/config.yml "$DOTFILES_DIR/cli/gh/config.yml"
fi

# LazyGit
ensure_dir "$DOTFILES_DIR/cli/lazygit"
safe_copy_dir ~/.config/lazygit "$DOTFILES_DIR/cli/lazygit"

# btop
ensure_dir "$DOTFILES_DIR/cli/btop"
safe_copy_dir ~/.config/btop "$DOTFILES_DIR/cli/btop"

# AeroSpace
ensure_dir "$DOTFILES_DIR/cli/aerospace"
safe_copy ~/.config/aerospace/aerospace.toml "$DOTFILES_DIR/cli/aerospace/aerospace.toml"



# ============================================================================
# mise (runtime version manager)
# ============================================================================
print_status "Exporting mise configs..."

ensure_dir "$DOTFILES_DIR/mise"
safe_copy ~/.config/mise/config.toml "$DOTFILES_DIR/mise/config.toml"
safe_copy ~/.tool-versions "$DOTFILES_DIR/mise/.tool-versions"
safe_copy ~/.default-gems "$DOTFILES_DIR/mise/.default-gems"

# ============================================================================
# AI Tools (Claude Code, Codex, opencode)
# ============================================================================
print_status "Exporting AI tools configs..."

# Claude Code
ensure_dir "$DOTFILES_DIR/ai/claude"
if [[ -d ~/.claude ]]; then
    safe_copy ~/.claude/settings.json "$DOTFILES_DIR/ai/claude/settings.json"
    safe_copy ~/.claude/keybindings.json "$DOTFILES_DIR/ai/claude/keybindings.json"
    safe_copy ~/.claude/CLAUDE.md "$DOTFILES_DIR/ai/claude/CLAUDE.md"
    safe_copy ~/.claude/memory.md "$DOTFILES_DIR/ai/claude/memory.md"
    if [[ -d ~/.claude/commands ]]; then
        safe_copy_dir ~/.claude/commands "$DOTFILES_DIR/ai/claude/commands"
    fi
    if [[ -d ~/.claude/skills ]]; then
        safe_copy_dir ~/.claude/skills "$DOTFILES_DIR/ai/claude/skills"
    fi
    if [[ -d ~/.claude/agents ]]; then
        safe_copy_dir ~/.claude/agents "$DOTFILES_DIR/ai/claude/agents"
    fi
    if [[ -d ~/.claude/hooks ]]; then
        safe_copy_dir ~/.claude/hooks "$DOTFILES_DIR/ai/claude/hooks"
    fi
fi

# Codex
ensure_dir "$DOTFILES_DIR/ai/codex"
if [[ -d ~/.codex ]]; then
    safe_copy ~/.codex/config.toml "$DOTFILES_DIR/ai/codex/config.toml"
    safe_copy ~/.codex/AGENTS.md "$DOTFILES_DIR/ai/codex/AGENTS.md"
    if [[ -d ~/.codex/rules ]]; then
        safe_copy_dir ~/.codex/rules "$DOTFILES_DIR/ai/codex/rules"
    fi
    if [[ -d ~/.codex/skills ]]; then
        safe_copy_dir ~/.codex/skills "$DOTFILES_DIR/ai/codex/skills"
    fi
    if [[ -d ~/.codex/automations ]]; then
        safe_copy_dir ~/.codex/automations "$DOTFILES_DIR/ai/codex/automations"
    fi
fi

# opencode
ensure_dir "$DOTFILES_DIR/ai/opencode"
if [[ -d ~/.config/opencode ]]; then
    safe_copy ~/.config/opencode/opencode.json "$DOTFILES_DIR/ai/opencode/opencode.json"
fi

# ============================================================================
# Generate secrets checklist
# ============================================================================
print_status "Generating secrets checklist..."

cat > "$SCRIPT_DIR/secrets-checklist.md" << 'SECRETS_EOF'
# Secrets & Credentials Checklist

> These items contain sensitive data and were NOT exported. Restore manually on the new Mac.

## SSH Keys (copy manually or regenerate)

- [ ] `~/.ssh/github_suho` - GitHub SSH key
- [ ] `~/.ssh/id_ed25519_el` - Ed25519 key
- [ ] `~/.ssh/lgtv_webos` - LG TV WebOS key
- [ ] `~/.ssh/webos_emul` - WebOS emulator key
- [ ] `~/.ssh/known_hosts` - Known hosts file

After copying, fix permissions:
```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub ~/.ssh/config ~/.ssh/known_hosts
```

## GPG Keys

- [ ] Export: `gpg --export-secret-keys --armor 8D4B6ED5 > gpg-key.asc`
- [ ] Import: `gpg --import gpg-key.asc`
- [ ] Trust: `gpg --edit-key 8D4B6ED5` then `trust` -> `5` -> `quit`

## CLI Authentication

- [ ] `gh auth login` - GitHub CLI

## Config Files with Tokens

- [ ] `~/.npmrc` - May contain npm tokens
- [ ] `~/.sentryclirc` - Sentry auth token
- [ ] `~/.config/gh/hosts.yml` - GitHub CLI tokens

## App Data to Transfer Manually

- [ ] Obsidian vault: `~/me/obsidian/vansuho/`
- [ ] 1Password: Sign in (syncs from cloud)
- [ ] Raycast: Sign in (syncs from cloud)

## Xcode & Development

- [ ] Xcode signing certificates: Export from Keychain Access → "My Certificates"
- [ ] Provisioning profiles: Check ~/Library/MobileDevice/Provisioning Profiles/

## Other

- [ ] LM Studio models: Download fresh or copy from `~/.lmstudio/`
SECRETS_EOF

print_success "Generated secrets-checklist.md"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    Export Complete!                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
print_status "Exported configs to: $DOTFILES_DIR"
print_status "Generated: Brewfile, secrets-checklist.md"
echo ""
print_warning "Next steps:"
echo "  1. Review the exported files for any accidental secrets"
echo "  2. Commit changes: git add -A && git commit -m 'Export configs'"
echo "  3. Push to remote: git push"
echo "  4. Check secrets-checklist.md for items to transfer manually"
echo ""
