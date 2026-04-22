# laptop

Personal macOS bootstrap repo for setting up a real, completely new MacBook.

The repo has one job now: install apps, CLI tools, and base preferences onto a fresh MacBook. It does not export state from an old machine or sync personal config back into the repository.

## What This Repo Manages

| Category | Tools |
|----------|-------|
| Shell | Fish, Fisher, Starship |
| Terminal | Ghostty |
| Editor | Neovim |
| Window Mgmt | AeroSpace, Raycast |
| Productivity | Obsidian, MeetingBar, Itsycal, 1Password, Shottr, The Unarchiver |
| CLI | git, git-lfs, gh, LazyGit, btop, fzf, ripgrep, fd, jq, tree, mise |
| AI | Claude Code, Codex, opencode, LM Studio |
| Communication | Slack, Telegram |
| Browser | Google Chrome |

## Quick Start

On a brand-new MacBook:

```sh
git clone <this-repo> ~/Developer/suho/laptop
cd ~/Developer/suho/laptop
./setup.sh
```

What `setup.sh` does:

1. Installs Xcode Command Line Tools
2. Installs and updates Homebrew
3. Installs everything declared in `Brewfile`
4. Sets up Fish, Fisher, the required Fish plugin, and persistent Fish initialization for Homebrew, `mise`, and `starship`
5. Applies a small set of macOS defaults
6. Runs `brew cleanup`

## Repository Layout

```text
laptop/
├── setup.sh
├── verify.sh
├── Brewfile
└── macbook-setup-checklist.md
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
