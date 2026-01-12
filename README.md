# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Machines

| Machine | OS | Type |
|---------|-----|------|
| jslay-arch | Arch Linux | Desktop |
| (laptop) | Arch Linux | Laptop |
| (macmini) | macOS | Mac Mini |

## Quick Start

### New Machine Setup

**One-liner install:**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jslay88
```

**Or manually:**

```bash
# Install chezmoi (Arch)
sudo pacman -S chezmoi
# OR via asdf
asdf plugin add chezmoi
asdf install chezmoi latest
asdf global chezmoi latest

# Install chezmoi (macOS)
brew install chezmoi

# Initialize from this repo
chezmoi init https://github.com/jslay88/dotfiles.git

# Preview changes
chezmoi diff

# Apply dotfiles
chezmoi apply -v
```

### Daily Usage

```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Push changes to repo
chezmoi cd
git add -A && git commit -m "Update dotfiles" && git push
exit

# Pull and apply latest from repo
chezmoi update
```

## Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl      # Config template (prompts for machine info)
├── .chezmoiignore          # Files to ignore per OS
├── dot_zshrc.tmpl          # ZSH config (templated for OS)
├── dot_gitconfig.tmpl      # Git config (templated)
├── dot_gitconfig-personal.tmpl
├── dot_gitconfig-work.tmpl
├── dot_gitignore           # Global gitignore
├── dot_zsh/
│   ├── themes/gallois.zsh  # Custom ZSH theme
│   └── plugins/.keep       # Plugins installed via bootstrap
├── private_dot_zsh/
│   └── private_secrets/    # Secrets directory (empty, local only)
├── private_dot_config/
│   └── ghostty/config      # Ghostty terminal (Linux only)
├── run_once_install-packages.sh.tmpl  # Bootstrap script
├── README.md
└── SECRETS.md              # Secrets documentation
```

## Templating

Chezmoi uses Go templates for conditional logic:

```go
{{- if .isLinux }}
# Linux-specific config
{{- else if .isMacOS }}
# macOS-specific config
{{- end }}

{{- if .isDesktop }}
# Desktop-specific config
{{- end }}
```

### Available Variables

| Variable | Description |
|----------|-------------|
| `.machineType` | `desktop`, `laptop`, or `macmini` |
| `.isLinux` | `true` on Linux |
| `.isMacOS` | `true` on macOS |
| `.isArch` | `true` on Arch Linux |
| `.isDesktop` | `true` if machine type is desktop |
| `.isLaptop` | `true` if machine type is laptop |
| `.isMacMini` | `true` if machine type is macmini |
| `.personalName` | Personal git username |
| `.personalEmail` | Personal git email |
| `.personalSigningKey` | Personal GPG key ID |
| `.hasWorkConfig` | `true` if work config enabled |
| `.workName` | Work git username |
| `.workEmail` | Work git email |
| `.workDir` | Work projects directory path |

View all variables: `chezmoi data`

## Secrets

**No secrets are stored in this repository.** See [SECRETS.md](SECRETS.md) for details.

- ZSH secrets: `~/.zsh/secrets/` (sourced automatically)
- Git config: Prompted during `chezmoi init`
- Age encryption: Optional for synced secrets

## Requirements

- zsh
- git
- neovim (or change `$EDITOR`)
- GPG (for commit signing)

The bootstrap script installs these automatically.

## License

MIT
