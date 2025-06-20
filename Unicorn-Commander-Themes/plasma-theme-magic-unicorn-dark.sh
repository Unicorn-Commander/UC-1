#!/bin/bash

# Create Magic Unicorn Dark plasma theme
THEME_DIR="/usr/share/plasma/desktoptheme/magic-unicorn-dark"

sudo mkdir -p "$THEME_DIR"

# Create metadata
sudo tee "$THEME_DIR/metadata.desktop" > /dev/null << 'EOF'
[Desktop Entry]
Name=Magic Unicorn Dark
Comment=Dark plasma theme for Magic Unicorn
Encoding=UTF-8
Keywords=plasma,theme,dark,unicorn
Type=Service

[KPackageStructure]
Type=Plasma/Theme

[ContentsInfo]
Name=Magic Unicorn Dark
Description=Dark plasma theme with purple accents for Magic Unicorn desktop
Author=UnicornCommander Team
Email=team@unicorncommander.ai
Website=https://unicorncommander.ai
Version=1.0
License=GPL-3.0
EOF

# Create colors file
sudo tee "$THEME_DIR/colors" > /dev/null << 'EOF'
[Colors:Button]
BackgroundNormal=45,48,51
BackgroundAlternate=35,38,39
ForegroundNormal=252,252,252
ForegroundInactive=127,140,141
ForegroundActive=139,92,246
ForegroundLink=96,165,250
ForegroundVisited=168,85,247
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundPositive=34,197,94
DecorationFocus=139,92,246
DecorationHover=157,139,251

[Colors:Selection]
BackgroundNormal=139,92,246
BackgroundAlternate=88,28,135
ForegroundNormal=255,255,255
ForegroundInactive=255,255,255
ForegroundActive=255,255,255
ForegroundLink=255,255,255
ForegroundVisited=255,255,255
ForegroundNegative=255,255,255
ForegroundNeutral=255,255,255
ForegroundPositive=255,255,255
DecorationFocus=139,92,246
DecorationHover=157,139,251

[Colors:Tooltip]
BackgroundNormal=24,24,27
BackgroundAlternate=39,39,42
ForegroundNormal=252,252,252
ForegroundInactive=127,140,141
ForegroundActive=139,92,246
ForegroundLink=96,165,250
ForegroundVisited=168,85,247
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundPositive=34,197,94
DecorationFocus=139,92,246
DecorationHover=157,139,251

[Colors:View]
BackgroundNormal=24,24,27
BackgroundAlternate=30,30,30
ForegroundNormal=252,252,252
ForegroundInactive=127,140,141
ForegroundActive=139,92,246
ForegroundLink=96,165,250
ForegroundVisited=168,85,247
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundPositive=34,197,94
DecorationFocus=139,92,246
DecorationHover=157,139,251

[Colors:Window]
BackgroundNormal=24,24,27
BackgroundAlternate=39,39,42
ForegroundNormal=252,252,252
ForegroundInactive=127,140,141
ForegroundActive=139,92,246
ForegroundLink=96,165,250
ForegroundVisited=168,85,247
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundPositive=34,197,94
DecorationFocus=139,92,246
DecorationHover=157,139,251

[Colors:Complementary]
BackgroundNormal=139,92,246
BackgroundAlternate=157,139,251
ForegroundNormal=255,255,255
ForegroundInactive=200,200,200
ForegroundActive=255,255,255
ForegroundLink=96,165,250
ForegroundVisited=168,85,247
ForegroundNegative=239,68,68
ForegroundNeutral=245,158,11
ForegroundPositive=34,197,94
DecorationFocus=255,255,255
DecorationHover=240,240,240

[General]
ColorScheme=Magic Unicorn Dark
Name=Magic Unicorn Dark
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=24,24,27
activeForeground=252,252,252
inactiveBackground=39,39,42
inactiveForeground=127,140,141
EOF

echo "✅ Magic Unicorn Dark plasma theme created"