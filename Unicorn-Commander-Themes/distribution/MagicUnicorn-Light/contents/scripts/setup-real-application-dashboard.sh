#!/bin/bash

# Setup the REAL Application Dashboard widget

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🎉 Setting up REAL Application Dashboard!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🔧 Replacing kicker with true Application Dashboard...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            print('📍 Found bottom dock panel');
            
            var widgets = panel.widgets();
            var tasksIndex = -1;
            var hasKickerdash = false;
            
            // Remove existing kicker and find icon tasks position
            for (var j = widgets.length - 1; j >= 0; j--) {
                var widget = widgets[j];
                print('  📦 Widget ' + j + ': ' + widget.type);
                
                if (widget.type === 'org.kde.plasma.icontasks') {
                    tasksIndex = j;
                } else if (widget.type === 'org.kde.plasma.kickerdash') {
                    hasKickerdash = true;
                    print('  ✅ Application Dashboard already exists');
                } else if (widget.type === 'org.kde.plasma.kicker' || 
                          widget.type === 'org.kde.plasma.kickoff') {
                    widget.remove();
                    print('🗑️ Removed old launcher: ' + widget.type);
                }
            }
            
            if (!hasKickerdash) {
                var dashboard = panel.addWidget('org.kde.plasma.kickerdash');
                
                if (dashboard) {
                    dashboard.currentConfigGroup = ['General'];
                    
                    // Beautiful rainbow grid icon
                    dashboard.writeConfig('useCustomButtonImage', true);
                    dashboard.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                    
                    // Configure for optimal dashboard experience
                    dashboard.writeConfig('showAppsByName', true);
                    dashboard.writeConfig('alphaSort', true);
                    dashboard.writeConfig('showRecentApps', false);
                    dashboard.writeConfig('showRecentDocs', false);
                    dashboard.writeConfig('showRecentContacts', false);
                    dashboard.writeConfig('showSystemActions', false);
                    
                    dashboard.reloadConfig();
                    
                    // Position it: center (after icon tasks)
                    if (tasksIndex >= 0) {
                        dashboard.index = tasksIndex + 1;
                        print('📍 Positioned Application Dashboard after icon tasks (center)');
                    } else {
                        dashboard.index = 0;
                        print('📍 Positioned Application Dashboard at left side');
                    }
                    
                    print('✅ Added REAL Application Dashboard with rainbow grid icon');
                    print('🎉 Full-screen app grid overlay ready!');
                } else {
                    print('❌ Failed to create Application Dashboard');
                }
            } else {
                // Configure existing Application Dashboard
                var widgets = panel.widgets();
                for (var k = 0; k < widgets.length; k++) {
                    var widget = widgets[k];
                    if (widget.type === 'org.kde.plasma.kickerdash') {
                        widget.currentConfigGroup = ['General'];
                        widget.writeConfig('useCustomButtonImage', true);
                        widget.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                        widget.writeConfig('showAppsByName', true);
                        widget.writeConfig('alphaSort', true);
                        widget.writeConfig('showRecentApps', false);
                        widget.writeConfig('showRecentDocs', false);
                        widget.writeConfig('showRecentContacts', false);
                        widget.writeConfig('showSystemActions', false);
                        widget.reloadConfig();
                        print('✅ Configured existing Application Dashboard with rainbow grid');
                        break;
                    }
                }
            }
            
            break;
        }
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ REAL Application Dashboard configured!${NC}"
echo
echo -e "${PURPLE}🎉 Your TRUE Application Dashboard features:${NC}"
echo "• ${YELLOW}Full-screen overlay${NC} when clicked (not a menu!)"
echo "• ${YELLOW}Beautiful rainbow grid icon${NC} in dock"
echo "• ${YELLOW}Grid of all applications${NC} with large icons"
echo "• ${YELLOW}macOS Launchpad experience${NC} on KDE"
echo "• ${YELLOW}ESC or click outside${NC} to close"
echo
echo -e "${BLUE}🧪 Test the REAL Application Dashboard:${NC}"
echo "Click the rainbow grid icon → Full-screen app grid overlay!"
echo
echo -e "${YELLOW}💡 This is the true Application Dashboard widget - full-screen app browsing!${NC}"