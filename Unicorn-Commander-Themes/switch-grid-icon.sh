#!/bin/bash

# Switch between 3x3 and 4x4 rainbow grid icons

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${PURPLE}🌈 Rainbow Grid Icon Switcher${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo -e "${BLUE}Choose your rainbow grid style:${NC}"
echo
echo -e "  ${PURPLE}1.${NC} 3x3 Rainbow Grid (larger squares)"
echo -e "  ${PURPLE}2.${NC} 4x4 Rainbow Grid (more squares)"
echo -e "  ${NC}3.${NC} Exit"
echo
read -p "Select grid style (1-3): " choice

case $choice in
    1)
        icon_path="file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg"
        grid_type="3x3"
        ;;
    2)
        icon_path="file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid-4x4.svg"
        grid_type="4x4"
        ;;
    3)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Invalid choice${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}🎨 Applying $grid_type rainbow grid icon...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            var widgets = panel.widgets();
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                if (widget.type === 'org.kde.plasma.kicker') {
                    widget.currentConfigGroup = ['General'];
                    widget.writeConfig('customButtonImage', '$icon_path');
                    widget.reloadConfig();
                    print('✅ Updated to $grid_type rainbow grid icon');
                    updated = true;
                    break;
                }
            }
        }
    }
    
    if (updated) {
        print('🌈 Rainbow grid icon updated successfully!');
    } else {
        print('❌ Could not find launcher to update');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ $grid_type rainbow grid icon applied!${NC}"
echo -e "${YELLOW}💡 Check your dock for the beautiful new rainbow grid launcher!${NC}"