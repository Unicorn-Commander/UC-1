#!/bin/bash

# UnicornCommander SDDM Theme Installation Script
# Professional login theme with cosmic branding

set -e

# Colors for output
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander SDDM Theme Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
   echo "Usage: sudo ./install-sddm-theme.sh"
   exit 1
fi

# Check if SDDM is installed
if ! command -v sddm &> /dev/null; then
    echo -e "${RED}❌ SDDM is not installed on this system${NC}"
    exit 1
fi

# Variables
THEME_NAME="UnicornCommander"
THEME_DIR="/usr/share/sddm/themes"
SOURCE_DIR="$(dirname "$0")/$THEME_NAME"
INSTALL_DIR="$THEME_DIR/$THEME_NAME"
CONFIG_FILE="/etc/sddm.conf.d/kde_settings.conf"

echo -e "${BLUE}Installing UnicornCommander SDDM theme...${NC}"

# Create SDDM themes directory if it doesn't exist
mkdir -p "$THEME_DIR"

# Remove existing theme if present
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Removing existing UnicornCommander theme...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Copy theme files
echo -e "${BLUE}📦 Copying theme files...${NC}"
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Source theme directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

cp -r "$SOURCE_DIR" "$INSTALL_DIR"

# Set proper permissions
echo -e "${BLUE}🔒 Setting permissions...${NC}"
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod 644 "$INSTALL_DIR"/*.conf "$INSTALL_DIR"/*.desktop

# Create SDDM config directory if it doesn't exist
mkdir -p "$(dirname "$CONFIG_FILE")"

# Configure SDDM to use the new theme
echo -e "${BLUE}⚙️  Configuring SDDM...${NC}"
cat > "$CONFIG_FILE" << EOF
[Theme]
Current=$THEME_NAME
ThemeDir=$THEME_DIR
FacesDir=/usr/share/sddm/faces
CursorTheme=breeze_cursors

[General]
Numlock=on
EOF

# Verify installation
if [ -f "$INSTALL_DIR/Main.qml" ] && [ -f "$INSTALL_DIR/metadata.desktop" ]; then
    echo ""
    echo -e "${GREEN}✅ UnicornCommander SDDM theme installed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Theme Details:${NC}"
    echo -e "  📍 Location: $INSTALL_DIR"
    echo -e "  ⚙️  Config: $CONFIG_FILE"
    echo -e "  🎨 Theme: $THEME_NAME"
    echo ""
    echo -e "${YELLOW}💡 Tips:${NC}"
    echo -e "  • ${BLUE}Test the theme:${NC} sudo sddm-greeter-qt6 --test-mode --theme $INSTALL_DIR"
    echo -e "  • ${BLUE}Restart SDDM:${NC} sudo systemctl restart sddm"
    echo -e "  • ${BLUE}Check config:${NC} sddm --example-config"
    echo ""
    echo -e "${PURPLE}🦄 The cosmic login experience awaits! ✨${NC}"
else
    echo -e "${RED}❌ Installation failed - theme files not found${NC}"
    exit 1
fi

# Optional: Test the theme
read -p "Do you want to test the theme now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🧪 Testing SDDM theme...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit the test${NC}"
    sleep 2
    sddm-greeter-qt6 --test-mode --theme "$INSTALL_DIR" || {
        echo -e "${YELLOW}⚠️  Test mode failed. The theme should still work on actual login.${NC}"
    }
fi

echo ""
echo -e "${GREEN}🎉 Installation complete! Restart your system to see the new login theme.${NC}"