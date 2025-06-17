#!/bin/bash

# Alternative method: Convert existing launcher to Application Dashboard

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}📱 Converting to Application Dashboard (Full-Screen App Drawer)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🔄 Converting existing launcher to Application Dashboard...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            var widgets = panel.widgets();
            
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                
                if (widget.type === 'org.kde.plasma.kicker' || widget.type === 'org.kde.plasma.kickoff') {
                    print('📍 Found launcher widget: ' + widget.type);
                    
                    // Configure for full-screen dashboard behavior
                    widget.currentConfigGroup = ['General'];
                    
                    // Set up the unicorn icon
                    widget.writeConfig('useCustomButtonImage', true);
                    widget.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg');
                    
                    // Configure for dashboard-style behavior
                    widget.writeConfig('favoriteApps', 'preferred://browser,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,org.kde.plasma.systemmonitor.desktop');
                    widget.writeConfig('showAppsAsGrid', true);
                    widget.writeConfig('showRecentApps', true);
                    widget.writeConfig('showRecentDocs', false);
                    widget.writeConfig('showRecentContacts', false);
                    widget.writeConfig('alphaSort', false);
                    widget.writeConfig('limitDepth', false);
                    
                    widget.reloadConfig();
                    
                    print('✅ Configured launcher as full-screen dashboard style');
                    print('📱 Click the unicorn icon for app drawer experience');
                }
            }
        }
    }
" 2>/dev/null

echo
echo -e "${YELLOW}💡 Manual alternative if needed:${NC}"
echo "1. Right-click on the unicorn launcher in your dock"
echo "2. Select 'Configure [Launcher Name]'"
echo "3. Look for 'Show Alternatives' or 'Alternative' button"
echo "4. Choose 'Application Dashboard' if available"
echo

echo -e "${GREEN}✅ App drawer configuration completed!${NC}"
echo
echo -e "${BLUE}🧪 Test your app drawer:${NC}"
echo "Click the unicorn icon in the dock → Should open full-screen app grid!"