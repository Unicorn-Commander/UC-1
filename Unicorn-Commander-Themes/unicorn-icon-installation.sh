#!/bin/bash
# UnicornCommander Icon Theme Installation Script

set -e

ICON_THEME_NAME="UnicornCommander"
ICON_DIR="$HOME/.local/share/icons/$ICON_THEME_NAME"

echo "🦄 Installing UnicornCommander Icon Theme..."

# Create directory structure
echo "Creating icon directories..."
mkdir -p "$ICON_DIR"/{scalable,16x16,22x22,24x24,32x32,48x48,64x64,96x96,128x128,256x256}/{apps,places,actions,devices,mimetypes,status,categories}

# Create index.theme
echo "Creating theme index..."
cat > "$ICON_DIR/index.theme" << 'EOF'
[Icon Theme]
Name=UnicornCommander
Comment=Neural-Enhanced Icon Theme for UnicornCommander OS
Inherits=breeze-dark,breeze,hicolor
Example=folder
FollowsColorScheme=true

# KDE specific
DisplayDepth=32
LinkOverlay=link
LockOverlay=lockoverlay
ShareOverlay=share
ZipOverlay=zip

DesktopDefault=48
DesktopSizes=16,22,32,48,64,128,256
ToolbarDefault=22
ToolbarSizes=16,22,32,48
MainToolbarDefault=22
MainToolbarSizes=16,22,32,48
SmallDefault=16
SmallSizes=16,22,32,48
PanelDefault=48
PanelSizes=16,22,32,48,64,128,256
DialogDefault=32
DialogSizes=16,22,32,48,64,128,256

# Directory definitions
Directories=scalable/apps,scalable/places,scalable/actions,scalable/devices,scalable/mimetypes,scalable/status,scalable/categories,16x16/apps,16x16/places,16x16/actions,16x16/devices,16x16/mimetypes,16x16/status,22x22/apps,22x22/places,22x22/actions,22x22/devices,22x22/mimetypes,22x22/status,24x24/apps,24x24/places,24x24/actions,24x24/devices,24x24/mimetypes,24x24/status,32x32/apps,32x32/places,32x32/actions,32x32/devices,32x32/mimetypes,32x32/status,48x48/apps,48x48/places,48x48/actions,48x48/devices,48x48/mimetypes,48x48/status,64x64/apps,64x64/places,64x64/actions,64x64/devices,64x64/mimetypes,64x64/status,96x96/apps,96x96/places,128x128/apps,128x128/places,256x256/apps,256x256/places

[scalable/apps]
Context=Applications
Size=48
MinSize=16
MaxSize=512
Type=Scalable

[scalable/places]
Context=Places
Size=48
MinSize=16
MaxSize=512
Type=Scalable

[scalable/actions]
Context=Actions
Size=22
MinSize=16
MaxSize=256
Type=Scalable

[scalable/devices]
Context=Devices
Size=48
MinSize=16
MaxSize=512
Type=Scalable

[scalable/mimetypes]
Context=MimeTypes
Size=48
MinSize=16
MaxSize=512
Type=Scalable

[scalable/status]
Context=Status
Size=22
MinSize=16
MaxSize=256
Type=Scalable

[scalable/categories]
Context=Categories
Size=48
MinSize=16
MaxSize=512
Type=Scalable

[16x16/apps]
Context=Applications
Size=16
Type=Fixed

[16x16/places]
Context=Places
Size=16
Type=Fixed

[22x22/apps]
Context=Applications
Size=22
Type=Fixed

[22x22/actions]
Context=Actions
Size=22
Type=Fixed

[24x24/apps]
Context=Applications
Size=24
Type=Fixed

[24x24/places]
Context=Places
Size=24
Type=Fixed

[32x32/apps]
Context=Applications
Size=32
Type=Fixed

[32x32/places]
Context=Places
Size=32
Type=Fixed

[48x48/apps]
Context=Applications
Size=48
Type=Fixed

[48x48/places]
Context=Places
Size=48
Type=Fixed

[64x64/apps]
Context=Applications
Size=64
Type=Fixed

[64x64/places]
Context=Places
Size=64
Type=Fixed

[96x96/apps]
Context=Applications
Size=96
Type=Fixed

[96x96/places]
Context=Places
Size=96
Type=Fixed

[128x128/apps]
Context=Applications
Size=128
Type=Fixed

[128x128/places]
Context=Places
Size=128
Type=Fixed

[256x256/apps]
Context=Applications
Size=256
Type=Fixed

[256x256/places]
Context=Places
Size=256
Type=Fixed
EOF

# Function to create a sample SVG icon (you'll replace with actual icons)
create_sample_svg() {
    local name=$1
    local category=$2
    local color=$3
    
    cat > "$ICON_DIR/scalable/$category/$name.svg" << EOF
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="ucGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#B794F4"/>
      <stop offset="100%" style="stop-color:#4299E1"/>
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="1"/>
      <feMerge>
        <feMergeNode/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <rect x="4" y="4" width="40" height="40" rx="8" fill="$color" filter="url(#glow)"/>
  <text x="24" y="30" text-anchor="middle" font-family="sans-serif" font-size="16" fill="white">UC</text>
</svg>
EOF
}

# Create placeholder icons (replace with actual SVG content)
echo "Creating icon files..."

# System icons
SYSTEM_ICONS=(
    "system-file-manager:apps:#B794F4"
    "utilities-terminal:apps:#4299E1"
    "preferences-system:apps:#A78BFA"
    "system-search:apps:#60A5FA"
    "user-home:places:#F687B3"
)

