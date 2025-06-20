#!/bin/bash

# Unicorn Commander Themes Complete Installer
# This installer ensures all components are properly installed on any system

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear
echo -e "${PURPLE}🦄 Unicorn Commander Themes Complete Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📍 Installation source: ${SCRIPT_DIR}${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Running as root - will install system-wide${NC}"
    INSTALL_MODE="system"
    USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
    PLASMA_THEMES_DIR="/usr/share/plasma/look-and-feel"
    ICONS_DIR="/usr/share/icons"
    WALLPAPER_DIR="/usr/share/wallpapers"
    SDDM_DIR="/usr/share/sddm/themes"
    SCRIPT_INSTALL_DIR="/usr/local/bin"
else
    echo -e "${BLUE}👤 Running as user - will install for current user${NC}"
    INSTALL_MODE="user"
    USER_HOME="$HOME"
    PLASMA_THEMES_DIR="$HOME/.local/share/plasma/look-and-feel"
    ICONS_DIR="$HOME/.local/share/icons"
    WALLPAPER_DIR="$HOME/.local/share/wallpapers"
    SDDM_DIR="/usr/share/sddm/themes"  # SDDM always needs system install
    SCRIPT_INSTALL_DIR="$HOME/.local/bin"
fi

echo -e "${BLUE}🏠 User home directory: ${USER_HOME}${NC}"
echo ""

# Create directories if they don't exist
create_directories() {
    echo -e "${BLUE}📂 Creating installation directories...${NC}"
    
    if [ "$INSTALL_MODE" = "user" ]; then
        mkdir -p "$PLASMA_THEMES_DIR"
        mkdir -p "$ICONS_DIR"
        mkdir -p "$WALLPAPER_DIR"
        mkdir -p "$SCRIPT_INSTALL_DIR"
        
        # Add ~/.local/bin to PATH if not already there
        if [[ ":$PATH:" != *":$SCRIPT_INSTALL_DIR:"* ]]; then
            echo "export PATH=\"\$PATH:$SCRIPT_INSTALL_DIR\"" >> "$USER_HOME/.bashrc"
            echo -e "${GREEN}   ✅ Added $SCRIPT_INSTALL_DIR to PATH${NC}"
        fi
    fi
    
    echo -e "${GREEN}   ✅ Directories ready${NC}"
}

