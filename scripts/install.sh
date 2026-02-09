#!/bin/bash
# Claude Code Switcher - Smart Installer
# Validates existing installation and updates only what's needed

set -e

VERSION="2.1.0"
SCRIPT_NAME="claude-switch"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_SRC="$PROJECT_ROOT/bin/$SCRIPT_NAME"
BIN_DST="$HOME/.local/bin/$SCRIPT_NAME"
CONFIG_EXAMPLE="$PROJECT_ROOT/config/api-keys.env.example"
CONFIG_DST="$HOME/.claude/api-keys.env"
ALIAS_DST="$HOME/.claude/aliases.sh"

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

# Track what needs to be done
NEEDS_UPDATE=false
NEEDS_ALIASES=false
ALIASES_OUTDATED=false

echo ""
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Claude Code Switcher v${VERSION} - Smart Installer${NC}"
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if source script exists
if [ ! -f "$BIN_SRC" ]; then
  echo -e "${RED}❌ Error: Source script not found: $BIN_SRC${NC}"
  echo "Please run this script from the project repository."
  exit 1
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATE EXISTING INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo -e "${CYAN}Checking existing installation...${NC}"

# Check if already installed
if [ -f "$BIN_DST" ]; then
  INSTALLED_VERSION=$(grep "^VERSION=" "$BIN_DST" 2>/dev/null | cut -d'"' -f2)
  echo -e "${GREEN}✓${NC} Already installed: v${INSTALLED_VERSION:-unknown}"

  # Compare versions
  if [ "$INSTALLED_VERSION" != "$VERSION" ]; then
    echo -e "${YELLOW}⚠️  New version available: v${INSTALLED_VERSION} → v${VERSION}${NC}"
    NEEDS_UPDATE=true
  else
    # Check if files are different (content comparison)
    if ! cmp -s "$BIN_SRC" "$BIN_DST"; then
      echo -e "${YELLOW}⚠️  Script has local modifications${NC}"
      NEEDS_UPDATE=true
    else
      echo -e "${GREEN}✓${NC} Script is up to date"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  Not installed yet${NC}"
  NEEDS_UPDATE=true
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo -e "${RED}❌ jq is not installed${NC}"
  echo "Installing jq..."

  if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y jq
  elif command -v dnf &> /dev/null; then
    sudo dnf install -y jq
  elif command -v pacman &> /dev/null; then
    sudo pacman -S jq
  elif command -v brew &> /dev/null; then
    brew install jq
  else
    echo -e "${RED}❌ Cannot install jq automatically${NC}"
    echo "Please install jq manually:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  Fedora: sudo dnf install jq"
    echo "  macOS: brew install jq"
    exit 1
  fi
  echo -e "${GREEN}✓${NC} jq installed"
else
  echo -e "${GREEN}✓${NC} jq is installed"
fi

# Check directories
echo ""
echo -e "${CYAN}Checking directories...${NC}"

if [ ! -d "$HOME/.local/bin" ]; then
  echo -e "${YELLOW}⚠️  ~/.local/bin not found${NC}"
  mkdir -p "$HOME/.local/bin"
  echo -e "${GREEN}✓${NC} Created ~/.local/bin"
else
  echo -e "${GREEN}✓${NC} ~/.local/bin exists"
fi

if [ ! -d "$HOME/.claude" ]; then
  echo -e "${YELLOW}⚠️  ~/.claude not found${NC}"
  mkdir -p "$HOME/.claude"
  echo -e "${GREEN}✓${NC} Created ~/.claude"
else
  echo -e "${GREEN}✓${NC} ~/.claude exists"
fi

if [ ! -d "$HOME/.claude/backups" ]; then
  mkdir -p "$HOME/.claude/backups"
fi

# Check PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo ""
  echo -e "${YELLOW}⚠️  ~/.local/bin is not in your PATH${NC}"
  echo ""
  echo "Add this to your ~/.bashrc or ~/.zshrc:"
  echo -e "${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
  echo ""
  echo "Then run: source ~/.bashrc  # or source ~/.zshrc"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALL OR UPDATE SCRIPT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$NEEDS_UPDATE" = true ]; then
  echo ""
  echo -e "${CYAN}Installing $SCRIPT_NAME v${VERSION}...${NC}"
  cp "$BIN_SRC" "$BIN_DST"
  chmod +x "$BIN_DST"
  echo -e "${GREEN}✓${NC} Script installed/updated"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATE API KEYS FILE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${CYAN}Checking API keys configuration...${NC}"

