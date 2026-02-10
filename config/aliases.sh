#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code Switcher - Shell Aliases
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Add to your ~/.bashrc or ~/.zshrc:
# source ~/.claude/aliases.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLOUD PROVIDERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Anthropic Claude (OAuth/Pro)
claude-switch() {
  command claude-switch claude && claude
}

# Anthropic Claude (API key)
anthropic-api-switch() {
  command claude-switch anthropic-api && claude
}

# Z.AI
zai-switch() {
  command claude-switch zai && claude
}

# DeepSeek
deepseek-switch() {
  command claude-switch deepseek && claude
}

# Kimi
kimi-switch() {
  command claude-switch kimi && claude
}

# Qwen
qwen-switch() {
  command claude-switch qwen && claude
}

# Groq
groq-switch() {
  command claude-switch groq && claude
}

# Together AI
together-switch() {
  command claude-switch together && claude
}

# OpenRouter (with optional model)
openrouter-switch() {
  if [ -z "$1" ]; then
    command claude-switch openrouter && claude
  else
    command claude-switch "openrouter:$1" && claude
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOCAL PROVIDERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Ollama (with optional model)
ollama-switch() {
  if [ -z "$1" ]; then
    command claude-switch ollama && claude
  else
    command claude-switch "ollama:$1" && claude
  fi
}

# LM Studio
lmstudio-switch() {
  command claude-switch lmstudio && claude
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STATUS & INFO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alias cs-status='claude-switch status'
alias cs-list='claude-switch list'
alias cs-models='claude-switch models'
alias cs-keys='claude-switch keys'
alias cs-help='claude-switch help'
alias cs-update='claude-switch update'
alias cs-wizard='claude-switch wizard'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONVENIENCE ALIASES (Ollama models)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alias ollama7='ollama-switch qwen3-coder:7b'
alias ollama14='ollama-switch qwen3-coder:14b'
alias ollama32='ollama-switch qwen3-coder:32b'
