#!/bin/bash

# Colors
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${PURPLE}🦄 UnicornCommander Theme Switcher (with Global Menu)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${PURPLE}1.${NC} Magic Unicorn Light ☀️ (with macOS global menu)"
echo -e "  ${PURPLE}2.${NC} Magic Unicorn Dark 🌙 (with macOS global menu)"
echo -e "  ${BLUE}3.${NC} UnicornCommander Light 🪟"
echo -e "  ${BLUE}4.${NC} UnicornCommander Dark 🌚"
echo -e "  ${NC}5.${NC} Exit"
echo ""
read -p "Select theme (1-5): " choice

# Function to apply unicorn logo to kickoff widgets
apply_unicorn_logo() {
    echo -e "${BLUE}🦄 Applying unicorn logo to menu button...${NC}"
    
    local unicorn_icon="file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg"
    
    # Check if unicorn SVG exists
    if [ ! -f "/home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg" ]; then
        echo -e "${RED}❌ Unicorn SVG not found, skipping logo application${NC}"
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
                if (widget.type === 'org.kde.plasma.kickoff') {
                    widget.currentConfigGroup = ['General'];
                    widget.writeConfig('icon', unicornIcon);
                    widget.reloadConfig();
                    print('✅ Applied unicorn icon to kickoff widget on panel ' + i);
                    updated = true;
                }
            }
        }
        
        if (updated) {
            print('🦄 Unicorn logo successfully applied to all menu buttons!');
        } else {
            print('⚠️ No kickoff widgets found for logo application');
        }
    " 2>/dev/null || true
    
    echo -e "${GREEN}✅ Unicorn logo application completed${NC}"
}

# Function to enable macOS-style global menu
enable_macos_global_menu() {
    echo -e "${BLUE}🍎 Enabling macOS-style global menu...${NC}"
    
    # Set environment variables for global menu
    export QT_QPA_PLATFORMTHEME=kde
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    
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
                        
                        // Enable macOS-style features - show active app menus
                        widget.writeConfig('view', 0);                // ButtonAndTitle view (best for macOS style)
                        widget.writeConfig('showTitle', true);        // Show app name like macOS
                        widget.writeConfig('compactView', false);     // Show full menu like macOS
                        widget.writeConfig('filterByActive', true);   // Only show active window menus
                        widget.writeConfig('showButtons', true);      // Show menu buttons with title
                        widget.reloadConfig();
                        
                        print('✅ Configured Application Menu for macOS-style behavior');
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
    
    # Enable system-wide global menu support
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    kwriteconfig6 --file kdeglobals --group KDE --key ShowIconsInMenuItems true
    
    # Enable DBus menu for applications
    kwriteconfig6 --file kdeglobals --group KDE --key appmenu_enabled true
    
    echo -e "${GREEN}✅ macOS global menu configuration completed${NC}"
}

