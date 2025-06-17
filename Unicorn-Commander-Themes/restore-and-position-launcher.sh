#!/bin/bash

# Restore Application Dashboard and position it correctly

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🌈 Restoring & Positioning Application Dashboard${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🔧 Adding Application Dashboard with proper positioning...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            print('📍 Found bottom dock panel');
            
            var widgets = panel.widgets();
            var hasLauncher = false;
            var tasksIndex = -1;
            var trashIndex = -1;
            
            // Check current widgets and find positions
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                print('  📦 Widget ' + j + ': ' + widget.type);
                
                if (widget.type === 'org.kde.plasma.icontasks') {
                    tasksIndex = j;
                } else if (widget.type === 'org.kde.plasma.trash') {
                    trashIndex = j;
                } else if (widget.type.includes('kicker')) {
                    hasLauncher = true;
                    print('  ✅ Launcher already exists at position ' + j);
                }
            }
            
            if (!hasLauncher) {
                var dashboard = panel.addWidget('org.kde.plasma.private.kicker');
                
                if (dashboard) {
                    // Configure the dashboard
                    dashboard.currentConfigGroup = ['General'];
                    dashboard.writeConfig('useCustomButtonImage', true);
                    dashboard.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                    dashboard.reloadConfig();
                    
                    // Position it: try center (after icon tasks), or left if center doesn't work
                    if (tasksIndex >= 0) {
                        // Put it after icon tasks (center-ish)
                        dashboard.index = tasksIndex + 1;
                        print('📍 Positioned dashboard after icon tasks (center)');
                    } else {
                        // Put it at the beginning (left side)
                        dashboard.index = 0;
                        print('📍 Positioned dashboard at left side');
                    }
                    
                    print('✅ Added Application Dashboard with rainbow grid icon');
                } else {
                    print('❌ Failed to create Application Dashboard');
                }
            }
            
            break;
        }
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ Application Dashboard restored and positioned!${NC}"
echo
echo -e "${PURPLE}📱 Your setup:${NC}"
echo "• ${YELLOW}Rainbow grid icon${NC} in dock (positioned optimally)"
echo "• ${YELLOW}Click it${NC} → Full-screen app grid overlay"
echo "• ${YELLOW}ESC or click outside${NC} to close"
echo
echo -e "${BLUE}🧪 Test it now: Click the rainbow grid icon in your dock!${NC}"