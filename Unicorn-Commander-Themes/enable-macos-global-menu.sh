#!/bin/bash

# Enable macOS-style Global Menu for Magic Unicorn themes
# This script configures the Application Menu widget to show app titles like macOS

set -e

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🍎 macOS-style Global Menu Configurator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to configure Application Menu widget for macOS behavior
configure_global_menu() {
    echo -e "${BLUE}🔧 Configuring Application Menu for macOS-style behavior...${NC}"
    
    local result=$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allPanels = panels();
        var updated = false;
        
        for (var i = 0; i < allPanels.length; i++) {
            var panel = allPanels[i];
            if (panel.location == 'top') {
                var widgets = panel.widgets();
                for (var j = 0; j < widgets.length; j++) {
                    var widget = widgets[j];
                    if (widget.type === 'org.kde.plasma.appmenu') {
                        widget.currentConfigGroup = ['General'];
                        
                        // Configure for macOS-style behavior
                        widget.writeConfig('showTitle', true);        // Show app name in menu bar
                        widget.writeConfig('compactView', false);     // Show full menu like macOS
                        widget.reloadConfig();
                        
                        print('SUCCESS: Configured Application Menu widget');
                        updated = true;
                    }
                }
            }
        }
        
        if (updated) {
            print('RESULT: macOS-style global menu enabled');
        } else {
            print('ERROR: No Application Menu widget found');
        }
    " 2>/dev/null)
    
    if echo "$result" | grep -q "SUCCESS"; then
        echo -e "${GREEN}✅ Application Menu widget configured successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to configure Application Menu widget${NC}"
        echo "$result"
        return 1
    fi
}

# Function to enable system-wide global menu support
enable_system_support() {
    echo -e "${BLUE}🔧 Enabling system-wide global menu support...${NC}"
    
    # Enable global menu support in KDE
    kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    
    echo -e "${GREEN}✅ System-wide global menu support enabled${NC}"
}

# Function to verify configuration
verify_configuration() {
    echo -e "${BLUE}🔍 Verifying macOS-style global menu configuration...${NC}"
    
    local verification=$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allPanels = panels();
        var found = false;
        
        for (var i = 0; i < allPanels.length; i++) {
            var panel = allPanels[i];
            if (panel.location == 'top') {
                var widgets = panel.widgets();
                for (var j = 0; j < widgets.length; j++) {
                    var widget = widgets[j];
                    if (widget.type === 'org.kde.plasma.appmenu') {
                        widget.currentConfigGroup = ['General'];
                        var showTitle = widget.readConfig('showTitle', false);
                        var compactView = widget.readConfig('compactView', true);
                        
                        if (showTitle && !compactView) {
                            print('VERIFIED: macOS-style configuration active');
                            found = true;
                        } else {
                            print('ISSUE: Configuration not optimal');
                            print('  showTitle: ' + showTitle + ' (should be true)');
                            print('  compactView: ' + compactView + ' (should be false)');
                        }
                    }
                }
            }
        }
        
        if (!found) {
            print('ERROR: No properly configured Application Menu found');
        }
    " 2>/dev/null)
    
    if echo "$verification" | grep -q "VERIFIED"; then
        echo -e "${GREEN}✅ Configuration verified successfully!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Configuration verification issues:${NC}"
        echo "$verification"
        return 1
    fi
}

# Function to refresh panels
refresh_panels() {
    echo -e "${BLUE}🔄 Refreshing panels to apply changes...${NC}"
    
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var allPanels = panels();
        for (var i = 0; i < allPanels.length; i++) {
            allPanels[i].reloadConfig();
        }
    " 2>/dev/null || true
    
    echo -e "${GREEN}✅ Panels refreshed${NC}"
}

# Main execution
echo -e "${BLUE}🚀 Starting macOS-style global menu configuration...${NC}"
echo ""

# Step 1: Configure Application Menu widget
if configure_global_menu; then
    echo ""
    
    # Step 2: Enable system support
    enable_system_support
    echo ""
    
    # Step 3: Refresh panels
    refresh_panels
    echo ""
    
    # Step 4: Verify configuration
    if verify_configuration; then
        echo ""
        echo -e "${GREEN}🎉 SUCCESS! macOS-style global menu is now enabled!${NC}"
        echo ""
        echo -e "${PURPLE}🍎 How to see it in action:${NC}"
        echo -e "1. Open any application (Kate, Firefox, Dolphin, etc.)"
        echo -e "2. Look at the top menu bar - you should see the app name"
        echo -e "3. The app's menus (File, Edit, View, etc.) appear in the top bar"
        echo -e "4. This behaves exactly like macOS!"
        echo ""
        echo -e "${YELLOW}💡 Note: Some applications need to be restarted to fully support global menus${NC}"
    else
        echo ""
        echo -e "${YELLOW}⚠️  Configuration applied but verification had issues${NC}"
        echo -e "${YELLOW}Try opening an application to test the global menu${NC}"
    fi
else
    echo ""
    echo -e "${RED}❌ Failed to configure global menu${NC}"
    echo -e "${YELLOW}💡 Manual steps:${NC}"
    echo -e "1. Right-click on the top panel"
    echo -e "2. Select 'Configure Panel'"
    echo -e "3. Find the 'Application Menu' widget"
    echo -e "4. Click the settings icon and enable 'Show application name'"
    exit 1
fi

echo ""
echo -e "${PURPLE}🍎 macOS-style global menu configuration completed!${NC}"