apply_theme() {
    local theme_id="$1"
    local theme_name="$2"
    
    echo -e "${PURPLE}Applying $theme_name...${NC}"
    
    # Apply Look and Feel theme
    lookandfeeltool --apply "$theme_id" 2>/dev/null || true
    sleep 2
    
    # Apply icons based on theme type
    case "$theme_id" in
        *magicunicorn.light*)
            echo -e "${BLUE}Applying Flat-Remix-Violet-Light icons...${NC}"
            kwriteconfig6 --file kdeglobals --group Icons --key Theme "Flat-Remix-Violet-Light"
            ;;
        *magicunicorn*)
            echo -e "${BLUE}Applying Flat-Remix-Violet-Dark icons...${NC}"
            kwriteconfig6 --file kdeglobals --group Icons --key Theme "Flat-Remix-Violet-Dark"
            ;;
        *unicorncommander.windows.light*)
            echo -e "${BLUE}Applying Flat-Remix-Violet-Light icons...${NC}"
            kwriteconfig6 --file kdeglobals --group Icons --key Theme "Flat-Remix-Violet-Light"
            ;;
        *unicorncommander*)
            echo -e "${BLUE}Applying Flat-Remix-Violet-Dark icons...${NC}"
            kwriteconfig6 --file kdeglobals --group Icons --key Theme "Flat-Remix-Violet-Dark"
            ;;
    esac
    
    # Apply wallpaper based on theme type
    local wallpaper_path=""
    case "$theme_id" in
        *magicunicorn*)
            wallpaper_path="$HOME/.local/share/wallpapers/MagicUnicorn/unicorncommander_1920x1080.jpg"
            ;;
        *unicorncommander*)
            wallpaper_path="$HOME/.local/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg"
            ;;
    esac
    
    if [ -f "$wallpaper_path" ]; then
        plasma-apply-wallpaperimage "$wallpaper_path" 2>/dev/null || true
    fi
    
    # Enable blur effects
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    
    # Apply theme-specific panel configurations
    case "$theme_id" in
        *magicunicorn*)
            echo -e "${BLUE}Configuring Magic Unicorn (macOS-style) layout...${NC}"
            sleep 2
            
            # Ensure we have the correct macOS layout: top panel + bottom dock
            qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                var allPanels = panels();
                var hasTop = false, hasBottom = false;
                
                // Check current panels
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
                    topPanel.addWidget('org.kde.plasma.windowtitle');  // Add window title for app names
                    topPanel.addWidget('org.kde.plasma.appmenu');
                    topPanel.addWidget('org.kde.plasma.panelspacer');
                    topPanel.addWidget('org.kde.plasma.systemtray');
                    topPanel.addWidget('org.kde.plasma.digitalclock');
                    print('Created macOS top panel with app name display');
                }
                
                // Configure bottom panel as macOS dock
                for (var i = 0; i < allPanels.length; i++) {
                    var panel = allPanels[i];
                    if (panel.location == 'bottom') {
                        // Clean dock - remove unwanted widgets but keep essential ones
                        var widgets = panel.widgets();
                        var hasLauncher = false;
                        var hasTrash = false;
                        
                        for (var j = widgets.length - 1; j >= 0; j--) {
                            var widget = widgets[j];
                            if (widget.type === 'org.kde.plasma.kickerdash' ||
                                widget.type === 'org.kde.plasma.private.kicker' ||
                                widget.type === 'org.kde.plasma.kicker' || 
                                widget.type === 'org.kde.plasma.kickoff') {
                                hasLauncher = true;
                            } else if (widget.type === 'org.kde.plasma.trash') {
                                hasTrash = true;
                            } else if (widget.type !== 'org.kde.plasma.icontasks') {
                                // Remove other widgets but keep icon tasks, launcher, and trash
                                widget.remove();
                            }
                        }
                        // Add Application Dashboard (full-screen app grid) if not present
                        var dockLauncher = null;
                        if (!hasLauncher) {
                            // Try Application Dashboard first (the real full-screen one)
                            try {
                                dockLauncher = panel.addWidget('org.kde.plasma.kickerdash');
                                print('✅ Added Application Dashboard widget');
                            } catch (e) {
                                // Fallback to regular kicker
                                try {
                                    dockLauncher = panel.addWidget('org.kde.plasma.kicker');
                                    print('⚠️ Using fallback kicker widget');
                                } catch (e2) {
                                    print('❌ Failed to add launcher widget');
                                }
                            }
                        } else {
                            // Configure existing launcher
                            var widgets = panel.widgets();
                            for (var k = 0; k < widgets.length; k++) {
                                if (widgets[k].type === 'org.kde.plasma.kickerdash' ||
                                    widgets[k].type === 'org.kde.plasma.private.kicker' ||
                                    widgets[k].type === 'org.kde.plasma.kicker' || 
                                    widgets[k].type === 'org.kde.plasma.kickoff') {
                                    dockLauncher = widgets[k];
                                    break;
                                }
                            }
                        }
                        if (dockLauncher) {
                            dockLauncher.currentConfigGroup = ['General'];
                            dockLauncher.writeConfig('useCustomButtonImage', true);
                            dockLauncher.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                            
                            // Configure for Launchpad-style app icons grid
                            dockLauncher.writeConfig('useExtraRunners', false);
                            dockLauncher.writeConfig('showAppsByName', true);
                            dockLauncher.writeConfig('showAppsAsGrid', true);
                            dockLauncher.writeConfig('showRecentApps', false);
                            dockLauncher.writeConfig('showRecentDocs', false);
                            dockLauncher.writeConfig('showRecentContacts', false);
                            dockLauncher.writeConfig('showRunCommand', false);
                            dockLauncher.writeConfig('showSystemActions', false);
                            dockLauncher.writeConfig('alphaSort', true);
                            dockLauncher.writeConfig('limitDepth', true);
                            dockLauncher.writeConfig('appNameFormat', 0);
                            dockLauncher.writeConfig('showingApps', true);
                            dockLauncher.writeConfig('gridAllowTwoLines', true);
                            
                            dockLauncher.reloadConfig();
                        }
                        // Add trash if not present
                        if (!hasTrash) {
                            panel.addWidget('org.kde.plasma.trash');
                        }
                        
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
            
            # 🍎 NEW: Enable macOS-style global menu for Magic Unicorn themes
            sleep 1
            enable_macos_global_menu
            
            # 🚀 NEW: Configure GNOME-style launcher for Magic Unicorn themes
            echo -e "${BLUE}🚀 Configuring GNOME-style app launcher...${NC}"
            kwriteconfig6 --file kwinrc --group Plugins --key overviewEnabled true
            kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9
            ;;
        *unicorncommander*)
            echo -e "${BLUE}Configuring UnicornCommander (Windows-style) layout...${NC}"
            sleep 2
            
            # Ensure we have the correct Windows layout: single bottom taskbar
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
                        // Configure as Windows taskbar
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
    
    # 🦄 Apply unicorn logo to kickoff widgets
    sleep 1
    apply_unicorn_logo
    
    # Restart plasmashell to apply changes
    echo -e "${BLUE}🔄 Restarting plasma shell to apply all changes...${NC}"
    kquitapp6 plasmashell 2>/dev/null || true
    sleep 3
    nohup plasmashell > /dev/null 2>&1 &
    sleep 2
    
    # 🦄 Re-apply unicorn logo after restart (sometimes needed)
    echo -e "${BLUE}🦄 Ensuring unicorn logo is properly applied...${NC}"
    sleep 2
    apply_unicorn_logo
    
    # 🍎 Re-apply macOS global menu after restart (for Magic Unicorn themes)
    case "$theme_id" in
        *magicunicorn*)
            echo -e "${BLUE}🍎 Ensuring macOS global menu is properly configured...${NC}"
            sleep 1
            enable_macos_global_menu
            ;;
    esac
    
    # Reconfigure KWin
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    
    case "$theme_id" in
        *magicunicorn*)
            echo -e "${GREEN}✅ $theme_name applied with unicorn logo and macOS global menu!${NC}"
            ;;
        *)
            echo -e "${GREEN}✅ $theme_name applied with unicorn logo!${NC}"
            ;;
    esac
}

