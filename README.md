# Claude Code Switcher

> Fast CLI tool to switch Claude Code between LLM providers - supporting cloud and local models

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.2.0-blue.svg)](CHANGELOG.md)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-green.svg)](https://github.com/renatoroquejani/claude-code-switcher)

## Features

- **Cloud Providers:** Anthropic (Opus), Anthropic API, Z.AI (GLM), DeepSeek, Kimi, SiliconFlow (Qwen), Groq, Together AI, OpenRouter
- **Local Providers:** Ollama, LM Studio
- **Instant Switching:** Change models without manual reconfiguration
- **Interactive Wizard:** Guided setup for first-time users
- **Auto-Update:** Built-in update mechanism to stay current
- **Package Management:** Available via AUR (Arch) and Homebrew (macOS)
- **Secure:** API keys stored with restricted permissions (chmod 600)
- **Automatic Backups:** Settings backed up before every switch
- **Convenient Aliases:** One-word commands for each provider
- **Tested:** Comprehensive test suite with unit and integration tests

## Quick Install

### Quick curl install

```bash
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/install.sh | bash
source ~/.bashrc  # or ~/.zshrc
```

### Install from repository

```bash
# Clone the repository
git clone https://github.com/renatoroquejani/claude-code-switcher.git
cd claude-code-switcher

# Run the installer
./scripts/install.sh
source ~/.bashrc  # or ~/.zshrc
```

### Uninstall

```bash
./scripts/uninstall.sh
```

## Documentation

- [Setup Guide](docs/SETUP.md) - Installation and configuration
- [Supported Providers](docs/PROVIDERS.md) - All providers with pricing and setup
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Release Notes](docs/RELEASE.md) - Version-specific release information

## Basic Usage

```bash
# Switch to Claude (Anthropic official/OAuth)
claude-switch claude

# Switch to Anthropic with API key (pay-as-you-go)
claude-switch anthropic-api

# Switch to Z.AI GLM
claude-switch zai              # or: claude-switch z.ai

# Switch to Groq (ultra-fast inference)
claude-switch groq

# Switch to Together AI
claude-switch together

# Switch to OpenRouter with specific model
claude-switch openrouter:anthropic/claude-opus-4

# Switch to local Ollama model
claude-switch ollama:qwen3-coder:7b

# Interactive setup wizard
claude-switch wizard

# Update to latest version
claude-switch update

# Check current status
claude-switch status

# List all providers
claude-switch list

# Show model mapping for a provider
claude-switch models zai

# Show where to get API keys
claude-switch keys

# Show help
claude-switch help
```

## Supported Providers

### Cloud (Paid)

| Provider | Command | Pricing | Model Mapping |
|----------|---------|---------|---------------|
| Claude | `claude-switch claude` | $20/month (Pro) | Opus/Sonnet/Haiku → Official |
| Claude API | `claude-switch anthropic-api` | Per-use | Opus/Sonnet/Haiku → Official |
| Z.AI | `claude-switch zai` | $15/month | Opus→4.7, Sonnet→4.6, Haiku→4.5-Flash |
| DeepSeek | `claude-switch deepseek` | $0.14/1M tokens | All tiers → deepseek-chat |
| Kimi | `claude-switch kimi` | Variable | Opus→128k, Sonnet→32k, Haiku→8k |
| Qwen | `claude-switch qwen` | $0.42/1M tokens | Opus→32B, Sonnet→14B, Haiku→7B |
| Groq | `claude-switch groq` | Free tier available | Opus/Sonnet→Llama 3.3 70B, Haiku→Mixtral 8x7B |
| Together AI | `claude-switch together` | Per-use | User specified |
| OpenRouter | `claude-switch openrouter:model` | Varies | User specified |

### Local (Free)

| Provider | Command | Setup |
|----------|---------|-------|
| Ollama | `claude-switch ollama:model` | https://ollama.com |
| LM Studio | `claude-switch lmstudio` | https://lmstudio.ai |

## Requirements

- Claude Code installed: `npm install -g @anthropic-ai/claude-code`
- `jq` for JSON manipulation: `sudo apt install jq` or `brew install jq`
- Bash or Zsh shell
- For local providers: Ollama or LM Studio running

## API Keys Setup

After installation, configure your API keys:

