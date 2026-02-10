#!/bin/bash
VERSION="2.1.0"
SETTINGS="$HOME/.claude/settings.json"
BACKUP_DIR="$HOME/.claude/backups"

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MODEL MAPPING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Maps Claude Code model tiers (Opus, Sonnet, Haiku) to provider-specific models

# Anthropic Claude (official/OAuth)
get_anthropic_oauth_models() {
  echo "opus:claude-opus-4-6 sonnet:claude-sonnet-4-5-20250929 haiku:claude-haiku-4-20250920"
}

# Anthropic API (API key)
get_anthropic_api_models() {
  echo "opus:claude-opus-4-6 sonnet:claude-sonnet-4-5-20250929 haiku:claude-haiku-4-20250920"
}

# Z.AI (GLM models)
get_zai_models() {
  # GLM-4.7 for Opus/Sonnet (best models), GLM-4.5-Flash for Haiku (fast)
  echo "opus:glm-4.7 sonnet:glm-4.7 haiku:glm-4.5-flash"
}

# DeepSeek
get_deepseek_models() {
  # deepseek-chat (capable), deepseek-coder (coding focused)
  echo "opus:deepseek-chat sonnet:deepseek-chat haiku:deepseek-chat"
}

# Kimi (Moonshot AI)
get_kimi_models() {
  echo "opus:moonshot-v1-128k sonnet:moonshot-v1-32k haiku:moonshot-v1-8k"
}

# Qwen (SiliconFlow)
get_qwen_models() {
  # Different sizes of Qwen2.5-Coder
  echo "opus:Qwen/Qwen2.5-Coder-32B-Instruct sonnet:Qwen/Qwen2.5-Coder-14B-Instruct haiku:Qwen/Qwen2.5-Coder-7B-Instruct"
}

# Groq (fast inference)
get_groq_models() {
  # Llama 3.3 70B for Opus/Sonnet, Mixtral 8x7B for Haiku
  echo "opus:llama-3.3-70b-versatile sonnet:llama-3.3-70b-versatile haiku:mixtral-8x7b-32768"
}

# OpenRouter (user specifies model, all tiers use the same)
get_openrouter_models() {
  # Model is specified by user, all tiers map to same model
  local model="${OPENROUTER_DEFAULT_MODEL:-anthropic/claude-opus-4.6}"
  echo "opus:$model sonnet:$model haiku:$model"
}

# Ollama (local, tiered models by default)
get_ollama_models() {
  # Qwen3-Coder tiered models (7b is default for local use)
  local installed=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  local opus="qwen3-coder:32b" sonnet="qwen3-coder:14b" haiku="qwen3-coder:7b"

  # Fallback to available models
  echo "$installed" | grep -q "^${opus}" || opus="$sonnet"
  echo "$installed" | grep -q "^${opus}" || opus="$haiku"
  echo "$installed" | grep -q "^${sonnet}" || sonnet="$opus"
  echo "$installed" | grep -q "^${haiku}" || haiku="$sonnet"

  # If still nothing, use first available
  if [ -z "$opus" ]; then
    opus=$(echo "$installed" | head -1)
    sonnet="$opus"
    haiku="$opus"
  fi

  echo "opus:$opus sonnet:$sonnet haiku:$haiku"
}