case $choice in
    1)
        apply_theme "org.magicunicorn.light" "Magic Unicorn Light"
        ;;
    2)
        apply_theme "org.magicunicorn.dark" "Magic Unicorn Dark"
        ;;
    3)
        apply_theme "org.unicorncommander.light" "UnicornCommander Light"
        ;;
    4)
        apply_theme "org.unicorncommander.dark" "UnicornCommander Dark"
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
        echo -e "${PURPLE}🎉 Magic Unicorn theme applied with unicorn logo and macOS global menu! 🍎🦄${NC}"
        echo -e "${GREEN}Features enabled:${NC}"
        echo -e "  • Unicorn logo in menu button"
        echo -e "  • macOS-style global menu (app name in menu bar)"
        echo -e "  • Application menus appear in top bar"
        echo ""
        echo -e "${YELLOW}💡 Open any app (Kate, Firefox, etc.) to see the global menu in action!${NC}"
        ;;
    3|4)
        echo -e "${PURPLE}🎉 UnicornCommander theme applied with unicorn logo! 🦄${NC}"
        echo -e "${GREEN}Features enabled:${NC}"
        echo -e "  • Unicorn logo in menu button"
        echo -e "  • Windows-style taskbar"
        ;;
esac
echo ""
read -p "Press Enter to close..."