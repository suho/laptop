# laptop

Personal macOS laptop setup and migration toolkit.

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
# Install Xcode CLI tools first
xcode-select --install

# Clone and run setup
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

## What's Included

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
├── terminal/       # Ghostty, Warp, Starship
├── editors/        # VS Code, Zed, Neovim
├── cli/            # gh, lazygit, btop, aerospace
├── mise/           # Runtime version manager
└── claude/         # Claude Code settings
```

## Manual Steps

After running `setup.sh`, complete these manually:

1. Copy SSH keys and fix permissions
2. Import GPG key: `gpg --import gpg-key.asc`
3. Authenticate: `gh auth login`, `gcloud auth login`, `aws configure`
4. Sign in to apps: 1Password, Slack, Obsidian, Raycast

See `secrets-checklist.md` for full list.
