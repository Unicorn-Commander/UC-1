#!/bin/bash

# Unicorn Commander Theme Switcher - Unified Edition
# Single script for all theme switching needs

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Auto-detect the installation path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find the assets directory in various locations
ASSETS_PATHS=(
    "$SCRIPT_DIR/assets"
    "$SCRIPT_DIR/../share/unicorn-commander-themes/assets"
    "/usr/share/unicorn-commander-themes/assets"
    "$HOME/.local/share/unicorn-commander-themes/assets"
    "/home/ucadmin/UC-1/Unicorn-Commander-Themes/assets"
)

ASSETS_DIR=""
for path in "${ASSETS_PATHS[@]}"; do
    if [ -d "$path" ]; then
        ASSETS_DIR="$path"
        break
    fi
done

if [ -z "$ASSETS_DIR" ]; then
    echo -e "${RED}❌ Could not find Unicorn Commander assets directory${NC}"
    echo -e "${YELLOW}Please ensure the theme is properly installed${NC}"
    exit 1
fi

clear
echo -e "${PURPLE}🦄 Unicorn Commander Theme Switcher${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${PURPLE}1.${NC} Magic Unicorn Light ☀️ (macOS-style with global menu)"
echo -e "  ${PURPLE}2.${NC} Magic Unicorn Dark 🌙 (macOS-style with global menu)"
echo -e "  ${BLUE}3.${NC} UnicornCommander Light 🪟 (Windows-style)"
echo -e "  ${BLUE}4.${NC} UnicornCommander Dark 🌚 (Windows-style)"
echo -e "  ${NC}5.${NC} Exit"
echo ""
read -p "Select theme (1-5): " choice

# Function to apply unicorn logo to menu widgets
apply_unicorn_logo() {
    echo -e "${BLUE}🦄 Applying unicorn logo to menu button...${NC}"
    
    local unicorn_icon="file://$ASSETS_DIR/menu-button/unicorn.svg"
    
    if [ ! -f "$ASSETS_DIR/menu-button/unicorn.svg" ]; then
        echo -e "${RED}❌ Unicorn SVG not found at $ASSETS_DIR/menu-button/unicorn.svg${NC}"
        return 1
    fi
    
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allPanels = panels();
        var unicornIcon = '$unicorn_icon';
        var updated = false;
        
        for (var i = 0; i < allPanels.length; i++) {
            var panel = allPanels[i];
            var widgets = panel.widgets();
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                if (widget.type === 'org.kde.plasma.kickoff' || 
                    widget.type === 'org.kde.plasma.kicker' ||
                    widget.type === 'org.kde.plasma.kickerdash' ||
                    widget.type === 'org.kde.plasma.applicationlauncher' ||
                    widget.type === 'org.kde.plasma.simplemenu') {
                    widget.currentConfigGroup = ['General'];
                    widget.writeConfig('icon', unicornIcon);
                    widget.reloadConfig();
                    print('✅ Applied unicorn icon to ' + widget.type);
                    updated = true;
                }
            }
        }
        
        if (updated) {
            print('🦄 Unicorn logo successfully applied!');
        } else {
            print('⚠️ No menu widgets found');
        }
    " 2>/dev/null || true
    
    echo -e "${GREEN}✅ Unicorn logo application completed${NC}"
}

# Function to enable macOS-style global menu
enable_macos_global_menu() {
    echo -e "${BLUE}🍎 Enabling macOS-style global menu...${NC}"
    
    # Enable system-wide global menu support
    kwriteconfig6 --file kdeglobals --group KDE --key appmenu_enabled true
    
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allPanels = panels();
        var updated = false;
        
        for (var i = 0; i < allPanels.length; i++) {
            var panel = allPanels[i];
            if (panel.location == 'top') {
                var widgets = panel.widgets();
                for (var j = 0; j < widgets.length; j++) {
                    var widget = widgets[j];
                    if (widget.type === 'org.kde.plasma.appmenu') {
                        widget.currentConfigGroup = ['General'];
                        widget.writeConfig('view', 0);
                        widget.writeConfig('showTitle', true);
                        widget.writeConfig('compactView', false);
                        widget.writeConfig('filterByActive', true);
                        widget.writeConfig('showButtons', true);
                        widget.reloadConfig();
                        print('✅ Configured global menu for macOS-style behavior');
                        updated = true;
                    }
                }
            }
        }
        
        if (updated) {
            print('🍎 macOS-style global menu enabled!');
        } else {
            print('⚠️ No Application Menu widget found');
        }
    " 2>/dev/null || true
    
    echo -e "${GREEN}✅ macOS global menu configuration completed${NC}"
}

