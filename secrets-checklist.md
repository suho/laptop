# Secrets & Credentials Checklist

> These items contain sensitive data and are NOT exported. Restore manually on the new Mac.

## SSH Keys (copy manually or regenerate)

- [ ] `~/.ssh/github_suho` - GitHub SSH key
- [ ] `~/.ssh/id_ed25519_el` - Ed25519 key
- [ ] `~/.ssh/lgtv_webos` - LG TV WebOS key
- [ ] `~/.ssh/webos_emul` - WebOS emulator key
- [ ] `~/.ssh/known_hosts` - Known hosts file

After copying, fix permissions:
```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 ~/.ssh/*.pub ~/.ssh/config ~/.ssh/known_hosts
```

## GPG Keys

- [ ] Export: `gpg --export-secret-keys --armor 8D4B6ED5 > gpg-key.asc`
- [ ] Import: `gpg --import gpg-key.asc`
- [ ] Trust: `gpg --edit-key 8D4B6ED5` then `trust` -> `5` -> `quit`

## CLI Authentication

- [ ] `gh auth login` - GitHub CLI

## Config Files with Tokens

- [ ] `~/.npmrc` - May contain npm tokens
- [ ] `~/.sentryclirc` - Sentry auth token
- [ ] `~/.config/gh/hosts.yml` - GitHub CLI tokens

## App Sign-ins

- [ ] 1Password - Sign in (syncs from cloud)
- [ ] Slack - Sign in to workspaces
- [ ] Telegram - Sign in
- [ ] Obsidian - Sign in for sync
- [ ] Raycast - Sign in (syncs from cloud)

## Other

- [ ] Xcode signing certificates: Export from Keychain Access -> "My Certificates"
- [ ] LM Studio models: Download fresh or copy from `~/.lmstudio/`
