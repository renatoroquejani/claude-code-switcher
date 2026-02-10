#!/bin/bash
# Claude Code Switcher - Interactive Configuration Wizard
# Guides users through setting up API keys and detecting local providers

set -e

VERSION="2.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
API_KEYS_FILE="$HOME/.claude/api-keys.env"
ALIASES_FILE="$HOME/.claude/aliases.sh"

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

# Track which providers are configured
CONFIGURED_PROVIDERS=()

echo ""
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Claude Code Switcher v${VERSION} - Configuration Wizard${NC}"
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}This wizard will help you:${NC}"
echo "  1. Configure API keys for cloud providers"
echo "  2. Detect and validate local providers (Ollama, LM Studio)"
echo "  3. Set up shell aliases for quick switching"
echo ""
read -p "Press Enter to continue..."
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILITY FUNCTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Check if API key is set (not empty and not a placeholder)
is_key_configured() {
  local key_name="$1"
  local key_value="${!key_name}"

  # Check if variable is set and not empty
  if [ -z "$key_value" ]; then
    return 1
  fi

  # Check for placeholder values
  case "$key_value" in
    *"your-key-here"*|*"<your-key>"*|*"PLACEHOLDER"*)
      return 1
      ;;
  esac

  return 0
}

# Validate API key format (basic checks)
validate_api_key() {
  local key="$1"
  local provider="$2"

  # Basic length check (most API keys are at least 20 chars)
  if [ ${#key} -lt 10 ]; then
    echo -e "${RED}❌ API key seems too short (minimum 10 characters)${NC}"
    return 1
  fi

  # Provider-specific checks
  case "$provider" in
    zai)
      # Z.AI keys typically start with specific patterns
      if [[ ! "$key" =~ ^[a-zA-Z0-9_-]{20,}$ ]]; then
        echo -e "${YELLOW}⚠️  Warning: Key format may be invalid for Z.AI${NC}"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        [[ $REPLY =~ ^[SsYy]$ ]] || return 1
      fi
      ;;
    openrouter)
      # OpenRouter keys typically start with "sk-or-"
      if [[ ! "$key" =~ ^sk-or-[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${YELLOW}⚠️  Warning: OpenRouter keys usually start with 'sk-or-'${NC}"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        [[ $REPLY =~ ^[SsYy]$ ]] || return 1
      fi
      ;;
  esac

  return 0
}

# Detect and configure local providers
detect_local_providers() {
  echo ""
  echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  LOCAL PROVIDERS DETECTION${NC}"
  echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
  echo ""

  # Check Ollama
  echo -e "${CYAN}Checking Ollama...${NC}"
  if command -v ollama &> /dev/null; then
    echo -e "${GREEN}✓${NC} Ollama is installed"

    # Check if running
    if pgrep -x ollama > /dev/null 2>&1; then
      echo -e "${GREEN}✓${NC} Ollama is running"

      # List installed models
      local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | tr '\n' ' ')
      if [ -n "$models" ]; then
        echo -e "${GREEN}✓${NC} Installed models: ${CYAN}$models${NC}"
      else
        echo -e "${YELLOW}⚠️  No models installed${NC}"
        echo -e "  Download a model: ${GREEN}ollama pull qwen3-coder:7b${NC}"
      fi
    else
      echo -e "${YELLOW}⚠️  Ollama is not running${NC}"
      echo -e "  Start with: ${GREEN}ollama serve${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  Ollama not installed${NC}"
    echo -e "  Install: ${GREEN}curl -fsSL https://ollama.com/install.sh | sh${NC}"
  fi
  echo ""

  # Check LM Studio
  echo -e "${CYAN}Checking LM Studio...${NC}"
  if curl -s http://localhost:1234/v1/models > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} LM Studio is running"
  else
    echo -e "${YELLOW}⚠️  LM Studio is not running${NC}"
    echo -e "  Open LM Studio and start the local server"
  fi
  echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# API KEY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

configure_cloud_providers() {
  echo ""
  echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  CLOUD PROVIDERS CONFIGURATION${NC}"
  echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "${YELLOW}Note: Claude (Anthropic) uses your Pro subscription (no API key)${NC}"
  echo ""

  # Create api-keys.env if it doesn't exist
  if [ ! -f "$API_KEYS_FILE" ]; then
    echo -e "${CYAN}Creating ~/.claude/api-keys.env...${NC}"
    cat > "$API_KEYS_FILE" << 'EOF'
# API Keys for Claude Code Switcher
# Get keys at: https://github.com/renatoroquejani/claude-code-switcher
#
# Usage: Run 'claude-switch keys' to see where to get API keys

# Z.AI (GLM models)
#ZAI_API_KEY="your-key-here"

# DeepSeek
#DEEPSEEK_API_KEY="your-key-here"

# Kimi (Moonshot AI)
#KIMI_API_KEY="your-key-here"

# Qwen (SiliconFlow)
#SILICONFLOW_API_KEY="your-key-here"

# OpenRouter
#OPENROUTER_API_KEY="your-key-here"
#OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4.6"
EOF
    chmod 600 "$API_KEYS_FILE"
  fi

  # Source existing keys
  source "$API_KEYS_FILE" 2>/dev/null || true

  # Provider configuration prompts
  declare -A providers=(
    ["zai"]="Z.AI (GLM-4.7, \$3-15/month) - https://z.ai/manage-apikey/apikey-list"
    ["deepseek"]="DeepSeek (\$0.14/1M tokens) - https://platform.deepseek.com/api_keys"
    ["kimi"]="Kimi/Moonshot AI - https://platform.moonshot.cn/console/api-keys"
    ["qwen"]="Qwen/SiliconFlow (\$0.42/1M) - https://siliconflow.cn/account/ak"
    ["openrouter"]="OpenRouter (100+ models) - https://openrouter.ai/keys"
  )

  declare -A env_vars=(
    ["zai"]="ZAI_API_KEY"
    ["deepseek"]="DEEPSEEK_API_KEY"
    ["kimi"]="KIMI_API_KEY"
    ["qwen"]="SILICONFLOW_API_KEY"
    ["openrouter"]="OPENROUTER_API_KEY"
  )

  echo "Available cloud providers:"
  local i=1
  for provider in "${!providers[@]}"; do
    echo "  ${i}. ${GREEN}${provider}${NC} - ${providers[$provider]}"
    ((i++))
  done
  echo "  ${i}. ${YELLOW}Skip${NC} - Configure later"
  echo ""

  # Check already configured providers
  echo -e "${CYAN}Currently configured:${NC}"
  local has_configured=false
  for provider in "${!providers[@]}"; do
    local var="${env_vars[$provider]}"
    if is_key_configured "$var"; then
      echo -e "  ${GREEN}✓${NC} $provider"
      CONFIGURED_PROVIDERS+=("$provider")
      has_configured=true
    fi
  done
  if [ "$has_configured" = false ]; then
    echo -e "  ${YELLOW}None configured yet${NC}"
  fi
  echo ""

  read -p "Configure a provider now? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo "Skipping cloud provider configuration."
    return
  fi

  # Provider selection loop
  while true; do
    echo ""
    read -p "Enter provider name (or 'done' to finish): " provider_choice

    if [[ "$provider_choice" == "done" ]] || [[ "$provider_choice" == "exit" ]]; then
      break
    fi

    # Normalize input
    provider_choice=$(echo "$provider_choice" | tr '[:upper:]' '[:lower:]')

    if [[ -z "${env_vars[$provider_choice]}" ]]; then
      echo -e "${RED}❌ Unknown provider: $provider_choice${NC}"
      echo "Valid options: ${!env_vars[@]}"
      continue
    fi

    local var="${env_vars[$provider_choice]}"
    local info="${providers[$provider_choice]}"

    echo ""
    echo -e "${CYAN}Configuring: ${GREEN}$provider_choice${NC}"
    echo -e "Get your key at: ${CYAN}${info##* - }${NC}"
    echo ""

    # Prompt for API key
    read -p "Enter API key (or press Enter to skip): " api_key_input

    if [ -z "$api_key_input" ]; then
      echo "Skipped $provider_choice"
      continue
    fi

    # Validate the key
    if ! validate_api_key "$api_key_input" "$provider_choice"; then
      echo -e "${RED}❌ Invalid API key${NC}"
      continue
    fi

    # Update the config file
    # Use sed to replace or add the key
    if grep -q "^${var}=" "$API_KEYS_FILE" 2>/dev/null; then
      # Key exists, update it
      sed -i "s|^${var}=.*|${var}=\"$api_key_input\"|" "$API_KEYS_FILE"
    else
      # Key doesn't exist, add it
      echo "${var}=\"$api_key_input\"" >> "$API_KEYS_FILE"
    fi

    chmod 600 "$API_KEYS_FILE"
    echo -e "${GREEN}✓${NC} API key saved for $provider_choice"
    CONFIGURED_PROVIDERS+=("$provider_choice")
  done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SHELL ALIASES SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

configure_aliases() {
  echo ""
  echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${CYAN}  SHELL ALIASES SETUP${NC}"
  echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════${NC}"
  echo ""

  # Detect shell config
  local shell_config=""
  if [ -n "$ZSH_VERSION" ]; then
    shell_config="$HOME/.zshrc"
  elif [ -n "$BASH_VERSION" ]; then
    shell_config="$HOME/.bashrc"
  else
    shell_config="$HOME/.profile"
  fi

  echo -e "${CYAN}Detected shell config:${NC} $shell_config"

  # Check if aliases are already sourced
  if grep -q "source.*$ALIASES_FILE" "$shell_config" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Aliases are already configured in $shell_config"

    # Check if the file exists
    if [ -f "$ALIASES_FILE" ]; then
      echo -e "${GREEN}✓${NC} Aliases file exists"
    else
      echo -e "${YELLOW}⚠️  Aliases file missing, creating...${NC}"
      create_aliases_file
    fi

    echo ""
    echo "Available aliases:"
    echo -e "  ${GREEN}claude${NC}     - Switch to Claude"
    echo -e "  ${GREEN}zai${NC}       - Switch to Z.AI"
    echo -e "  ${GREEN}deepseek${NC}  - Switch to DeepSeek"
    echo -e "  ${GREEN}kimi${NC}      - Switch to Kimi"
    echo -e "  ${GREEN}qwen${NC}      - Switch to Qwen"
    echo -e "  ${GREEN}cstatus${NC}   - Show current status"
    echo -e "  ${GREEN}clist${NC}     - List providers"
    return
  fi

  echo -e "${YELLOW}⚠️  Aliases not configured in $shell_config${NC}"
  echo ""
  echo "Shell aliases provide convenient shortcuts for switching providers."
  echo ""

  read -p "Install shell aliases? [y/N] " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo "Skipping aliases setup."
    return
  fi

  create_aliases_file

  # Add to shell config
  if ! grep -q "source.*$ALIASES_FILE" "$shell_config" 2>/dev/null; then
    echo "" >> "$shell_config"
    echo "# Claude Code Switcher aliases" >> "$shell_config"
    echo "source \"$ALIASES_FILE\"" >> "$shell_config"
  fi

  echo -e "${GREEN}✓${NC} Aliases installed to $ALIASES_FILE"
  echo -e "${GREEN}✓${NC} Aliases sourced in $shell_config"
  echo ""
  echo -e "${YELLOW}⚠️  To load aliases in your current session, run:${NC}"
  echo -e "  ${GREEN}source $shell_config${NC}"
  echo "  Or restart your terminal."
}

create_aliases_file() {
  cat > "$ALIASES_FILE" << 'EOF'
# Claude Code Switcher Aliases
# Source this file in your ~/.bashrc or ~/.zshrc:
#   source ~/.claude/aliases.sh

# Provider switching (all end with -switch to avoid conflicts)
claude-switch() { command claude-switch claude && claude; }
anthropic-api-switch() { command claude-switch anthropic-api && claude; }
zai-switch() { command claude-switch zai && claude; }
deepseek-switch() { command claude-switch deepseek && claude; }
kimi-switch() { command claude-switch kimi && claude; }
qwen-switch() { command claude-switch qwen && claude; }
groq-switch() { command claude-switch groq && claude; }
together-switch() { command claude-switch together && claude; }
ollama-switch() { command claude-switch ollama && claude; }
lmstudio-switch() { command claude-switch lmstudio && claude; }

# Status and info (cs- prefix)
alias cs-status='claude-switch status'
alias cs-list='claude-switch list'
alias cs-models='claude-switch models'
alias cs-keys='claude-switch keys'
alias cs-help='claude-switch help'
alias cs-update='claude-switch update'
alias cs-wizard='claude-switch wizard'

# Ollama quick switches
alias ollama7='ollama-switch qwen3-coder:7b'
alias ollama14='ollama-switch qwen3-coder:14b'
alias ollama32='ollama-switch qwen3-coder:32b'
EOF
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SUMMARY AND NEXT STEPS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

show_summary() {
  echo ""
  echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${GREEN}  CONFIGURATION SUMMARY${NC}"
  echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════${NC}"
  echo ""

  # Show configured providers
  if [ ${#CONFIGURED_PROVIDERS[@]} -gt 0 ]; then
    echo -e "${GREEN}✓ Configured cloud providers:${NC}"
    for provider in "${CONFIGURED_PROVIDERS[@]}"; do
      echo -e "  • ${GREEN}$provider${NC}"
    done
    echo ""
  else
    echo -e "${YELLOW}⚠️  No cloud providers configured${NC}"
    echo "  Run this wizard again or edit ~/.claude/api-keys.env"
    echo ""
  fi

  # Show next steps
  echo -e "${BOLD}${CYAN}Next Steps:${NC}"
  echo ""
  echo "1. Try switching providers:"
  echo -e "   ${GREEN}claude-switch list${NC}              # List all providers"
  echo -e "   ${GREEN}claude-switch claude${NC}            # Use official Claude"
  echo -e "   ${GREEN}claude-switch status${NC}            # Show current config"
  echo ""

  if [[ " ${CONFIGURED_PROVIDERS[@]} " =~ " zai " ]]; then
    echo -e "   ${GREEN}claude-switch zai${NC}               # Use Z.AI"
  fi
  if [[ " ${CONFIGURED_PROVIDERS[@]} " =~ " deepseek " ]]; then
    echo -e "   ${GREEN}claude-switch deepseek${NC}          # Use DeepSeek"
  fi

  echo ""
  echo "2. Get help:"
  echo -e "   ${GREEN}claude-switch help${NC}               # Show all commands"
  echo -e "   ${GREEN}claude-switch keys${NC}               # Where to get API keys"
  echo -e "   ${GREEN}claude-switch models <provider>${NC}  # Show model mapping"
  echo ""

  # Check for local providers
  if command -v ollama &> /dev/null || curl -s http://localhost:1234/v1/models > /dev/null 2>&1; then
    echo "3. Try local providers:"
    if command -v ollama &> /dev/null; then
      echo -e "   ${GREEN}claude-switch ollama${NC}           # Use local Ollama"
    fi
    if curl -s http://localhost:1234/v1/models > /dev/null 2>&1; then
      echo -e "   ${GREEN}claude-switch lmstudio${NC}         # Use LM Studio"
    fi
    echo ""
  fi

  echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${CYAN}Configuration complete!${NC}"
  echo ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MAIN WIZARD FLOW
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main() {
  # Step 1: Detect local providers
  detect_local_providers

  # Step 2: Configure cloud providers
  configure_cloud_providers

  # Step 3: Setup shell aliases
  configure_aliases

  # Step 4: Show summary
  show_summary
}

# Run the wizard
main
