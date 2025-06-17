#!/bin/bash

# Restore rainbow grid launcher after theme switching

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${PURPLE}🌈 Restoring Rainbow Grid Launcher${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo -e "${BLUE}🔧 Adding rainbow grid launcher back to dock...${NC}"

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allPanels = panels();
    var updated = false;
    
    for (var i = 0; i < allPanels.length; i++) {
        var panel = allPanels[i];
        if (panel.location == 'bottom') {
            print('📍 Found bottom dock panel');
            
            var widgets = panel.widgets();
            var hasLauncher = false;
            var tasksIndex = -1;
            
            // Check what's currently there
            for (var j = 0; j < widgets.length; j++) {
                var widget = widgets[j];
                print('  📦 Widget ' + j + ': ' + widget.type);
                
                if (widget.type === 'org.kde.plasma.icontasks') {
                    tasksIndex = j;
                } else if (widget.type === 'org.kde.plasma.kicker' || 
                          widget.type === 'org.kde.plasma.kickoff') {
                    hasLauncher = true;
                    print('  ✅ Launcher already exists');
                }
            }
            
            if (!hasLauncher) {
                // Add rainbow grid launcher
                var launcher = panel.addWidget('org.kde.plasma.kicker');
                
                if (launcher) {
                    launcher.currentConfigGroup = ['General'];
                    
                    // Beautiful rainbow grid icon
                    launcher.writeConfig('useCustomButtonImage', true);
                    launcher.writeConfig('customButtonImage', 'file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/rainbow-grid.svg');
                    
                    // Configure for Launchpad-style app icons grid
                    launcher.writeConfig('useExtraRunners', false);
                    launcher.writeConfig('showAppsByName', true);
                    launcher.writeConfig('showAppsAsGrid', true);
                    launcher.writeConfig('showRecentApps', false);
                    launcher.writeConfig('showRecentDocs', false);
                    launcher.writeConfig('showRecentContacts', false);
                    launcher.writeConfig('showRunCommand', false);
                    launcher.writeConfig('showSystemActions', false);
                    launcher.writeConfig('alphaSort', true);
                    launcher.writeConfig('limitDepth', true);
                    launcher.writeConfig('appNameFormat', 0);
                    launcher.writeConfig('showingApps', true);
                    launcher.writeConfig('gridAllowTwoLines', true);
                    
                    launcher.reloadConfig();
                    
                    // Position it at the leftmost position (like macOS Launchpad)
                    launcher.index = 0;
                    
                    print('✅ Added rainbow grid launcher with app icons configuration');
                    updated = true;
                } else {
                    print('❌ Failed to create launcher');
                }
            }
            
            break;
        }
    }
    
    if (updated) {
        print('🌈 Rainbow grid launcher restored!');
    } else if (!updated) {
        print('⚠️ Launcher may already exist or could not be added');
    }
" 2>/dev/null

echo
echo -e "${GREEN}✅ Rainbow grid launcher restoration completed!${NC}"
echo
echo -e "${YELLOW}💡 Check your dock for the rainbow grid icon - click it to see app icons!${NC}"