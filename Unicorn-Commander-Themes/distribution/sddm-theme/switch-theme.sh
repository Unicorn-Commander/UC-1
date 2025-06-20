#!/bin/bash

# SDDM Theme Switcher for Unicorn Commander themes
# Allows easy switching between UnicornCommander and MagicUnicorn themes

set -e

# Colors for output
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🦄 Unicorn Commander SDDM Theme Switcher${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
   echo "Usage: sudo ./switch-theme.sh [UnicornCommander|MagicUnicorn]"
   exit 1
fi

CONFIG_FILE="/etc/sddm.conf.d/kde_settings.conf"
THEME_DIR="/usr/share/sddm/themes"

# Get current theme
CURRENT_THEME=$(grep "Current=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 || echo "Unknown")

echo -e "${BLUE}Current theme: ${YELLOW}$CURRENT_THEME${NC}"
echo ""

# If no argument provided, show menu
if [ $# -eq 0 ]; then
    echo -e "${BLUE}Available themes:${NC}"
    echo -e "  ${GREEN}1)${NC} UnicornCommander (Windows 11 inspired with cosmic particles)"
    echo -e "  ${GREEN}2)${NC} MagicUnicorn (macOS inspired with elegant design)"
    echo ""
    read -p "Select theme (1-2): " -n 1 -r choice
    echo ""
    
    case $choice in
        1)
            NEW_THEME="UnicornCommander"
            ;;
        2)
            NEW_THEME="MagicUnicorn"
            ;;
        *)
            echo -e "${RED}❌ Invalid selection${NC}"
            exit 1
            ;;
    esac
else
    NEW_THEME="$1"
fi

# Validate theme exists
if [ ! -d "$THEME_DIR/$NEW_THEME" ]; then
    echo -e "${RED}❌ Theme '$NEW_THEME' not found in $THEME_DIR${NC}"
    echo -e "${YELLOW}Available themes:${NC}"
    ls -1 "$THEME_DIR" | grep -E "(UnicornCommander|MagicUnicorn)"
    exit 1
fi

# Check if already current theme
if [ "$CURRENT_THEME" = "$NEW_THEME" ]; then
    echo -e "${YELLOW}ℹ️  '$NEW_THEME' is already the active theme${NC}"
    exit 0
fi

# Switch theme
echo -e "${BLUE}🔄 Switching to $NEW_THEME theme...${NC}"

# Update configuration
sed -i "s/Current=.*/Current=$NEW_THEME/" "$CONFIG_FILE"

# Verify the change
NEW_CURRENT=$(grep "Current=" "$CONFIG_FILE" | cut -d'=' -f2)

if [ "$NEW_CURRENT" = "$NEW_THEME" ]; then
    echo -e "${GREEN}✅ Successfully switched to $NEW_THEME theme!${NC}"
    echo ""
    echo -e "${BLUE}Theme Details:${NC}"
    echo -e "  🎨 Active Theme: $NEW_THEME"
    echo -e "  📍 Location: $THEME_DIR/$NEW_THEME"
    echo -e "  ⚙️  Config: $CONFIG_FILE"
    echo ""
    echo -e "${YELLOW}💡 To apply the change:${NC}"
    echo -e "  • ${BLUE}Restart SDDM:${NC} sudo systemctl restart sddm"
    echo -e "  • ${BLUE}Test theme:${NC} sudo sddm-greeter-qt6 --test-mode --theme $THEME_DIR/$NEW_THEME"
    echo ""
    echo -e "${PURPLE}🦄 Your new login theme is ready! ✨${NC}"
else
    echo -e "${RED}❌ Failed to switch theme${NC}"
    exit 1
fi