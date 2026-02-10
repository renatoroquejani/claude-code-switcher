#!/bin/bash
# Claude Code Switcher - Smart Installer
# Supports both local (git clone) and remote (curl) installation

set -e

VERSION="2.2.0"
SCRIPT_NAME="claude-switch"
REPO_URL="https://github.com/renatoroquejani/claude-code-switcher"
RAW_BASE_URL="https://raw.githubusercontent.com/renatoroquejani/claude-code-switcher/main"

# Detect installation mode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Try local paths first
BIN_SRC="$PROJECT_ROOT/bin/$SCRIPT_NAME"
CONFIG_EXAMPLE="$PROJECT_ROOT/config/api-keys.env.example"
ALIASES_SRC="$PROJECT_ROOT/config/aliases.sh"

# Destination paths
BIN_DST="$HOME/.local/bin/$SCRIPT_NAME"
CONFIG_DST="$HOME/.claude/api-keys.env"
ALIAS_DST="$HOME/.claude/aliases.sh"

# Installation mode
REMOTE_MODE=false

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

echo ""
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Claude Code Switcher v${VERSION} - Smart Installer${NC}"
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DOWNLOAD FUNCTIONS (for remote installation)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

download_file() {
  local url="$1"
  local dest="$2"
  local desc="$3"

  if command -v curl &> /dev/null; then
    echo -e "${CYAN}Downloading $desc...${NC}"
    curl -fsSL "$url" -o "$dest"
  elif command -v wget &> /dev/null; then
    echo -e "${CYAN}Downloading $desc...${NC}"
    wget -q "$url" -O "$dest"
  else
    echo -e "${RED}❌ Error: Neither curl nor wget is available${NC}"
    echo "Please install curl or wget to continue."
    exit 1
  fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DETECTION: LOCAL OR REMOTE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ ! -f "$BIN_SRC" ]; then
  echo -e "${YELLOW}⚠️  Local files not found, switching to remote mode...${NC}"
  REMOTE_MODE=true

  # Create temp directory for downloads
  TEMP_DIR=$(mktemp -d)
  BIN_SRC="$TEMP_DIR/$SCRIPT_NAME"
  ALIASES_SRC="$TEMP_DIR/aliases.sh"

  # Download main script
  download_file "$RAW_BASE_URL/bin/$SCRIPT_NAME" "$BIN_SRC" "main script"

  # Try to download aliases file
  if ! download_file "$RAW_BASE_URL/config/aliases.sh" "$ALIASES_SRC" "aliases file" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Could not download aliases file, will create default${NC}"
    ALIASES_SRC=""
  fi
else
  echo -e "${GREEN}✓${NC} Local installation detected"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATE EXISTING INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
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
  echo ""
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
  chmod 700 "$HOME/.claude"
  echo -e "${GREEN}✓${NC} Created ~/.claude"
else
  echo -e "${GREEN}✓${NC} ~/.claude exists"
fi

if [ ! -d "$HOME/.claude/backups" ]; then
  mkdir -p "$HOME/.claude/backups"
  chmod 700 "$HOME/.claude/backups"
fi

# Check and add ~/.local/bin to PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo ""
  echo -e "${YELLOW}⚠️  ~/.local/bin is not in your PATH${NC}"
  echo ""

  # Detect shell config file
  if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
  else
    SHELL_CONFIG="$HOME/.bashrc"
  fi

  # Add PATH to shell config if not already there
  if ! grep -q "PATH.*\.local/bin" "$SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$SHELL_CONFIG"
    echo "# Add ~/.local/bin to PATH (required for claude-switch)" >> "$SHELL_CONFIG"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_CONFIG"
    echo -e "${GREEN}✓${NC} Added ~/.local/bin to PATH in $SHELL_CONFIG"
  fi

  echo ""
  echo -e "${CYAN}Run this command to activate:${NC}"
  echo -e "${GREEN}source $SHELL_CONFIG${NC}"
  echo ""
  echo "Or restart your terminal."
