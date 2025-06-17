#!/bin/bash

# Apply Unicorn Logo to KDE Plasma Menu Button
# This script updates the current KDE panel to use the unicorn logo

set -e

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🦄 Applying Unicorn Logo to Menu Button${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

UNICORN_SVG="/home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg"

# Check if SVG exists
if [ ! -f "$UNICORN_SVG" ]; then
    echo -e "${RED}❌ Unicorn SVG not found: $UNICORN_SVG${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Found unicorn logo: $UNICORN_SVG${NC}"

# Function to update kickoff icon using kwriteconfig
update_kickoff_icon() {
    echo -e "${BLUE}📝 Updating kickoff menu icon configuration...${NC}"
    
    # Get list of all panels
    PANELS=$(qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var panels = panelIds;
        panels.join(',');
    ")
    
    if [ -z "$PANELS" ]; then
        echo -e "${RED}❌ No panels found${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Found panels: $PANELS${NC}"
    
    # Try to update kickoff widgets in all panels
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var panels = panelIds;
        for (var i = 0; i < panels.length; i++) {
            var panel = panelById(panels[i]);
            if (panel) {
                var widgets = panel.widgets();
                for (var j = 0; j < widgets.length; j++) {
                    var widget = widgets[j];
                    if (widget.type === 'org.kde.plasma.kickoff') {
                        print('Found kickoff widget on panel ' + panels[i]);
                        widget.currentConfigGroup = ['General'];
                        widget.writeConfig('icon', 'file://$UNICORN_SVG');
                        widget.reloadConfig();
                        print('Updated kickoff icon to unicorn logo');
                    }
                }
            }
        }
    "
}

# Function to restart plasma shell
restart_plasma() {
    echo -e "${YELLOW}🔄 Restarting plasma shell to apply changes...${NC}"
    
    # Method 1: Try plasmashell restart
    if command -v plasmashell >/dev/null 2>&1; then
        killall plasmashell 2>/dev/null || true
        sleep 2
        nohup plasmashell >/dev/null 2>&1 &
        sleep 3
        echo -e "${GREEN}✅ Plasma shell restarted${NC}"
    else
        echo -e "${YELLOW}⚠️  plasmashell command not found, trying alternative method${NC}"
        
        # Method 2: Try kquitapp/kstart
        if command -v kquitapp5 >/dev/null 2>&1; then
            kquitapp5 plasmashell
            sleep 2
            kstart5 plasmashell
        elif command -v kquitapp6 >/dev/null 2>&1; then
            kquitapp6 plasmashell  
            sleep 2
            kstart6 plasmashell
        else
            echo -e "${RED}❌ Could not restart plasma shell automatically${NC}"
            echo -e "${YELLOW}Please manually restart plasma shell or log out/in${NC}"
        fi
    fi
}

# Main execution
echo -e "${BLUE}📋 Attempting to update kickoff menu icon...${NC}"

if update_kickoff_icon; then
    echo -e "${GREEN}✅ Kickoff icon updated successfully${NC}"
    
    read -p "$(echo -e ${YELLOW}Restart plasma shell to apply changes? [y/N]: ${NC})" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restart_plasma
    else
        echo -e "${YELLOW}💡 Changes will take effect after plasma restart or logout/login${NC}"
    fi
else
    echo -e "${RED}❌ Failed to update kickoff icon automatically${NC}"
    echo -e "${YELLOW}💡 Manual steps:${NC}"
    echo -e "1. Right-click on the menu button"
    echo -e "2. Select 'Configure Application Launcher...'"
    echo -e "3. Click on the icon next to 'Icon:'"
    echo -e "4. Click 'Browse...' and select: $UNICORN_SVG"
    echo -e "5. Click 'OK' to apply"
fi

echo ""
echo -e "${GREEN}🦄 Unicorn logo application completed!${NC}"