if [ ! -f "$CONFIG_DST" ]; then
  echo -e "${YELLOW}⚠️  api-keys.env not found${NC}"
  if [ -f "$CONFIG_EXAMPLE" ]; then
    echo -e "${CYAN}Creating api-keys.env from example...${NC}"
    cp "$CONFIG_EXAMPLE" "$CONFIG_DST"
  else
    echo -e "${CYAN}Creating empty api-keys.env...${NC}"
    cat > "$CONFIG_DST" << 'EOF'
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
  fi
  chmod 600 "$CONFIG_DST"
  echo -e "${YELLOW}⚠️  Edit ~/.claude/api-keys.env to add your API keys${NC}"
else
  echo -e "${GREEN}✓${NC} api-keys.env exists"

  # Check if file has correct permissions
  PERMS=$(stat -c %a "$CONFIG_DST" 2>/dev/null || stat -f %A "$CONFIG_DST" 2>/dev/null)
  if [ "$PERMS" != "600" ]; then
    echo -e "${YELLOW}⚠️  Fixing permissions (600)${NC}"
    chmod 600 "$CONFIG_DST"
  fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATE ALIASES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${CYAN}Checking shell aliases...${NC}"

# Detect shell config
if [ -n "$ZSH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.bashrc"
else
  SHELL_CONFIG="$HOME/.profile"
fi

if [ -f "$ALIAS_DST" ]; then
  echo -e "${GREEN}✓${NC} Aliases file exists"

  # Check if aliases are sourced in shell config
  if grep -q "source.*$ALIAS_DST" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Aliases are loaded in $SHELL_CONFIG"
  else
    echo -e "${YELLOW}⚠️  Aliases file exists but not loaded in $SHELL_CONFIG${NC}"
    NEEDS_ALIASES=true
  fi
else
  echo -e "${YELLOW}⚠️  Aliases file not found${NC}"
  NEEDS_ALIASES=true
fi

# Offer to install/update aliases
if [ "$NEEDS_ALIASES" = true ]; then
  echo ""
  read -p "Install shell aliases for quick switching? [y/N] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[SsYy]$ ]]; then
    # Create aliases file
    cat > "$ALIAS_DST" << 'EOF'
# Claude Code Switcher Aliases
# Source this file in your ~/.bashrc or ~/.zshrc:
#   source ~/.claude/aliases.sh

# Quick provider switching
alias claude='claude-switch claude'
alias zai='claude-switch zai'
alias deepseek='claude-switch deepseek'
alias kimi='claude-switch kimi'
alias qwen='claude-switch qwen'
alias ollama='claude-switch ollama'
alias lmstudio='claude-switch lmstudio'

# Status and info
alias cstatus='claude-switch status'
alias clist='claude-switch list'
alias cmodels='claude-switch models'

# Common model-specific switches
alias ollama7='claude-switch ollama:qwen3-coder:7b'
alias ollama14='claude-switch ollama:qwen3-coder:14b'
alias ollama32='claude-switch ollama:qwen3-coder:32b'
EOF

    # Add to shell config if not already there
    if ! grep -q "source.*$ALIAS_DST" "$SHELL_CONFIG" 2>/dev/null; then
      echo "" >> "$SHELL_CONFIG"
      echo "# Claude Code Switcher aliases" >> "$SHELL_CONFIG"
      echo "source \"$ALIAS_DST\"" >> "$SHELL_CONFIG"
    fi

    echo -e "${GREEN}✓${NC} Aliases installed to $ALIAS_DST"

    # Source aliases immediately for current session
    source "$ALIAS_DST"
    echo -e "${GREEN}✓${NC} Aliases loaded in current session"
  fi
else
  echo -e "${GREEN}✓${NC} Aliases are configured"
  # Load existing aliases for current session
  if [ -f "$ALIAS_DST" ]; then
    source "$ALIAS_DST"
    echo -e "${GREEN}✓${NC} Aliases loaded in current session"
  fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SUMMARY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Aliases are ready to use! Try:"
echo -e "  ${CYAN}cstatus${NC}           - Show current config"
echo -e "  ${CYAN}clist${NC}             - List providers"
echo -e "  ${CYAN}zai${NC}               - Switch to Z.AI"
echo -e "  ${CYAN}claude${NC}            - Switch to Claude"
echo ""
echo "Or use full commands:"
echo -e "  ${CYAN}claude-switch help${NC}     - Show help"
echo -e "  ${CYAN}claude-switch keys${NC}     - Where to get API keys"
echo ""
echo "Add your API keys to: ${YELLOW}~/.claude/api-keys.env${NC}"
echo ""
