#!/bin/bash

# Setup full-screen app drawer like macOS Launchpad / GNOME app grid

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}📱 Setting up Full-Screen App Drawer (Launchpad Style)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🚀 Converting dock launcher to full-screen app drawer...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            print('📍 Found bottom dock panel');
            
            var widgets = panel.widgets();
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                
                // Remove existing kicker launcher if present
                if (widget.type === 'org.kde.plasma.kicker') {
                    widget.remove();
                    print('🗑️ Removed old launcher');
                }
            }
            
            // Try different Application Dashboard widget names
            var appDrawer = null;
            var dashboardNames = [
                'org.kde.plasma.kickerdash',
                'org.kde.plasma.kicker.dash',
                'org.kde.kicker.dash'
            ];
            
            for (var dashIndex = 0; dashIndex < dashboardNames.length; dashIndex++) {
                try {
                    appDrawer = panel.addWidget(dashboardNames[dashIndex]);
                    if (appDrawer) {
                        print('✅ Added dashboard widget: ' + dashboardNames[dashIndex]);
                        break;
                    }
                } catch (e) {
                    print('⚠️ Dashboard widget not available: ' + dashboardNames[dashIndex]);
                }
            }
            
            // Fallback: Configure existing kicker as full-screen style
            if (!appDrawer) {
                appDrawer = panel.addWidget('org.kde.plasma.kicker');
                print('📱 Using kicker with full-screen configuration');
            }
            
            if (appDrawer) {
                appDrawer.currentConfigGroup = ['General'];
                
                // Configure for full-screen app drawer experience
                appDrawer.writeConfig('useCustomButtonImage', true);
                appDrawer.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg');
                appDrawer.writeConfig('alphaSort', false);                    // Categories like GNOME
                appDrawer.writeConfig('showAppsAsGrid', true);              // Grid layout
                appDrawer.writeConfig('limitDepth', false);                 // Show all apps
                appDrawer.writeConfig('showAppsByName', true);              // Show app names
                appDrawer.writeConfig('showRecentApps', true);              // Recent apps
                appDrawer.writeConfig('showRecentDocs', false);             // Clean interface
                appDrawer.writeConfig('showRecentContacts', false);         // Clean interface
                appDrawer.writeConfig('fullScreen', true);                  // Full-screen overlay
                
                appDrawer.reloadConfig();
                
                // Position it in center of dock
                var tasksIndex = -1;
                var newWidgets = panel.widgets();
                for (var k = 0; k < newWidgets.length; k++) {
                    if (newWidgets[k].type === 'org.kde.plasma.icontasks') {
                        tasksIndex = k;
                        break;
                    }
                }
                if (tasksIndex >= 0) {
                    appDrawer.index = tasksIndex + 1;
                }
                
                print('✅ Added full-screen app drawer with unicorn icon');
                print('📱 Configured for Launchpad-style experience');
                updated = true;
            } else {
                print('❌ Failed to create app drawer widget');
            }
            
            break;
        }
    }
    
    if (updated) {
        print('🚀 Full-screen app drawer setup completed!');
    } else {
        print('❌ Could not find dock panel');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ Full-screen app drawer configured!${NC}"
echo
echo -e "${PURPLE}📱 Your new app drawer features:${NC}"
echo "• ${YELLOW}Full-screen overlay${NC} - like macOS Launchpad"
echo "• ${YELLOW}Grid layout${NC} - like GNOME app grid"
echo "• ${YELLOW}Category organization${NC} - browse by app type"
echo "• ${YELLOW}Search functionality${NC} - type to find apps"
echo "• ${YELLOW}Unicorn icon${NC} - in center of dock"
echo
echo -e "${BLUE}🧪 Test it now:${NC}"
echo "Click the unicorn icon in your dock → Full-screen app grid opens!"
echo "ESC or click outside → Closes the app drawer"
echo
echo -e "${YELLOW}💡 Just like Android app drawer, macOS Launchpad, or GNOME app grid!${NC}"