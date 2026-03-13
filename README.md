# Claude Code Switcher

> Fast CLI tool to switch Claude Code between LLM providers - supporting cloud and local models

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.3.1-blue.svg)](CHANGELOG.md)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-green.svg)](https://github.com/renatoroquejani/claude-code-switcher)

## Features

- **Cloud Providers:** Anthropic (Opus), Anthropic API, Z.AI (GLM), DeepSeek, Kimi, SiliconFlow (Qwen), Groq, Together AI, OpenRouter
- **Local Providers:** Ollama, LM Studio
- **Instant Switching:** Change models without manual reconfiguration
- **Multi-Account Foundation:** Track multiple Claude instances with isolated state directories
- **Named Profiles:** Reapply saved account/provider/scope combos in one command
- **Custom Providers:** Register additional Anthropic-compatible endpoints without editing the script
- **Interactive Wizard:** Guided setup for first-time users
- **Auto-Update:** Built-in update mechanism to stay current
- **Versioned Provider Catalog:** Provider presets live in `providers.json` and can be refreshed separately
- **Package Management:** Ready for AUR and Homebrew distribution (internal use)
- **Secure:** API keys stored with restricted permissions (chmod 600)
- **Automatic Backups:** Settings backed up before every switch
- **Convenient Aliases:** One-word commands for each provider
- **Tested:** Comprehensive test suite with unit and integration tests

## Quick Install

```bash
# Quick curl install (one-liner)
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/install.sh | bash
source ~/.bashrc  # or ~/.zshrc

# OR install from repository
git clone https://github.com/renatoroquejani/claude-code-switcher.git
cd claude-code-switcher
./scripts/install.sh
source ~/.bashrc  # or ~/.zshrc
```

### Uninstall

```bash
./scripts/uninstall.sh
```

The uninstaller preserves your existing `~/.claude` Claude Code directory, backs up `~/.claude/settings.json`, cleans only the routing keys managed by `claude-switcher`, and only offers removal of `~/.claude-switcher` state.

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

# Switch without confirmation prompts
claude-switch --yes zai

# Apply a project-local override in .claude/settings.local.json
claude-switch project zai
claude-switch global claude
claude-switch where
claude-switch reset project

# Run environment diagnostics
claude-switch doctor
claude-switch doctor --json

# Interactive setup wizard
claude-switch wizard

# Update to latest version
claude-switch update
claude-switch update-config

# Check current status
claude-switch status

# List accounts and switch the active account
claude-switch account list
claude-switch account create work
claude-switch account use work
claude-switch account login work
claude-switch account test work

# Save and reuse a named profile
claude-switch profile save work-zai --provider zai
claude-switch profile save work-zai --provider zai --yes
claude-switch profile list
claude-switch profile use work-zai

# Register a custom provider
claude-switch provider add acme --base-url https://acme.example/api/anthropic --auth-env ACME_API_KEY --mapping fixed --opus acme-opus --sonnet acme-sonnet --haiku acme-haiku
claude-switch provider list
claude-switch provider delete acme
claude-switch models acme

# Launch Claude for the active account
claude-switch exec -- -p "hello"
claude-switch exec zai -- -p "use Z.AI for this session"
claude-switch exec --yes zai -- -p "use Z.AI without prompts"

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
| Z.AI | `claude-switch zai` | $15/month | Provider-managed |
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

## Accounts

Phase 1 introduces account-aware state management.

- `default` points to your existing `~/.claude` directory, so current single-account behavior keeps working
- new accounts live under `~/.claude-switcher/instances/<name>`
- provider switches always target the active account
- `claude-switch exec` launches Claude with the correct runtime for the active account
- `claude-switch project <provider>` writes a local override to `.claude/settings.local.json`
- `claude-switch global <provider>` updates the active account global settings
- `claude-switch where` shows which file is effective in the current directory
- `claude-switch doctor` validates the active account, settings files, auth state, and local runtimes
- provider presets are stored in `~/.claude-switcher/providers.json`
- custom providers are stored in `~/.claude-switcher/custom-providers.json`
- saved profiles are stored in `~/.claude-switcher/profiles.json`

Examples:

```bash
claude-switch account list
claude-switch account create work
claude-switch account import-current personal
claude-switch account use work
claude-switch account login work
claude-switch account test work
claude-switch profile save work-zai --provider zai
claude-switch profile save work-zai --provider zai --yes
claude-switch profile use work-zai
claude-switch provider add acme --base-url https://acme.example/api/anthropic --auth-env ACME_API_KEY --mapping fixed --opus acme-opus --sonnet acme-sonnet --haiku acme-haiku
claude-switch provider list
claude-switch provider delete acme
claude-switch project zai
claude-switch global claude
claude-switch where
claude-switch reset project
claude-switch doctor
claude-switch doctor --json
claude-switch update-config
claude-switch exec -- -p "hello from the active account"
claude-switch exec zai -- -p "switch provider and launch"
claude-switch status
```

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
cs-update-config  # Refresh provider presets
cs-wizard    # Run configuration wizard
cs-exec      # Launch Claude for the active account
cs-accounts  # List accounts
cs-profiles  # List profiles
cs-providers # List custom providers
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
│   ├── aliases.sh             # Shell aliases
│   └── providers.json         # Provider preset catalog
├── ~/.claude-switcher/
│   ├── accounts.json          # Account registry
│   ├── custom-providers.json  # Custom provider registry
│   ├── instances/             # Isolated Claude runtime directories
│   ├── profiles.json          # Saved account/provider profiles
│   ├── providers.json         # Installed provider preset catalog
│   └── state.json             # Active account pointer
├── dist/
│   ├── arch/                  # AUR package (internal use)
│   └── homebrew/              # Homebrew formula (internal use)
├── docs/
│   ├── SETUP.md               # Installation guide
│   ├── PROVIDERS.md           # Provider documentation
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

Completed in v2.3.1:
- [x] Multi-account Claude runtimes
- [x] Account login/import/test flows
- [x] `exec` launcher with isolated runtime selection
- [x] Global and project-scoped switching
- [x] `doctor` diagnostics and JSON output
- [x] Versioned provider catalog with `update-config`
- [x] Named profiles and custom providers

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
