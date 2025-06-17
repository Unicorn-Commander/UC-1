#!/bin/bash

# Install Window Title Applet for macOS-style app name display

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🍎 Installing Window Title Widget for macOS-style App Names${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}📥 This will add a Window Title widget to show active app names${NC}"
echo -e "${YELLOW}💡 This is a workaround for the KDE6+Wayland global menu issues${NC}"
echo

# Add Window Title widget to the top panel
echo -e "${BLUE}🔧 Adding Window Title widget to top panel...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'top') {
            // Find the position after kickoff but before appmenu
            var widgets = panel.widgets();
            var insertIndex = -1;
            
            for (var j = 0; j < widgets.length; j++) {
                if (widgets[j].type === 'org.kde.plasma.kickoff') {
                    insertIndex = j + 1;
                    break;
                }
            }
            
            if (insertIndex >= 0) {
                // Add Window Title widget
                var windowTitle = panel.addWidget('org.kde.plasma.windowtitle');
                
                // Move it to the correct position (after kickoff)
                panel.widgets()[panel.widgets().length - 1].index = insertIndex;
                
                // Configure the widget
                if (windowTitle) {
                    windowTitle.currentConfigGroup = ['General'];
                    windowTitle.writeConfig('showIcon', true);
                    windowTitle.writeConfig('showTitle', true);
                    windowTitle.writeConfig('bold', false);
                    windowTitle.writeConfig('undefinedWindowTitle', '');
                    windowTitle.reloadConfig();
                }
                
                print('✅ Added Window Title widget to show active app names');
                updated = true;
            }
        }
    }
    
    if (updated) {
        print('🍎 Window Title widget installed - app names will now show!');
    } else {
        print('❌ Could not find suitable panel position');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ Window Title widget installation completed!${NC}"
echo
echo -e "${PURPLE}🍎 How it works:${NC}"
echo "• The widget shows the active application name in the top bar"
echo "• It works alongside the global menu"
echo "• This provides macOS-style behavior on Wayland"
echo
echo -e "${YELLOW}💡 Switch between apps to see the name change!${NC}"