else
  echo -e "${GREEN}✓${NC} ~/.local/bin is already in your PATH"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALL OR UPDATE SCRIPT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "$NEEDS_UPDATE" = true ]; then
  echo ""
  echo -e "${CYAN}Installing $SCRIPT_NAME v${VERSION}...${NC}"
  cp "$BIN_SRC" "$BIN_DST"
  chmod 755 "$BIN_DST"
  echo -e "${GREEN}✓${NC} Script installed/updated"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VALIDATE API KEYS FILE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${CYAN}Checking API keys configuration...${NC}"

if [ ! -f "$CONFIG_DST" ]; then
  echo -e "${YELLOW}⚠️  api-keys.env not found${NC}"
  echo -e "${CYAN}Creating api-keys.env...${NC}"

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

# Groq
#GROQ_API_KEY="your-key-here"

# Together AI
#TOGETHER_API_KEY="your-key-here"

# OpenRouter
#OPENROUTER_API_KEY="your-key-here"
#OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4.6"

# Anthropic API (pay-as-you-go)
#ANTHROPIC_API_KEY="your-key-here"
EOF

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
    # Use downloaded aliases if available, otherwise create default
    if [ -n "$ALIASES_SRC" ] && [ -f "$ALIASES_SRC" ]; then
      cp "$ALIASES_SRC" "$ALIAS_DST"
    else
      # Create default aliases
      cat > "$ALIAS_DST" << 'EOF'
#!/bin/bash
# Claude Code Switcher - Shell Aliases
# Source this file in your ~/.bashrc or ~/.zshrc

# Provider switching (all end with -switch to avoid conflicts)
claude-switch() {
  command claude-switch claude && claude
}
anthropic-api-switch() {
  command claude-switch anthropic-api && claude
}
zai-switch() {
  command claude-switch zai && claude
}
deepseek-switch() {
  command claude-switch deepseek && claude
}
kimi-switch() {
  command claude-switch kimi && claude
}
qwen-switch() {
  command claude-switch qwen && claude
}
groq-switch() {
  command claude-switch groq && claude
}
together-switch() {
  command claude-switch together && claude
}
openrouter-switch() {
  if [ -z "$1" ]; then
    command claude-switch openrouter && claude
  else
    command claude-switch "openrouter:$1" && claude
  fi
}
ollama-switch() {
  if [ -z "$1" ]; then
    command claude-switch ollama && claude
  else
    command claude-switch "ollama:$1" && claude
  fi
}
lmstudio-switch() {
  command claude-switch lmstudio && claude
}

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
    fi

    # Add to shell config if not already there
    if ! grep -q "source.*$ALIAS_DST" "$SHELL_CONFIG" 2>/dev/null; then
      echo "" >> "$SHELL_CONFIG"
      echo "# Claude Code Switcher aliases" >> "$SHELL_CONFIG"
      echo "source \"$ALIAS_DST\"" >> "$SHELL_CONFIG"
    fi

    echo -e "${GREEN}✓${NC} Aliases installed to $ALIAS_DST"
    echo -e "${GREEN}✓${NC} Aliases sourced in $SHELL_CONFIG"
  fi
else
  echo -e "${GREEN}✓${NC} Aliases are configured"
fi

# Cleanup temp directory
if [ "$REMOTE_MODE" = true ] && [ -n "$TEMP_DIR" ]; then
  rm -rf "$TEMP_DIR"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SUMMARY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if aliases are loaded in current shell
if ! type cs-status &>/dev/null; then
  echo -e "${YELLOW}⚠️  Aliases are not loaded in this session yet.${NC}"
  echo ""
  echo -e "${CYAN}Run this command to load aliases now:${NC}"
  echo -e "${GREEN}source $ALIAS_DST${NC}"
  echo ""
  echo "Or restart your terminal."
else
  echo "Aliases are ready to use! Try:"
  echo -e "  ${CYAN}cs-status${NC}           - Show current config"
  echo -e "  ${CYAN}cs-list${NC}             - List providers"
  echo -e "  ${CYAN}zai-switch${NC}          - Switch to Z.AI"
  echo -e "  ${CYAN}claude-switch${NC}       - Switch to Claude"
fi

echo ""
echo "Full commands:"
echo -e "  ${CYAN}claude-switch help${NC}     - Show help"
echo -e "  ${CYAN}claude-switch keys${NC}     - Where to get API keys"
echo ""
echo "Add your API keys to: ${YELLOW}~/.claude/api-keys.env${NC}"
echo ""