# LM Studio (local, single model for all tiers)
get_lmstudio_models() {
  # Uses whatever model is loaded in LM Studio
  echo "opus: sonnet: haiku:"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DOCUMENTATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show_help() {
  echo ""
  echo -e "${BOLD}Claude Code Model Switcher v${VERSION}${NC}"
  echo ""
  echo -e "${YELLOW}USAGE:${NC}"
  echo "  claude-switch <provider>[:model]"
  echo ""
  echo -e "${YELLOW}CLOUD PROVIDERS:${NC}"
  echo "  ${GREEN}claude${NC}            Anthropic Claude (OAuth - no API key)"
  echo "  ${GREEN}anthropic${NC}         Anthropic Claude API (requires key)"
  echo "  ${GREEN}zai / z.ai${NC}        Z.AI GLM models (4.7, 4.6, 4.5-Flash)"
  echo "  ${GREEN}deepseek${NC}          DeepSeek Chat/Coder"
  echo "  ${GREEN}kimi${NC}              Kimi (Moonshot AI)"
  echo "  ${GREEN}qwen${NC}              Qwen Coder (7B, 14B, 32B)"
  echo "  ${GREEN}groq${NC}              Groq (Llama 3.3, Mixtral)"
  echo "  ${GREEN}openrouter${NC}        OpenRouter (requires :model)"
  echo ""
  echo -e "${YELLOW}LOCAL PROVIDERS:${NC}"
  echo "  ${CYAN}ollama${NC}             Ollama (local GGUF models)"
  echo "  ${CYAN}lmstudio${NC}           LM Studio (GUI)"
  echo ""
  echo -e "${YELLOW}MODEL MAPPING:${NC}"
  echo "  Each provider maps Claude's model tiers to their specific models:"
  echo "  • Opus tier    → Provider's most capable model"
  echo "  • Sonnet tier  → Provider's balanced model"
  echo "  • Haiku tier   → Provider's fast/compact model"
  echo ""
  echo -e "${YELLOW}EXAMPLES:${NC}"
  echo "  claude-switch claude           # Use Anthropic Claude (OAuth)"
  echo "  claude-switch anthropic        # Use Anthropic Claude API (requires key)"
  echo "  claude-switch zai              # Use Z.AI GLM-4.7 (Opus/Sonnet/Haiku mapped)"
  echo "  claude-switch openrouter:qwen/qwen-2.5-coder-32b"
  echo "  claude-switch ollama           # Use local Ollama (qwen3-coder:7b default)"
  echo "  claude-switch ollama:qwen3-coder:14b  # Use specific model"
  echo ""
  echo -e "${YELLOW}SPECIAL COMMANDS:${NC}"
  echo "  ${GREEN}keys${NC}              Show where to get API keys"
  echo "  ${GREEN}list${NC}              List available providers"
  echo "  ${GREEN}status${NC}            Show current configuration"
  echo "  ${GREEN}models <provider>${NC} Show model mapping for provider"
  echo "  ${GREEN}update${NC}            Update to latest version from GitHub"
  echo "  ${GREEN}help${NC}              Show this help"
  echo ""
  echo -e "${YELLOW}AVAILABLE ALIASES:${NC}"
  echo "  claude, anthropic, zai, z.ai, deepseek, kimi, qwen"
  echo ""
}

show_key_docs() {
  echo ""
  echo -e "${BLUE}━━━ WHERE TO GET API KEYS ━━━${NC}"
  echo ""
  echo -e "${YELLOW}CLOUD PROVIDERS:${NC}"
  echo "  ${GREEN}Claude (OAuth):${NC} Uses Claude Pro subscription (no API key)"
  echo ""
  echo "  ${GREEN}Anthropic (API):${NC} https://console.anthropic.com/settings/keys"
  echo "    → API key required, pricing based on usage"
  echo "    → Models: claude-opus-4-6, claude-sonnet-4-5-20250929, claude-haiku-4-20250920"
  echo ""
  echo "  ${GREEN}Z.AI:${NC} https://z.ai/manage-apikey/apikey-list"
  echo "    → Plans: \$3/month or \$15/month (annual ~\$180/year)"
  echo "    → Models: GLM-4.7, GLM-4.6, GLM-4.5-Flash"
  echo ""
  echo "  ${GREEN}DeepSeek:${NC} https://platform.deepseek.com/api_keys"
  echo "    → \$0.14/1M input, \$0.28/1M output"
  echo ""
  echo "  ${GREEN}Kimi:${NC} https://platform.moonshot.cn/console/api-keys"
  echo "    → Moonshot AI (may require Chinese phone number)"
  echo ""
  echo "  ${GREEN}Qwen/SiliconFlow:${NC} https://siliconflow.cn/account/ak"
  echo "    → \$0.42/1M tokens (Qwen2.5-Coder)"
  echo ""
  echo "  ${GREEN}Groq:${NC} https://console.groq.com/keys"
  echo "    → Fast inference, generous free tier"
  echo "    → Models: llama-3.3-70b-versatile, mixtral-8x7b-32768"
  echo "  ${GREEN}OpenRouter:${NC} https://openrouter.ai/keys"
  echo "    → Access to 100+ models, pricing varies"
  echo ""
  echo -e "${YELLOW}LOCAL PROVIDERS:${NC}"
  echo "  ${CYAN}Ollama:${NC} https://ollama.com/download"
  echo "    → Free, private, runs locally"
  echo "    → Install: curl -fsSL https://ollama.com/install.sh | sh"
  echo "    → Download: ollama pull qwen3-coder:7b   # Default (fast)"
  echo "    →          ollama pull qwen3-coder:14b  # Optional (balanced)"
  echo "    →          ollama pull qwen3-coder:32b  # Optional (capable)"
  echo ""
  echo "  ${CYAN}LM Studio:${NC} https://lmstudio.ai/"
  echo "    → GUI for local models"
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

list_providers() {
  echo ""
  echo -e "${BOLD}Available Providers:${NC}"
  echo ""
  echo -e "${YELLOW}CLOUD (paid):${NC}"
  echo "  claude     - Anthropic Claude OAuth (Opus/Sonnet/Haiku)"
  echo "  anthropic  - Anthropic Claude API (requires key)"
  echo "  zai       - Z.AI GLM (4.7/4.6/4.5-Flash)"
  echo "  deepseek  - DeepSeek Chat/Coder"
  echo "  kimi      - Kimi (Moonshot AI)"
  echo "  qwen      - Qwen Coder (32B/14B/7B)"
  echo "  groq      - Groq (Llama 3.3/Mixtral)"
  echo "  openrouter - OpenRouter (100+ models)"
  echo ""
  echo -e "${YELLOW}LOCAL (free):${NC}"
  echo "  ollama    - Ollama (local GGUF models)"
  echo "  lmstudio  - LM Studio (GUI)"
  echo ""
  echo -e "${YELLOW}Installed Ollama Models:${NC}"
  if command -v ollama &> /dev/null; then
    ollama list 2>/dev/null || echo "  No models installed"
  else
    echo "  Ollama not installed"
  fi
  echo ""
}

show_model_mapping() {
  local provider="$1"

  if [ -z "$provider" ]; then
    echo -e "${RED}Usage: claude-switch models <provider>${NC}"
    echo ""
    echo "Example: claude-switch models zai"
    return 1
  fi

  echo ""
  echo -e "${BOLD}Model Mapping for: ${GREEN}$provider${NC}${BOLD}${NC}"
  echo ""
  echo -e "${YELLOW}Claude Code Tier${NC}  →  ${YELLOW}Provider Model${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  case "$provider" in
    claude|anthropic)
      echo -e "  Opus    →  claude-opus-4-6"
      echo -e "  Sonnet  →  claude-sonnet-4-5-20250929"
      echo -e "  Haiku   →  claude-haiku-4-20250920"
      ;;
    zai|z.ai|glm)
      echo -e "  Opus    →  glm-4.7"
      echo -e "  Sonnet  →  glm-4.7"
      echo -e "  Haiku   →  glm-4.5-flash"
      ;;
    deepseek)
      echo -e "  Opus    →  deepseek-chat"
      echo -e "  Sonnet  →  deepseek-chat"
      echo -e "  Haiku   →  deepseek-chat"
      ;;
    kimi)
      echo -e "  Opus    →  moonshot-v1-128k"
      echo -e "  Sonnet  →  moonshot-v1-32k"
      echo -e "  Haiku   →  moonshot-v1-8k"
      ;;
    qwen)
      echo -e "  Opus    →  Qwen/Qwen2.5-Coder-32B-Instruct"
      echo -e "  Sonnet  →  Qwen/Qwen2.5-Coder-14B-Instruct"
      echo -e "  Haiku   →  Qwen/Qwen2.5-Coder-7B-Instruct"
      ;;
    groq)
      echo -e "  Opus    →  llama-3.3-70b-versatile"
      echo -e "  Sonnet  →  llama-3.3-70b-versatile"
      echo -e "  Haiku   →  mixtral-8x7b-32768"
      ;;
    groq)
      echo -e "  Opus    →  llama-3.3-70b-versatile"
      echo -e "  Sonnet  →  llama-3.3-70b-versatile"
      echo -e "  Haiku   →  mixtral-8x7b-32768"
      ;;
    groq)
      validate_key "GROQ_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$GROQ_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.groq.com/openai/v1" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "mixtral-8x7b-32768"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;
    groq)
      validate_key "GROQ_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$GROQ_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.groq.com/openai/v1" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "mixtral-8x7b-32768"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    openrouter)
      local model="${OPENROUTER_DEFAULT_MODEL:-anthropic/claude-opus-4.6}"
      echo -e "  Opus    →  $model"
      echo -e "  Sonnet  →  $model"
      echo -e "  Haiku   →  $model"
      echo ""
      echo -e "${CYAN}(All tiers use the same OpenRouter model)${NC}"
      ;;
    ollama)
      local installed=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
      local opus="qwen3-coder:32b" sonnet="qwen3-coder:14b" haiku="qwen3-coder:7b"

      # Show what would actually be used (with fallback)
      echo "$installed" | grep -q "^${opus}" || opus="$sonnet"
      echo "$installed" | grep -q "^${opus}" || opus="$haiku"
      echo "$installed" | grep -q "^${sonnet}" || sonnet="$opus"
      echo "$installed" | grep -q "^${haiku}" || haiku="$sonnet"
      [ -z "$opus" ] && opus=$(echo "$installed" | head -1)

      echo -e "  Opus    →  ${opus:-<not set>}"
      echo -e "  Sonnet  →  ${sonnet:-<not set>}"
      echo -e "  Haiku   →  ${haiku:-<not set>} ${CYAN}(default)${NC}"
      echo ""
      echo -e "${CYAN}(Tiered models: 32b/14b/7b - 7b is default for local use)${NC}"
      ;;
    lmstudio)
      echo -e "  Opus    →  <loaded in LM Studio>"
      echo -e "  Sonnet  →  <loaded in LM Studio>"
      echo -e "  Haiku   →  <loaded in LM Studio>"
      echo ""
      echo -e "${CYAN}(Uses whatever model is loaded in LM Studio)${NC}"
      ;;
    *)
      echo -e "${RED}Unknown provider: $provider${NC}"
      echo "Run: claude-switch list"
      return 1
      ;;
  esac
  echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CURRENT CONFIG DETECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

