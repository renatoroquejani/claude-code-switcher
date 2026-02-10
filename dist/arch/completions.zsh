#compdef claude-switch
# Zsh completion for claude-switch

_claude_switch() {
  local -a commands providers cloud_providers local_providers

  commands=(
    'help:Show help message'
    'keys:Show where to get API keys'
    'list:List available providers'
    'status:Show current configuration'
    'models:Show model mapping for provider'
  )

  cloud_providers=(
    'claude:Anthropic Claude (Opus, Sonnet, Haiku)'
    'anthropic-api:Anthropic Claude API (requires key)'
    'zai:Z.AI GLM models (4.7, 4.6, 4.5-Flash)'
    'z.ai:Same as zai'
    'glm:Legacy name for zai'
    'deepseek:DeepSeek Chat/Coder'
    'kimi:Kimi (Moonshot AI)'
    'qwen:Qwen Coder (7B, 14B, 32B)'
    'groq:Groq (Llama 3.3, Mixtral)'
    'together:Together AI (Llama, Mixtral, Mistral)'
    'openrouter:OpenRouter (requires :model)'
  )

  local_providers=(
    'ollama:Ollama (local GGUF models)'
    'lmstudio:LM Studio (GUI)'
  )

  providers=($cloud_providers $local_providers)

  if (( CURRENT == 2 )); then
    _describe -t commands 'commands' commands
    _describe -t providers 'providers' providers
  elif (( CURRENT == 3 )); then
    case $words[2] in
      models)
        _describe -t providers 'providers' providers
        ;;
      openrouter)
        _message 'model (e.g. anthropic/claude-opus-4.6)'
        ;;
      ollama)
        _message 'model (e.g. qwen3-coder:7b)'
        ;;
    esac
  fi
}

_claude_switch "$@"
