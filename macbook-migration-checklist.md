# MacBook Migration Checklist

> Generated: 2026-04-22

---

## Applications

### Install via Homebrew (restore with `.Brewfile`)

Your `~/.Brewfile` already exists — run on the new Mac:

```sh
brew bundle --file ~/.Brewfile
```

| Category | Apps |
|---|---|
| Terminal / Shell | Ghostty, Warp, fish |
| Editors | VS Code Insiders, Zed, Neovim |
| Dev Tools | OrbStack, Proxyman, Postman, TablePlus, Xcode |
| Window Mgmt | AeroSpace, BetterDisplay, Raycast |
| Productivity | Obsidian, MeetingBar, Itsycal, 1Password |
| Communication | Slack, Telegram, WhatsApp |
| Other | LM Studio, Shottr, The Unarchiver, OpenKey |

---

## Shell & Terminal Configs

| What | Path |
|---|---|
| Fish config | `~/.config/fish/` (entire dir) |
| Fish plugins list | `~/.config/fish/fish_plugins` — run `fisher install` after |
| Zsh configs | `~/.zshrc`, `~/.zprofile`, `~/.profile` |
| Zsh history | `~/.zsh_history` |
| Starship prompt | `~/.config/starship.toml` |
| Ghostty config | `~/.config/ghostty/config` |
| Warp keybindings | `~/.warp/keybindings.yaml` |

---

## Git & Version Control

| What | Path / Action |
|---|---|
| Git config | `~/.gitconfig` |
| Global gitignore | `~/.gitignore_global` |
| Commit message template | `~/.stCommitMsg` |
| GPG key | `gpg --export-secret-keys --armor 8D4B6ED5 > gpg-key.asc` then import on new Mac |
| SSH keys | `~/.ssh/` (entire dir — `github_suho`, `id_ed25519_el`, `lgtv_webos`, `webos_emul`) |
| SSH config | `~/.ssh/config` |
| known_hosts | `~/.ssh/known_hosts` |
| git-lfs | Reinstall via brew |

---

## Developer Tools & Version Managers

| What | Path / Action |
|---|---|
| mise config | `~/.config/mise/config.toml` |
| mise tool versions | `~/.tool-versions` |
| Node global packages | Re-install: `firebase-tools`, `@webos-tools/cli`, `@qwen-code/qwen-code` |
| Ruby gems defaults | `~/.default-gems` |
| Cocoapods | Re-install via `gem install cocoapods` |
| pip packages | Run `pip3 freeze > requirements.txt` now to capture all packages |

**mise managed runtimes** (from `~/.config/mise/config.toml`):

```toml
tuist = "4.19.0"
python = "latest"
dotnet = "latest"
deno = "latest"
ruby = "3.1.2"
node = "latest"
uv = "latest"
lua = "5.1"
rust = "latest"
terraform = "latest"
go = "latest"
maven = "latest"
bun = "latest"
```

---

## Editors

### VS Code Insiders

| What | Path |
|---|---|
| Settings | `~/Library/Application Support/Code/User/settings.json` |
| Keybindings | `~/Library/Application Support/Code/User/keybindings.json` |
| Extensions | Re-install: `anthropic.claude-code`, `github.copilot-chat`, `openai.chatgpt` |

### Zed

| What | Path |
|---|---|
| Full config | `~/.config/zed/` (settings.json, themes, prompts, conversations) |

### Neovim

| What | Path |
|---|---|
| Full config | `~/.config/nvim/` |

---

## CLI Tool Configs

| Tool | Path |
|---|---|
| GitHub CLI (`gh`) | `~/.config/gh/` — re-auth: `gh auth login` |
| gcloud | `~/.config/gcloud/` |
| AWS CLI | `~/.aws/` |
| 1Password CLI | `~/.config/op/` |
| LazyGit | `~/.config/lazygit/` |
| btop | `~/.config/btop/` |
| AeroSpace | `~/.config/aerospace/aerospace.toml` |
| Raycast scripts | `~/me/raycast/` |
| actrc | `~/.actrc` |
| npmrc | `~/.npmrc` |
| yarnrc | `~/.yarnrc` |
| netrc | `~/.netrc` (contains tokens — handle carefully) |
| sentryclirc | `~/.sentryclirc` |
| lldbinit | `~/.lldbinit` |

---

## Apps with Local Data

| App | Path |
|---|---|
| Obsidian vault | `~/me/obsidian/vansuho/` (entire vault) |
| Postman | `~/Library/Application Support/Postman/` (workspace & collections) |
| TablePlus | `~/Library/Application Support/com.tinyapp.TablePlus/` (connections) |
| Proxyman | `~/Library/Application Support/com.proxyman.NSProxy/` (certificates, SSL scripts) |
| Claude Code | `~/.claude/` (settings, custom commands, memory, skills) |
| claude.json | `~/.claude.json` |
| LM Studio | `~/.lmstudio-home-pointer` + downloaded models |
| Warp | `~/Library/Application Support/dev.warp.Warp-Stable/` |

---

## Personal / Project Files

| What | Path |
|---|---|
| Developer projects | `~/Developer/` |
| Personal scripts | `~/me/files/` |
| Raycast scripts | `~/me/raycast/` |
| Exercism tracks | `~/Exercism/` |
| Fonts | `~/Library/Fonts/` (CascadiaCode family) |

---

## Credentials & Keys (Handle Carefully)

| What | Action |
|---|---|
| GPG key | `gpg --export-secret-keys --armor 8D4B6ED5 > gpg-key.asc` |
| SSH private keys | `~/.ssh/github_suho`, `~/.ssh/id_ed25519_el`, `~/.ssh/lgtv_webos`, `~/.ssh/webos_emul` |
| 1Password | Re-login on new machine (syncs from cloud) |
| AWS credentials | `~/.aws/credentials` |
| gcloud credentials | `~/.config/gcloud/credentials.db` |
| netrc tokens | `~/.netrc` |

---

## Misc / Don't Forget

| What | Notes |
|---|---|
| Xcode developer signing certs | Export from Keychain Access → "My Certificates" |
| Homebrew taps | Captured in `~/.Brewfile` |
| `terraform.tfstate` | `~/terraform.tfstate` — check if still active before copying |
| Fish plugins | After fisher: `fisher install jorgebucaran/fisher jethrokuan/z` |
| macOS System Preferences | Trackpad, keyboard repeat, Dock settings — manual setup |

---

## Quick Start Order on New Mac

1. Install Xcode Command Line Tools:
   ```sh
   xcode-select --install
   ```
2. Install Homebrew:
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Restore Homebrew packages:
   ```sh
   brew bundle --file ~/.Brewfile
   ```
4. Copy all config dirs listed above
5. Import GPG key:
   ```sh
   gpg --import gpg-key.asc
   ```
6. Set correct permissions on SSH keys:
   ```sh
   chmod 600 ~/.ssh/github_suho ~/.ssh/id_ed25519_el
   ```
7. Re-auth CLI tools:
   ```sh
   gh auth login
   gcloud auth login
   aws configure
   ```
8. Install mise runtimes:
   ```sh
   mise install
   ```
9. Install fish plugins:
   ```sh
   fisher install jorgebucaran/fisher jethrokuan/z
   ```
10. Sign in to apps: 1Password, Slack, Obsidian sync, Raycast, etc.