get_current_config() {
  local base_url=$(jq -r '.env.ANTHROPIC_BASE_URL // "oauth"' "$SETTINGS" 2>/dev/null)

  case "$base_url" in
    "oauth"|"null") echo "claude" ;;
    *"z.ai"*) echo "zai" ;;
    *"deepseek"*) echo "deepseek" ;;
    *"moonshot"*) echo "kimi" ;;
    *"siliconflow"*) echo "qwen" ;;
    *"groq"*) echo "groq" ;;
    *"openrouter"*) echo "openrouter" ;;
    *"localhost:11434"*|*"127.0.0.1:11434"*) echo "ollama" ;;
    *"localhost:1234"*|*"127.0.0.1:1234"*) echo "lmstudio" ;;
    *) echo "unknown" ;;
  esac
}

get_friendly_name() {
  case "$1" in
    claude|anthropic) echo "Claude (Anthropic)" ;;
    zai|z.ai|glm) echo "Z.AI (GLM)" ;;
    deepseek) echo "DeepSeek" ;;
    kimi) echo "Kimi (Moonshot)" ;;
    qwen) echo "Qwen Coder" ;;
    groq)
      echo -e "  Opus    →  llama-3.3-70b-versatile"
      echo -e "  Opus    →  llama-3.3-70b-versatile"
      echo -e "  Sonnet  →  llama-3.3-70b-versatile"
      echo -e "  Haiku   →  mixtral-8x7b-32768"
      ;;
    groq)
      validate_key "GROQ_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$GROQ_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.groq.com/openai/v1" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "mixtral-8x7b-32768"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;
    groq)
      validate_key "GROQ_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$GROQ_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.groq.com/openai/v1" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "mixtral-8x7b-32768"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    openrouter) echo "OpenRouter" ;;
    ollama) echo "Ollama (Local)" ;;
    lmstudio) echo "LM Studio (Local)" ;;
    *) echo "Unknown" ;;
  esac
}

