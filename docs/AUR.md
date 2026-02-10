# AUR Installation Guide

This guide covers installing `claude-code-switcher` from the Arch User Repository (AUR).

## Prerequisites

- Arch Linux or Arch-based distribution
- `base-devel` package group installed
- `yay` or `paru` (AUR helper) - optional but recommended

## Installation

### Using an AUR Helper (Recommended)

#### With yay
```bash
yay -S claude-code-switcher
```

#### With paru
```bash
paru -S claude-code-switcher
```

### Manual Installation

```bash
# Clone the AUR repository
git clone https://aur.archlinux.org/claude-code-switcher.git
cd claude-code-switcher

# Build and install
makepkg -si
```

## Post-Installation

### Configure API Keys

The package installs a template configuration file at `/etc/claude-code-switcher/api-keys.env.example`. Copy it to your home directory:

```bash
mkdir -p ~/.claude
cp /etc/claude-code-switcher/api-keys.env.example ~/.claude/api-keys.env
chmod 600 ~/.claude/api-keys.env
```

Edit the file and add your API keys:

```bash
nano ~/.claude/api-keys.env
```

### Load API Keys in Your Shell

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Claude Code Switcher
if [ -f ~/.claude/api-keys.env ]; then
  source ~/.claude/api-keys.env
fi
```

Then reload your shell:

```bash
source ~/.bashrc  # or source ~/.zshrc
```


## Usage

```bash
# Show help
claude-switch help

# List available providers
claude-switch list

# Switch to Anthropic Claude
claude-switch claude

# Switch to Z.AI GLM
claude-switch zai

# Switch to Ollama with specific model
claude-switch ollama:qwen3-coder:7b

# Switch to OpenRouter with specific model
claude-switch openrouter:anthropic/claude-opus-4.6

# Show current configuration
claude-switch status
```

## Shell Completion

The package includes bash and zsh completion files. They are automatically installed to:

- Bash: `/usr/share/bash-completion/completions/claude-switch`
- Zsh: `/usr/share/zsh/site-functions/_claude-switch`

Completions should work automatically after installation or after reloading your shell.

## Uninstalling

### With an AUR Helper

```bash
yay -Rns claude-code-switcher
# or
paru -Rns claude-code-switcher
```

### Manually

```bash
# Remove package
sudo pacman -Rns claude-code-switcher

# Optionally remove your configuration
rm -rf ~/.claude/api-keys.env

# Remove shell aliases (edit your ~/.bashrc or ~/.zshrc)
```

## Available Dependencies

### Required Dependencies

- `bash` - The script is written in Bash
- `jq` - JSON processor for manipulating Claude Code settings

### Optional Dependencies

- `git` - For auto-update feature

## Troubleshooting

### Command Not Found

If `claude-switch` is not found after installation:

1. Make sure `/usr/bin` is in your PATH:
   ```bash
   echo $PATH | grep -q /usr/bin || echo 'export PATH="/usr/bin:$PATH"' >> ~/.bashrc
   ```

2. Log out and log back in, or reload your shell:
   ```bash
   source ~/.bashrc
   ```

### Completions Not Working

1. **For Bash**, ensure `bash-completion` is installed:
   ```bash
   sudo pacman -S bash-completion
   ```

2. **For Zsh**, ensure completion system is enabled in your `~/.zshrc`:
   ```bash
   autoload -U compinit && compinit
   ```

### Permission Denied

If you get a permission error when running `claude-switch`:

```bash
# Fix permissions
sudo chmod 755 /usr/bin/claude-switch
```

## Getting Help

- Project repository: https://github.com/renatobohler/claude-code-switcher
- AUR package page: https://aur.archlinux.org/packages/claude-code-switcher
- Report issues: https://github.com/renatobohler/claude-code-switcher/issues

## License

This package is licensed under the MIT License. See `/usr/share/licenses/claude-code-switcher/LICENSE` for details.