# Application icons
APP_ICONS=(
    "firefox:apps:#FF9500"
    "chromium:apps:#4285F4"
    "edge:apps:#0078D4"
    "code:apps:#007ACC"
    "sublime-text:apps:#FF9800"
    "intellij-idea:apps:#000000"
    "git:apps:#F05032"
    "docker:apps:#2496ED"
    "discord:apps:#5865F2"
    "slack:apps:#4A154B"
    "telegram:apps:#26A5E4"
    "thunderbird:apps:#0A84FF"
    "signal:apps:#2090EA"
    "libreoffice:apps:#18A303"
    "gimp:apps:#5C5543"
    "inkscape:apps:#000000"
    "blender:apps:#F5792A"
    "obs-studio:apps:#302E38"
    "vlc:apps:#FF8800"
    "spotify:apps:#1DB954"
    "steam:apps:#171A21"
)

# Folder icons
FOLDER_ICONS=(
    "folder:places:#60A5FA"
    "folder-documents:places:#B794F4"
    "folder-download:places:#34D399"
    "folder-pictures:places:#F687B3"
    "folder-music:places:#A78BFA"
    "folder-videos:places:#F59E0B"
)

# Create sample icons
for icon_data in "${SYSTEM_ICONS[@]}"; do
    IFS=':' read -r name category color <<< "$icon_data"
    create_sample_svg "$name" "$category" "$color"
done

for icon_data in "${APP_ICONS[@]}"; do
    IFS=':' read -r name category color <<< "$icon_data"
    create_sample_svg "$name" "$category" "$color"
done

for icon_data in "${FOLDER_ICONS[@]}"; do
    IFS=':' read -r name category color <<< "$icon_data"
    create_sample_svg "$name" "$category" "$color"
done

# Generate PNG versions using rsvg-convert or inkscape
echo "Generating PNG versions..."
if command -v rsvg-convert &> /dev/null; then
    echo "Using rsvg-convert..."
    for size in 16 22 24 32 48 64 96 128 256; do
        for svg in "$ICON_DIR"/scalable/*/*.svg; do
            if [ -f "$svg" ]; then
                category=$(basename $(dirname "$svg"))
                filename=$(basename "$svg" .svg)
                output_dir="$ICON_DIR/${size}x${size}/$category"
                mkdir -p "$output_dir"
                rsvg-convert -w "$size" -h "$size" "$svg" -o "$output_dir/$filename.png"
            fi
        done
    done
elif command -v inkscape &> /dev/null; then
    echo "Using inkscape..."
    for size in 16 22 24 32 48 64 96 128 256; do
        for svg in "$ICON_DIR"/scalable/*/*.svg; do
            if [ -f "$svg" ]; then
                category=$(basename $(dirname "$svg"))
                filename=$(basename "$svg" .svg)
                output_dir="$ICON_DIR/${size}x${size}/$category"
                mkdir -p "$output_dir"
                inkscape --export-type=png \
                        --export-width="$size" \
                        --export-height="$size" \
                        --export-filename="$output_dir/$filename.png" \
                        "$svg" 2>/dev/null
            fi
        done
    done
else
    echo "Warning: Neither rsvg-convert nor inkscape found. PNG generation skipped."
fi

# Create symbolic links for common alternatives
echo "Creating symbolic links..."
cd "$ICON_DIR/scalable/apps"
ln -sf firefox.svg firefox-esr.svg
ln -sf code.svg code-oss.svg
ln -sf code.svg visual-studio-code.svg
ln -sf utilities-terminal.svg konsole.svg
ln -sf system-file-manager.svg dolphin.svg
ln -sf thunderbird.svg mail-client.svg

cd "$ICON_DIR/scalable/places"
ln -sf folder.svg folder-blue.svg
ln -sf folder-documents.svg folder-text.svg
ln -sf folder-download.svg folder-downloads.svg
ln -sf folder-pictures.svg folder-images.svg
ln -sf folder-music.svg folder-sound.svg

# Update icon cache
echo "Updating icon cache..."
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_DIR"
fi

# Apply the icon theme
echo "Applying icon theme..."
if command -v plasma-apply-desktoptheme &> /dev/null; then
    # For KDE Plasma
    kwriteconfig6 --file kdeglobals --group Icons --key Theme "$ICON_THEME_NAME"
    # Also update the current Look and Feel themes
    for theme in org.magicunicorn.dark org.magicunicorn.light org.unicorncommander.dark org.unicorncommander.light; do
        if [ -d "$HOME/.local/share/plasma/look-and-feel/$theme" ]; then
            echo "Icons=$ICON_THEME_NAME" >> "$HOME/.local/share/plasma/look-and-feel/$theme/contents/defaults"
        fi
    done
fi

# Create integration with uc-theme-switch
echo "Integrating with theme switcher..."
cat > "$HOME/.local/bin/uc-apply-icons" << 'SCRIPT_EOF'
#!/bin/bash
# Apply UnicornCommander icons
kwriteconfig6 --file kdeglobals --group Icons --key Theme "UnicornCommander"
# Restart plasma to apply changes
kquitapp6 plasmashell && kstart6 plasmashell > /dev/null 2>&1 &
echo "✅ UnicornCommander icons applied!"
SCRIPT_EOF

chmod +x "$HOME/.local/bin/uc-apply-icons"

echo "✅ Icon theme installation complete!"
echo ""
echo "To apply the icons:"
echo "  1. Go to System Settings > Appearance > Icons"
echo "  2. Select 'UnicornCommander'"
echo "  3. Or run: uc-apply-icons"
echo ""
echo "Note: Replace the placeholder SVGs in $ICON_DIR/scalable/"
echo "with the actual icon designs from the artifact above."