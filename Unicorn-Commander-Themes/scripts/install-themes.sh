#!/bin/bash

# UnicornCommander KDE Theme Installer
# Installs built themes to system and user directories

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

echo "=== UnicornCommander KDE Theme Installer ==="

# Check if themes are built
if [ ! -d "$BUILD_DIR/look-and-feel" ]; then
    echo "Error: Themes not built. Run ./scripts/build-themes.sh first."
    exit 1
fi

# Install color schemes
echo "Installing color schemes..."
mkdir -p "$HOME/.local/share/color-schemes"
cp "$BUILD_DIR/color-schemes"/*.colors "$HOME/.local/share/color-schemes/"

# Install look-and-feel themes
echo "Installing look-and-feel themes..."
mkdir -p "$HOME/.local/share/plasma/look-and-feel"

for theme in UC-Mac-Light UC-Mac-Dark UC-Windows-Light UC-Windows-Dark; do
    echo "Installing $theme..."
    
    # Copy theme (will overwrite existing)
    cp -r "$BUILD_DIR/look-and-feel/$theme" "$HOME/.local/share/plasma/look-and-feel/"
done

# Copy wallpapers to user directory
echo "Installing wallpapers..."
mkdir -p "$HOME/.local/share/wallpapers/UnicornCommander"
cp "$PROJECT_DIR/assets/wallpapers"/* "$HOME/.local/share/wallpapers/UnicornCommander/"

# Refresh KDE cache
echo "Refreshing KDE cache..."
if command -v kbuildsycoca6 > /dev/null 2>&1; then
    kbuildsycoca6 --noincremental
elif command -v kbuildsycoca5 > /dev/null 2>&1; then
    kbuildsycoca5 --noincremental
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Available themes:"
echo "- UnicornCommander Mac Light"
echo "- UnicornCommander Mac Dark"  
echo "- UnicornCommander Windows Light"
echo "- UnicornCommander Windows Dark"
echo ""
echo "To apply a theme:"
echo "1. Open System Settings"
echo "2. Go to Appearance > Global Theme"
echo "3. Select your preferred UnicornCommander theme"
echo "4. Click 'Apply'"
echo ""
echo "Note: You may need to log out and back in for all changes to take effect."