```bash
# Edit the configuration file
nano ~/.claude/api-keys.env

# Add your keys (example)
export ZAI_API_KEY="your-zai-key"
export DEEPSEEK_API_KEY="your-deepseek-key"
export KIMI_API_KEY="your-kimi-key"
export SILICONFLOW_API_KEY="your-siliconflow-key"
export GROQ_API_KEY="your-groq-key"
export TOGETHER_API_KEY="your-together-key"
export OPENROUTER_API_KEY="your-openrouter-key"
export ANTHROPIC_API_KEY="your-anthropic-key"  # For anthropic-api provider

# Reload shell
source ~/.bashrc
```

**Where to get API keys:** Run `claude-switch keys` for direct links to each provider.

## Shell Aliases

After installation, you can use convenient aliases (created during install):

**Provider Switching (all end with `-switch` to avoid conflicts):**

```bash
claude-switch              # Switch to Anthropic (OAuth)
anthropic-api-switch      # Switch to Anthropic (API key)
zai-switch                 # Switch to Z.AI
deepseek-switch            # Switch to DeepSeek
kimi-switch                # Switch to Kimi
qwen-switch                # Switch to Qwen
groq-switch                # Switch to Groq
together-switch            # Switch to Together AI
openrouter-switch          # Switch to OpenRouter
ollama-switch [model]      # Switch to Ollama
lmstudio-switch            # Switch to LM Studio
```

**Status & Info (prefixed with `cs-`):**

```bash
cs-status    # Show current status
cs-list      # List all providers
cs-models    # Show model mapping
cs-keys      # Show where to get API keys
cs-help      # Show help
cs-update    # Update to latest version
cs-wizard    # Run configuration wizard
```

**Ollama Quick Switches:**

```bash
ollama7     # Switch to Ollama with qwen3-coder:7b
ollama14    # Switch to Ollama with qwen3-coder:14b
ollama32    # Switch to Ollama with qwen3-coder:32b
```

**Note:** These aliases are created by the installer when you choose to install them.

## Project Structure

```
claude-code-switcher/
├── bin/
│   └── claude-switch          # Main executable script
├── config/
│   ├── api-keys.env.example   # API key template
│   └── aliases.sh              # Shell aliases
├── dist/
│   ├── arch/                  # AUR package (Arch Linux)
│   └── homebrew/              # Homebrew formula (macOS)
├── docs/
│   ├── SETUP.md               # Installation guide
│   ├── PROVIDERS.md           # Provider documentation
│   ├── AUR.md                 # AUR installation guide
│   ├── TROUBLESHOOTING.md     # Troubleshooting guide
│   └── RELEASE.md             # Release notes
├── scripts/
│   ├── install.sh             # Automated installer
│   ├── uninstall.sh           # Uninstaller
│   ├── config-wizard.sh       # Interactive setup wizard
│   └── update.sh              # Auto-update script
└── tests/
    ├── test-suite.sh          # Main test runner
    ├── unit/                  # Unit tests
    └── integration/           # Integration tests
```

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Quick steps:
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-provider`
3. Commit changes: `git commit -m "feat: add XYZ provider"`
4. Push and open a Pull Request

## Troubleshooting

**"API key not configured"**
```bash
source ~/.claude/api-keys.env
claude-switch status
```

**"Ollama model not found"**
```bash
ollama list              # Check installed models
ollama pull qwen3-coder:7b  # Download a model
ollama serve             # Start Ollama server
```

**"Command not found: claude-switch"**
```bash
# Check PATH
echo $PATH | grep ".local/bin"

# Add to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

For more troubleshooting, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## License

MIT License - see [LICENSE](LICENSE) for details.

## Roadmap

Completed in v2.2.0:
- [x] Groq provider support
- [x] Together AI provider support
- [x] Interactive configuration wizard
- [x] Auto-update functionality
- [x] Comprehensive test suite

Future plans:
- [ ] Web-based configuration interface
- [ ] Support for more providers (Mistral, Cohere)
- [ ] Usage telemetry (opt-in)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Acknowledgments

Built for the Claude Code community to enable flexible LLM provider switching.

---

**Made with love by [Renato Roquejani](https://github.com/renatoroquejani)**

If you find this tool useful, please give it a star on GitHub!
