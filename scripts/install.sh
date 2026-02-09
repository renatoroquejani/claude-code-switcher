#!/bin/bash
# Claude Code Switcher - Installer
# Installs the claude-switch script to ~/.local/bin/

set -e

VERSION="2.1.0"
SCRIPT_NAME="claude-switch"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_SRC="$PROJECT_ROOT/bin/$SCRIPT_NAME"
BIN_DST="$HOME/.local/bin/$SCRIPT_NAME"
CONFIG_EXAMPLE="$PROJECT_ROOT/config/api-keys.env.example"
CONFIG_DST="$HOME/.claude/api-keys.env"

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

echo ""
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Claude Code Switcher v${VERSION} - Installer${NC}"
echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if source script exists
if [ ! -f "$BIN_SRC" ]; then
  echo -e "${RED}❌ Error: Source script not found: $BIN_SRC${NC}"
  echo "Please run this script from the project repository."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo -e "${YELLOW}⚠️  jq is not installed${NC}"
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
fi

# Create ~/.local/bin if it doesn't exist
if [ ! -d "$HOME/.local/bin" ]; then
  echo -e "${CYAN}Creating ~/.local/bin...${NC}"
  mkdir -p "$HOME/.local/bin"
fi

# Install the script
echo -e "${CYAN}Installing $SCRIPT_NAME to ~/.local/bin...${NC}"
cp "$BIN_SRC" "$BIN_DST"
chmod +x "$BIN_DST"

# Create config directory if it doesn't exist
if [ ! -d "$HOME/.claude" ]; then
  echo -e "${CYAN}Creating ~/.claude directory...${NC}"
  mkdir -p "$HOME/.claude"
fi

# Create backups directory
if [ ! -d "$HOME/.claude/backups" ]; then
  mkdir -p "$HOME/.claude/backups"
fi

# Create api-keys.env if it doesn't exist
if [ ! -f "$CONFIG_DST" ]; then
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
#OPENROUTER_DEFAULT_MODEL="anthropic/claude-opus-4"
EOF
  fi
  chmod 600 "$CONFIG_DST"
  echo -e "${YELLOW}⚠️  Edit ~/.claude/api-keys.env to add your API keys${NC}"
else
  echo -e "${GREEN}✓${NC} api-keys.env already exists"
fi

# Add to PATH if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo ""
  echo -e "${YELLOW}⚠️  ~/.local/bin is not in your PATH${NC}"
  echo ""
  echo "Add this to your ~/.bashrc or ~/.zshrc:"
  echo -e "${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
  echo ""
  echo "Then run: source ~/.bashrc  # or source ~/.zshrc"
else
  echo -e "${GREEN}✓${NC} ~/.local/bin is in your PATH"
fi

# Offer to install shell aliases
echo ""
read -p "Install shell aliases for quick switching? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[SsYy]$ ]]; then
  ALIAS_FILE="$HOME/.claude/aliases.sh"

  cat > "$ALIAS_FILE" << 'EOF'
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

  # Detect shell and add to config
  if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
  else
    SHELL_CONFIG="$HOME/.bashrc"
  fi

  if ! grep -q "source.*$ALIAS_FILE" "$SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$SHELL_CONFIG"
    echo "# Claude Code Switcher aliases" >> "$SHELL_CONFIG"
    echo "source \"$ALIAS_FILE\"" >> "$SHELL_CONFIG"
    echo -e "${GREEN}✓${NC} Aliases installed to $SHELL_CONFIG"
    echo "Run: source $SHELL_CONFIG"
  else
    echo -e "${GREEN}✓${NC} Aliases already configured"
  fi
fi

# Done
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Quick start:"
echo -e "  ${CYAN}claude-switch help${NC}     - Show help"
echo -e "  ${CYAN}claude-switch list${NC}     - List providers"
echo -e "  ${CYAN}claude-switch status${NC}   - Show current config"
echo -e "  ${CYAN}claude-switch keys${NC}     - Where to get API keys"
echo ""
echo "Switch providers:"
echo -e "  ${CYAN}claude-switch zai${NC}      - Switch to Z.AI"
echo -e "  ${CYAN}claude-switch ollama${NC}   - Switch to local Ollama"
echo ""
echo "Add your API keys to: ${YELLOW}~/.claude/api-keys.env${NC}"
echo ""
