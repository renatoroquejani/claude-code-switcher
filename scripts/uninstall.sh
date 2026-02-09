#!/bin/bash
# Claude Code Switcher - Uninstaller
# Removes the claude-switch script and related files

set -e

SCRIPT_NAME="claude-switch"
BIN_DST="$HOME/.local/bin/$SCRIPT_NAME"
ALIAS_FILE="$HOME/.claude/aliases.sh"
CONFIG_DIR="$HOME/.claude"

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
NC=$'\033[0m'

echo ""
echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Claude Code Switcher - Uninstaller${NC}"
echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Confirm
echo -e "${YELLOW}This will remove:${NC}"
echo "  - $BIN_DST"
echo "  - $ALIAS_FILE"
echo -e "\n${RED}Note: Your API keys ($CONFIG_DIR/api-keys.env) will be kept.${NC}"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
  echo "Uninstall cancelled"
  exit 0
fi

# Remove the script
if [ -f "$BIN_DST" ]; then
  echo -e "${CYAN}Removing $BIN_DST...${NC}"
  rm -f "$BIN_DST"
  echo -e "${GREEN}✓${NC} Removed"
else
  echo -e "${YELLOW}⚠️  Script not found at $BIN_DST${NC}"
fi

# Remove aliases file
if [ -f "$ALIAS_FILE" ]; then
  echo -e "${CYAN}Removing $ALIAS_FILE...${NC}"
  rm -f "$ALIAS_FILE"
  echo -e "${GREEN}✓${NC} Removed"
fi

# Remove alias sourcing from shell config
if [ -n "$ZSH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
else
  SHELL_CONFIG="$HOME/.bashrc"
fi

if [ -f "$SHELL_CONFIG" ] && grep -q "source.*$ALIAS_FILE" "$SHELL_CONFIG" 2>/dev/null; then
  echo -e "${CYAN}Removing alias sourcing from $SHELL_CONFIG...${NC}"
  # Create temp file without the alias lines
  grep -v "source.*$ALIAS_FILE" "$SHELL_CONFIG" > "$SHELL_CONFIG.tmp"
  mv "$SHELL_CONFIG.tmp" "$SHELL_CONFIG"
  echo -e "${GREEN}✓${NC} Removed"
fi

# Ask about config directory
echo ""
read -p "Remove entire ~/.claude directory? ${RED}(This will delete backups and API keys!)${NC} [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[SsYy]$ ]]; then
  echo -e "${CYAN}Removing $CONFIG_DIR...${NC}"
  rm -rf "$CONFIG_DIR"
  echo -e "${GREEN}✓${NC} Removed"
else
  echo -e "${YELLOW}Keeping $CONFIG_DIR${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Uninstall complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "If you modified your PATH, you may want to remove:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "from your ~/.bashrc or ~/.zshrc"
echo ""
