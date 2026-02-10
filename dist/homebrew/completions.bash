# Bash completion for claude-switch

_claude_switch_completion() {
  local cur prev words cword
  _init_completion || return

  case "${prev}" in
    models)
      # Provider names for models command
      COMPREPLY=($(compgen -W "claude anthropic-api zai z.ai glm deepseek kimi qwen groq together openrouter ollama lmstudio" -- "${cur}"))
      return
      ;;
  esac

  # If we're at the first argument (after command name)
  if [[ ${cword} -eq 1 ]]; then
    # Special commands
    local special_cmds="help keys docs list ls status current models"

    # Provider names
    local providers="claude anthropic-api zai z.ai glm deepseek kimi qwen groq together openrouter ollama lmstudio"

    # Combined list
    COMPREPLY=($(compgen -W "${special_cmds} ${providers}" -- "${cur}"))
  fi

  # Handle provider:model syntax
  if [[ ${cur} == *:* ]] && [[ ${cword} -eq 1 ]]; then
    local provider="${cur%%:*}"
    case "${provider}" in
      openrouter)
        # OpenRouter requires a model - suggest common ones
        COMPREPLY=($(compgen -W "openrouter:anthropic/claude-opus-4.6 \
                                    openrouter:anthropic/claude-sonnet-4 \
                                    openrouter:anthropic/claude-haiku-4 \
                                    openrouter:google/gemini-2.0-flash-exp \
                                    openrouter:mistralai/mistral-large" -- "${cur}"))
        ;;
      ollama)
        # Suggest common Ollama models
        COMPREPLY=($(compgen -W "ollama:qwen3-coder:7b \
                                    ollama:qwen3-coder:14b \
                                    ollama:qwen3-coder:32b \
                                    ollama:codellama:7b \
                                    ollama:deepseek-coder" -- "${cur}"))
        ;;
    esac
  fi
}

complete -F _claude_switch_completion claude-switch
