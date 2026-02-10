# Setup Guide

Complete installation and configuration guide for Claude Code Switcher.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Install](#quick-install)
- [Manual Install](#manual-install)
- [Interactive Wizard](#interactive-wizard)
- [Auto-Update](#auto-update)
- [Verification](#verification)
- [Configuration](#configuration)
- [Uninstallation](#uninstallation)

---

## Prerequisites

Before installing, ensure you have:

- **Claude Code** installed globally:
  ```bash
  npm install -g @anthropic-ai/claude-code
  ```

- **jq** for JSON processing:
  ```bash
  # Ubuntu/Debian
  sudo apt install jq

  # macOS
  brew install jq

  # Arch Linux
  sudo pacman -S jq
  ```

- **Bash or Zsh** shell
- **curl** or **wget** for downloading files

---

## Quick Install

The fastest way to install Claude Code Switcher:

```bash
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/install.sh | bash
source ~/.bashrc  # or source ~/.zshrc
```

The installer will:
1. Download the `claude-switch` script to `~/.local/bin/`
2. Create the configuration directory `~/.claude/`
3. Set up the API keys template
4. Add shell aliases to your `~/.bashrc` or `~/.zshrc`

---

## Manual Install

If you prefer manual installation or the quick install fails:

### Step 1: Clone the Repository

```bash
git clone https://github.com/renatoroquejani/claude-code-switcher.git
cd claude-code-switcher
```

### Step 2: Install the Script

```bash
# Copy the main script
cp bin/claude-switch ~/.local/bin/

# Make it executable
chmod +x ~/.local/bin/claude-switch

# Verify installation
claude-switch --version
```

### Step 3: Configure API Keys

```bash
# Copy the example configuration
cp config/api-keys.env.example ~/.claude/api-keys.env

# Edit with your API keys
nano ~/.claude/api-keys.env
# or use: code ~/.claude/api-keys.env
```

Add your API keys:

```bash
# Cloud Providers
export GLM_API_KEY="your-glm-key-here"
export DEEPSEEK_API_KEY="your-deepseek-key-here"
export KIMI_API_KEY="your-kimi-key-here"
export SILICONFLOW_API_KEY="your-siliconflow-key-here"
export OPENROUTER_API_KEY="your-openrouter-key-here"
export ANTHROPIC_API_KEY="your-anthropic-key-here"

# Optional: Set default OpenRouter model
export OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4.6"
```

**Secure the file:**
```bash
chmod 600 ~/.claude/api-keys.env
```

### Step 4: Source in Shell

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Load API keys
if [ -f ~/.claude/api-keys.env ]; then
  source ~/.claude/api-keys.env
fi
```

Then reload:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Step 5: Add Aliases (Optional)

For convenience, add the aliases to your shell config:

```bash
# Add to ~/.bashrc or ~/.zshrc
source /path/to/claude-code-switcher/config/aliases.sh
```

---

## Interactive Wizard

New in v2.2.0, the interactive wizard provides step-by-step guidance for first-time setup.

```bash
claude-switch wizard
```

The wizard will guide you through:

1. **Welcome Screen**: Introduction to Claude Code Switcher
2. **Provider Selection**: Choose which providers you want to configure
3. **API Key Entry**: Enter API keys for selected providers
4. **Validation**: Verify that API keys are properly formatted
5. **Test Connection**: Optionally test provider connectivity
6. **Shell Aliases**: Optionally install convenient shell aliases
7. **Completion**: Summary of configured providers

### Wizard Features

- **Smart Defaults**: Remembers your choices for future runs
- **Validation**: Checks API key format before saving
- **Auto-Detection**: Detects installed local providers (Ollama, LM Studio)
- **Safe Mode**: Creates backups before modifying any configuration

### Example Wizard Session

```bash
$ claude-switch wizard

Welcome to Claude Code Switcher setup wizard!
This wizard will help you configure your LLM providers.

? Which providers would you like to configure? (Space to select, Enter to continue)
  ☑ Anthropic Claude (OAuth - no API key needed)
  ☐ Anthropic API (API key required)
  ☑ Z.AI (GLM models)
  ☐ DeepSeek
  ☑ OpenRouter

? Enter your Z.AI API key: ****************************
? Enter your OpenRouter API key: ****************************

✅ Configuration saved successfully!
✅ 3 providers configured

Next steps:
  - Run: claude-switch list
  - Try: claude-switch zai
  - Help: claude-switch help
```

---

## Auto-Update

New in v2.2.0, Claude Code Switcher can automatically check for and install updates.

### Check for Updates

```bash
claude-switch check-update
```

This will:
- Check the latest version available on GitHub
- Compare with your installed version
- Inform you if an update is available

### Update to Latest Version

```bash
claude-switch update
```

This will:
- Download the latest version from GitHub
- Replace the current script
- Preserve your configuration and API keys
- Show you what's new in the update

### Automatic Update Checks

You can enable automatic update checks by adding to your `~/.bashrc` or `~/.zshrc`:

```bash
# Check for updates daily (runs in background)
if [ -f ~/.local/bin/claude-switch ]; then
  ~/.local/bin/claude-switch check-update --quiet &
fi
```

### Update Channels

By default, updates are pulled from the `main` branch. To use a different channel:

```bash
# Use development branch
export CLAUDE_SWITCH_CHANNEL="develop"

# Use specific repository
export CLAUDE_SWITCH_REPO="your-fork/claude-code-switcher"
```

---

## Verification

After installation, verify everything works:

```bash
# Check version
claude-switch --version

# Show help
claude-switch help

# List all providers
claude-switch list

# Check current status
claude-switch status
```

Expected output:
```
Claude Code Model Switcher v2.2.0

Status:
  Provider: Anthropic Claude (Opus 4.6)
  Opus Model: claude-opus-4-6
  Sonnet Model: claude-sonnet-4-5-20250929
  Haiku Model: claude-haiku-4-20250920
```

---

## Configuration

### Getting API Keys

Run `claude-switch keys` to see where to get API keys for each provider:

```bash
claude-switch keys
```

This will display:
- Direct links to API key pages
- Pricing information
- Setup instructions for each provider

### Setting Default Model (OpenRouter)

To avoid specifying the model every time with OpenRouter:

```bash
# Edit ~/.claude/api-keys.env
nano ~/.claude/api-keys.env

# Add your preferred default model
export OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4.6"
```

Then you can simply run:
```bash
claude-switch openrouter  # Uses default model
```

### Local Providers Setup

#### Ollama

1. Install Ollama:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

2. Start the server:
   ```bash
   ollama serve
   ```

3. Download a model:
   ```bash
   ollama pull qwen3-coder:7b
   ```

4. Switch to use it:
   ```bash
   claude-switch ollama:qwen3-coder:7b
   ```

#### LM Studio

1. Download from https://lmstudio.ai/
2. Open LM Studio and load a model
3. Go to "Local Server" tab
4. Click "Start Server"
5. Switch to use it:
   ```bash
   claude-switch lmstudio
   ```

---

## Uninstallation

To completely remove Claude Code Switcher:

### Using the Uninstall Script

```bash
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/uninstall.sh | bash
```

### Manual Uninstall

```bash
# Remove the script
rm ~/.local/bin/claude-switch

# Remove configuration (optional - keeps your API keys)
rm -rf ~/.claude/api-keys.env

# Remove aliases from ~/.bashrc or ~/.zshrc
# Edit the file and remove the claude-switch section
```

---

## Next Steps

- [Browse Supported Providers](PROVIDERS.md) - Learn about all available providers
- [Troubleshooting](TROUBLESHOOTING.md) - Solve common issues
- [Usage Examples](../README.md#-basic-usage) - See practical examples

---

## Still Having Issues?

1. Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Open an issue on GitHub: https://github.com/renatoroquejani/claude-code-switcher/issues
3. Include:
   - Your OS and shell
   - Output of `claude-switch status`
   - Output of `claude --version`
   - Full error message
