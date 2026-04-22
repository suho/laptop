# laptop

Personal macOS laptop setup and migration toolkit.

## Tools Managed

| Category | Tools |
|----------|-------|
| Shell | Fish, Starship prompt |
| Terminal | Ghostty |
| Editor | Neovim |
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

## Structure

```
dotfiles/
├── fish/           # Fish shell config
├── git/            # .gitconfig, .gitignore_global
├── ssh/            # SSH config (not keys)
├── terminal/       # Ghostty, Starship
├── editors/nvim/   # Neovim
├── cli/            # gh, lazygit, btop, aerospace
├── mise/           # Runtime version manager
└── ai/             # Claude Code, Codex, opencode
```

## Manual Steps After Setup

1. Copy SSH keys and fix permissions
2. Import GPG key: `gpg --import gpg-key.asc`
3. Authenticate GitHub CLI: `gh auth login`
4. Sign in to apps: 1Password, Slack, Telegram, Obsidian, Raycast

See `secrets-checklist.md` for full list.
