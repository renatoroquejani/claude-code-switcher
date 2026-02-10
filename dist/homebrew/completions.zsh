#compdef claude-switch

# Zsh completion for claude-switch

_claude_switch() {
  local -a commands providers

  commands=(
    'help:Show help message'
    'keys:Show where to get API keys'
    'docs:Show documentation (same as keys)'
    'list:List available providers'
    'ls:List available providers (same as list)'
    'status:Show current configuration'
    'current:Show current configuration (same as status)'
    'models:Show model mapping for a provider'
  )

  providers=(
    'claude:Anthropic Claude (Opus, Sonnet, Haiku)'
    'anthropic:Same as claude'
    'zai:Z.AI GLM models'
    'z.ai:Same as zai'
    'glm:Legacy name for zai'
    'deepseek:DeepSeek Chat/Coder'
    'kimi:Kimi (Moonshot AI)'
    'qwen:Qwen Coder (7B, 14B, 32B)'
    'openrouter:OpenRouter (requires :model)'
    'ollama:Ollama (local GGUF models)'
    'lmstudio:LM Studio (GUI)'
  )

  case $state in
    command)
      _describe -t commands 'claude-switch commands' commands
      ;;
    provider)
      _describe -t providers 'providers' providers
      ;;
    models_provider)
      _describe -t providers 'providers' providers
      ;;
  esac
}

_claude_switch_arguments() {
  local -a arguments
  arguments=(
    '1: :->command_or_provider'
    '*:: :->args'
  )

  _arguments -s -S $arguments

  local cmd_or_provider=$line[1]

  case $cmd_or_provider in
    models)
      _arguments '2: :->models_provider'
      _claude_switch models_provider
      ;;
    help|keys|docs|list|ls|status|current)
      # No arguments needed
      ;;
    *)
      # Provider with optional :model suffix
      ;;
  esac
}

_claude_switch_arguments "$@"
