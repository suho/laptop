# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project Purpose

Personal macOS setup repository for provisioning a completely new MacBook. The codebase is setup-only:

1. Install tools and applications from `Brewfile`
2. Apply setup-time shell and macOS preferences
3. Apply the setup directly on a real MacBook

This repository no longer supports export or sync workflows.

## Architecture

```text
laptop/
├── setup.sh                    # Main bootstrap entrypoint for a fresh Mac
├── verify.sh                   # Verifies installed tools and shell state
├── Brewfile                    # Homebrew bundle manifest, source of truth for packages
└── macbook-setup-checklist.md  # Manual follow-up items not automated by setup.sh
```

## Key Design Decisions

- **Fish shell** instead of Zsh
- **LazyVim on Neovim** as the editor setup
- **Warp or Ghostty** as the terminal (picked interactively during setup)
- **mise** for runtime version management
- **Brewfile** is the source of truth for installed packages
- Scripts should be idempotent and safe to re-run
- The repository currently targets real hardware only, not Tart or other VM flows

## Shell Script Conventions

- Use `#!/usr/bin/env bash` for portability
- Enable strict mode: `set -euo pipefail`
- Detect architecture with `[[ $(uname -m) == "arm64" ]]`
- Use functions for logical grouping
- Print clear status output with colors

## Scope

This repository installs tools and a few system preferences only. Personal application config and local state are out of scope unless the repository structure is expanded again later.
