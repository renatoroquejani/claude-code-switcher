#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code Switcher - Auto-Update Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# This script updates claude-switch to the latest version from GitHub releases.
#
# Usage:
#   ./scripts/update.sh          # Update to latest version
#   REPO_OWNER=user ./update.sh  # Update from custom fork
#
# Environment Variables:
#   REPO_OWNER - GitHub username (default: renatoroquejani)
#   REPO_NAME  - Repository name (default: claude-code-switcher)
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
REPO_OWNER="${REPO_OWNER:-renatoroquejani}"
REPO_NAME="${REPO_NAME:-claude-code-switcher}"
REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="claude-switch"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

# Get current version from installed script
if [ -f "$SCRIPT_PATH" ]; then
  CURRENT_VERSION=$(grep '^VERSION=' "$SCRIPT_PATH" | cut -d'"' -f2)
else
  CURRENT_VERSION="not installed"
fi

echo ""
echo -e "${BOLD}━━━ Claude Code Switcher - Auto-Update ━━━${NC}"
echo ""
echo -e "${YELLOW}Repository:${NC} $REPO_URL"
echo -e "${YELLOW}Current version:${NC} $CURRENT_VERSION"
echo ""
echo -e "${YELLOW}Checking for updates...${NC}"

# Fetch latest release info from GitHub API
LATEST_INFO=$(curl -s "$API_URL" 2>/dev/null)

if [ -z "$LATEST_INFO" ]; then
  echo -e "${RED}❌ Failed to fetch release information${NC}"
  echo ""
  echo "Possible reasons:"
  echo "  • No internet connection"
  echo "  • GitHub API is rate limited"
  echo "  • Repository does not exist"
  echo ""
  echo "You can also download manually:"
  echo "  curl -fsSL $REPO_URL/raw/main/bin/claude-switch -o $SCRIPT_PATH"
  echo "  chmod +x $SCRIPT_PATH"
  exit 1
fi

# Parse latest version
LATEST_VERSION=$(echo "$LATEST_INFO" | jq -r '.tag_name' 2>/dev/null | sed 's/^v//')

if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" = "null" ]; then
  echo -e "${RED}❌ Failed to parse version information${NC}"
  echo ""
  echo "The repository might not have any releases yet."
  exit 1
fi

echo -e "${YELLOW}Latest version:${NC} $LATEST_VERSION"
echo ""

# Check if update is needed
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo -e "${GREEN}✓ Already up to date!${NC}"
  echo ""
  echo "You're running the latest version of claude-switch."
  exit 0
fi

echo -e "${CYAN}A new version is available!${NC}"
echo ""

# Show release notes
RELEASE_NOTES=$(echo "$LATEST_INFO" | jq -r '.body' 2>/dev/null)
if [ -n "$RELEASE_NOTES" ] && [ "$RELEASE_NOTES" != "null" ]; then
  echo -e "${BOLD}Release Notes:${NC}"
  echo "$RELEASE_NOTES" | head -20
  if [ $(echo "$RELEASE_NOTES" | wc -l) -gt 20 ]; then
    echo ""
    echo "... (truncated)"
  fi
  echo ""
fi

# Get download URL
# Try to find the claude-switch asset in the release
DOWNLOAD_URL=$(echo "$LATEST_INFO" | jq -r '.assets[] | select(.name == "claude-switch") | .browser_download_url' 2>/dev/null)

# If no asset found, use the raw file URL from main branch
if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
  DOWNLOAD_URL="${REPO_URL}/raw/main/bin/claude-switch"
  echo -e "${YELLOW}Using raw file URL (no release asset found)${NC}"
else
  echo -e "${YELLOW}Using release asset${NC}"
fi

echo ""
echo -e "${YELLOW}Download URL:${NC} $DOWNLOAD_URL"
echo ""

# Confirm update
read -p "Update now? [y/N] " -n 1 -r
echo ""
echo ""

if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
  echo "Update cancelled."
  exit 0
fi

# Create install directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Backup current script
if [ -f "$SCRIPT_PATH" ]; then
  BACKUP_PATH="${SCRIPT_PATH}.backup-${CURRENT_VERSION}"
  cp "$SCRIPT_PATH" "$BACKUP_PATH"
  echo -e "${YELLOW}✓ Backed up current version to:${NC} $BACKUP_PATH"
fi

# Download new version
echo -e "${YELLOW}Downloading...${NC}"

TMP_FILE=$(mktemp)
if curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE" 2>/dev/null; then
  chmod +x "$TMP_FILE"
  mv "$TMP_FILE" "$SCRIPT_PATH"
  echo -e "${GREEN}✓ Download complete${NC}"
else
  echo -e "${RED}❌ Failed to download update${NC}"
  rm -f "$TMP_FILE"

  # Restore backup if it exists
  if [ -f "$BACKUP_PATH" ]; then
    echo -e "${YELLOW}Restoring backup...${NC}"
    cp "$BACKUP_PATH" "$SCRIPT_PATH"
  fi

  exit 1
fi

# Verify the new script
if ! bash "$SCRIPT_PATH" help > /dev/null 2>&1; then
  echo -e "${RED}❌ Downloaded script appears to be broken${NC}"

  # Restore backup
  if [ -f "$BACKUP_PATH" ]; then
    echo -e "${YELLOW}Restoring backup...${NC}"
    cp "$BACKUP_PATH" "$SCRIPT_PATH"
  fi

  exit 1
fi

# Success!
echo ""
echo -e "${GREEN}━━━ Update Successful! ━━━${NC}"
echo ""
echo -e "${BOLD}Updated from:${NC} $CURRENT_VERSION"
echo -e "${BOLD}Updated to:${NC}   $LATEST_VERSION"
echo ""
echo -e "${CYAN}What's next?${NC}"
echo "  • Run: ${BOLD}claude-switch help${NC} to see new features"
echo "  • Read release notes at: ${REPO_URL}/releases/tag/v${LATEST_VERSION}"
echo ""

if [ -f "$BACKUP_PATH" ]; then
  echo -e "${YELLOW}Backup saved at:${NC} $BACKUP_PATH"
  echo "You can remove it with: rm $BACKUP_PATH"
fi
