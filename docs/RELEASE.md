# Release Notes

Version-specific release information for Claude Code Switcher.

## [2.2.0] - 2025-02-10

### What's New

This release focuses on improving user experience with interactive setup and automated updates.

### New Features

#### Interactive Configuration Wizard
- **New command**: `claude-switch wizard`
- Step-by-step guided setup for first-time users
- Provider selection with multi-select interface
- API key entry with validation
- Auto-detection of local providers (Ollama, LM Studio)
- Optional shell alias installation
- Remembers preferences for future runs

#### Auto-Update Functionality
- **New command**: `claude-switch update`
- Automatically checks for and installs latest version
- **New command**: `claude-switch check-update`
- Checks if newer version is available
- Preserves configuration during updates
- Configurable update channels (main, develop)
- Support for custom repositories

#### Anthropic API Key Support
- **New provider**: `anthropic-api`
- Use Claude with API key instead of OAuth
- Same quality as official Claude
- Pay-as-you-go pricing
- Useful for team accounts and enterprise

#### Groq Provider
- **New provider**: `groq`
- Ultra-fast inference with purpose-built infrastructure
- Generous free tier for development
- Meta Llama and Mistral models available
- Ideal for speed-critical applications

#### Together AI Provider
- **New provider**: `together`
- Access to 100+ open-source models
- Competitive pricing with no monthly fees
- Fast inference on optimized infrastructure
- Great for testing different open-source models

#### Package Management Support
- **AUR Package**: Arch Linux users can install via `yay -S claude-code-switcher`
- **Homebrew Formula**: macOS users can install via `brew install claude-code-switcher`
- Easy installation and updates via package managers
- Automatic dependency handling

#### Comprehensive Test Suite
- Full test coverage with unit and integration tests
- Automated testing for all providers
- Continuous integration support
- Easy testing for contributors

#### Enhanced Model Mapping
- Improved Ollama model mapping for all three tiers
- Better OpenRouter model handling
- Fallback logic for unavailable local models
- Per-tier model configuration support

#### Configuration Management
- **New command**: `claude-switch validate`
- Validates current configuration for errors
- **New command**: `claude-switch restore`
- Restore from previous backups
- List available backups
- Timestamped backup files

### Improvements

- **Better error messages** with suggested fixes
- **Improved local provider detection**
- **Enhanced shell compatibility** (Bash/Zsh)
- **Better path detection** across environments
- **Improved validation** for API keys
- **Enhanced security** for sensitive files

### Bug Fixes

- **Fixed Ollama model mapping**: Now correctly sets all three tiers (Opus, Sonnet, Haiku)
- **Fixed OpenRouter silent failures**: Proper output messages and error handling
- **Fixed LM Studio connection**: Improved connection handling and retries
- **Fixed shell compatibility**: Better support for both Bash and Zsh
- **Fixed path detection**: Improved detection of Claude Code settings path

### Security

- API keys now validated for proper format before use
- All sensitive files enforce chmod 600
- Backup directory uses chmod 700
- Safer temporary file handling

### Breaking Changes

None. This release is fully backward compatible with v2.1.0.

### Migration Notes

No migration needed. Existing configurations work as-is.

### Upgrade Instructions

```bash
# Using auto-update
claude-switch update

# Or manual reinstall
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/install.sh | bash
source ~/.bashrc
```

### Developer Notes

- Added `run_wizard()` function for interactive setup
- Added `check_updates()` and `perform_update()` functions
- Added `validate_config()` function
- Added `restore_backup()` function
- Refactored model mapping into separate functions per provider
- Improved error handling with context-aware messages

---

## [2.1.0] - 2025-02-09

### What's New

Focus on better visibility into provider configurations and model mappings.

### New Features

- **Model mapping display**: `claude-switch models <provider>`
- **Enhanced help text**: Better examples and explanations
- **API key documentation**: `claude-switch keys` command
- **Ollama auto-detection**: Detects installed models
- **Tiered model support**: Proper Opus/Sonnet/Haiku tiers

### Improvements

- Added `z.ai` as alias for `zai` provider
- Enhanced status display with model information
- Improved list command with Ollama models

### Bug Fixes

- Fixed provider detection from settings.json
- Corrected Qwen model names (Qwen2.5-Coder)
- Fixed color output issues in some terminals

---

## [2.0.0] - 2025-02-09

### What's New

Major release with multi-provider support and enhanced UX.

### New Features

- **8 Provider Support**:
  - Cloud: Anthropic (Opus), Z.AI (GLM), DeepSeek, Kimi, Qwen, OpenRouter
  - Local: Ollama, LM Studio

- **Automatic Backups**: Settings backed up before every switch
- **Shell Aliases**: Convenient one-word commands
- **API Key Management**: Secure storage and loading
- **Configuration Validation**: Pre-flight checks for all providers
- **Local Provider Checks**: Validates Ollama/LM Studio before switching

### Improvements

- Complete rewrite with modular architecture
- Color-coded output
- Clear success/error messages
- Automatic provider detection

---

## [1.0.0] - 2025-02-08

### Initial Release

- Basic provider switching between Anthropic Opus and Z.AI GLM
- Simple command-line interface
- Configuration file modification

---

## Version Summary

| Version | Date | Key Features |
|---------|------|--------------|
| 2.2.0 | 2025-02-10 | Wizard, auto-update, Anthropic API, Groq, Together AI, AUR, Homebrew, test suite |
| 2.1.0 | 2025-02-09 | Model mapping display, enhanced help, Ollama auto-detection |
| 2.0.0 | 2025-02-09 | Multi-provider support, backups, shell aliases |
| 1.0.0 | 2025-02-08 | Initial release with basic switching |

---

## Upgrade Path

All versions are backward compatible. To upgrade:

```bash
# Check current version
claude-switch --version

# Check for updates
claude-switch check-update

# Update to latest
claude-switch update
```

For manual upgrades or issues with auto-update:

```bash
curl -fsSL https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main/scripts/install.sh | bash
```

---

## Support

For issues with a specific release:
- Check [Troubleshooting](TROUBLESHOOTING.md)
- Search [GitHub Issues](https://github.com/renatoroquejani/claude-code-switcher/issues)
- Open a new issue with version information

When reporting issues, include:
- Output of `claude-switch --version`
- Your OS and shell version
- Full error message
- Steps to reproduce
