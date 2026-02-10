# Bash completion for claude-switch

_claude_switch_completion() {
  local cur prev words cword
  _init_completion || return

  # Special commands
  local special_commands="help keys list status models"

  # Cloud providers
  local cloud_providers="claude anthropic-api zai z.ai glm deepseek kimi qwen groq together openrouter"

  # Local providers
  local local_providers="ollama lmstudio"

  # All providers
  local all_providers="$cloud_providers $local_providers"

  case $prev in
    models)
      # Complete provider name after 'models' command
      COMPREPLY=($(compgen -W "$all_providers" -- "$cur"))
      return
      ;;
    ollama)
      # Complete with colon for model specification
      if [[ $cur == *:* ]]; then
        # After colon, suggest common Ollama models
        local model="${cur#*:}"
        local ollama_models="qwen3-coder:7b qwen3-coder:14b qwen3-coder:32b deepseek-coder-v2 llama3.2"
        COMPREPLY=($(compgen -W "$ollama_models" -P "${cur%%:*}:" -S "" -- "$model"))
      else
        # Before colon, just add colon hint
        COMPREPLY=($(compgen -W "$ollama_models" -P "$cur:" -S "" -- ""))
      fi
      return
      ;;
    openrouter)
      # Complete with colon for model specification
      if [[ $cur == *:* ]]; then
        # After colon, suggest common OpenRouter models
        local model="${cur#*:}"
        local or_models="anthropic/claude-opus-4.6 anthropic/claude-sonnet-4 anthropic/claude-haiku-4 qwen/qwen-2.5-coder-32b deepseek/deepseek-coder"
        COMPREPLY=($(compgen -W "$or_models" -P "${cur%%:*}:" -S "" -- "$model"))
      else
        # Before colon, just add colon hint
        COMPREPLY=($(compgen -W "$or_models" -P "$cur:" -S "" -- ""))
      fi
      return
      ;;
  esac

  # Main completion
  if [[ $cur == -* ]]; then
    # Options (if any in future)
    COMPREPLY=($(compgen -W "--help -h" -- "$cur"))
  else
    # Complete commands and providers
    COMPREPLY=($(compgen -W "$special_commands $all_providers" -- "$cur"))
  fi
}

complete -F _claude_switch_completion claude-switch