apply_theme() {
    local theme_id="$1"
    local theme_name="$2"
    
    echo -e "${PURPLE}Applying $theme_name...${NC}"
    
    # Apply Look and Feel theme
    lookandfeeltool --apply "$theme_id" 2>/dev/null || true
    sleep 2
    
    # Apply wallpaper based on theme type
    local wallpaper_path=""
    case "$theme_id" in
        *magicunicorn*)
            wallpaper_path="$HOME/.local/share/wallpapers/MagicUnicorn/unicorncommander_1920x1080.jpg"
            if [ ! -f "$wallpaper_path" ]; then
                wallpaper_path="/usr/share/wallpapers/MagicUnicorn/unicorncommander_1920x1080.jpg"
            fi
            ;;
        *unicorncommander*)
            wallpaper_path="$HOME/.local/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg"
            if [ ! -f "$wallpaper_path" ]; then
                wallpaper_path="/usr/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg"
            fi
            ;;
    esac
    
    if [ -f "$wallpaper_path" ]; then
        plasma-apply-wallpaperimage "$wallpaper_path" 2>/dev/null || true
    fi
    
    # Enable blur effects
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    
    # Apply theme-specific configurations
    case "$theme_id" in
        *magicunicorn*)
            echo -e "${BLUE}Configuring Magic Unicorn (macOS-style) layout...${NC}"
            sleep 2
            
            local rainbow_grid_icon="file://$ASSETS_DIR/menu-button/rainbow-grid.svg"
            
            # Configure macOS layout: top panel + bottom dock
            qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                var allPanels = panels();
                var hasTop = false, hasBottom = false;
                
                for (var i = 0; i < allPanels.length; i++) {
                    if (allPanels[i].location == 'top') hasTop = true;
                    if (allPanels[i].location == 'bottom') hasBottom = true;
                }
                
                // Create top panel if missing (macOS menu bar)
                if (!hasTop) {
                    var topPanel = new Panel;
                    topPanel.location = 'top';
                    topPanel.height = 28;
                    topPanel.addWidget('org.kde.plasma.kickoff');
                    topPanel.addWidget('org.kde.plasma.appmenu');
                    topPanel.addWidget('org.kde.plasma.panelspacer');
                    topPanel.addWidget('org.kde.plasma.systemtray');
                    topPanel.addWidget('org.kde.plasma.digitalclock');
                    print('Created macOS top panel');
                }
                
                // Configure bottom panel as macOS dock
                for (var i = 0; i < allPanels.length; i++) {
                    var panel = allPanels[i];
                    if (panel.location == 'bottom') {
                        // Configure as macOS dock
                        panel.lengthMode = 'fit';
                        panel.alignment = 'center';
                        panel.floating = true;
                        panel.hiding = 'windowsgobelow';
                        panel.height = 60;
                        print('Configured macOS dock');
                        break;
                    }
                }
            " 2>/dev/null || true
            
            # Enable macOS-style global menu
            sleep 1
            enable_macos_global_menu
            ;;
        *unicorncommander*)
            echo -e "${BLUE}Configuring UnicornCommander (Windows-style) layout...${NC}"
            sleep 2
            
            # Configure Windows layout: single bottom taskbar
            qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                var allPanels = panels();
                var hasBottom = false;
                
                // Remove top panel if exists (Windows has no top panel)
                for (var i = 0; i < allPanels.length; i++) {
                    var panel = allPanels[i];
                    if (panel.location == 'top') {
                        panel.remove();
                        print('Removed top panel for Windows layout');
                    } else if (panel.location == 'bottom') {
                        hasBottom = true;
                    }
                }
                
                // Create bottom panel if missing
                if (!hasBottom) {
                    var bottomPanel = new Panel;
                    bottomPanel.location = 'bottom';
                    bottomPanel.height = 48;
                    bottomPanel.addWidget('org.kde.plasma.kickoff');
                    bottomPanel.addWidget('org.kde.plasma.icontasks');
                    bottomPanel.addWidget('org.kde.plasma.systemtray');
                    bottomPanel.addWidget('org.kde.plasma.digitalclock');
                    print('Created Windows taskbar');
                }
                
                // Configure bottom panel as Windows taskbar
                for (var i = 0; i < allPanels.length; i++) {
                    var panel = allPanels[i];
                    if (panel.location == 'bottom') {
                        panel.lengthMode = 'fill';
                        panel.alignment = 'left';
                        panel.floating = false;
                        panel.hiding = 'none';
                        panel.height = 48;
                        print('Configured Windows taskbar');
                        break;
                    }
                }
            " 2>/dev/null || true
            ;;
    esac
    
    # Apply unicorn logo
    sleep 1
    apply_unicorn_logo
    
    # Restart plasmashell to apply changes
    echo -e "${BLUE}🔄 Restarting plasma shell...${NC}"
    kquitapp6 plasmashell 2>/dev/null || true
    sleep 3
    nohup plasmashell > /dev/null 2>&1 &
    sleep 2
    
    # Re-apply unicorn logo after restart
    echo -e "${BLUE}🦄 Ensuring unicorn logo is properly applied...${NC}"
    sleep 2
    apply_unicorn_logo
    
    # Re-apply macOS global menu after restart (for Magic Unicorn themes)
    case "$theme_id" in
        *magicunicorn*)
            echo -e "${BLUE}🍎 Ensuring macOS global menu is properly configured...${NC}"
            sleep 1
            enable_macos_global_menu
            ;;
    esac
    
    # Reconfigure KWin
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    
    echo -e "${GREEN}✅ $theme_name applied successfully!${NC}"
}

case $choice in
    1)
        apply_theme "org.magicunicorn.light" "Magic Unicorn Light"
        ;;
    2)
        apply_theme "org.magicunicorn.dark" "Magic Unicorn Dark"
        ;;
    3)
        apply_theme "org.unicorncommander.windows.light" "UnicornCommander Light"
        ;;
    4)
        apply_theme "org.unicorncommander.windows.dark" "UnicornCommander Dark"
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
case $choice in
    1|2)
        echo -e "${PURPLE}🎉 Magic Unicorn theme applied! 🍎🦄${NC}"
        echo -e "${GREEN}Features enabled:${NC}"
        echo -e "  • Unicorn logo in menu button"
        echo -e "  • macOS-style global menu"
        echo -e "  • Application menus in top bar"
        echo ""
        echo -e "${YELLOW}💡 Open any app to see the global menu in action!${NC}"
        ;;
    3|4)
        echo -e "${PURPLE}🎉 UnicornCommander theme applied! 🦄${NC}"
        echo -e "${GREEN}Features enabled:${NC}"
        echo -e "  • Unicorn logo in menu button"
        echo -e "  • Windows-style taskbar"
        ;;
esac
echo ""
read -p "Press Enter to close..."