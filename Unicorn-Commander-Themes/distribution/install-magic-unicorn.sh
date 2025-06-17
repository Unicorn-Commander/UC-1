#!/bin/bash

# Magic Unicorn Theme Complete Installer
# Installs KDE Look and Feel themes, icons, CLI tools, and dependencies

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${PURPLE}🦄 Magic Unicorn Theme Complete Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check for root/sudo access for system-wide installation
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  This installer requires sudo access for system-wide installation${NC}"
    echo -e "${BLUE}   Re-run with: sudo $0${NC}"
    exit 1
fi

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="/usr/share/plasma/look-and-feel"
ICONS_DIR="/usr/share/icons"
SCRIPTS_DIR="/usr/local/bin"

echo -e "${BLUE}📦 Installing Magic Unicorn Theme Components...${NC}"
echo ""

# 1. Install Look and Feel themes
echo -e "${BLUE}1. Installing Look and Feel themes...${NC}"
if [ -d "$INSTALL_DIR/MagicUnicorn-Light" ]; then
    cp -r "$INSTALL_DIR/MagicUnicorn-Light" "$THEMES_DIR/"
    echo -e "${GREEN}   ✅ Magic Unicorn Light theme installed${NC}"
else
    echo -e "${RED}   ❌ Magic Unicorn Light theme not found${NC}"
fi

if [ -d "$INSTALL_DIR/MagicUnicorn-Dark" ]; then
    cp -r "$INSTALL_DIR/MagicUnicorn-Dark" "$THEMES_DIR/"
    echo -e "${GREEN}   ✅ Magic Unicorn Dark theme installed${NC}"
else
    echo -e "${RED}   ❌ Magic Unicorn Dark theme not found${NC}"
fi

# 2. Install Flat-Remix-Violet icons (if included)
echo -e "${BLUE}2. Installing Flat-Remix-Violet icons...${NC}"
if command -v apt &> /dev/null; then
    # Try to install via package manager first
    if apt list --installed 2>/dev/null | grep -q "flat-remix"; then
        echo -e "${GREEN}   ✅ Flat-Remix icons already installed${NC}"
    else
        echo -e "${YELLOW}   📥 Installing Flat-Remix icons via apt...${NC}"
        apt update &>/dev/null
        apt install -y flat-remix-gtk flat-remix-gnome &>/dev/null || true
        
        # If package install fails, try manual install
        if [ -d "$INSTALL_DIR/icons/Flat-Remix-Violet-Light" ]; then
            cp -r "$INSTALL_DIR/icons/Flat-Remix-Violet-Light" "$ICONS_DIR/"
            echo -e "${GREEN}   ✅ Flat-Remix-Violet-Light icons installed manually${NC}"
        fi
        if [ -d "$INSTALL_DIR/icons/Flat-Remix-Violet-Dark" ]; then
            cp -r "$INSTALL_DIR/icons/Flat-Remix-Violet-Dark" "$ICONS_DIR/"
            echo -e "${GREEN}   ✅ Flat-Remix-Violet-Dark icons installed manually${NC}"
        fi
    fi
else
    echo -e "${YELLOW}   ⚠️  Package manager not found, manual icon installation needed${NC}"
fi

# 3. Install plasma-widgets-addons for Application Dashboard
echo -e "${BLUE}3. Installing Application Dashboard dependencies...${NC}"
if command -v apt &> /dev/null; then
    if dpkg -l | grep -q "plasma-widgets-addons"; then
        echo -e "${GREEN}   ✅ plasma-widgets-addons already installed${NC}"
    else
        echo -e "${YELLOW}   📥 Installing plasma-widgets-addons...${NC}"
        apt install -y plasma-widgets-addons &>/dev/null
        echo -e "${GREEN}   ✅ plasma-widgets-addons installed${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Please install plasma-widgets-addons manually for your distribution${NC}"
fi

# 4. Install CLI theme switcher
echo -e "${BLUE}4. Installing CLI theme switcher...${NC}"
if [ -f "$INSTALL_DIR/scripts/uc-theme-switch" ]; then
    cp "$INSTALL_DIR/scripts/uc-theme-switch" "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR/uc-theme-switch"
    echo -e "${GREEN}   ✅ uc-theme-switch command installed${NC}"
else
    echo -e "${RED}   ❌ uc-theme-switch script not found${NC}"
fi

if [ -f "$INSTALL_DIR/scripts/uc-theme-switch-with-global-menu.sh" ]; then
    cp "$INSTALL_DIR/scripts/uc-theme-switch-with-global-menu.sh" "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR/uc-theme-switch-with-global-menu.sh"
    echo -e "${GREEN}   ✅ Enhanced theme switcher with global menu installed${NC}"
else
    echo -e "${RED}   ❌ Enhanced theme switcher script not found${NC}"
fi

# 5. Install SDDM themes
echo -e "${BLUE}5. Installing SDDM login themes...${NC}"
SDDM_DIR="/usr/share/sddm/themes"
if [ -d "$INSTALL_DIR/sddm-theme" ]; then
    if [ -d "$SDDM_DIR" ]; then
        cp -r "$INSTALL_DIR/sddm-theme"/* "$SDDM_DIR/"
        echo -e "${GREEN}   ✅ Magic Unicorn SDDM themes installed${NC}"
    else
        echo -e "${YELLOW}   ⚠️  SDDM not found, skipping SDDM theme installation${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  SDDM themes not included in package${NC}"
fi

# 6. Update icon cache
echo -e "${BLUE}6. Updating system caches...${NC}"
if command -v update-icon-caches &> /dev/null; then
    update-icon-caches "$ICONS_DIR" &>/dev/null || true
fi
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICONS_DIR" &>/dev/null || true
fi
echo -e "${GREEN}   ✅ System caches updated${NC}"

echo ""
echo -e "${GREEN}🎉 Magic Unicorn Theme Installation Complete!${NC}"
echo ""
echo -e "${PURPLE}📋 What was installed:${NC}"
echo -e "   • Magic Unicorn Light & Dark Look and Feel themes"
echo -e "   • Flat-Remix-Violet icon themes"
echo -e "   • Application Dashboard with rainbow grid launcher"
echo -e "   • CLI theme switcher (uc-theme-switch command)"
echo -e "   • macOS-style global menu support"
echo -e "   • Unicorn logo assets"
echo -e "   • SDDM login themes (if SDDM available)"
echo ""
echo -e "${BLUE}🚀 Next steps:${NC}"
echo -e "   1. Open System Settings > Appearance > Global Theme"
echo -e "   2. Select 'Magic Unicorn Light' or 'Magic Unicorn Dark'"
echo -e "   3. Or use CLI: ${YELLOW}uc-theme-switch${NC}"
echo ""
echo -e "${YELLOW}💡 The themes include all advanced features like unicorn logo, rainbow app launcher, and global menu!${NC}"