#!/bin/bash
# Complete UnicornCommander Icon Theme Integration
# This script integrates the icon theme with your existing KDE themes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$HOME/.local/share/plasma/look-and-feel"
ICON_THEME="UnicornCommander"

echo "🦄 UnicornCommander Icon Theme Integration"
echo "=========================================="

# Function to update theme defaults
update_theme_defaults() {
    local theme_id=$1
    local theme_path="$THEMES_DIR/$theme_id"
    
    if [ -d "$theme_path" ]; then
        echo "Updating $theme_id..."
        
        # Update defaults file
        local defaults_file="$theme_path/contents/defaults"
        if [ -f "$defaults_file" ]; then
            # Remove old Icons line if exists
            sed -i '/^Icons=/d' "$defaults_file"
            # Add new Icons line
            echo "Icons=$ICON_THEME" >> "$defaults_file"
        else
            # Create defaults file if it doesn't exist
            mkdir -p "$theme_path/contents"
            cat > "$defaults_file" << EOF
[kdeglobals][Icons]
Theme=$ICON_THEME

[Icons]
Theme=$ICON_THEME
EOF
        fi
        
        # Update metadata.json to include icon dependency
        local metadata_file="$theme_path/metadata.json"
        if [ -f "$metadata_file" ]; then
            # Use python to update JSON properly
            python3 -c "
import json
with open('$metadata_file', 'r') as f:
    data = json.load(f)
if 'X-KDE-PluginInfo-Depends' not in data:
    data['X-KDE-PluginInfo-Depends'] = []
if '$ICON_THEME-icons' not in data['X-KDE-PluginInfo-Depends']:
    data['X-KDE-PluginInfo-Depends'].append('$ICON_THEME-icons')
with open('$metadata_file', 'w') as f:
    json.dump(data, f, indent=4)
"
        fi
        
        echo "  ✓ Updated $theme_id"
    fi
}

# Update all UnicornCommander themes
echo "Updating theme configurations..."
update_theme_defaults "org.magicunicorn.dark"
update_theme_defaults "org.magicunicorn.light"
update_theme_defaults "org.unicorncommander.dark"
update_theme_defaults "org.unicorncommander.light"

# Update the theme switcher script
echo -e "\nUpdating theme switcher..."
THEME_SWITCHER="$HOME/.local/bin/uc-theme-switch"
if [ -f "$THEME_SWITCHER" ]; then
    # Check if icon application is already in the script
    if ! grep -q "plasma-apply-icontheme" "$THEME_SWITCHER"; then
        # Add icon theme application to each theme case
        sed -i '/lookandfeeltool --apply/a\    plasma-apply-icontheme '"$ICON_THEME"' 2>/dev/null || kwriteconfig6 --file kdeglobals --group Icons --key Theme '"$ICON_THEME" "$THEME_SWITCHER"
        echo "  ✓ Updated theme switcher"
    else
        echo "  ✓ Theme switcher already includes icon support"
    fi
fi

# Create icon theme application script
echo -e "\nCreating helper scripts..."
cat > "$HOME/.local/bin/uc-icons-apply" << 'EOF'
#!/bin/bash
# Apply UnicornCommander icon theme

ICON_THEME="UnicornCommander"

echo "Applying $ICON_THEME icons..."

# Method 1: Using plasma-apply-icontheme (if available)
if command -v plasma-apply-icontheme &> /dev/null; then
    plasma-apply-icontheme "$ICON_THEME"
else
    # Method 2: Using kwriteconfig6
    kwriteconfig6 --file kdeglobals --group Icons --key Theme "$ICON_THEME"
    
    # Update GTK settings too
    if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
        sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
    else
        mkdir -p "$HOME/.config/gtk-3.0"
        echo "[Settings]" > "$HOME/.config/gtk-3.0/settings.ini"
        echo "gtk-icon-theme-name=$ICON_THEME" >> "$HOME/.config/gtk-3.0/settings.ini"
    fi
fi

# Refresh icon caches
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/$ICON_THEME" 2>/dev/null || true
fi

# Update KDE icon cache
if [ -d "$HOME/.cache/icon-cache.kcache" ]; then
    rm -f "$HOME/.cache/icon-cache.kcache"
fi

echo "✅ Icon theme applied! You may need to restart plasmashell for all changes to take effect."
echo "   Run: kquitapp6 plasmashell && kstart6 plasmashell"
EOF

chmod +x "$HOME/.local/bin/uc-icons-apply"

# Create icon theme info script
cat > "$HOME/.local/bin/uc-icons-info" << 'EOF'
#!/bin/bash
# Show UnicornCommander icon theme information

ICON_DIR="$HOME/.local/share/icons/UnicornCommander"

echo "🦄 UnicornCommander Icon Theme Information"
echo "=========================================="
echo ""
echo "Installation path: $ICON_DIR"
echo ""

if [ -d "$ICON_DIR" ]; then
    echo "Icon statistics:"
    echo "  Scalable icons: $(find "$ICON_DIR/scalable" -name "*.svg" 2>/dev/null | wc -l)"
    for size in 16 22 24 32 48 64 96 128 256; do
        count=$(find "$ICON_DIR/${size}x${size}" -name "*.png" 2>/dev/null | wc -l)
        if [ $count -gt 0 ]; then
            echo "  ${size}x${size} icons: $count"
        fi
    done
    echo ""
    echo "Categories:"
    for category in apps places actions devices mimetypes status; do
        count=$(find "$ICON_DIR/scalable/$category" -name "*.svg" 2>/dev/null | wc -l)
        if [ $count -gt 0 ]; then
            echo "  $category: $count icons"
        fi
    done
else
    echo "❌ Icon theme not installed at $ICON_DIR"
    echo "   Run the installation script first."
fi

echo ""
echo "Current system icon theme:"
kreadconfig6 --file kdeglobals --group Icons --key Theme

echo ""
echo "To apply UnicornCommander icons: uc-icons-apply"
EOF

chmod +x "$HOME/.local/bin/uc-icons-info"

# Final instructions
echo -e "\n✅ Integration complete!"
echo ""
echo "Next steps:"
echo "1. Install the icon files:"
echo "   - Save the master icon SVG from the artifact"
echo "   - Run: python3 extract-icons.py master-icons.svg ~/.local/share/icons/UnicornCommander"
echo "   - Run: ./install-icon-theme.sh"
echo ""
echo "2. Apply the icons:"
echo "   - Run: uc-icons-apply"
echo "   - Or use: uc-theme-switch (icons will be applied automatically)"
echo ""
echo "3. Check icon status:"
echo "   - Run: uc-icons-info"
echo ""
echo "The icon theme is now integrated with all your UnicornCommander themes! 🎨"