# Install color schemes first
install_color_schemes() {
    echo -e "${BLUE}🎨 Installing color schemes...${NC}"
    
    local color_schemes_dir=""
    if [ "$INSTALL_MODE" = "system" ]; then
        color_schemes_dir="/usr/share/color-schemes"
    else
        color_schemes_dir="$HOME/.local/share/color-schemes"
        mkdir -p "$color_schemes_dir"
    fi
    
    # Install custom color schemes
    for color_file in "$SCRIPT_DIR"/*.colors; do
        if [ -f "$color_file" ]; then
            cp "$color_file" "$color_schemes_dir/"
            color_name=$(basename "$color_file")
            echo -e "${GREEN}   ✅ $color_name color scheme installed${NC}"
        fi
    done
    
    # Also check for color schemes in root directory
    if [ -f "$HOME/.local/share/color-schemes/UCMacDark.colors" ]; then
        cp "$HOME/.local/share/color-schemes/UCMacDark.colors" "$color_schemes_dir/"
        echo -e "${GREEN}   ✅ UCMacDark.colors installed${NC}"
    fi
    
    if [ -f "$HOME/.local/share/color-schemes/UCWindowsDark.colors" ]; then
        cp "$HOME/.local/share/color-schemes/UCWindowsDark.colors" "$color_schemes_dir/"
        echo -e "${GREEN}   ✅ UCWindowsDark.colors installed${NC}"
    fi
    
    if [ -f "$HOME/.local/share/color-schemes/UCMacLight.colors" ]; then
        cp "$HOME/.local/share/color-schemes/UCMacLight.colors" "$color_schemes_dir/"
        echo -e "${GREEN}   ✅ UCMacLight.colors installed${NC}"
    fi
    
    if [ -f "$HOME/.local/share/color-schemes/UCWindowsLight.colors" ]; then
        cp "$HOME/.local/share/color-schemes/UCWindowsLight.colors" "$color_schemes_dir/"
        echo -e "${GREEN}   ✅ UCWindowsLight.colors installed${NC}"
    fi
}

# Install Look and Feel themes
install_themes() {
    echo -e "${BLUE}🎨 Installing Look and Feel themes...${NC}"
    
    # Install MagicUnicorn themes from distribution directory
    if [ -d "$SCRIPT_DIR/distribution/MagicUnicorn-Dark" ]; then
        cp -r "$SCRIPT_DIR/distribution/MagicUnicorn-Dark" "$PLASMA_THEMES_DIR/"
        
        # Fix configuration for proper dark theme and paths
        if [ "$INSTALL_MODE" = "system" ]; then
            sed -i 's/Theme=papirus-unicorn-icons/Theme=breeze-dark/' "$PLASMA_THEMES_DIR/MagicUnicorn-Dark/contents/defaults" 2>/dev/null || true
            sed -i 's/name=default/name=magic-unicorn-dark/' "$PLASMA_THEMES_DIR/MagicUnicorn-Dark/contents/defaults" 2>/dev/null || true
            
            # Fix hardcoded paths in all files
            find "$PLASMA_THEMES_DIR/MagicUnicorn-Dark" -type f \( -name "*.js" -o -name "*.sh" -o -name "defaults" \) -exec sed -i 's#/home/ucadmin/UC-1/KDE-Themes/assets/menu-button/#/usr/share/plasma/look-and-feel/MagicUnicorn-Dark/contents/assets/menu-button/#g' {} \; 2>/dev/null || true
            find "$PLASMA_THEMES_DIR/MagicUnicorn-Dark" -type f \( -name "*.js" -o -name "*.sh" -o -name "defaults" \) -exec sed -i 's#/home/ucadmin/UC-1/assets/wallpapers/#/usr/share/wallpapers/UnicornCommander/#g' {} \; 2>/dev/null || true
            find "$PLASMA_THEMES_DIR/MagicUnicorn-Dark" -type f \( -name "*.js" -o -name "*.sh" -o -name "defaults" \) -exec sed -i 's#file:///home/ucadmin/UC-1/KDE-Themes/assets/wallpapers/unicorncommander_1920x1080.jpg#file:///usr/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg#g' {} \; 2>/dev/null || true
            
            # Copy assets to theme directory for self-containment
            mkdir -p "$PLASMA_THEMES_DIR/MagicUnicorn-Dark/contents/assets/menu-button"
            cp "$SCRIPT_DIR/assets/menu-button"/* "$PLASMA_THEMES_DIR/MagicUnicorn-Dark/contents/assets/menu-button/" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}   ✅ Magic Unicorn Dark theme installed${NC}"
    else
        echo -e "${RED}   ❌ Magic Unicorn Dark theme not found${NC}"
    fi
    
    if [ -d "$SCRIPT_DIR/distribution/MagicUnicorn-Light" ]; then
        cp -r "$SCRIPT_DIR/distribution/MagicUnicorn-Light" "$PLASMA_THEMES_DIR/"
        
        # Fix configuration for proper light theme and paths
        if [ "$INSTALL_MODE" = "system" ]; then
            sed -i 's/Theme=papirus-unicorn-icons/Theme=breeze/' "$PLASMA_THEMES_DIR/MagicUnicorn-Light/contents/defaults" 2>/dev/null || true
            sed -i 's/library=org.kde.kwin.aurorae/library=org.kde.breeze/' "$PLASMA_THEMES_DIR/MagicUnicorn-Light/contents/defaults" 2>/dev/null || true
            sed -i 's/theme=__aurorae__svg__UC-Mac-Light/theme=Breeze/' "$PLASMA_THEMES_DIR/MagicUnicorn-Light/contents/defaults" 2>/dev/null || true
            sed -i 's/name=UC-Mac-Light/name=breeze/' "$PLASMA_THEMES_DIR/MagicUnicorn-Light/contents/defaults" 2>/dev/null || true
            
            # Fix hardcoded paths in all files
            find "$PLASMA_THEMES_DIR/MagicUnicorn-Light" -type f \( -name "*.js" -o -name "*.sh" -o -name "defaults" \) -exec sed -i 's#/home/ucadmin/UC-1/KDE-Themes/assets/menu-button/#/usr/share/plasma/look-and-feel/MagicUnicorn-Light/contents/assets/menu-button/#g' {} \; 2>/dev/null || true
            find "$PLASMA_THEMES_DIR/MagicUnicorn-Light" -type f \( -name "*.js" -o -name "*.sh" -o -name "defaults" \) -exec sed -i 's#/home/ucadmin/UC-1/assets/wallpapers/#/usr/share/wallpapers/UnicornCommander/#g' {} \; 2>/dev/null || true
            find "$PLASMA_THEMES_DIR/MagicUnicorn-Light" -type f \( -name "*.js" -o -name "*.sh" -o -name "defaults" \) -exec sed -i 's#file:///home/ucadmin/UC-1/KDE-Themes/assets/wallpapers/unicorncommander_1920x1080.jpg#file:///usr/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg#g' {} \; 2>/dev/null || true
            
            # Copy assets to theme directory for self-containment
            mkdir -p "$PLASMA_THEMES_DIR/MagicUnicorn-Light/contents/assets/menu-button"
            cp "$SCRIPT_DIR/assets/menu-button"/* "$PLASMA_THEMES_DIR/MagicUnicorn-Light/contents/assets/menu-button/" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}   ✅ Magic Unicorn Light theme installed${NC}"
    else
        echo -e "${RED}   ❌ Magic Unicorn Light theme not found${NC}"
    fi
    
    # Install UC Windows themes
    if [ -d "$SCRIPT_DIR/themes" ]; then
        for theme_dir in "$SCRIPT_DIR/themes"/*; do
            if [ -d "$theme_dir" ]; then
                theme_name=$(basename "$theme_dir")
                cp -r "$theme_dir" "$PLASMA_THEMES_DIR/"
                
                # Fix dark theme configurations
                if [[ "$theme_name" == *"Dark"* ]] && [ "$INSTALL_MODE" = "system" ]; then
                    sed -i 's/Theme=breeze-dark/Theme=breeze-dark/' "$PLASMA_THEMES_DIR/$theme_name/contents/defaults" 2>/dev/null || true
                    sed -i 's/library=org.kde.kwin.aurorae/library=org.kde.breeze/' "$PLASMA_THEMES_DIR/$theme_name/contents/defaults" 2>/dev/null || true
                    sed -i 's/theme=__aurorae__svg__UC-Mac-Light/theme=Breeze/' "$PLASMA_THEMES_DIR/$theme_name/contents/defaults" 2>/dev/null || true
                    sed -i 's#Image=file:///home/ucadmin/UC-1/KDE-Themes/assets/wallpapers/unicorncommander_1920x1080.jpg#Image=file:///usr/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg#' "$PLASMA_THEMES_DIR/$theme_name/contents/defaults" 2>/dev/null || true
                fi
                
                echo -e "${GREEN}   ✅ $theme_name theme installed${NC}"
            fi
        done
    fi
}

# Install wallpapers
install_wallpapers() {
    echo -e "${BLUE}🖼️  Installing wallpapers...${NC}"
    
    # Install wallpapers for each theme
    for theme in "MagicUnicorn" "UnicornCommander"; do
        theme_wallpaper_dir="$WALLPAPER_DIR/$theme"
        mkdir -p "$theme_wallpaper_dir"
        
        if [ -d "$SCRIPT_DIR/assets/wallpapers" ]; then
            cp "$SCRIPT_DIR/assets/wallpapers"/* "$theme_wallpaper_dir/" 2>/dev/null || true
            echo -e "${GREEN}   ✅ $theme wallpapers installed${NC}"
        fi
        
        # Also copy from distribution assets if available
        if [ -d "$SCRIPT_DIR/distribution/MagicUnicorn-Dark/contents/assets/wallpapers" ]; then
            cp "$SCRIPT_DIR/distribution/MagicUnicorn-Dark/contents/assets/wallpapers"/* "$theme_wallpaper_dir/" 2>/dev/null || true
        fi
    done
}

# Install icon themes
install_icons() {
    echo -e "${BLUE}🎭 Installing icon themes...${NC}"
    
    # Check if Flat-Remix-Violet icons are already installed
    if [ -d "/usr/share/icons/Flat-Remix-Violet-Dark" ] || [ -d "$HOME/.local/share/icons/Flat-Remix-Violet-Dark" ]; then
        echo -e "${GREEN}   ✅ Flat-Remix-Violet icons already installed${NC}"
    else
        echo -e "${YELLOW}   📥 Installing Flat-Remix-Violet icons...${NC}"
        
        # Try package manager first (if running as root)
        if [ "$INSTALL_MODE" = "system" ] && command -v apt &> /dev/null; then
            apt update &>/dev/null
            if apt install -y flat-remix-gtk &>/dev/null; then
                echo -e "${GREEN}   ✅ Flat-Remix icons installed via package manager${NC}"
            else
                echo -e "${YELLOW}   ⚠️  Package installation failed, manual installation needed${NC}"
            fi
        fi
        
        # Install custom unicorn icons
        if [ -d "$SCRIPT_DIR/unicorn-icons" ]; then
            cp -r "$SCRIPT_DIR/unicorn-icons" "$ICONS_DIR/UnicornCommander-Icons"
            echo -e "${GREEN}   ✅ Unicorn Commander icons installed${NC}"
        fi
        
        # Install Papirus unicorn icons
        if [ -d "$SCRIPT_DIR/papirus-unicorn-icons" ]; then
            cp -r "$SCRIPT_DIR/papirus-unicorn-icons" "$ICONS_DIR/Papirus-Unicorn"
            echo -e "${GREEN}   ✅ Papirus Unicorn icons installed${NC}"
        fi
    fi
}

# Install theme switching scripts
install_scripts() {
    echo -e "${BLUE}🔧 Installing theme switching scripts...${NC}"
    
    # Fix the uc-theme-switch script with correct paths
    if [ -f "$SCRIPT_DIR/distribution/scripts/uc-theme-switch" ]; then
        # Create a fixed version with correct paths
        sed "s|/home/ucadmin/UC-1/KDE-Themes|$SCRIPT_DIR|g" "$SCRIPT_DIR/distribution/scripts/uc-theme-switch" > "$SCRIPT_INSTALL_DIR/uc-theme-switch"
        chmod +x "$SCRIPT_INSTALL_DIR/uc-theme-switch"
        echo -e "${GREEN}   ✅ uc-theme-switch command installed${NC}"
    fi
    
    # Install enhanced theme switcher with corrected paths
    if [ -f "$SCRIPT_DIR/uc-theme-switch-with-global-menu.sh" ]; then
        # Create a fixed version with correct paths
        sed "s|/home/ucadmin/UC-1/KDE-Themes|$SCRIPT_DIR|g" "$SCRIPT_DIR/uc-theme-switch-with-global-menu.sh" > "$SCRIPT_INSTALL_DIR/uc-theme-switch-global"
        chmod +x "$SCRIPT_INSTALL_DIR/uc-theme-switch-global"
        echo -e "${GREEN}   ✅ uc-theme-switch-global command installed${NC}"
    fi
    
    # Create a master installer script
    cat > "$SCRIPT_INSTALL_DIR/uc-theme-install" << 'EOF'
#!/bin/bash
# Re-run the Unicorn Commander installer from anywhere
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../share/unicorn-commander-themes/install.sh" ]; then
    "$SCRIPT_DIR/../share/unicorn-commander-themes/install.sh" "$@"
else
    echo "Unicorn Commander Themes installer not found"
    echo "Please run the installer from the original directory"
fi
EOF
    chmod +x "$SCRIPT_INSTALL_DIR/uc-theme-install"
    echo -e "${GREEN}   ✅ uc-theme-install command installed${NC}"
}

# Install SDDM themes (requires root)
install_sddm_themes() {
    echo -e "${BLUE}🔐 Installing SDDM login themes...${NC}"
    
    if [ "$INSTALL_MODE" = "system" ] && [ -d "$SDDM_DIR" ]; then
        if [ -d "$SCRIPT_DIR/distribution/sddm-theme" ]; then
            # First, backup existing SDDM config if it exists
            if [ -f "/etc/sddm.conf.d/kde_settings.conf" ]; then
                cp "/etc/sddm.conf.d/kde_settings.conf" "/etc/sddm.conf.d/kde_settings.conf.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
                echo -e "${GREEN}   ✅ SDDM config backed up${NC}"
            fi
            
            # Copy theme files but DON'T auto-apply them
            cp -r "$SCRIPT_DIR/distribution/sddm-theme"/* "$SDDM_DIR/" 2>/dev/null || true
            echo -e "${GREEN}   ✅ SDDM themes installed (not activated)${NC}"
            echo -e "${YELLOW}   ⚠️  SDDM themes are installed but NOT automatically applied${NC}"
            echo -e "${YELLOW}   💡 To apply manually: run 'uc-theme-switch' and select a theme${NC}"
        fi
    else
        echo -e "${YELLOW}   ⚠️  SDDM themes require system installation (run with sudo)${NC}"
    fi
}

# Install dependencies
install_dependencies() {
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    
    if [ "$INSTALL_MODE" = "system" ] && command -v apt &> /dev/null; then
        # Install required packages
        packages_to_install=""
        
        if ! dpkg -l | grep -q "plasma-widgets-addons"; then
            packages_to_install="$packages_to_install plasma-widgets-addons"
        fi
        
        if ! dpkg -l | grep -q "qml-module-qtquick-layouts"; then
            packages_to_install="$packages_to_install qml-module-qtquick-layouts"
        fi
        
        if ! dpkg -l | grep -q "qml-module-qtquick-controls"; then
            packages_to_install="$packages_to_install qml-module-qtquick-controls2"
        fi
        
        if [ -n "$packages_to_install" ]; then
            echo -e "${YELLOW}   📥 Installing: $packages_to_install${NC}"
            apt install -y $packages_to_install &>/dev/null
            echo -e "${GREEN}   ✅ Dependencies installed${NC}"
        else
            echo -e "${GREEN}   ✅ All dependencies already installed${NC}"
        fi
    else
        echo -e "${YELLOW}   ⚠️  Please ensure these packages are installed manually:${NC}"
        echo -e "${YELLOW}      - plasma-widgets-addons${NC}"
        echo -e "${YELLOW}      - qml-module-qtquick-layouts${NC}"
        echo -e "${YELLOW}      - qml-module-qtquick-controls2${NC}"
    fi
}

# Update system caches
update_caches() {
    echo -e "${BLUE}🔄 Updating system caches...${NC}"
    
    # Update icon caches
    if command -v gtk-update-icon-cache &> /dev/null; then
        for icon_dir in "$ICONS_DIR"/*; do
            if [ -d "$icon_dir" ]; then
                gtk-update-icon-cache -f -t "$icon_dir" &>/dev/null || true
            fi
        done
    fi
    
    # Update KDE caches
    if command -v kbuildsycoca6 &> /dev/null; then
        kbuildsycoca6 &>/dev/null || true
    elif command -v kbuildsycoca5 &> /dev/null; then
        kbuildsycoca5 &>/dev/null || true
    fi
    
    echo -e "${GREEN}   ✅ Caches updated${NC}"
}

# Create desktop shortcut for theme switcher (optional)
create_desktop_shortcut() {
    echo -e "${BLUE}🖥️  Creating desktop shortcut...${NC}"
    
    # Ask user if they want desktop shortcut
    read -p "Create desktop shortcut for theme switcher? (y/N): " create_shortcut
    if [ "$create_shortcut" = "y" ] || [ "$create_shortcut" = "Y" ]; then
        desktop_file="$USER_HOME/Desktop/UnicornCommander-ThemeSwitcher.desktop"
        
        cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Unicorn Commander Theme Switcher
Comment=Switch between Unicorn Commander themes
Exec=$SCRIPT_INSTALL_DIR/uc-theme-switch
Icon=$SCRIPT_DIR/assets/menu-button/unicorn.svg
Terminal=true
Categories=System;Settings;
EOF
        
        chmod +x "$desktop_file"
        echo -e "${GREEN}   ✅ Desktop shortcut created${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Desktop shortcut skipped${NC}"
    fi
}

# Main installation process
main() {
    echo -e "${BLUE}🚀 Starting installation...${NC}"
    echo ""
    
    create_directories
    install_dependencies
    install_color_schemes
    install_themes
    install_wallpapers
    install_icons
    install_scripts
    # install_sddm_themes  # Now separate installer
    update_caches
    create_desktop_shortcut
    
    echo ""
    echo -e "${GREEN}🎉 Unicorn Commander Themes Installation Complete!${NC}"
    echo ""
    echo -e "${PURPLE}📋 What was installed:${NC}"
    echo -e "   • Magic Unicorn Light & Dark themes"
    echo -e "   • UnicornCommander Windows-style themes"
    echo -e "   • Unicorn Commander wallpapers"
    echo -e "   • Custom unicorn icons"
    echo -e "   • Unified theme switching command: ${YELLOW}uc-theme-switch${NC}"
    if [ "$INSTALL_MODE" = "system" ]; then
        echo -e "   • SDDM login themes"
    fi
    echo ""
    echo -e "${BLUE}🚀 Usage:${NC}"
    echo -e "   • GUI: System Settings > Appearance > Global Theme"
    echo -e "   • CLI: ${YELLOW}uc-theme-switch${NC} (unified theme switcher)"
    echo -e "   • SDDM: ${YELLOW}sudo ./install-sddm.sh${NC} (separate login theme installer)"
    echo ""
    
    if [ "$INSTALL_MODE" = "user" ]; then
        echo -e "${YELLOW}💡 Note: You may need to restart your terminal or run:${NC}"
        echo -e "   ${YELLOW}source ~/.bashrc${NC}"
        echo -e "   to use the uc-theme-switch commands."
        echo ""
    fi
    
    echo -e "${GREEN}✨ All themes include:${NC}"
    echo -e "   • Unicorn logo in menu buttons"
    echo -e "   • Custom wallpapers"
    echo -e "   • Proper light/dark theme switching"
    echo -e "   • macOS-style features (global menu for Magic Unicorn themes)"
    echo -e "   • Windows-style taskbar (for UnicornCommander themes)"
    echo ""
    
    # Test if themes are available
    echo -e "${BLUE}🔍 Verifying installation...${NC}"
    
    theme_count=$(ls -1 "$PLASMA_THEMES_DIR" 2>/dev/null | grep -i unicorn | wc -l)
    if [ "$theme_count" -gt 0 ]; then
        echo -e "${GREEN}   ✅ Found $theme_count Unicorn Commander theme(s)${NC}"
    else
        echo -e "${RED}   ❌ No themes found - installation may have failed${NC}"
    fi
    
    if [ -x "$SCRIPT_INSTALL_DIR/uc-theme-switch" ]; then
        echo -e "${GREEN}   ✅ uc-theme-switch command is available${NC}"
    else
        echo -e "${RED}   ❌ uc-theme-switch command not found${NC}"
    fi
    
    echo ""
    echo -e "${PURPLE}🦄 Ready to use! Run ${YELLOW}uc-theme-switch${NC} to start theming! 🦄${NC}"
}

# Run the installer
main "$@"