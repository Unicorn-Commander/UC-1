#!/bin/bash

# Create proper Global Theme packages for KDE Plasma 6
# This script creates theme packages that work with System Settings > Global Theme

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🦄 Creating Global Theme Packages for KDE Plasma 6${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root for system install
if [ "$EUID" -eq 0 ]; then
    PLASMA_THEMES_DIR="/usr/share/plasma/look-and-feel"
    echo -e "${YELLOW}⚠️  Installing system-wide to $PLASMA_THEMES_DIR${NC}"
else
    PLASMA_THEMES_DIR="$HOME/.local/share/plasma/look-and-feel"
    echo -e "${BLUE}👤 Installing for user to $PLASMA_THEMES_DIR${NC}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"

# Create installation directory
mkdir -p "$PLASMA_THEMES_DIR"

# Clean up old theme installations with incorrect names
echo -e "${YELLOW}🧹 Cleaning up old theme installations...${NC}"
OLD_THEMES=(
    "UC-Mac-Light" "UC-Mac-Dark" 
    "UC-Windows-Light" "UC-Windows-Dark"
    "UnicornCommander-Light" "UnicornCommander-Dark"
    "MagicUnicorn-Light" "MagicUnicorn-Dark"
    "org.unicorncommander.windows.light" "org.unicorncommander.windows.dark"
    "org.unicorncommander.mac.light" "org.unicorncommander.mac.dark"
)

for old_theme in "${OLD_THEMES[@]}"; do
    if [ -d "$PLASMA_THEMES_DIR/$old_theme" ]; then
        rm -rf "$PLASMA_THEMES_DIR/$old_theme"
        echo -e "${YELLOW}   Removed old theme: $old_theme${NC}"
    fi
done

# Install each theme
for THEME_DIR in "$THEMES_DIR"/*/; do
    THEME_NAME=$(basename "$THEME_DIR")
    
    echo -e "${BLUE}📦 Installing $THEME_NAME...${NC}"
    
    # Read the theme ID from metadata.json
    THEME_ID=$(grep '"Id":' "$THEME_DIR/metadata.json" | sed 's/.*"Id": *"\([^"]*\)".*/\1/')
    
    if [ -z "$THEME_ID" ]; then
        echo -e "${RED}❌ Could not find theme ID in $THEME_DIR/metadata.json${NC}"
        continue
    fi
    
    echo -e "${BLUE}   Theme ID: $THEME_ID${NC}"
    
    # Create theme directory using theme ID
    INSTALL_DIR="$PLASMA_THEMES_DIR/$THEME_ID"
    rm -rf "$INSTALL_DIR"
    
    # Copy theme contents
    cp -r "$THEME_DIR" "$INSTALL_DIR"
    
    # Fix asset paths in layout scripts to use absolute paths
    if [ -f "$INSTALL_DIR/contents/layouts/org.kde.plasma.desktop-layout.js" ]; then
        sed -i "s|/usr/share/plasma/look-and-feel/$THEME_NAME/|/usr/share/plasma/look-and-feel/$THEME_ID/|g" \
            "$INSTALL_DIR/contents/layouts/org.kde.plasma.desktop-layout.js"
        
        # If installing to user directory, update paths accordingly
        if [ "$EUID" -ne 0 ]; then
            sed -i "s|/usr/share/plasma/look-and-feel/|$HOME/.local/share/plasma/look-and-feel/|g" \
                "$INSTALL_DIR/contents/layouts/org.kde.plasma.desktop-layout.js"
        fi
        
        echo -e "${GREEN}   ✅ Fixed layout script paths${NC}"
    fi
    
    # Fix wallpaper paths in defaults
    if [ -f "$INSTALL_DIR/contents/defaults" ]; then
        if [ "$EUID" -eq 0 ]; then
            sed -i 's|file:///home/ucadmin/UC-1/.*wallpapers/|file:///usr/share/wallpapers/UnicornCommander/|g' \
                "$INSTALL_DIR/contents/defaults"
        else
            sed -i 's|file:///home/ucadmin/UC-1/.*wallpapers/|file://'$HOME'/.local/share/wallpapers/UnicornCommander/|g' \
                "$INSTALL_DIR/contents/defaults"
        fi
        echo -e "${GREEN}   ✅ Fixed wallpaper paths in defaults${NC}"
    fi
    
    # Ensure proper permissions
    chmod -R 755 "$INSTALL_DIR"
    
    echo -e "${GREEN}   ✅ $THEME_NAME installed as $THEME_ID${NC}"
done

echo ""
echo -e "${GREEN}🎉 Global Theme packages created successfully!${NC}"
echo ""
echo -e "${BLUE}📋 How to use:${NC}"
echo -e "${BLUE}1. Open System Settings${NC}"
echo -e "${BLUE}2. Go to Appearance > Global Theme${NC}"
echo -e "${BLUE}3. Select your preferred theme:${NC}"
echo -e "${BLUE}   • Magic Unicorn Light/Dark (macOS-style)${NC}"
echo -e "${BLUE}   • UnicornCommander Light/Dark (Windows-style)${NC}"
echo -e "${BLUE}4. ⚠️  IMPORTANT: Check 'Use desktop layout from theme'${NC}"
echo -e "${BLUE}5. Click 'Apply'${NC}"
echo ""
echo -e "${YELLOW}💡 The 'Use desktop layout from theme' option is crucial for:${NC}"
echo -e "${YELLOW}   • Custom panel layouts (Windows vs macOS style)${NC}"
echo -e "${YELLOW}   • Unicorn logo on start buttons${NC}"
echo -e "${YELLOW}   • Rainbow application launcher${NC}"
echo -e "${YELLOW}   • Proper system tray positioning${NC}"
echo ""
echo -e "${BLUE}Alternative: Use ${GREEN}uc-theme-switch${BLUE} command for full automation${NC}"

# Refresh KDE cache
if command -v kbuildsycoca6 > /dev/null 2>&1; then
    echo -e "${BLUE}🔄 Refreshing KDE cache...${NC}"
    kbuildsycoca6 --noincremental
    echo -e "${GREEN}✅ KDE cache refreshed${NC}"
fi