#!/bin/bash

# UnicornCommander KDE Theme Builder
# Builds all theme variants and creates installable packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
THEMES_DIR="$PROJECT_DIR/themes"
BUILD_DIR="$PROJECT_DIR/build"
ASSETS_DIR="$PROJECT_DIR/assets"

echo "=== UnicornCommander KDE Theme Builder ==="
echo "Project directory: $PROJECT_DIR"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create color schemes
echo "Creating color schemes..."
mkdir -p "$BUILD_DIR/color-schemes"

# UC Mac Light Color Scheme
cat > "$BUILD_DIR/color-schemes/UCMacLight.colors" << 'EOF'
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=255,255,255
BackgroundNormal=248,248,248
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=139,92,246
ForegroundInactive=127,140,141
ForegroundLink=59,130,246
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Selection]
BackgroundAlternate=196,181,253
BackgroundNormal=139,92,246
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=255,255,255
ForegroundInactive=255,255,255
ForegroundLink=255,255,255
ForegroundNegative=255,255,255
ForegroundNeutral=255,255,255
ForegroundNormal=255,255,255
ForegroundPositive=255,255,255
ForegroundVisited=255,255,255

[Colors:View]
BackgroundAlternate=255,255,255
BackgroundNormal=252,252,252
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=139,92,246
ForegroundInactive=127,140,141
ForegroundLink=59,130,246
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Window]
BackgroundAlternate=245,245,245
BackgroundNormal=248,248,248
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=139,92,246
ForegroundInactive=127,140,141
ForegroundLink=59,130,246
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=35,38,39
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[General]
ColorScheme=UCMacLight
Name=UC Mac Light
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=248,248,248
activeForeground=35,38,39
inactiveBackground=245,245,245
inactiveForeground=127,140,141
EOF

# UC Windows Light Color Scheme  
cat > "$BUILD_DIR/color-schemes/UCWindowsLight.colors" << 'EOF'
[Colors:Button]
BackgroundAlternate=245,245,245
BackgroundNormal=240,240,240
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=0,120,215
ForegroundInactive=109,109,109
ForegroundLink=0,102,204
ForegroundNegative=196,43,28
ForegroundNeutral=255,140,0
ForegroundNormal=0,0,0
ForegroundPositive=16,124,16
ForegroundVisited=118,0,118

[Colors:Selection]
BackgroundAlternate=150,200,255
BackgroundNormal=0,120,215
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=255,255,255
ForegroundInactive=255,255,255
ForegroundLink=255,255,255
ForegroundNegative=255,255,255
ForegroundNeutral=255,255,255
ForegroundNormal=255,255,255
ForegroundPositive=255,255,255
ForegroundVisited=255,255,255

[Colors:View]
BackgroundAlternate=255,255,255
BackgroundNormal=255,255,255
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=0,120,215
ForegroundInactive=109,109,109
ForegroundLink=0,102,204
ForegroundNegative=196,43,28
ForegroundNeutral=255,140,0
ForegroundNormal=0,0,0
ForegroundPositive=16,124,16
ForegroundVisited=118,0,118

[Colors:Window]
BackgroundAlternate=240,240,240
BackgroundNormal=255,255,255
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=0,120,215
ForegroundInactive=109,109,109
ForegroundLink=0,102,204
ForegroundNegative=196,43,28
ForegroundNeutral=255,140,0
ForegroundNormal=0,0,0
ForegroundPositive=16,124,16
ForegroundVisited=118,0,118

[General]
ColorScheme=UCWindowsLight
Name=UC Windows Light
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=255,255,255
activeForeground=0,0,0
inactiveBackground=240,240,240
inactiveForeground=109,109,109
EOF

# UC Windows Dark Color Scheme
cat > "$BUILD_DIR/color-schemes/UCWindowsDark.colors" << 'EOF'
[Colors:Button]
BackgroundAlternate=52,52,52
BackgroundNormal=43,43,43
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=0,120,215
ForegroundInactive=153,153,153
ForegroundLink=99,162,255
ForegroundNegative=242,80,34
ForegroundNeutral=255,185,0
ForegroundNormal=255,255,255
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Selection]
BackgroundAlternate=0,84,153
BackgroundNormal=0,120,215
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=255,255,255
ForegroundInactive=255,255,255
ForegroundLink=255,255,255
ForegroundNegative=255,255,255
ForegroundNeutral=255,255,255
ForegroundNormal=255,255,255
ForegroundPositive=255,255,255
ForegroundVisited=255,255,255

