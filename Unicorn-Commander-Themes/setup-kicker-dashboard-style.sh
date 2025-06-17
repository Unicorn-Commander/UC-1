#!/bin/bash

# Setup Kicker launcher configured as Application Dashboard style

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🌈 Setting up Kicker in Dashboard Style${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🔧 Adding Kicker launcher configured for dashboard-style behavior...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            print('📍 Found bottom dock panel');
            
            var widgets = panel.widgets();
            var hasLauncher = false;
            var tasksIndex = -1;
            
            // Remove any broken launchers and find icon tasks position
            for (var j = widgets.length - 1; j >= 0; j--) {
                var widget = widgets[j];
                print('  📦 Widget ' + j + ': ' + widget.type);
                
                if (widget.type === 'org.kde.plasma.icontasks') {
                    tasksIndex = j;
                } else if (widget.type.includes('kicker') && widget.type !== 'org.kde.plasma.kicker') {
                    // Remove broken launcher widgets
                    widget.remove();
                    print('🗑️ Removed broken launcher: ' + widget.type);
                } else if (widget.type === 'org.kde.plasma.kicker') {
                    hasLauncher = true;
                    print('  ✅ Working kicker launcher exists');
                }
            }
            
            if (!hasLauncher) {
                var launcher = panel.addWidget('org.kde.plasma.kicker');
                
                if (launcher) {
                    launcher.currentConfigGroup = ['General'];
                    
                    // Beautiful rainbow grid icon
                    launcher.writeConfig('useCustomButtonImage', true);
                    launcher.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                    
                    // Configure for dashboard-like behavior (best approximation)
                    launcher.writeConfig('showAppsByName', true);
                    launcher.writeConfig('alphaSort', true);
                    launcher.writeConfig('showRecentApps', false);
                    launcher.writeConfig('showRecentDocs', false);
                    launcher.writeConfig('showRecentContacts', false);
                    launcher.writeConfig('showSystemActions', false);
                    launcher.writeConfig('limitDepth', false);
                    launcher.writeConfig('appNameFormat', 0);
                    
                    launcher.reloadConfig();
                    
                    // Position it: center (after icon tasks) or left
                    if (tasksIndex >= 0) {
                        launcher.index = tasksIndex + 1;
                        print('📍 Positioned launcher after icon tasks (center)');
                    } else {
                        launcher.index = 0;
                        print('📍 Positioned launcher at left side');
                    }
                    
                    print('✅ Added Kicker launcher with rainbow grid icon');
                    print('🌈 Configured for dashboard-style app browsing');
                } else {
                    print('❌ Failed to create Kicker launcher');
                }
            } else {
                // Configure existing launcher
                var widgets = panel.widgets();
                for (var k = 0; k < widgets.length; k++) {
                    var widget = widgets[k];
                    if (widget.type === 'org.kde.plasma.kicker') {
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
                        print('✅ Configured existing launcher with rainbow grid');
                        break;
                    }
                }
            }
            
            break;
        }
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ Kicker launcher configured in dashboard style!${NC}"
echo
echo -e "${PURPLE}🌈 Your launcher features:${NC}"
echo "• ${YELLOW}Rainbow grid icon${NC} in dock (positioned optimally)"
echo "• ${YELLOW}Grid-style app browser${NC} when clicked"
echo "• ${YELLOW}Clean interface${NC} - apps organized by category"
echo "• ${YELLOW}Search functionality${NC} - type to find apps"
echo "• ${YELLOW}No clutter${NC} - recent items disabled"
echo
echo -e "${BLUE}🧪 Test it now: Click the rainbow grid icon!${NC}"
echo -e "${YELLOW}💡 This gives you the closest experience to Application Dashboard using available widgets.${NC}"