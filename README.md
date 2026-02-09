# 🔄 Claude Code Switcher

> Fast CLI tool to switch Claude Code between LLM providers — supporting cloud and local models

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](CHANGELOG.md)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-green.svg)](https://github.com/claude-code-switcher)

## ✨ Features

- 🌐 **Cloud Providers:** Anthropic (Opus), Z.AI (GLM), DeepSeek, Kimi, SiliconFlow (Qwen), OpenRouter
- 🏠 **Local Providers:** Ollama, LM Studio
- ⚡ **Instant Switching:** Change models without manual reconfiguration
- 🔒 **Secure:** API keys stored with restricted permissions (chmod 600)
- 🎨 **Convenient Aliases:** One-word commands for each provider
- 💾 **Automatic Backups:** Settings backed up before every switch

## 🚀 Quick Install

### Option 1: Install from repository (recommended for development)

```bash
# Clone the repository
git clone https://github.com/renatoroquejani/claude-code-switcher.git
cd claude-code-switcher

# Run the installer
./scripts/install.sh
source ~/.bashrc  # or ~/.zshrc
```

### Option 2: Quick curl install

```bash
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/install.sh | bash
source ~/.bashrc  # or ~/.zshrc
```

### Uninstall

```bash
./scripts/uninstall.sh
```

## 📖 Documentation

- [Setup Guide](docs/SETUP.md) - Installation and configuration
- [Supported Providers](docs/PROVIDERS.md) - All providers with pricing and setup
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🎯 Basic Usage

```bash
# Switch to Claude (Anthropic official)
claude-switch claude

# Switch to Z.AI GLM
claude-switch zai              # or: claude-switch z.ai

# Switch to OpenRouter with specific model
claude-switch openrouter:anthropic/claude-opus-4

# Switch to local Ollama model
claude-switch ollama:qwen2.5-coder:7b

# Check current status
claude-switch status

# List all providers
claude-switch list

# Show model mapping for a provider
claude-switch models zai

# Show help
claude-switch help
```

## 🌐 Supported Providers

### Cloud (Paid)

| Provider | Command | Pricing | Model Mapping |
|----------|---------|---------|---------------|
| Claude | `claude-switch claude` | $20/month (Pro) | Opus/Sonnet/Haiku → Official |
| Z.AI | `claude-switch zai` | $15/month | Opus→4.7, Sonnet→4.7, Haiku→4.5-Flash |
| DeepSeek | `claude-switch deepseek` | $0.14/1M tokens | All tiers → deepseek-chat |
| Kimi | `claude-switch kimi` | Variable | Opus→128k, Sonnet→32k, Haiku→8k |
| Qwen | `claude-switch qwen` | $0.42/1M tokens | Opus→32B, Sonnet→14B, Haiku→7B |
| OpenRouter | `claude-switch openrouter:model` | Varies | User specified |

### Local (Free)

| Provider | Command | Setup |
|----------|---------|-------|
| Ollama | `claude-switch ollama:model` | https://ollama.com |
| LM Studio | `claude-switch lmstudio` | https://lmstudio.ai |

## 📦 Requirements

- Claude Code installed: `npm install -g @anthropic-ai/claude-code`
- `jq` for JSON manipulation: `sudo apt install jq` or `brew install jq`
- Bash or Zsh shell
- For local providers: Ollama or LM Studio running

## 🔑 API Keys Setup

After installation, configure your API keys:

```bash
# Edit the configuration file
nano ~/.claude/api-keys.env

# Add your keys (example)
export ZAI_API_KEY="your-zai-key"
export DEEPSEEK_API_KEY="your-deepseek-key"
export SILICONFLOW_API_KEY="your-siliconflow-key"
export OPENROUTER_API_KEY="your-openrouter-key"

# Reload shell
source ~/.bashrc
```

**Where to get API keys:** Run `claude-switch keys` for direct links to each provider.

## 🎨 Shell Aliases

After installation, you can use convenient aliases (created during install):

```bash
claude        # Switch to Claude (Anthropic)
zai           # Switch to Z.AI
deepseek      # Switch to DeepSeek
kimi          # Switch to Kimi
qwen          # Switch to Qwen
ollama        # Switch to Ollama
lmstudio      # Switch to LM Studio

# Status and info
cstatus       # Show current status (same as claude-switch status)
clist         # List all providers
cmodels       # Show model mapping for a provider

# Ollama model-specific
ollama7       # Switch to Ollama with qwen3-coder:7b
ollama14      # Switch to Ollama with qwen3-coder:14b
ollama32      # Switch to Ollama with qwen3-coder:32b
```

**Note:** These aliases are created by the installer when you choose to install them.

## 📁 Project Structure

```
claude-code-switcher/
├── bin/
│   └── claude-switch          # Main executable script
├── config/
│   ├── api-keys.env.example   # API key template
│   └── aliases.sh              # Shell aliases
├── docs/
│   ├── SETUP.md               # Installation guide
│   ├── PROVIDERS.md           # Provider documentation
│   └── TROUBLESHOOTING.md     # Troubleshooting guide
├── scripts/
│   ├── install.sh             # Automated installer
│   └── uninstall.sh           # Uninstaller
└── tests/
    └── test-providers.sh      # Provider tests
```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Quick steps:
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-provider`
3. Commit changes: `git commit -m "feat: add XYZ provider"`
4. Push and open a Pull Request

## 🐛 Troubleshooting

**"API key not configured"**
```bash
source ~/.claude/api-keys.env
claude-switch status
```

**"Ollama model not found"**
```bash
ollama list              # Check installed models
ollama pull qwen2.5-coder:7b  # Download a model
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

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

## 🗺️ Roadmap

- [ ] Auto-update via `claude-switch update`
- [ ] Interactive configuration wizard
- [ ] Homebrew formula (macOS)
- [ ] AUR package (Arch Linux)
- [ ] Support for more providers (Groq, Together AI)

## 📚 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## 🙏 Acknowledgments

Built for the Claude Code community to enable flexible LLM provider switching.

---

**Made with ❤️ by [Renato Roquejani](https://github.com/renatoroquejani)**

If you find this tool useful, please give it a ⭐ on GitHub!