[Colors:View]
BackgroundAlternate=37,37,37
BackgroundNormal=32,32,32
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=0,120,215
ForegroundInactive=153,153,153
ForegroundLink=99,162,255
ForegroundNegative=242,80,34
ForegroundNeutral=255,185,0
ForegroundNormal=255,255,255
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Window]
BackgroundAlternate=43,43,43
BackgroundNormal=32,32,32
DecorationFocus=0,120,215
DecorationHover=70,140,230
ForegroundActive=0,120,215
ForegroundInactive=153,153,153
ForegroundLink=99,162,255
ForegroundNegative=242,80,34
ForegroundNeutral=255,185,0
ForegroundNormal=255,255,255
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[General]
ColorScheme=UCWindowsDark
Name=UC Windows Dark
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=32,32,32
activeForeground=255,255,255
inactiveBackground=43,43,43
inactiveForeground=153,153,153
EOF

# UC Mac Dark Color Scheme
cat > "$BUILD_DIR/color-schemes/UCMacDark.colors" << 'EOF'
[Colors:Button]
BackgroundAlternate=45,48,51
BackgroundNormal=35,38,39
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=139,92,246
ForegroundInactive=127,140,141
ForegroundLink=96,165,250
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundNormal=252,252,252
ForegroundPositive=34,197,94
ForegroundVisited=168,85,247

[Colors:Selection]
BackgroundAlternate=88,28,135
BackgroundNormal=139,92,246
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=255,255,255
ForegroundInactive=255,255,255
ForegroundLink=255,255,255
ForegroundNegative=255,255,255
ForegroundNeutral=255,255,255
ForegroundNormal=255,255,255
ForegroundPositive=255,255,255
ForegroundVisited=255,255,255

[Colors:View]
BackgroundAlternate=30,30,30
BackgroundNormal=24,24,27
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=139,92,246
ForegroundInactive=127,140,141
ForegroundLink=96,165,250
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundNormal=252,252,252
ForegroundPositive=34,197,94
ForegroundVisited=168,85,247

[Colors:Window]
BackgroundAlternate=39,39,42
BackgroundNormal=24,24,27
DecorationFocus=139,92,246
DecorationHover=157,139,251
ForegroundActive=139,92,246
ForegroundInactive=127,140,141
ForegroundLink=96,165,250
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundNormal=252,252,252
ForegroundPositive=34,197,94
ForegroundVisited=168,85,247

[General]
ColorScheme=UCMacDark
Name=UC Mac Dark
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=24,24,27
activeForeground=252,252,252
inactiveBackground=39,39,42
inactiveForeground=127,140,141
EOF

# Build theme packages
echo "Building theme packages..."

for theme in MagicUnicorn-Light MagicUnicorn-Dark UnicornCommander-Light UnicornCommander-Dark; do
    echo "Building $theme..."
    
    # Create theme package directory
    package_dir="$BUILD_DIR/look-and-feel/$theme"
    mkdir -p "$package_dir"
    
    # Copy theme contents
    cp -r "$THEMES_DIR/$theme"/* "$package_dir/"
    
    # Copy Windows color schemes to build directory
    if [[ "$theme" == *"Windows"* ]]; then
        if [[ "$theme" == *"Light"* ]]; then
            cp "$PROJECT_DIR/UCWindowsLight.colors" "$BUILD_DIR/color-schemes/"
        else
            cp "$PROJECT_DIR/UCWindowsDark.colors" "$BUILD_DIR/color-schemes/"
        fi
    fi
    
    # Update defaults for different themes
    case "$theme" in
        "UC-Mac-Dark")
            sed -i 's/UCMacLight/UCMacDark/g' "$package_dir/contents/defaults"
            ;;
        "UC-Windows-Light")
            sed -i 's/UCMacLight/UCWindowsLight/g' "$package_dir/contents/defaults"
            # Copy Windows layout
            cp "$PROJECT_DIR/configs/windows-layout.js" "$package_dir/contents/layouts/org.kde.plasma.desktop-layout.js"
            ;;
        "UC-Windows-Dark")
            sed -i 's/UCMacLight/UCWindowsDark/g' "$package_dir/contents/defaults"
            # Copy Windows layout  
            cp "$PROJECT_DIR/configs/windows-layout.js" "$package_dir/contents/layouts/org.kde.plasma.desktop-layout.js"
            ;;
    esac
done

echo "=== Build Complete ==="
echo "Theme packages created in: $BUILD_DIR"
echo ""
echo "To install themes, run: ./scripts/install-themes.sh"