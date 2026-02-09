#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code Switcher - Shell Aliases
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Add to your ~/.bashrc or ~/.zshrc:
# source /path/to/claude-code-switcher/config/aliases.sh
#

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROVIDER ALIASES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Anthropic Claude (official)
alias claude='claude-switch claude && claude'

# Z.AI (both aliases work)
alias zai='claude-switch zai && claude'
alias z.ai='claude-switch zai && claude'

# Other cloud providers
alias deepseek='claude-switch deepseek && claude'
alias kimi='claude-switch kimi && claude'
alias qwen='claude-switch qwen && claude'

# OpenRouter with dynamic model
openrouter() {
  if [ -z "$1" ]; then
    claude-switch openrouter && claude
  else
    claude-switch "openrouter:$1" && claude
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOCAL PROVIDERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Ollama with optional model
ollama-claude() {
  if [ -z "$1" ]; then
    claude-switch ollama && claude
  else
    claude-switch "ollama:$1" && claude
  fi
}

# LM Studio
alias lmstudio-claude='claude-switch lmstudio && claude'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILITY ALIASES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Shortcuts for claude-switch
alias ccs='claude-switch'
alias ccs-status='claude-switch status'
alias ccs-list='claude-switch list'
alias ccs-keys='claude-switch keys'
alias ccs-models='claude-switch models'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LEGACY ALIASES (for backward compatibility)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# These still work but map to new provider names
alias opus='claude-switch claude && claude'
alias glm='claude-switch zai && claude'
