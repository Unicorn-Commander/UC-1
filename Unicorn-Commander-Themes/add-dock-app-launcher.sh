#!/bin/bash

# Add GNOME-style app launcher to center of dock

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Adding GNOME-style App Launcher to Dock${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🎯 Adding app launcher button to center of dock...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            print('📍 Found bottom panel (dock)');
            
            // Get current widgets
            var widgets = panel.widgets();
            var hasLauncher = false;
            var tasksIndex = -1;
            
            // Check what's already there
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                print('  - Widget ' + j + ': ' + widget.type);
                
                if (widget.type === 'org.kde.plasma.icontasks') {
                    tasksIndex = j;
                }
                if (widget.type === 'org.kde.plasma.kickoff' || 
                    widget.type === 'org.kde.plasma.kicker') {
                    hasLauncher = true;
                }
            }
            
            if (!hasLauncher) {
                // Add app launcher in center of dock
                var launcher = panel.addWidget('org.kde.plasma.kicker');
                
                if (launcher) {
                    // Configure the launcher
                    launcher.currentConfigGroup = ['General'];
                    launcher.writeConfig('useCustomButtonImage', true);
                    launcher.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg');
                    launcher.writeConfig('showAppsByName', true);
                    launcher.writeConfig('alphaSort', false);
                    launcher.reloadConfig();
                    
                    // Position it in the center (after icon tasks if they exist)
                    if (tasksIndex >= 0) {
                        launcher.index = tasksIndex + 1;
                    }
                    
                    print('✅ Added GNOME-style app launcher to dock with unicorn icon');
                    updated = true;
                } else {
                    print('❌ Failed to create launcher widget');
                }
            } else {
                print('⚠️ Launcher already exists in dock');
                updated = true;
            }
            
            break;
        }
    }
    
    if (updated) {
        print('🚀 Dock app launcher setup completed!');
    } else {
        print('❌ Could not find bottom panel (dock)');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ GNOME-style dock app launcher added!${NC}"
echo
echo -e "${PURPLE}🚀 Your dock now has:${NC}"
echo "• App launcher button (with unicorn icon) in the center"
echo "• Click it to open the application grid"
echo "• Just like GNOME's 'Show Applications' button"
echo
echo -e "${YELLOW}💡 Click the unicorn icon in your dock to see the app grid!${NC}"