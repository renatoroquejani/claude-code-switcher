# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Web-based configuration interface
- Usage telemetry (opt-in)
- Support for additional providers (Mistral, Cohere)

## [2.2.0] - 2025-02-10

### Added
- **Interactive Configuration Wizard**: New `claude-switch wizard` command provides step-by-step guided setup for first-time users
- **Auto-Update Functionality**: New `claude-switch update` command automatically checks for and installs the latest version
- **Anthropic API Key Support**: New `anthropic-api` provider allows using Anthropic Claude with an API key instead of OAuth
- **Groq Provider**: New `groq` provider for ultra-fast inference with generous free tier
- **Together AI Provider**: New `together` provider for access to 100+ open-source models
- **Enhanced Model Mapping**: Improved model mapping for all providers with proper tier detection
- **Configuration Validation**: Added `validate_config` command to check current configuration for errors
- **Backup Management**: New `claude-switch restore` command to restore from previous backups
- **Version Check**: New `claude-switch check-update` command to check if a newer version is available
- **Comprehensive Test Suite**: Full test coverage with unit and integration tests
- **AUR Package**: Arch Linux users can install via `yay -S claude-code-switcher`
- **Homebrew Formula**: macOS users can install via `brew install claude-code-switcher`

### Changed
- **Improved Error Messages**: More descriptive error messages with suggested fixes
- **Better Local Provider Detection**: Enhanced detection of Ollama and LM Studio availability
- **Updated Documentation**: Comprehensive documentation updates for all features
- **Refactored Model Mapping**: Consolidated model mapping functions for better maintainability
- **Installation Options**: Added package manager installation methods (AUR, Homebrew)

### Fixed
- **Ollama Model Mapping**: Fixed issue where only Opus tier was set; now all three tiers (Opus, Sonnet, Haiku) map correctly
- **OpenRouter Model Mapping**: Fixed OpenRouter provider to properly set all three model aliases
- **OpenRouter Silent Failures**: Fixed OpenRouter provider that wasn't showing output messages
- **LM Studio Connection**: Improved connection handling for LM Studio local server
- **Shell Compatibility**: Better compatibility with both Bash and Zsh shells
- **Path Detection**: Improved detection of Claude Code settings path across different environments

### Security
- **API Key Validation**: Added validation to ensure API keys are properly formatted before use
- **Secure File Permissions**: Enforced chmod 600 on all sensitive configuration files
- **Backup Directory Security**: Backups are stored in a dedicated directory with restricted permissions (chmod 700)

## [2.1.0] - 2025-02-09

### Added
- **Model Mapping Display**: New `models` command shows how Claude Code tiers map to provider models
- **Enhanced Help Output**: Improved help text with examples and model tier explanations
- **API Key Documentation**: New `keys` command showing where to obtain API keys for each provider
- **Ollama Auto-Detection**: Automatic detection of installed Ollama models
- **Tiered Model Support**: Proper support for Opus, Sonnet, and Haiku tiers across all providers

### Changed
- **Provider Aliases**: Added `z.ai` as an alias for `zai` provider
- **Status Output**: Enhanced status display with current provider and model information
- **List Command**: Improved list output showing installed Ollama models

### Fixed
- **Provider Detection**: Improved detection of current provider from settings.json
- **Model Names**: Corrected model names for Qwen provider (Qwen2.5-Coder)
- **Shell Output**: Fixed color output issues in some terminal environments

## [2.0.0] - 2025-02-09

### Added
- **Multi-Provider Support**: Support for 8 different LLM providers
  - Cloud: Anthropic Claude, Z.AI (GLM), DeepSeek, Kimi, Qwen, OpenRouter
  - Local: Ollama, LM Studio
- **Automatic Backups**: Settings are backed up before every switch operation
- **Shell Aliases**: Convenient aliases for quick provider switching
- **API Key Management**: Secure storage and loading of API keys
- **Configuration Validation**: Pre-flight checks for API keys and provider availability
- **Local Provider Checks**: Validation that Ollama and LM Studio are running before switching

### Changed
- **Complete Rewrite**: Refactored from simple script to modular architecture
- **Better UX**: Color-coded output and clear success/error messages
- **Provider Detection**: Automatic detection of currently configured provider

## [1.0.0] - 2025-02-08

### Added
- **Initial Release**: Basic provider switching between Anthropic Opus and Z.AI GLM
- **Simple Interface**: Command-line interface for switching providers
- **Configuration Management**: Basic modification of Claude Code settings.json

---

## Version Summary

| Version | Date | Key Features |
|---------|------|--------------|
| 2.2.0 | 2025-02-10 | Wizard, auto-update, Anthropic API, Groq, Together AI, AUR, Homebrew, test suite |
| 2.1.0 | 2025-02-09 | Model mapping display, enhanced help, Ollama auto-detection |
| 2.0.0 | 2025-02-09 | Multi-provider support, backups, shell aliases |
| 1.0.0 | 2025-02-08 | Initial release with basic switching |
