# MacBook Setup Checklist

> Updated: 2026-04-22

Manual items for a real-MacBook setup that are intentionally not automated by `setup.sh`.

## Automated By This Repo

Run:

```sh
git clone <repo> ~/Developer/suho/laptop
cd ~/Developer/suho/laptop
./setup.sh
```

That flow installs:

- Xcode Command Line Tools
- Homebrew and the full `Brewfile`
- Fish, Fisher, and the required Fish plugin
- Basic macOS defaults used in this setup

## Still Manual

### Accounts and sign-in

- 1Password
- Slack
- Telegram
- Obsidian
- Raycast
- Google Chrome profiles if needed

### Keys and credentials

- Restore SSH keys into `~/.ssh/`
- Fix permissions, for example: `chmod 600 ~/.ssh/<key>`
- Import GPG keys if needed: `gpg --import <keyfile>`

### Personal data not managed by this repo

- `~/Developer/`
- `~/me/files/`
- `~/me/obsidian/vansuho/`
- `~/me/raycast/`
- `~/Library/Fonts/`
- LM Studio downloaded models

### AI tool note

AI tools are installed during setup, but local state such as `~/.claude`, `~/.codex`, and `~/.config/opencode` is not migrated by this repo.

## Verification

Run:

```sh
./verify.sh
```

This checks the installed Homebrew packages, expected CLI tools, casks, and whether Fish is set as the default shell.
