#!/bin/bash
# Claude Code Switcher - Shell Aliases
# Source this file in your ~/.bashrc or ~/.zshrc

_ccs_claude_switch() {
  command claude-switch exec claude -- "$@"
}

_ccs_anthropic_api_switch() {
  command claude-switch exec anthropic-api -- "$@"
}

_ccs_zai_switch() {
  command claude-switch exec zai -- "$@"
}

_ccs_deepseek_switch() {
  command claude-switch exec deepseek -- "$@"
}

_ccs_kimi_switch() {
  command claude-switch exec kimi -- "$@"
}

_ccs_qwen_switch() {
  command claude-switch exec qwen -- "$@"
}

_ccs_groq_switch() {
  command claude-switch exec groq -- "$@"
}

_ccs_together_switch() {
  command claude-switch exec together -- "$@"
}

_ccs_openrouter_switch() {
  if [ -z "$1" ]; then
    command claude-switch exec openrouter -- "${@:2}"
  else
    command claude-switch exec "openrouter:$1" -- "${@:2}"
  fi
}

_ccs_ollama_switch() {
  if [ -z "$1" ]; then
    command claude-switch exec ollama -- "${@:2}"
  else
    command claude-switch exec "ollama:$1" -- "${@:2}"
  fi
}

_ccs_lmstudio_switch() {
  command claude-switch exec lmstudio -- "$@"
}

_ccs_claude_active() {
  command claude-switch exec -- "$@"
}

alias claude-switch='_ccs_claude_switch'
alias anthropic-api-switch='_ccs_anthropic_api_switch'
alias zai-switch='_ccs_zai_switch'
alias deepseek-switch='_ccs_deepseek_switch'
alias kimi-switch='_ccs_kimi_switch'
alias qwen-switch='_ccs_qwen_switch'
alias groq-switch='_ccs_groq_switch'
alias together-switch='_ccs_together_switch'
alias openrouter-switch='_ccs_openrouter_switch'
alias ollama-switch='_ccs_ollama_switch'
alias lmstudio-switch='_ccs_lmstudio_switch'
alias claude-active='_ccs_claude_active'

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

alias ollama7='ollama-switch qwen3-coder:7b'
alias ollama14='ollama-switch qwen3-coder:14b'
alias ollama32='ollama-switch qwen3-coder:32b'
