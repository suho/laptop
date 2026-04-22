# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project Purpose

Personal macOS laptop setup and migration toolkit. Contains scripts to:
1. **Export** configs and tool data from an existing Mac into this repository
2. **Setup** a new Mac with all tools, configs, and data
3. **Sync** configurations between multiple Macs

## Architecture

```
laptop/
├── export.sh              # Run on OLD Mac: exports configs to dotfiles/
├── setup.sh               # Run on NEW Mac: installs tools + imports configs
├── sync.sh                # Sync configs between Macs (push/pull)
├── dotfiles/              # Synced config files (git-tracked)
│   ├── fish/              # ~/.config/fish/
│   ├── git/               # .gitconfig, .gitignore_global, .stCommitMsg
│   ├── ssh/               # SSH config (NOT private keys)
│   ├── editors/nvim/      # LazyVim config under ~/.config/nvim
│   ├── terminal/          # Ghostty, Starship configs
│   ├── cli/               # gh, lazygit, btop, aerospace
│   └── mise/              # mise config (runtimes installed on demand)
├── Brewfile               # Homebrew bundle manifest
├── secrets-checklist.md   # List of secrets to manually restore
└── macbook-migration-checklist.md  # Reference document
```

## Key Design Decisions

- **Fish shell** instead of Zsh (user preference)
- **LazyVim on Neovim** as the only editor setup (no VS Code, Zed)
- **Ghostty** as the only terminal (no Warp)
- **mise** for runtime version management (install runtimes on demand, not preset)
- **Secrets excluded** from export - only listed in secrets-checklist.md for manual restoration
- **Brewfile** is the source of truth for installed applications
- Scripts are idempotent and can be re-run safely

## Shell Script Conventions

- Use `#!/usr/bin/env bash` for portability
- Enable strict mode: `set -euo pipefail`
- Detect architecture: `[[ $(uname -m) == "arm64" ]]`
- Use functions for logical grouping
- Print status with colored output for visibility

## Paths Reference

Key config locations on macOS:
- Fish: `~/.config/fish/`
- LazyVim / Neovim: `~/.config/nvim/`
- Ghostty: `~/.config/ghostty/config`
- mise: `~/.config/mise/config.toml`
- SSH: `~/.ssh/config` (config only, not keys)
- Git: `~/.gitconfig`, `~/.gitignore_global`
- CLI: `~/.config/{gh,lazygit,btop,aerospace}/`
