# laptop

Personal macOS laptop setup and migration toolkit.

AI tools are installed on new machines, but their local configs and data are not exported or synced by this repo.

## Tools Managed

| Category | Tools |
|----------|-------|
| Shell | Fish, Starship prompt |
| Terminal | Ghostty |
| Editor | LazyVim (Neovim) |
| Window Mgmt | AeroSpace, Raycast |
| Productivity | Obsidian, MeetingBar, Itsycal, 1Password |
| CLI | gh, LazyGit, btop |
| AI | Claude Code, Codex, opencode |
| Communication | Slack, Telegram |
| Runtimes | mise (install on demand) |

## Quick Start

### On your OLD Mac (export configs)

```sh
git clone <this-repo> ~/Developer/suho/laptop
cd ~/Developer/suho/laptop
./export.sh
git add -A && git commit -m "Export configs" && git push
```

### On your NEW Mac (setup)

```sh
git clone <this-repo> ~/Developer/suho/laptop
cd ~/Developer/suho/laptop
./setup.sh
```

### Ongoing sync between Macs

```sh
# Push local configs to repo
./sync.sh push
git add -A && git commit -m "Sync configs" && git push

# Pull configs from repo
git pull
./sync.sh pull
```

## Scripts

| Script | Purpose |
|--------|---------|
| `export.sh` | Export configs from current Mac to `dotfiles/` |
| `setup.sh` | Install tools and import configs on new Mac |
| `sync.sh` | Sync configs between Macs (push/pull) |
| `scripts/verify-setup.sh` | Verify Brewfile tools and synced configs on a target Mac |
| `scripts/test-tart-setup.sh` | Export locally, test `setup.sh` in a fresh Tart VM, verify, then destroy the VM |

## Structure

```
dotfiles/
├── fish/           # Fish shell config
├── git/            # .gitconfig, .gitignore_global
├── ssh/            # SSH config (not keys)
├── terminal/       # Ghostty, Starship
├── editors/nvim/   # LazyVim config under ~/.config/nvim
├── cli/            # gh, lazygit, btop, aerospace
└── mise/           # Runtime version manager
```

## Manual Steps After Setup

1. Copy SSH keys and fix permissions
2. Import GPG key: `gpg --import gpg-key.asc`
3. Authenticate GitHub CLI: `gh auth login`
4. Sign in to apps: 1Password, Slack, Telegram, Obsidian, Raycast

See `secrets-checklist.md` for full list.

## Tart VM Test Flow

Use this to simulate migration from your current laptop into a fresh macOS Tart VM:

```sh
./scripts/test-tart-setup.sh
```

What it does:

1. Runs `./export.sh` on the host Mac
2. Clones and boots a fresh Tart VM from `ghcr.io/cirruslabs/macos-tahoe-vanilla:latest`
3. Mounts this repository into the VM
4. Runs `NONINTERACTIVE=1 ./setup.sh` inside the VM
5. Runs `./scripts/verify-setup.sh` inside the VM
6. Always deletes the VM at the end, whether the test passes or fails

Useful overrides:

```sh
IMAGE_NAME=ghcr.io/cirruslabs/macos-tahoe-vanilla:latest ./scripts/test-tart-setup.sh
VM_CPU=6 VM_MEMORY=12288 VM_DISK_SIZE=120 ./scripts/test-tart-setup.sh
LOG_DIR="$PWD/.tmp/tart-test" ./scripts/test-tart-setup.sh
```
