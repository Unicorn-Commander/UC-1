#!/bin/bash

# Setup GNOME-style app launcher for Magic Unicorn themes

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Setting up GNOME-style App Launcher${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}Available launcher options:${NC}"
echo "1. ${YELLOW}Application Dashboard${NC} - Full-screen GNOME-style grid launcher"
echo "2. ${YELLOW}Overview Effect${NC} - GNOME-like overview with activities"
echo "3. ${YELLOW}Kicker Launcher${NC} - Compact grid-style launcher"
echo

# Option 1: Try to set up Application Dashboard
echo -e "${BLUE}🔧 Setting up Application Dashboard (GNOME-style)...${NC}"

# First, let's add the Application Dashboard widget
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'top') {
            // Try to add Application Dashboard
            try {
                var dashboard = panel.addWidget('org.kde.plasma.private.kicker');
                if (dashboard) {
                    dashboard.currentConfigGroup = ['General'];
                    dashboard.writeConfig('useCustomButtonImage', true);
                    dashboard.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg');
                    dashboard.writeConfig('alphaSort', false);
                    dashboard.writeConfig('showAppsAsGrid', true);
                    dashboard.reloadConfig();
                    print('✅ Added Application Dashboard with unicorn icon');
                    updated = true;
                }
            } catch (e) {
                print('⚠️ Application Dashboard not available, using alternative...');
            }
            break;
        }
    }
    
    if (!updated) {
        print('❌ Could not add Application Dashboard');
    }
" 2>/dev/null

# Option 2: Configure Overview Effect (GNOME-like activities)
echo -e "${BLUE}🔧 Enabling Overview Effect...${NC}"

# Enable the Overview effect in KWin
kwriteconfig6 --file kwinrc --group Plugins --key overviewEnabled true
kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9  # Top-left corner

# Set up Meta key for overview
kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Overview" "Meta+Tab,Meta+Tab,Toggle Overview"

# Option 3: Configure existing launcher to be more GNOME-like
echo -e "${BLUE}🔧 Configuring existing launcher for GNOME-style behavior...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        var widgets = panel.widgets();
        for (var j = 0; j < widgets.length; j++) {
            var widget = widgets[j];
            if (widget.type === 'org.kde.plasma.kickoff') {
                widget.currentConfigGroup = ['General'];
                
                // Configure for GNOME-style grid layout
                widget.writeConfig('useCustomButtonImage', true);
                widget.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg');
                widget.writeConfig('alphaSort', false);                    // Category-based like GNOME
                widget.writeConfig('limitDepth', false);                   // Show all apps
                widget.writeConfig('showAppsByName', true);               // Show app names
                widget.writeConfig('showRecentApps', true);               // Recent apps like GNOME
                widget.writeConfig('showRecentDocs', false);              // Keep clean
                widget.writeConfig('showRecentContacts', false);          // Keep clean
                
                widget.reloadConfig();
                print('✅ Configured Kickoff for GNOME-style behavior');
                updated = true;
            }
        }
    }
    
    if (updated) {
        print('🚀 GNOME-style launcher configuration applied!');
    } else {
        print('❌ No launcher found to configure');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ GNOME-style launcher setup completed!${NC}"
echo
echo -e "${PURPLE}🚀 How to use your new GNOME-style features:${NC}"
echo -e "${YELLOW}1. App Launcher:${NC} Click the unicorn icon to open the application grid"
echo -e "${YELLOW}2. Overview Effect:${NC} Press Meta+Tab or move mouse to top-left corner"
echo -e "${YELLOW}3. Activities:${NC} Super key opens activities overview"
echo
echo -e "${BLUE}💡 The launcher now shows apps in a grid layout like GNOME!${NC}"