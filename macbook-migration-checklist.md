# MacBook Migration Checklist

> Updated: 2026-04-22

---

## Applications

### Install via Homebrew (restore with `Brewfile`)

Run on the new Mac:

```sh
brew bundle --file ~/Developer/suho/laptop/Brewfile
```

| Category | Apps |
|---|---|
| Terminal / Shell | Ghostty, Fish, Starship |
| Editor | LazyVim (Neovim) |
| Window Mgmt | AeroSpace, Raycast |
| Productivity | Obsidian, MeetingBar, Itsycal, 1Password |
| Communication | Slack, Telegram |
| Other | LM Studio, Shottr, The Unarchiver |

---

## Shell & Terminal Configs

| What | Path |
|---|---|
| Fish config | `~/.config/fish/` (entire dir) |
| Fish plugins list | `~/.config/fish/fish_plugins` — run `fisher install` after |
| Starship prompt | `~/.config/starship.toml` |
| Ghostty config | `~/.config/ghostty/config` |

---

## Git & Version Control

| What | Path / Action |
|---|---|
| Git config | `~/.gitconfig` |
| Global gitignore | `~/.gitignore_global` |
| Commit message template | `~/.stCommitMsg` |
| GPG key | `gpg --export-secret-keys --armor 8D4B6ED5 > gpg-key.asc` then import on new Mac |
| SSH keys | `~/.ssh/` (github_suho, id_ed25519_el, lgtv_webos, webos_emul) |
| SSH config | `~/.ssh/config` |
| git-lfs | Reinstall via brew |

---

## Developer Tools & Version Managers

| What | Path / Action |
|---|---|
| mise config | `~/.config/mise/config.toml` |
| mise tool versions | `~/.tool-versions` |
| Ruby gems defaults | `~/.default-gems` |

**Note:** Runtimes are installed on demand with mise. Example:
```sh
mise use node@latest
mise use python@latest
```

---

## Editor

### LazyVim (Neovim)

| What | Path |
|---|---|
| Full config | `~/.config/nvim/` |

---

## CLI Tool Configs

| Tool | Path |
|---|---|
| GitHub CLI (`gh`) | `~/.config/gh/config.yml` — re-auth: `gh auth login` |
| LazyGit | `~/.config/lazygit/` |
| btop | `~/.config/btop/` |
| AeroSpace | `~/.config/aerospace/aerospace.toml` |
| Raycast scripts | `~/me/raycast/` |

---

## Apps with Local Data

| App | Path |
|---|---|
| Obsidian vault | `~/me/obsidian/vansuho/` (entire vault) |
| LM Studio | `~/.lmstudio-home-pointer` + downloaded models |

AI tools are installed during setup, but `~/.claude`, `~/.codex`, and `~/.config/opencode` are not migrated by this repo.

---

## Personal / Project Files

| What | Path |
|---|---|
| Developer projects | `~/Developer/` |
| Personal scripts | `~/me/files/` |
| Raycast scripts | `~/me/raycast/` |
| Fonts | `~/Library/Fonts/` (CascadiaCode family) |

---

## Credentials & Keys (Handle Carefully)

| What | Action |
|---|---|
| GPG key | `gpg --export-secret-keys --armor 8D4B6ED5 > gpg-key.asc` |
| SSH private keys | `~/.ssh/github_suho`, `~/.ssh/id_ed25519_el`, `~/.ssh/lgtv_webos`, `~/.ssh/webos_emul` |
| 1Password | Re-login on new machine (syncs from cloud) |

---

## Quick Start Order on New Mac

1. Install Xcode Command Line Tools:
   ```sh
   xcode-select --install
   ```
2. Clone this repo and run setup:
   ```sh
   git clone <repo> ~/Developer/suho/laptop
   cd ~/Developer/suho/laptop
   ./setup.sh
   ```
3. Copy SSH keys and set permissions:
   ```sh
   chmod 600 ~/.ssh/github_suho ~/.ssh/id_ed25519_el
   ```
4. Import GPG key:
   ```sh
   gpg --import gpg-key.asc
   ```
5. Authenticate GitHub CLI:
   ```sh
   gh auth login
   ```
6. Sign in to apps: 1Password, Slack, Telegram, Obsidian, Raycast
