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
├── Brewfile                    # Homebrew bundle manifest, source of truth for baseline packages
└── configs/                    # Starship and Ghostty configs copied into ~/.config
```

## Key Design Decisions

- **Fish shell** instead of Zsh
- **Zed** as the default GUI editor; **LazyVim on Neovim** available as an optional extra
- **Warp and/or Ghostty** as the terminal (picked interactively during setup; multi-select supported)
- **mise** for runtime version management
- **Brewfile** is the source of truth for baseline packages
- Optional bundles (AI, web, iOS, LazyVim) are installed via interactive pickers in `setup.sh`, not via Brewfile
- `setup.sh` supports selective re-runs through flags: `--terminal`, `--ai`, `--web`, `--ios`, `--lazyvim` (combinable)
- Env overrides for non-interactive runs: `INSTALL_TERMINAL`, `INSTALL_AI`, `INSTALL_WEB_ORBSTACK`, `INSTALL_IOS`, `INSTALL_LAZYVIM`, `NONINTERACTIVE`, `SUDO_PASSWORD`
- Scripts should be idempotent and safe to re-run
- The repository currently targets real hardware only, not Tart or other VM flows
- The GitHub repo is public at `https://github.com/suho/laptop`; quick-start instructions prefer a `curl`-based tarball fetch over `git clone` so a fresh Mac can bootstrap before git/SSH are configured

## Shell Script Conventions

- Use `#!/usr/bin/env bash` for portability
- Enable strict mode: `set -euo pipefail`
- Detect architecture with `[[ $(uname -m) == "arm64" ]]`
- Use functions for logical grouping
- Print clear status output with colors

## Scope

This repository installs tools and a few system preferences only. Personal application config and local state are out of scope unless the repository structure is expanded again later.
