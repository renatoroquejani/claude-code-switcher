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
  command claude-switch exec claude -- "$@"
}

# Anthropic Claude (API key)
anthropic-api-switch() {
  command claude-switch exec anthropic-api -- "$@"
}

# Z.AI
zai-switch() {
  command claude-switch exec zai -- "$@"
}

# DeepSeek
deepseek-switch() {
  command claude-switch exec deepseek -- "$@"
}

# Kimi
kimi-switch() {
  command claude-switch exec kimi -- "$@"
}

# Qwen
qwen-switch() {
  command claude-switch exec qwen -- "$@"
}

# Groq
groq-switch() {
  command claude-switch exec groq -- "$@"
}

# Together AI
together-switch() {
  command claude-switch exec together -- "$@"
}

# OpenRouter (with optional model)
openrouter-switch() {
  if [ -z "$1" ]; then
    command claude-switch exec openrouter -- "${@:2}"
  else
    command claude-switch exec "openrouter:$1" -- "${@:2}"
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOCAL PROVIDERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Ollama (with optional model)
ollama-switch() {
  if [ -z "$1" ]; then
    command claude-switch exec ollama -- "${@:2}"
  else
    command claude-switch exec "ollama:$1" -- "${@:2}"
  fi
}

# LM Studio
lmstudio-switch() {
  command claude-switch exec lmstudio -- "$@"
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
alias cs-update-config='claude-switch update-config'
alias cs-wizard='claude-switch wizard'
alias cs-exec='claude-switch exec'
alias cs-accounts='claude-switch account list'
alias cs-profiles='claude-switch profile list'
alias cs-providers='claude-switch provider list'

claude-active() {
  command claude-switch exec -- "$@"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONVENIENCE ALIASES (Ollama models)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alias ollama7='ollama-switch qwen3-coder:7b'
alias ollama14='ollama-switch qwen3-coder:14b'
alias ollama32='ollama-switch qwen3-coder:32b'
