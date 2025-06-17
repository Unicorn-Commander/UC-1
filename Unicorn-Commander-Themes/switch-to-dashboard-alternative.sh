#!/bin/bash

# Try to switch kicker to Application Dashboard using alternatives

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}📱 Switching to Application Dashboard Alternative${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🔧 Attempting to switch kicker to dashboard mode...${NC}"

# First, let's see what alternatives are available for the kicker widget
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            var widgets = panel.widgets();
            
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                if (widget.type === 'org.kde.plasma.kicker') {
                    print('📍 Found kicker launcher at position ' + j);
                    
                    // Try to switch to dashboard view if available
                    widget.currentConfigGroup = ['General'];
                    
                    // Set fullscreen/dashboard mode if available
                    try {
                        widget.writeConfig('showFullscreen', true);
                        print('✅ Enabled fullscreen mode');
                    } catch (e) {
                        print('⚠️ Fullscreen mode not available');
                    }
                    
                    try {
                        widget.writeConfig('dashboardMode', true);
                        print('✅ Enabled dashboard mode');
                    } catch (e) {
                        print('⚠️ Dashboard mode not available');
                    }
                    
                    // Try alternative widget types
                    try {
                        // Some systems have different internal names
                        widget.writeConfig('widgetType', 'dashboard');
                        print('✅ Set widget type to dashboard');
                    } catch (e) {
                        print('⚠️ Widget type setting not available');
                    }
                    
                    widget.reloadConfig();
                    print('🔄 Reloaded kicker configuration');
                    break;
                }
            }
            break;
        }
    }
" 2>/dev/null

echo
echo -e "${YELLOW}📝 Manual Alternative Method:${NC}"
echo "If the automatic switch didn't work, try this:"
echo "1. Right-click on the rainbow grid icon in your dock"
echo "2. Look for 'Configure [Widget Name]' or 'Alternatives'"
echo "3. Select 'Show Alternatives' if available"
echo "4. Choose 'Application Dashboard' from the list"
echo "5. Apply the changes"
echo
echo -e "${BLUE}🔍 Let me also check what launcher widgets are installed...${NC}"

# Check for any dashboard-related desktop files
find /usr/share/plasma/plasmoids/ -name "metadata.desktop" -exec grep -l -i "dashboard\|grid" {} \; 2>/dev/null | head -5

echo
echo -e "${GREEN}✅ Configuration attempt completed!${NC}"
echo -e "${YELLOW}💡 Try clicking the rainbow grid icon to see if it's now full-screen.${NC}"