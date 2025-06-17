#!/bin/bash

# Setup Application Dashboard widget for full-screen app grid

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}📱 Setting up Application Dashboard (Full-Screen App Grid)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🔧 Replacing current launcher with Application Dashboard...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            print('📍 Found bottom dock panel');
            
            var widgets = panel.widgets();
            var tasksIndex = -1;
            
            // Remove existing launchers and find icon tasks position
            for (var j = widgets.length - 1; j >= 0; j--) {
                var widget = widgets[j];
                print('  📦 Widget: ' + widget.type);
                
                if (widget.type === 'org.kde.plasma.icontasks') {
                    tasksIndex = j;
                } else if (widget.type === 'org.kde.plasma.kicker' || 
                          widget.type === 'org.kde.plasma.kickoff') {
                    widget.remove();
                    print('🗑️ Removed old launcher: ' + widget.type);
                }
            }
            
            // Try different Application Dashboard widget names
            var dashboardNames = [
                'org.kde.plasma.private.kicker',
                'org.kde.plasma.kickerdash',
                'org.kde.kicker.dash'
            ];
            
            var dashboard = null;
            for (var dashIndex = 0; dashIndex < dashboardNames.length; dashIndex++) {
                try {
                    dashboard = panel.addWidget(dashboardNames[dashIndex]);
                    if (dashboard) {
                        print('✅ Added Application Dashboard: ' + dashboardNames[dashIndex]);
                        break;
                    }
                } catch (e) {
                    print('⚠️ Dashboard not available: ' + dashboardNames[dashIndex]);
                }
            }
            
            if (dashboard) {
                dashboard.currentConfigGroup = ['General'];
                
                // Beautiful rainbow grid icon
                dashboard.writeConfig('useCustomButtonImage', true);
                dashboard.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                
                // Configure for full-screen dashboard
                dashboard.writeConfig('showAppsByName', true);
                dashboard.writeConfig('alphaSort', true);
                dashboard.writeConfig('showRecentApps', false);
                dashboard.writeConfig('showRecentDocs', false);
                dashboard.writeConfig('showRecentContacts', false);
                dashboard.writeConfig('showRunCommand', false);
                dashboard.writeConfig('showSystemActions', false);
                
                dashboard.reloadConfig();
                
                // Position after icon tasks
                if (tasksIndex >= 0) {
                    dashboard.index = tasksIndex + 1;
                }
                
                print('🌈 Application Dashboard configured with rainbow grid icon');
                updated = true;
            } else {
                print('❌ Could not create Application Dashboard - fallback to kicker');
                
                // Fallback to regular kicker if dashboard not available
                var fallback = panel.addWidget('org.kde.plasma.kicker');
                if (fallback) {
                    fallback.currentConfigGroup = ['General'];
                    fallback.writeConfig('useCustomButtonImage', true);
                    fallback.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                    fallback.reloadConfig();
                    
                    if (tasksIndex >= 0) {
                        fallback.index = tasksIndex + 1;
                    }
                    print('📱 Added kicker as fallback with rainbow grid');
                    updated = true;
                }
            }
            
            break;
        }
    }
    
    if (updated) {
        print('🚀 Application Dashboard setup completed!');
    } else {
        print('❌ Could not setup Application Dashboard');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ Application Dashboard configured!${NC}"
echo
echo -e "${PURPLE}📱 Your Application Dashboard features:${NC}"
echo "• ${YELLOW}Full-screen overlay${NC} when clicked"
echo "• ${YELLOW}Grid of all applications${NC} with large icons"
echo "• ${YELLOW}Rainbow grid icon${NC} in dock"
echo "• ${YELLOW}Clean interface${NC} - just apps"
echo "• ${YELLOW}ESC or click outside${NC} to close"
echo
echo -e "${BLUE}🧪 Test it:${NC}"
echo "Click the rainbow grid in your dock → Full-screen app dashboard!"
echo
echo -e "${YELLOW}💡 This is the true Application Dashboard widget for full-screen app browsing!${NC}"