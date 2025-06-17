#!/bin/bash

# Simple script to set unicorn icon via KDE configuration
# Alternative method using kwriteconfig

UNICORN_SVG="file:///home/ucadmin/UC-1/KDE-Themes/assets/menu-button/unicorn.svg"

echo "🦄 Setting unicorn logo for KDE menu button..."

# Try to find and update kickoff configurations
CONFIG_DIR="$HOME/.config"

# Look for plasma configuration files
if [ -d "$CONFIG_DIR" ]; then
    echo "📁 Found KDE config directory: $CONFIG_DIR"
    
    # Try kwriteconfig5 first, then kwriteconfig6
    if command -v kwriteconfig5 >/dev/null 2>&1; then
        KWRITE="kwriteconfig5"
    elif command -v kwriteconfig6 >/dev/null 2>&1; then
        KWRITE="kwriteconfig6"
    else
        echo "❌ kwriteconfig not found"
        exit 1
    fi
    
    echo "🔧 Using $KWRITE to update configuration..."
    
    # Try to update global kickoff settings
    $KWRITE --file kickoffrc --group General --key icon "$UNICORN_SVG"
    
    echo "✅ Configuration updated!"
    echo "💡 You may need to restart plasma shell or logout/login to see changes"
    echo "💡 Run: killall plasmashell && plasmashell &"
    
else
    echo "❌ KDE config directory not found"
    exit 1
fi