# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code Switcher is a Bash CLI tool (`claude-switch`) that switches Claude Code between LLM providers by modifying `~/.claude/settings.json`. It supports cloud providers (Anthropic Opus, Z.AI/GLM, DeepSeek, Kimi, SiliconFlow/Qwen, OpenRouter) and local providers (Ollama, LM Studio).

This is a **pure Bash project** -- no Node.js, no package manager, no build step. The only runtime dependency is `jq`.

## Repository Structure

The project is in pre-initialization state. `PROJECT_INIT.md` contains the full blueprint (in Portuguese). The existing working script lives at `~/.local/bin/claude-switch` and should be migrated to `bin/claude-switch`.

Planned layout:
- `bin/claude-switch` -- Main executable (413-line Bash script)
- `config/api-keys.env.example` -- API key template
- `config/aliases.sh` -- Shell aliases for quick provider switching
- `scripts/install.sh` -- Automated installer
- `scripts/uninstall.sh` -- Uninstaller (not yet created)
- `tests/test-providers.sh` -- Basic provider tests
- `docs/` -- SETUP.md, PROVIDERS.md, TROUBLESHOOTING.md

## Development

### Running the script
```bash
./bin/claude-switch help        # Show help
./bin/claude-switch list        # List providers
./bin/claude-switch status      # Show current config
./bin/claude-switch opus        # Switch to Anthropic Opus
./bin/claude-switch glm         # Switch to Z.AI
./bin/claude-switch ollama:qwen3-coder  # Switch to local Ollama model
```

### Testing
```bash
./tests/test-providers.sh
```

### Linting (shellcheck)
```bash
shellcheck bin/claude-switch
```

## Architecture

The script works by manipulating three env vars in `~/.claude/settings.json` via `jq`:
- `ANTHROPIC_AUTH_TOKEN` -- API key (or "ollama"/"lmstudio" for local)
- `ANTHROPIC_BASE_URL` -- Provider endpoint (deleted for Opus/OAuth)
- `ANTHROPIC_DEFAULT_OPUS_MODEL` -- Model override (some providers also need SONNET and HAIKU variants)

Key functions in `bin/claude-switch`:
- `apply_config()` -- Core switching logic; `case` statement per provider that rewrites settings.json
- `get_current_config()` -- Detects active provider by pattern-matching `ANTHROPIC_BASE_URL`
- `validate_key()` -- Checks env var is set for the target provider
- `check_ollama()` / `check_lmstudio()` -- Validates local provider readiness

API keys are sourced from `~/.claude/api-keys.env` (chmod 600). Backups go to `~/.claude/backups/` before every switch.

## Known Bugs (from PROJECT_INIT.md)

1. **Ollama model mapping**: Only sets `ANTHROPIC_DEFAULT_OPUS_MODEL` but Claude Code also queries sonnet/haiku aliases. Fix: set all three (`OPUS`, `SONNET`, `HAIKU`) to the same local model.
2. **OpenRouter model mapping**: Same issue -- needs all three model aliases set, plus may need `HTTP-Referer` and `X-Title` headers.

## Conventions

- Language: English for user-facing strings, docs, and commit messages
- Commit style: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`)
- Shell: Bash-compatible (bash/zsh), uses `set -e` in scripts
- All provider cases must include backup, validation, and jq-based settings.json manipulation
- Adding a new provider: add a case in `apply_config()`, add detection in `get_current_config()`, add friendly name in `get_friendly_name()`, update `show_help()` and `list_providers()`
