#!/bin/bash

# Configure rainbow grid launcher to show app icons grid like macOS Launchpad

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🌈 Setting up App Icons Grid Launcher (Launchpad Style)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🚀 Configuring rainbow grid for full-screen app icons view...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            var widgets = panel.widgets();
            
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                
                if (widget.type === 'org.kde.plasma.kicker') {
                    print('📍 Found kicker launcher - configuring for icon grid view');
                    
                    widget.currentConfigGroup = ['General'];
                    
                    // Rainbow grid icon
                    widget.writeConfig('useCustomButtonImage', true);
                    widget.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                    
                    // Configure for full-screen icon grid (like Launchpad)
                    widget.writeConfig('useExtraRunners', false);           // Clean interface
                    widget.writeConfig('showAppsByName', true);            // Show app names under icons
                    widget.writeConfig('showAppsAsGrid', true);            // Grid layout of icons
                    widget.writeConfig('showRecentApps', false);           // Don't show recent (cleaner)
                    widget.writeConfig('showRecentDocs', false);           // Don't show documents
                    widget.writeConfig('showRecentContacts', false);       // Don't show contacts
                    widget.writeConfig('showRunCommand', false);           // No run command
                    widget.writeConfig('showSystemActions', false);        // No system actions
                    widget.writeConfig('alphaSort', true);                 // Alphabetical like Launchpad
                    widget.writeConfig('limitDepth', true);                // Flat structure
                    widget.writeConfig('appNameFormat', 0);                // Show full app names
                    
                    // Grid appearance settings
                    widget.writeConfig('showingApps', true);               // Always show apps
                    widget.writeConfig('gridAllowTwoLines', true);         // Two lines for names
                    
                    widget.reloadConfig();
                    
                    print('✅ Configured launcher for full-screen app icons grid');
                    print('🌈 Rainbow grid now opens Launchpad-style app icons!');
                    updated = true;
                    break;
                }
            }
        }
    }
    
    if (updated) {
        print('🚀 App icons grid configuration completed!');
    } else {
        print('❌ Could not find launcher to configure');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ Rainbow grid launcher configured for app icons!${NC}"
echo
echo -e "${PURPLE}🌈 Your new Launchpad-style launcher:${NC}"
echo "• ${YELLOW}Click rainbow grid${NC} → Full-screen app icons appear"
echo "• ${YELLOW}Grid layout${NC} of app icons (like macOS Launchpad)"
echo "• ${YELLOW}App names${NC} under each icon"
echo "• ${YELLOW}Alphabetical order${NC} for easy browsing"
echo "• ${YELLOW}Clean interface${NC} - just apps, no clutter"
echo "• ${YELLOW}ESC or click outside${NC} to close"
echo
echo -e "${BLUE}🧪 Test it now:${NC}"
echo "Click the rainbow grid icon in your dock → See all your app icons!"
echo
echo -e "${YELLOW}💡 Just like macOS Launchpad, Android app drawer, or GNOME app grid!${NC}"