# laptop

Personal macOS bootstrap repo for setting up a real, completely new MacBook.

The repo has one job now: install apps, CLI tools, and base preferences onto a fresh MacBook. It does not export state from an old machine or sync personal config back into the repository.

## What This Repo Manages

| Category | Tools |
|----------|-------|
| Shell | Fish, Fisher, Starship |
| Terminal | Warp and/or Ghostty (interactive pick) |
| Editor | Zed (default), LazyVim on Neovim (optional) |
| Productivity | Raycast, Obsidian, MeetingBar, Itsycal, 1Password, Shottr |
| CLI | git, git-lfs, gh, LazyGit, btop, mise, ffmpeg |
| Security | openssl, gnupg, pinentry-mac |
| AI (optional) | Claude Code, Codex, LM Studio |
| Web (optional) | OrbStack |
| iOS (optional) | Xcodes, Proxyman, Postman, Fork |
| Configs | Starship prompt, Ghostty |

## Quick Start

On a brand-new MacBook, run the one-liner (repo is public, no auth needed):

```sh
mkdir -p ~/Developer/suho && cd ~/Developer/suho \
  && curl -fsSL https://github.com/suho/laptop/archive/refs/heads/main.tar.gz | tar -xz \
  && mv laptop-main laptop && cd laptop && ./setup.sh
```

Or clone with git if you prefer:

```sh
git clone https://github.com/suho/laptop.git ~/Developer/suho/laptop
cd ~/Developer/suho/laptop
./setup.sh
```

What `setup.sh` does:

1. Installs Xcode Command Line Tools
2. Installs and updates Homebrew
3. Installs everything declared in `Brewfile`
4. Runs interactive pickers for optional tools (terminal, AI, web, iOS, LazyVim)
5. Sets up Fish, Fisher, the required Fish plugin, and persistent Fish initialization for Homebrew, `mise`, and `starship`
6. Copies personal configs (Starship, Ghostty) into `~/.config`
7. Applies a small set of macOS defaults
8. Runs `brew cleanup`

## Selective Installs

Re-run pieces of the setup without going through the full bootstrap:

```sh
./setup.sh --terminal   # Warp and/or Ghostty
./setup.sh --ai         # Claude Code, Codex, LM Studio
./setup.sh --web        # OrbStack
./setup.sh --ios        # Xcodes, Proxyman, Postman, Fork
./setup.sh --lazyvim    # Neovim + fd + ripgrep + Nerd Font + LazyVim starter
./setup.sh --help
```

Flags can be combined (e.g. `./setup.sh --ai --ios`).

Env overrides for non-interactive runs: `INSTALL_TERMINAL`, `INSTALL_AI`, `INSTALL_WEB_ORBSTACK`, `INSTALL_IOS`, `INSTALL_LAZYVIM`, `NONINTERACTIVE`, `SUDO_PASSWORD`.

## Repository Layout

```text
laptop/
├── setup.sh                    # Main bootstrap entrypoint
├── verify.sh                   # Post-install verification
├── Brewfile                    # Homebrew bundle manifest
└── configs/                    # Starship and Ghostty configs copied to ~/.config
```

## Verification

After setup finishes:

```sh
./verify.sh
```

`verify.sh` checks macOS prerequisites, `brew bundle` state, expected CLI commands, installed casks, whether Fish is the default shell, whether Fish bootstrap lines are present, and whether Fisher plus the required plugin are installed.

## Manual Steps After Setup

1. Sign in to 1Password, Slack, Telegram, Obsidian, and Raycast
2. Restore SSH keys into `~/.ssh/` and fix permissions
3. Import your GPG key if needed
4. Bring over personal data and any personal app config that this repo intentionally does not manage
