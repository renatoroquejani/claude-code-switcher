#!/bin/bash
# Claude Code Switcher - Uninstaller
# Removes the claude-switch script and related files

set -e

SCRIPT_NAME="claude-switch"
BIN_DST="$HOME/.local/bin/$SCRIPT_NAME"
ALIAS_FILE="$HOME/.claude/aliases.sh"
CONFIG_DIR="$HOME/.claude"
SETTINGS_FILE="$CONFIG_DIR/settings.json"
BACKUP_DIR="$CONFIG_DIR/backups"
SWITCHER_STATE_DIR="$HOME/.claude-switcher"

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

confirm_prompt() {
  local prompt="$1"
  local reply=""

  if [ -r /dev/tty ]; then
    read -p "$prompt" -n 1 -r reply < /dev/tty
    printf '\n'
  else
    return 1
  fi

  [[ "$reply" =~ ^[SsYy]$ ]]
}

cleanup_switcher_settings() {
  local tmp_file
  local backup_path

  if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}⚠️  No Claude settings file found at $SETTINGS_FILE${NC}"
    return 0
  fi

  if ! command -v jq > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  jq not found, skipping settings cleanup${NC}"
    return 0
  fi

  mkdir -p "$BACKUP_DIR"
  chmod 700 "$BACKUP_DIR" 2>/dev/null || true
  backup_path="$BACKUP_DIR/settings.json.pre-claude-switcher-uninstall-$(date +%Y%m%d-%H%M%S)"
  cp "$SETTINGS_FILE" "$backup_path"
  chmod 600 "$backup_path" 2>/dev/null || true

  tmp_file=$(mktemp "${SETTINGS_FILE}.tmp.XXXXXX")
  jq 'del(.env.ANTHROPIC_AUTH_TOKEN,
          .env.ANTHROPIC_BASE_URL,
          .env.ANTHROPIC_MODEL,
          .env.ANTHROPIC_DEFAULT_OPUS_MODEL,
          .env.ANTHROPIC_DEFAULT_SONNET_MODEL,
          .env.ANTHROPIC_DEFAULT_HAIKU_MODEL)' \
     "$SETTINGS_FILE" > "$tmp_file"
  mv "$tmp_file" "$SETTINGS_FILE"
  chmod 600 "$SETTINGS_FILE" 2>/dev/null || true

  echo -e "${GREEN}✓${NC} Cleaned Claude settings managed by claude-switcher"
  echo "Backup: $backup_path"
}

echo ""
echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Claude Code Switcher - Uninstaller${NC}"
echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Confirm
echo -e "${YELLOW}This will remove:${NC}"
echo "  - $BIN_DST"
echo "  - $ALIAS_FILE"
echo -e "\n${GREEN}This will keep:${NC}"
echo "  - $CONFIG_DIR (Claude Code settings, projects, backups, and API keys)"
echo "  - $SWITCHER_STATE_DIR (unless you explicitly remove it below)"
echo ""
echo -e "${GREEN}This will clean from $SETTINGS_FILE:${NC}"
echo "  - ANTHROPIC_AUTH_TOKEN"
echo "  - ANTHROPIC_BASE_URL"
echo "  - ANTHROPIC_MODEL"
echo "  - ANTHROPIC_DEFAULT_OPUS_MODEL"
echo "  - ANTHROPIC_DEFAULT_SONNET_MODEL"
echo "  - ANTHROPIC_DEFAULT_HAIKU_MODEL"
echo ""
if ! confirm_prompt "Continue? [y/N] "; then
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

echo ""
cleanup_switcher_settings

# Ask about switcher state directory
echo ""
if confirm_prompt "Remove ~/.claude-switcher state directory? ${RED}(This removes saved accounts, profiles, custom providers, and switcher-managed runtime state)${NC} [y/N] "; then
  echo -e "${CYAN}Removing $SWITCHER_STATE_DIR...${NC}"
  rm -rf "$SWITCHER_STATE_DIR"
  echo -e "${GREEN}✓${NC} Removed"
else
  echo -e "${YELLOW}Keeping $SWITCHER_STATE_DIR${NC}"
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