show_status() {
  local current=$(get_current_config)
  local current_name=$(get_friendly_name "$current")

  echo ""
  echo -e "${BOLD}Current Status:${NC}"
  echo -e "  Provider: ${GREEN}$current_name${NC}"

  local base_url=$(jq -r '.env.ANTHROPIC_BASE_URL // "oauth"' "$SETTINGS" 2>/dev/null)
  if [ "$base_url" != "oauth" ] && [ "$base_url" != "null" ]; then
    echo "  Base URL: $base_url"
  fi

  local opus_model=$(jq -r '.env.ANTHROPIC_DEFAULT_OPUS_MODEL // "default"' "$SETTINGS" 2>/dev/null)
  if [ "$opus_model" != "default" ] && [ "$opus_model" != "null" ]; then
    echo "  Opus: $opus_model"
  fi

  local sonnet_model=$(jq -r '.env.ANTHROPIC_DEFAULT_SONNET_MODEL // "default"' "$SETTINGS" 2>/dev/null)
  if [ "$sonnet_model" != "default" ] && [ "$sonnet_model" != "null" ]; then
    echo "  Sonnet: $sonnet_model"
  fi

  local haiku_model=$(jq -r '.env.ANTHROPIC_DEFAULT_HAIKU_MODEL // "default"' "$SETTINGS" 2>/dev/null)
  if [ "$haiku_model" != "default" ] && [ "$haiku_model" != "null" ]; then
    echo "  Haiku: $haiku_model"
  fi
  echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

validate_key() {
  local key_name="$1"
  local key_value="${!key_name}"

  if [ -z "$key_value" ]; then
    echo -e "${RED}❌ $key_name not configured${NC}"
    echo "Configure it in: ~/.claude/api-keys.env"
    echo "Or run: claude-switch keys"
    return 1
  fi
  return 0
}

check_ollama() {
  if ! command -v ollama &> /dev/null; then
    echo -e "${RED}❌ Ollama not installed${NC}"
    echo "Install with: curl -fsSL https://ollama.com/install.sh | sh"
    return 1
  fi

  if ! pgrep -x ollama > /dev/null; then
    echo -e "${YELLOW}⚠️  Ollama is not running${NC}"
    echo "Start with: ollama serve"
    read -p "Start now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[SsYy]$ ]]; then
      nohup ollama serve > /dev/null 2>&1 &
      sleep 2
      echo -e "${GREEN}✓${NC} Ollama started"
    else
      return 1
    fi
  fi
  return 0
}

check_lmstudio() {
  if ! curl -s http://localhost:1234/v1/models > /dev/null 2>&1; then
    echo -e "${RED}❌ LM Studio is not running${NC}"
    echo "Open LM Studio and:"
    echo "1. Load a model"
    echo "2. Go to 'Local Server'"
    echo "3. Click 'Start Server'"
    return 1
  fi
  return 0
}

# Validate model name to prevent injection attacks
# Accepts: alphanumeric, hyphens, underscores, slashes, colons, dots
# Rejects: shell metacharacters, spaces, special chars
validate_model_name() {
  local model="$1"

  # Check if empty
  if [ -z "$model" ]; then
    return 0  # Empty is OK (will use default)
  fi

  # Check length (prevent DoS via ultra-long names)
  if [ ${#model} -gt 255 ]; then
    echo -e "${RED}❌ Model name too long (max 255 characters)${NC}"
    return 1
  fi

  # Validate characters: only allow safe chars
  case "$model" in
    *[!a-zA-Z0-9_\-/:.]*)
      echo -e "${RED}❌ Invalid model name: $model${NC}"
      echo "Model names can only contain: letters, numbers, hyphens, underscores, slashes, colons, and dots"
      return 1
      ;;
  esac

  # Prevent path traversal attempts
  if [[ "$model" =~ \.\. ]]; then
    echo -e "${RED}❌ Path traversal not allowed${NC}"
    return 1
  fi

  return 0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLY CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Clear all model-related environment variables
# This prevents stale model settings from leaking between providers
clear_all_models() {
  local tmp_settings
  tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
  jq 'del(.env.ANTHROPIC_MODEL,
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL,
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL,
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL)' \
     "$SETTINGS" > "$tmp_settings"
  mv "$tmp_settings" "$SETTINGS"
}

apply_config() {
  local provider="$1"
  local override_model="$2"

  # Validate model name if provided
  if [ -n "$override_model" ]; then
    validate_model_name "$override_model" || return 1
  fi

  # Normalize provider name
  case "$provider" in
    anthropic) provider="claude" ;;
    z.ai|glm) provider="zai" ;;
  esac

  # Backup
  cp "$SETTINGS" "$BACKUP_DIR/settings.json.backup-$(date +%Y%m%d-%H%M%S)"

  # Get model mapping for provider
  local opus_model=""
  local sonnet_model=""
  local haiku_model=""

  case "$provider" in
    claude)
      # Official Anthropic - no API key, no model overrides needed
      clear_all_models
      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq 'del(.env.ANTHROPIC_AUTH_TOKEN, .env.ANTHROPIC_BASE_URL)' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    zai)
      # Check both ZAI_API_KEY and GLM_API_KEY (legacy name)
      local api_key="${ZAI_API_KEY:-$GLM_API_KEY}"
      if [ -z "$api_key" ]; then
        echo -e "${RED}❌ ZAI_API_KEY (or GLM_API_KEY) not configured${NC}"
        echo "Configure it in: ~/.claude/api-keys.env"
        echo "Or run: claude-switch keys"
        return 1
      fi

      # Clear any stale model settings first
      clear_all_models

      # Map tiers to Z.AI models
      opus_model="glm-4.7"
      sonnet_model="glm-4.7"
      haiku_model="glm-4.5-flash"

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$api_key" \
         --arg opus "$opus_model" \
         --arg sonnet "$sonnet_model" \
         --arg haiku "$haiku_model" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $opus |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = $sonnet |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = $haiku' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    deepseek)
      validate_key "DEEPSEEK_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$DEEPSEEK_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-chat" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-chat" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-chat"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    kimi)
      validate_key "KIMI_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$KIMI_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.moonshot.ai/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "moonshot-v1-128k" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "moonshot-v1-32k" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "moonshot-v1-8k"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    qwen)
      validate_key "SILICONFLOW_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$SILICONFLOW_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.siliconflow.cn/v1/anthropic" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "Qwen/Qwen2.5-Coder-32B-Instruct" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "Qwen/Qwen2.5-Coder-14B-Instruct" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "Qwen/Qwen2.5-Coder-7B-Instruct"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

    groq)
      echo -e "  Opus    →  llama-3.3-70b-versatile"
      echo -e "  Sonnet  →  llama-3.3-70b-versatile"
      echo -e "  Haiku   →  mixtral-8x7b-32768"
      ;;
    groq)
      validate_key "GROQ_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$GROQ_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.groq.com/openai/v1" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "mixtral-8x7b-32768"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;
    groq)
      validate_key "GROQ_API_KEY" || return 1

      # Clear any stale model settings first
      clear_all_models

      local tmp_settings
      tmp_settings=$(mktemp "${SETTINGS}.tmp.XXXXXX")
      jq --arg token "$GROQ_API_KEY" \
         '.env.ANTHROPIC_AUTH_TOKEN = $token |
          .env.ANTHROPIC_BASE_URL = "https://api.groq.com/openai/v1" |
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL = "llama-3.3-70b-versatile" |
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "mixtral-8x7b-32768"' \
         "$SETTINGS" > "$tmp_settings"
      mv "$tmp_settings" "$SETTINGS"
      ;;

