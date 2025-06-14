#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander Theme Customization for KDE 6${NC}"
echo -e "${BLUE}Creating complete desktop experience with theme variants...${NC}"

# Ensure running as ucadmin
if [ "$(whoami)" != "ucadmin" ]; then
    echo -e "${YELLOW}⚠️ This script must be run as ucadmin. Exiting...${NC}"
    exit 1
fi

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check Wayland session
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    echo -e "${YELLOW}⚠️ Not running in Wayland session - some features may not work as expected${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Check and install dependencies
print_section "Checking Dependencies"
DEPS="imagemagick papirus-icon-theme breeze-cursor-theme git librsvg2-bin sox"
for dep in $DEPS; do
    if ! dpkg -l | grep -q "^ii  $dep"; then
        echo "Installing $dep..."
        sudo apt-get update
        sudo apt-get install -y $dep
    fi
done

# Create theme directories
print_section "Creating Theme Directory Structure"
sudo mkdir -p \
    /usr/share/wallpapers/unicorncommander/contents/images \
    /usr/share/sddm/themes/unicorncommander \
    /usr/share/plasma/desktoptheme/unicorncommander/{dialogs,widgets,icons,opaque/dialogs,opaque/widgets,translucent/dialogs,translucent/widgets} \
    /usr/share/plasma/desktoptheme/unicorncommander-professional/{dialogs,widgets,icons} \
    /usr/share/plymouth/themes/unicorncommander \
    /usr/share/sounds/unicorncommander \
    /usr/share/pixmaps/unicorncommander \
    /usr/share/aurorae/themes/UnicornCommander \
    /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/{layouts,previews,splash/images,lockscreen}

# Set permissions before creating symlinks
sudo chown -R ucadmin:ucadmin \
    /usr/share/wallpapers/unicorncommander \
    /usr/share/sddm/themes/unicorncommander \
    /usr/share/plasma/desktoptheme/unicorncommander* \
    /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop \
    /usr/share/sounds/unicorncommander \
    /usr/share/pixmaps/unicorncommander \
    /usr/share/plymouth/themes/unicorncommander \
    /usr/share/aurorae/themes/UnicornCommander

# Deploy wallpapers
print_section "Deploying Wallpapers"
WALLPAPER_SOURCE="/home/ucadmin/UC-1/assets"
WALLPAPER_TARGET="/usr/share/wallpapers/unicorncommander/contents/images"

# Check if source directory exists
if [ -d "$WALLPAPER_SOURCE" ]; then
    # Copy all resolution variants
    find "$WALLPAPER_SOURCE" -name 'unicorncommander_*x*.jpg' -exec cp {} "$WALLPAPER_TARGET/" \; 2>/dev/null || true
fi

# Check if any wallpapers were copied, if not create defaults
if [ -z "$(ls -A "$WALLPAPER_TARGET" 2>/dev/null)" ]; then
    echo -e "${YELLOW}⚠️ No wallpapers found, creating stunning gradients...${NC}"
    RESOLUTIONS=("1920x1080" "2560x1440" "3840x2160" "5120x2880" "7680x4320")
    for res in "${RESOLUTIONS[@]}"; do
        convert -size "$res" \
            -define gradient:vector="0,0,$res" \
            gradient:"#1E1B4B-#6B46C1-#8B5CF6-#3B82F6" \
            -blur 0x8 \
            "$WALLPAPER_TARGET/unicorncommander_$res.jpg"
    done
fi

# Create wallpaper metadata
print_section "Creating Wallpaper Metadata"
cat << EOF | sudo tee /usr/share/wallpapers/unicorncommander/metadata.desktop
[Desktop Entry]
Name=UnicornCommander
Name[en_US]=UnicornCommander
X-KDE-PluginInfo-Name=unicorncommander
X-KDE-PluginInfo-Author=UnicornCommander Team
X-KDE-PluginInfo-Email=team@unicorncommander.ai
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=https://unicorncommander.ai
EOF

# Create SDDM theme
print_section "Creating SDDM Login Theme"

# Copy unicorn.svg from assets if it exists
if [ -f "$WALLPAPER_SOURCE/unicorn.svg" ]; then
    cp "$WALLPAPER_SOURCE/unicorn.svg" /usr/share/sddm/themes/unicorncommander/
else
    # Create a default unicorn SVG if not found
    cat << 'EOF' | sudo tee /usr/share/sddm/themes/unicorncommander/unicorn.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
  <defs>
    <linearGradient id="unicornGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#8B5CF6"/>
      <stop offset="50%" style="stop-color:#A78BFA"/>
      <stop offset="100%" style="stop-color:#C4B5FD"/>
    </linearGradient>
    <linearGradient id="hornGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#E0E7FF"/>
      <stop offset="100%" style="stop-color:#C7D2FE"/>
    </linearGradient>
  </defs>
  <!-- Body -->
  <ellipse cx="64" cy="80" rx="35" ry="30" fill="url(#unicornGrad)"/>
  <!-- Head -->
  <circle cx="64" cy="48" r="25" fill="url(#unicornGrad)"/>
  <!-- Horn -->
  <path d="M64 28 L58 8 L70 8 Z" fill="url(#hornGrad)" stroke="#A78BFA" stroke-width="1"/>
  <!-- Eye -->
  <circle cx="54" cy="48" r="4" fill="#1F2937"/>
  <circle cx="56" cy="46" r="1" fill="white"/>
  <!-- Mane -->
  <path d="M75 35 Q85 40 88 50 Q85 45 80 42 Q82 48 80 55 Q78 50 75 48" 
        fill="#C4B5FD" opacity="0.8"/>
  <!-- Legs -->
  <rect x="48" y="90" width="8" height="20" rx="4" fill="url(#unicornGrad)"/>
  <rect x="72" y="90" width="8" height="20" rx="4" fill="url(#unicornGrad)"/>
</svg>
EOF
fi

# Create arrow SVG
cat << 'EOF' | sudo tee /usr/share/sddm/themes/unicorncommander/arrow.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <path d="M4 6l4 4 4-4" fill="white" stroke="white" stroke-width="1" stroke-linejoin="round" stroke-linecap="round"/>
</svg>
EOF

# Create theme configuration
cat << EOF | sudo tee /usr/share/sddm/themes/unicorncommander/theme.conf
[General]
type=image
color=#6B46C1
fontSize=10
background=/usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg
needsFullUserModel=false
EnableHiDPI=true
ScaleMethod=integer

[Blur]
EnableBlur=true
BlurRadius=64
EOF

# Create SDDM QML theme
cat << 'EOF' | sudo tee /usr/share/sddm/themes/unicorncommander/Main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "transparent"

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    // Background
    Image {
        id: background
        anchors.fill: parent
        source: config.background || ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
    }

    // Blur effect
    FastBlur {
        anchors.fill: background
        source: background
        radius: 48
        transparentBorder: true
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: "#40000000"
    }

    // Central login container
    Rectangle {
        id: loginContainer
        anchors.centerIn: parent
        width: 400
        height: 520
        color: "#20FFFFFF"
        radius: 20
        border.color: "#40FFFFFF"
        border.width: 1

        // Glass morphism effect
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 10
            radius: 20
            samples: 41
            color: "#40000000"
        }

        Column {
            anchors.centerIn: parent
            spacing: 30
            width: parent.width * 0.8

            // Logo with glow effect
            Item {
                width: 128
                height: 128
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: logo
                    source: "unicorn.svg"
                    sourceSize: Qt.size(128, 128)
                    anchors.centerIn: parent
                    smooth: true
                    antialiasing: true
                }

                DropShadow {
                    anchors.fill: logo
                    source: logo
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 20
                    samples: 41
                    color: "#808B5CF6"
                    transparentBorder: true
                }
            }

            // Title
            Text {
                text: "UnicornCommander"
                color: "white"
                font.pixelSize: 28
                font.bold: true
                font.family: "Ubuntu"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Subtitle
            Text {
                text: "Authenticated Access Portal"
                color: "#D8B4FE"
        font.pixelSize: 14
        font.family: "Ubuntu"
    }
    
    onStageChanged: {
        if (stage == 7) {
            Qt.quit()
        }
    }
    
    Timer {
        interval: 700
        repeat: true
        running: true
        onTriggered: {
            root.stage++
        }
    }
}
EOF

# Create Theme Switcher
print_section "Creating Theme Switcher"
cat << 'EOF' | sudo tee /usr/local/bin/uc-theme-switch
#!/bin/bash

# Colors
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${PURPLE}🦄 UnicornCommander Theme Switcher${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Available themes:"
echo -e "  ${PURPLE}1.${NC} Cosmic (Purple/Blue gradient) ✨"
echo -e "  ${BLUE}2.${NC} Professional (Dark blue/steel) 💼"
echo -e "  ${YELLOW}3.${NC} Backup current theme"
echo -e "  ${GREEN}4.${NC} Restore from backup"
echo -e "  ${NC}5.${NC} Exit"
echo ""
read -p "Select option (1-5): " choice

backup_current_theme() {
    local backup_dir="$HOME/.config/uc-theme-backups"
    mkdir -p "$backup_dir"
    local backup_name="uc-theme-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    echo -e "${YELLOW}Creating backup...${NC}"
    tar -czf "$backup_dir/$backup_name" \
        -C "$HOME/.config" \
        kdeglobals \
        kwinrc \
        plasmarc \
        plasma-org.kde.plasma.desktop-appletsrc \
        2>/dev/null || true
    
    if [ -f "$backup_dir/$backup_name" ]; then
        echo -e "${GREEN}✅ Backup saved to: $backup_dir/$backup_name${NC}"
    else
        echo -e "${YELLOW}⚠️ Backup may be incomplete${NC}"
    fi
}

restore_from_backup() {
    local backup_dir="$HOME/.config/uc-theme-backups"
    if [ ! -d "$backup_dir" ] || [ -z "$(ls -A "$backup_dir")" ]; then
        echo -e "${YELLOW}No backups found.${NC}"
        return
    fi
    
    echo -e "${BLUE}Available backups:${NC}"
    local i=1
    local -a backups
    while IFS= read -r backup; do
        backups+=("$backup")
        echo "  $i. $(basename "$backup")"
        ((i++))
    done < <(find "$backup_dir" -name "*.tar.gz" | sort -r)
    
    echo ""
    read -p "Select backup to restore (1-$((i-1))): " backup_choice
    
    if [[ "$backup_choice" =~ ^[0-9]+$ ]] && [ "$backup_choice" -ge 1 ] && [ "$backup_choice" -lt "$i" ]; then
        local selected_backup="${backups[$((backup_choice-1))]}"
        echo -e "${YELLOW}Restoring from $(basename "$selected_backup")...${NC}"
        
        cd "$HOME/.config" || exit
        tar -xzf "$selected_backup" 2>/dev/null
        
        # Restart plasmashell to apply changes
        kquitapp6 plasmashell 2>/dev/null || true
        sleep 2
        kstart6 plasmashell 2>/dev/null &
        
        echo -e "${GREEN}✅ Theme restored successfully!${NC}"
    else
        echo -e "${YELLOW}Invalid selection.${NC}"
    fi
}

apply_cosmic_theme() {
    echo -e "${PURPLE}Applying Cosmic theme...${NC}"
    
    # Apply desktop theme
    plasma-apply-desktoptheme unicorncommander 2>/dev/null || \
        lookandfeeltool --apply org.kde.unicorncommander.desktop 2>/dev/null || true
    
    # Apply color scheme
    plasma-apply-colorscheme UnicornCommander 2>/dev/null || true
    
    # Apply window decoration
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme UnicornCommander
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
    
    # Apply effects
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled true
    
    # Apply wallpaper
    plasma-apply-wallpaperimage /usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg 2>/dev/null || true
    
    # Apply cursors and icons
    plasma-apply-cursortheme Breeze_Snow 2>/dev/null || true
    plasma-apply-icons Papirus-Dark 2>/dev/null || true
    
    # Reconfigure KWin
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    
    echo -e "${GREEN}✅ Cosmic theme applied!${NC}"
}

apply_professional_theme() {
    echo -e "${BLUE}Applying Professional theme...${NC}"
    
    # Apply desktop theme
    plasma-apply-desktoptheme unicorncommander-professional 2>/dev/null || true
    
    # Apply color scheme
    plasma-apply-colorscheme UnicornCommanderProfessional 2>/dev/null || true
    
    # Apply window decoration
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme UnicornCommander
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
    
    # Apply more subtle effects
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled false
    kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled false
    
    # Apply wallpaper (use same but with different tint)
    plasma-apply-wallpaperimage /usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg 2>/dev/null || true
    
    # Apply cursors and icons
    plasma-apply-cursortheme Breeze_Snow 2>/dev/null || true
    plasma-apply-icons Papirus 2>/dev/null || true
    
    # Reconfigure KWin
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    
    echo -e "${GREEN}✅ Professional theme applied!${NC}"
}

case $choice in
    1)
        apply_cosmic_theme
        ;;
    2)
        apply_professional_theme
        ;;
    3)
        backup_current_theme
        ;;
    4)
        restore_from_backup
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}Theme operation complete!${NC}"
echo ""
echo "You may need to:"
echo "  • Log out and back in for full effect"
echo "  • Restart plasmashell: Alt+F2 → 'plasmashell --replace'"
EOF

sudo chmod +x /usr/local/bin/uc-theme-switch

# Create theme validation script
print_section "Creating Theme Validation Tool"
cat << 'EOF' | sudo tee /usr/local/bin/uc-theme-validate
#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🦄 UnicornCommander Theme Validation"
echo "===================================="

components=(
    "/usr/share/plasma/desktoptheme/unicorncommander/metadata.json:Plasma theme"
    "/usr/share/sddm/themes/unicorncommander/Main.qml:SDDM theme"
    "/usr/share/plymouth/themes/unicorncommander/unicorncommander.plymouth:Plymouth theme"
    "/usr/share/aurorae/themes/UnicornCommander/metadata.desktop:Window decorations"
    "/usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/metadata.json:Global theme"
    "/home/ucadmin/.local/share/color-schemes/UnicornCommander.colors:Color scheme"
    "/usr/share/wallpapers/unicorncommander/metadata.desktop:Wallpaper set"
    "/usr/local/bin/uc-theme-switch:Theme switcher"
)

missing=0
found=0

for component in "${components[@]}"; do
    IFS=':' read -r path name <<< "$component"
    if [ -f "$path" ]; then
        echo -e "${GREEN}✓${NC} $name"
        ((found++))
    else
        echo -e "${RED}✗${NC} $name (missing: $path)"
        ((missing++))
    fi
done

echo ""
echo "Summary: $found found, $missing missing"

if [ $missing -eq 0 ]; then
    echo -e "${GREEN}All components installed successfully!${NC}"
    exit 0
else
    echo -e "${YELLOW}Some components are missing. Run the installer again.${NC}"
    exit 1
fi
EOF

sudo chmod +x /usr/local/bin/uc-theme-validate

# Configure Wayland environment
print_section "Configuring Wayland Environment"
mkdir -p /home/ucadmin/.config/plasma-workspace/env
cat << 'EOF' > /home/ucadmin/.config/plasma-workspace/env/wayland.sh
#!/bin/bash
# UnicornCommander Wayland Environment

# Core Wayland settings
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=KDE
export KDE_SESSION_VERSION=6

# Application-specific Wayland support
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export GDK_BACKEND=wayland,x11
export CLUTTER_BACKEND=wayland
export ECORE_EVAS_ENGINE=wayland-egl
export ELM_ENGINE=wayland_egl
export _JAVA_AWT_WM_NONREPARENTING=1

# Qt settings
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=0

# Electron apps Wayland support
export ELECTRON_OZONE_PLATFORM_HINT=auto

# Enable GPU acceleration
export KWIN_COMPOSE=O2ES
export __GL_GSYNC_ALLOWED=1
export __GL_VRR_ALLOWED=1

# Vulkan settings
export VK_KHR_display=1
EOF
chmod +x /home/ucadmin/.config/plasma-workspace/env/wayland.sh

# Set initial theme configuration
print_section "Applying Initial Theme Configuration"

# Ensure plasmashell is running
if ! pgrep -x plasmashell > /dev/null; then
    echo -e "${YELLOW}Starting plasmashell...${NC}"
    kstart6 plasmashell 2>/dev/null &
    sleep 3
fi

# Apply theme components
plasma-apply-desktoptheme unicorncommander 2>/dev/null || true
plasma-apply-colorscheme UnicornCommander 2>/dev/null || true
plasma-apply-wallpaperimage /usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg 2>/dev/null || true
plasma-apply-cursortheme Breeze_Snow 2>/dev/null || true
plasma-apply-icons Papirus-Dark 2>/dev/null || true

# Configure SDDM
print_section "Configuring SDDM"
sudo mkdir -p /etc/sddm.conf.d
cat << EOF | sudo tee /etc/sddm.conf.d/theme.conf
[Theme]
Current=unicorncommander
CursorTheme=Breeze_Snow
EnableHiDPI=true
ServerArguments=-dpi 96

[Wayland]
SessionDir=/usr/share/wayland-sessions
EnableHiDPI=true
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1 --inputmethod maliit-keyboard

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_DISABLE_WINDOWDECORATION=1
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
Numlock=on

[Users]
RememberLastUser=true
RememberLastSession=true
EOF

# Set Plymouth theme
print_section "Setting Plymouth Theme"
sudo plymouth-set-default-theme unicorncommander 2>/dev/null || true
sudo update-initramfs -u 2>/dev/null || true

# Create Konsole theme
print_section "Configuring Terminal Theme"
mkdir -p /home/ucadmin/.local/share/konsole

cat << 'EOF' > /home/ucadmin/.local/share/konsole/UnicornCommander.profile
[Appearance]
ColorScheme=UnicornCommander
Font=JetBrains Mono,11,-1,5,50,0,0,0,0,0
BoldIntense=true
AntiAliasFonts=true
UseFontLineChararacters=false

[General]
Name=UnicornCommander
Parent=FALLBACK/
ShowTerminalSizeHint=true
TerminalColumns=120
TerminalRows=30

[Interaction Options]
AutoCopySelectedText=true
CopyTextAsHTML=false
TrimLeadingSpacesInSelectedText=true
TrimTrailingSpacesInSelectedText=true
UnderlineFilesEnabled=false
OpenLinksByDirectClickEnabled=true

[Scrolling]
HistoryMode=2
HistorySize=10000
ScrollBarPosition=2
ScrollFullPage=false

[Terminal Features]
BlinkingCursorEnabled=true
BlinkingTextEnabled=true
BidiRenderingEnabled=true
FlowControlEnabled=false
UrlHintsModifiers=0
VerticalLine=false
EOF

# Create Konsole color scheme
cat << 'EOF' > /home/ucadmin/.local/share/konsole/UnicornCommander.colorscheme
[Background]
Color=30,27,75

[BackgroundFaint]
Color=30,27,75

[BackgroundIntense]
Color=44,40,100

[Color0]
Color=49,54,59

[Color0Faint]
Color=49,54,59

[Color0Intense]
Color=107,114,128

[Color1]
Color=239,68,68

[Color1Faint]
Color=239,68,68

[Color1Intense]
Color=248,113,113

[Color2]
Color=34,197,94

[Color2Faint]
Color=34,197,94

[Color2Intense]
Color=74,222,128

[Color3]
Color=251,191,36

[Color3Faint]
Color=251,191,36

[Color3Intense]
Color=252,211,77

[Color4]
Color=59,130,246

[Color4Faint]
Color=59,130,246

[Color4Intense]
Color=96,165,250

[Color5]
Color=139,92,246

[Color5Faint]
Color=139,92,246

[Color5Intense]
Color=167,139,250

[Color6]
Color=14,165,233

[Color6Faint]
Color=14,165,233

[Color6Intense]
Color=56,189,248

[Color7]
Color=209,213,219

[Color7Faint]
Color=209,213,219

[Color7Intense]
Color=243,244,246

[Foreground]
Color=243,244,246

[ForegroundFaint]
Color=243,244,246

[ForegroundIntense]
Color=255,255,255

[General]
Blur=true
ColorRandomization=false
Description=UnicornCommander
Opacity=0.95
Wallpaper=
EOF

# Create desktop entries
print_section "Creating Desktop Entries"
mkdir -p /home/ucadmin/.local/share/applications

cat << 'EOF' > /home/ucadmin/.local/share/applications/uc-theme-switcher.desktop
[Desktop Entry]
Name=UnicornCommander Theme Switcher
Comment=Switch between Cosmic and Professional themes
Exec=konsole -e /usr/local/bin/uc-theme-switch
Icon=preferences-desktop-theme
Type=Application
Categories=Settings;DesktopSettings;
StartupNotify=true
Keywords=theme;appearance;unicorn;commander;
X-KDE-Wayland-Interfaces=org_kde_kwin_keystate
EOF

cat << 'EOF' > /home/ucadmin/.local/share/applications/uc-theme-validate.desktop
[Desktop Entry]
Name=UC Theme Validator
Comment=Validate UnicornCommander theme installation
Exec=konsole -e /usr/local/bin/uc-theme-validate
Icon=dialog-ok-apply
Type=Application
Categories=System;
StartupNotify=true
Terminal=false
EOF

# Update Zsh configuration
print_section "Configuring Zsh Theme Integration"
cat << 'EOF' >> /home/ucadmin/.zshrc

# UnicornCommander Theme Integration
export UNICORN_THEME="cosmic"

# Custom prompt with theme awareness
if [[ "$UNICORN_THEME" == "cosmic" ]]; then
    PROMPT='%F{#8B5CF6}🦄%f %F{#E0E7FF}%n@%m%f:%F{#60A5FA}%~%f$ '
else
    PROMPT='%F{#3B82F6}💼%f %F{#E0E7FF}%n@%m%f:%F{#60A5FA}%~%f$ '
fi

# Theme switching aliases
alias uc-theme="/usr/local/bin/uc-theme-switch"
alias uc-cosmic="plasma-apply-desktoptheme unicorncommander && plasma-apply-colorscheme UnicornCommander && export UNICORN_THEME=cosmic"
alias uc-professional="plasma-apply-desktoptheme unicorncommander-professional && plasma-apply-colorscheme UnicornCommanderProfessional && export UNICORN_THEME=professional"
alias uc-validate="/usr/local/bin/uc-theme-validate"

# UC-1 shortcuts with theme-aware icons
alias uc-start="cd ~/UC-1 && ./start-services.sh"
alias uc-stop="cd ~/UC-1 && ./stop-services.sh"
alias uc-status="cd ~/UC-1 && ./status-services.sh"
alias uc-monitor="/usr/local/bin/uc-monitor"
alias ai-env="source ~/ai-env/bin/activate"

# Wayland-specific aliases
alias wayland-info="echo $XDG_SESSION_TYPE && qdbus org.kde.KWin /KWin supportInformation | grep -i compositor"
alias fix-blur="qdbus org.kde.KWin /Effects org.kde.kwin.Effect.toggle blur"

# Show UC-1 status on startup
if [ -z "$UC_WELCOME_SHOWN" ]; then
    export UC_WELCOME_SHOWN=1
    echo "🦄 Welcome to UnicornCommander!"
    echo "Theme: $(plasma-apply-desktoptheme --list-desktopthemes 2>/dev/null | grep '^\*' | cut -d' ' -f2 || echo 'Unknown')"
    echo "Session: $XDG_SESSION_TYPE"
    echo ""
    echo "Quick commands:"
    echo "  • uc-theme     - Switch themes"
    echo "  • uc-start     - Start UC-1 services"
    echo "  • uc-monitor   - System monitoring"
    echo "  • uc-validate  - Check theme installation"
fi
EOF

# Fix all permissions
print_section "Setting Permissions"
chown -R ucadmin:ucadmin /home/ucadmin/.config
chown -R ucadmin:ucadmin /home/ucadmin/.local
chown ucadmin:ucadmin /home/ucadmin/.zshrc

# Create a systemd service for theme persistence
print_section "Creating Theme Persistence Service"
cat << 'EOF' | sudo tee /etc/systemd/user/unicorncommander-theme.service
[Unit]
Description=UnicornCommander Theme Persistence
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/uc-theme-apply
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

cat << 'EOF' | sudo tee /usr/local/bin/uc-theme-apply
#!/bin/bash
# Apply saved theme preference on login
if [ -f "$HOME/.config/unicorncommander/theme.conf" ]; then
    source "$HOME/.config/unicorncommander/theme.conf"
    case "$THEME" in
        cosmic)
            plasma-apply-desktoptheme unicorncommander 2>/dev/null || true
            plasma-apply-colorscheme UnicornCommander 2>/dev/null || true
            ;;
        professional)
            plasma-apply-desktoptheme unicorncommander-professional 2>/dev/null || true
            plasma-apply-colorscheme UnicornCommanderProfessional 2>/dev/null || true
            ;;
    esac
fi
EOF

sudo chmod +x /usr/local/bin/uc-theme-apply

# Enable the service for ucadmin
sudo -u ucadmin systemctl --user enable unicorncommander-theme.service 2>/dev/null || true

# Rebuild KDE cache
print_section "Rebuilding KDE Cache"
sudo -u ucadmin kbuildsycoca6 --noincremental 2>/dev/null || true

# Create a custom application launcher icon
print_section "Creating Application Launcher"
if [ -f "$WALLPAPER_SOURCE/unicorn.svg" ]; then
    cp "$WALLPAPER_SOURCE/unicorn.svg" /usr/share/pixmaps/unicorncommander/
else
    cp /usr/share/sddm/themes/unicorncommander/unicorn.svg /usr/share/pixmaps/unicorncommander/
fi

# Final validation
print_section "Running Theme Validation"
/usr/local/bin/uc-theme-validate

# Final message
echo ""
echo -e "${GREEN}🎉 UnicornCommander theme installation complete!${NC}"
echo -e "${PURPLE}🦄 Global Theme: org.kde.unicorncommander.desktop 🦄${NC}"
echo ""
echo -e "${BLUE}Features installed:${NC}"
echo -e "  ✓ SDDM login theme with glass morphism effects"
echo -e "  ✓ Lock screen with blurred wallpaper"
echo -e "  ✓ Plasma desktop theme with gradient aesthetics"
echo -e "  ✓ Plymouth boot animation with progress"
echo -e "  ✓ Professional theme variant"
echo -e "  ✓ Aurorae window decorations with glow"
echo -e "  ✓ Papirus-Dark icon theme"
echo -e "  ✓ Breeze Snow cursor theme"
echo -e "  ✓ Custom Konsole terminal theme"
echo -e "  ✓ Wallpapers with gradient effects"
echo -e "  ✓ Wayland-optimized environment"
echo -e "  ✓ Notification sounds"
echo -e "  ✓ Theme switcher with backup/restore"
echo -e "  ✓ Splash screen with animations"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo -e "  • ${PURPLE}uc-theme${NC}        - Interactive theme switcher"
echo -e "  • ${PURPLE}uc-validate${NC}     - Validate installation"
echo -e "  • ${PURPLE}uc-cosmic${NC}       - Quick switch to Cosmic theme"
echo -e "  • ${PURPLE}uc-professional${NC} - Quick switch to Professional theme"
echo ""
echo -e "${YELLOW}⚠️ Important next steps:${NC}"
echo -e "  1. Log out and back in for full effect"
echo -e "  2. Or restart SDDM: ${PURPLE}sudo systemctl restart sddm${NC}"
echo -e "  3. For immediate preview: ${PURPLE}Alt+F2${NC} → ${PURPLE}plasmashell --replace${NC}"
echo ""
echo -e "${RED}Troubleshooting:${NC}"
echo -e "  • If theme doesn't apply: Check System Settings → Appearance"
echo -e "  • For Wayland issues: Verify with ${PURPLE}echo \$XDG_SESSION_TYPE${NC}"
echo -e "  • Window decorations: May need to toggle in System Settings"
echo ""
echo -e "${PURPLE}🦄 UnicornCommander is ready to command your desktop! 🦄${NC}"
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // User selection
            ComboBox {
                id: userSelect
                model: userModel
                currentIndex: userModel.lastIndex
                width: parent.width
                height: 45
                font.pixelSize: 14
                font.family: "Ubuntu"
                
                delegate: ItemDelegate {
                    width: userSelect.width
                    height: 40
                    
                    contentItem: Text {
                        text: model.name
                        color: "white"
                        font: userSelect.font
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }
                    
                    background: Rectangle {
                        color: hovered ? "#60A78BFA" : "transparent"
                    }
                }
                
                background: Rectangle {
                    color: "#40FFFFFF"
                    border.color: "#60FFFFFF"
                    border.width: 1
                    radius: 8
                }
                
                contentItem: Text {
                    text: userSelect.displayText
                    font: userSelect.font
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                
                indicator: Image {
                    x: userSelect.width - width - 10
                    y: (userSelect.height - height) / 2
                    source: "arrow.svg"
                    sourceSize: Qt.size(16, 16)
                    rotation: userSelect.popup.visible ? 180 : 0
                    
                    Behavior on rotation {
                        NumberAnimation { duration: 200 }
                    }
                }
            }

            // Password field
            TextField {
                id: passwordInput
                width: parent.width
                height: 45
                placeholderText: textConstants.password
                placeholderTextColor: "#B0FFFFFF"
                echoMode: TextInput.Password
                font.pixelSize: 14
                font.family: "Ubuntu"
                color: "white"
                focus: true
                
                background: Rectangle {
                    color: "#40FFFFFF"
                    border.color: passwordInput.focus ? "#A78BFA" : "#60FFFFFF"
                    border.width: passwordInput.focus ? 2 : 1
                    radius: 8
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                onAccepted: loginButton.clicked()
            }

            // Login button
            Button {
                id: loginButton
                text: textConstants.login
                width: parent.width
                height: 50
                font.pixelSize: 16
                font.bold: true
                font.family: "Ubuntu"
                
                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: loginButton.pressed ? "#7C3AED" : "#8B5CF6" }
                        GradientStop { position: 1.0; color: loginButton.pressed ? "#6D28D9" : "#7C3AED" }
                    }
                    radius: 8
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        opacity: loginButton.hovered ? 0.1 : 0
                        radius: parent.radius
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }
                
                onClicked: sddm.login(userSelect.currentText, passwordInput.text, sessionIndex)
            }

            // Session selector
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                
                Text {
                    text: "Session:"
                    color: "#B0FFFFFF"
                    font.pixelSize: 12
                    font.family: "Ubuntu"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                ComboBox {
                    id: sessionSelect
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex
                    width: 180
                    height: 30
                    font.pixelSize: 12
                    font.family: "Ubuntu"
                    
                    background: Rectangle {
                        color: "#30FFFFFF"
                        border.color: "#40FFFFFF"
                        radius: 6
                    }
                }
            }
        }
    }

    // Power controls
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 40
        spacing: 20
        
        PowerButton {
            id: rebootButton
            iconSource: "system-reboot"
            text: textConstants.reboot
            onClicked: sddm.reboot()
        }
        
        PowerButton {
            id: shutdownButton
            iconSource: "system-shutdown"
            text: textConstants.shutdown
            onClicked: sddm.powerOff()
        }
    }
}
EOF

# Create PowerButton component
cat << 'EOF' | sudo tee /usr/share/sddm/themes/unicorncommander/PowerButton.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    property alias iconSource: icon.name
    property alias text: label.text
    
    width: 100
    height: 40
    
    contentItem: Row {
        spacing: 5
        anchors.centerIn: parent
        
        Icon {
            id: icon
            width: 16
            height: 16
            color: "white"
        }
        
        Text {
            id: label
            color: "white"
            font.pixelSize: 12
            font.family: "Ubuntu"
        }
    }
    
    background: Rectangle {
        color: parent.hovered ? "#40FFFFFF" : "#20FFFFFF"
        radius: 6
        border.color: "#40FFFFFF"
        border.width: 1
    }
}
EOF

# Create SDDM metadata
cat << EOF | sudo tee /usr/share/sddm/themes/unicorncommander/metadata.desktop
[SddmGreeterTheme]
Name=UnicornCommander
Description=UnicornCommander SDDM theme with glass morphism
Author=UnicornCommander Team
Copyright=(c) 2025 UnicornCommander
License=GPL-3.0
Type=sddm-theme
Version=1.0
Website=https://github.com/unicorncommander
Screenshot=screenshot.png
MainScript=Main.qml
ConfigFile=theme.conf
TranslationsDirectory=
Email=team@unicorncommander.ai
Theme-Id=unicorncommander
Theme-API=2.0
EOF

# Create Plasma Desktop Theme
print_section "Creating Plasma Desktop Theme"
cat << EOF | sudo tee /usr/share/plasma/desktoptheme/unicorncommander/metadata.json
{
    "KPackageStructure": "Plasma/Theme",
    "KPlugin": {
        "Authors": [{
            "Email": "team@unicorncommander.ai",
            "Name": "UnicornCommander Team"
        }],
        "Category": "Plasma Theme",
        "Description": "UnicornCommander Plasma Theme with purple gradient aesthetics",
        "EnabledByDefault": true,
        "Id": "unicorncommander",
        "License": "GPL-3.0",
        "Name": "UnicornCommander",
        "Version": "1.0",
        "Website": "https://unicorncommander.ai"
    },
    "X-Plasma-API-Minimum-Version": "6.0"
}
EOF

# Create colors file for Plasma theme
cat << 'EOF' | sudo tee /usr/share/plasma/desktoptheme/unicorncommander/colors
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
BackgroundAlternate=77,77,77
BackgroundNormal=49,46,129
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Complementary]
BackgroundAlternate=30,27,75
BackgroundNormal=24,21,59
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Header]
BackgroundAlternate=42,46,50
BackgroundNormal=49,54,59
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Selection]
BackgroundAlternate=30,27,75
BackgroundNormal=107,70,193
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=252,252,252
ForegroundInactive=189,195,199
ForegroundLink=253,188,75
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=189,195,199

[Colors:Tooltip]
BackgroundAlternate=49,46,129
BackgroundNormal=30,27,75
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:View]
BackgroundAlternate=49,54,59
BackgroundNormal=35,38,41
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Window]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[General]
ColorSchemeHash=5cc4a7b42c7c2bfc846e244586e9e13e98a90600

[WM]
activeBackground=49,54,59
activeBlend=255,255,255
activeForeground=252,252,252
inactiveBackground=42,46,50
inactiveBlend=75,71,67
inactiveForeground=189,195,199
EOF

# Create basic panel background SVG
print_section "Creating Plasma Theme Assets"
cat << 'EOF' | sudo tee /usr/share/plasma/desktoptheme/unicorncommander/widgets/panel-background.svg
<?xml version="1.0" encoding="UTF-8"?>
<svg id="svg" version="1.1" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="panel-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#6B46C1;stop-opacity:0.95"/>
            <stop offset="100%" style="stop-color:#7C3AED;stop-opacity:0.95"/>
        </linearGradient>
    </defs>
    <g id="center">
        <rect width="100" height="100" fill="url(#panel-gradient)"/>
    </g>
    <g id="top">
        <rect width="100" height="1" fill="#8B5CF6" opacity="0.3"/>
    </g>
    <g id="bottom">
        <rect y="99" width="100" height="1" fill="#5B21B6" opacity="0.5"/>
    </g>
    <g id="left">
        <rect width="1" height="100" fill="#8B5CF6" opacity="0.3"/>
    </g>
    <g id="right">
        <rect x="99" width="1" height="100" fill="#5B21B6" opacity="0.5"/>
    </g>
</svg>
EOF

# Create button SVG
cat << 'EOF' | sudo tee /usr/share/plasma/desktoptheme/unicorncommander/widgets/button.svg
<?xml version="1.0" encoding="UTF-8"?>
<svg id="svg" version="1.1" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <linearGradient id="button-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#8B5CF6;stop-opacity:1"/>
            <stop offset="100%" style="stop-color:#7C3AED;stop-opacity:1"/>
        </linearGradient>
        <linearGradient id="button-hover-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#A78BFA;stop-opacity:1"/>
            <stop offset="100%" style="stop-color:#8B5CF6;stop-opacity:1"/>
        </linearGradient>
    </defs>
    <g id="normal-center">
        <rect width="100" height="100" rx="4" fill="url(#button-gradient)"/>
    </g>
    <g id="hover-center">
        <rect width="100" height="100" rx="4" fill="url(#button-hover-gradient)"/>
    </g>
    <g id="pressed-center">
        <rect width="100" height="100" rx="4" fill="#6D28D9"/>
    </g>
</svg>
EOF

# Create Professional Theme Variant
print_section "Creating Professional Theme Variant"
cp -r /usr/share/plasma/desktoptheme/unicorncommander/* /usr/share/plasma/desktoptheme/unicorncommander-professional/

# Update professional theme metadata
cat << EOF | sudo tee /usr/share/plasma/desktoptheme/unicorncommander-professional/metadata.json
{
    "KPackageStructure": "Plasma/Theme",
    "KPlugin": {
        "Authors": [{
            "Email": "team@unicorncommander.ai",
            "Name": "UnicornCommander Team"
        }],
        "Category": "Plasma Theme",
        "Description": "UnicornCommander Professional - Dark blue and steel theme",
        "EnabledByDefault": true,
        "Id": "unicorncommander-professional",
        "License": "GPL-3.0",
        "Name": "UnicornCommander Professional",
        "Version": "1.0",
        "Website": "https://unicorncommander.ai"
    },
    "X-Plasma-API-Minimum-Version": "6.0"
}
EOF

# Create Professional color scheme
print_section "Installing Color Schemes"
mkdir -p /home/ucadmin/.local/share/color-schemes

# Original UnicornCommander scheme
cat << EOF | tee /home/ucadmin/.local/share/color-schemes/UnicornCommander.colors
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=77,77,77
BackgroundNormal=107,70,193
DecorationFocus=139,92,246
DecorationHover=167,139,250
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Selection]
BackgroundAlternate=30,27,75
BackgroundNormal=139,92,246
DecorationFocus=167,139,250
DecorationHover=196,181,253
ForegroundActive=252,252,252
ForegroundInactive=224,231,255
ForegroundLink=253,188,75
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=189,195,199

[Colors:Tooltip]
BackgroundAlternate=49,46,129
BackgroundNormal=30,27,75
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:View]
BackgroundAlternate=49,54,59
BackgroundNormal=35,38,41
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[Colors:Window]
BackgroundAlternate=77,77,77
BackgroundNormal=49,54,59
DecorationFocus=107,70,193
DecorationHover=139,92,246
ForegroundActive=61,174,233
ForegroundInactive=189,195,199
ForegroundLink=41,128,185
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=127,140,141

[General]
ColorScheme=UnicornCommander
Name=UnicornCommander
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=107,70,193
activeBlend=255,255,255
activeForeground=252,252,252
inactiveBackground=49,54,59
inactiveBlend=75,71,67
inactiveForeground=189,195,199
EOF

# Professional color scheme
cat << EOF | tee /home/ucadmin/.local/share/color-schemes/UnicornCommanderProfessional.colors
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[Colors:Button]
BackgroundAlternate=55,65,81
BackgroundNormal=31,41,55
DecorationFocus=59,130,246
DecorationHover=96,165,250
ForegroundActive=147,197,253
ForegroundInactive=156,163,175
ForegroundLink=96,165,250
ForegroundNegative=239,68,68
ForegroundNeutral=251,146,60
ForegroundNormal=243,244,246
ForegroundPositive=34,197,94
ForegroundVisited=147,51,234

[Colors:Selection]
BackgroundAlternate=37,99,235
BackgroundNormal=59,130,246
DecorationFocus=96,165,250
DecorationHover=147,197,253
ForegroundActive=255,255,255
ForegroundInactive=219,234,254
ForegroundLink=251,191,36
ForegroundNegative=254,202,202
ForegroundNeutral=254,215,170
ForegroundNormal=255,255,255
ForegroundPositive=167,243,208
ForegroundVisited=196,181,253

[Colors:View]
BackgroundAlternate=31,41,55
BackgroundNormal=17,24,39
DecorationFocus=59,130,246
DecorationHover=96,165,250
ForegroundActive=147,197,253
ForegroundInactive=156,163,175
ForegroundLink=96,165,250
ForegroundNegative=239,68,68
ForegroundNeutral=251,146,60
ForegroundNormal=243,244,246
ForegroundPositive=34,197,94
ForegroundVisited=147,51,234

[Colors:Window]
BackgroundAlternate=31,41,55
BackgroundNormal=17,24,39
DecorationFocus=59,130,246
DecorationHover=96,165,250
ForegroundActive=147,197,253
ForegroundInactive=156,163,175
ForegroundLink=96,165,250
ForegroundNegative=239,68,68
ForegroundNeutral=251,146,60
ForegroundNormal=243,244,246
ForegroundPositive=34,197,94
ForegroundVisited=147,51,234

[General]
ColorScheme=UnicornCommanderProfessional
Name=UnicornCommander Professional
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=31,41,55
activeBlend=255,255,255
activeForeground=243,244,246
inactiveBackground=17,24,39
inactiveBlend=55,65,81
inactiveForeground=156,163,175
EOF

# Create Plymouth boot theme
print_section "Creating Plymouth Boot Theme"
cat << EOF | sudo tee /usr/share/plymouth/themes/unicorncommander/unicorncommander.plymouth
[Plymouth Theme]
Name=UnicornCommander
Description=UnicornCommander boot theme with animated unicorn
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/unicorncommander
ScriptFile=/usr/share/plymouth/themes/unicorncommander/unicorncommander.script
EOF

# Create Plymouth script
cat << 'EOF' | sudo tee /usr/share/plymouth/themes/unicorncommander/unicorncommander.script
Window.SetBackgroundTopColor(0.42, 0.27, 0.76);
Window.SetBackgroundBottomColor(0.23, 0.51, 0.96);

logo.image = Image("logo.png");
logo.sprite = Sprite(logo.image);
logo.x = Window.GetX() + Window.GetWidth() / 2 - logo.image.GetWidth() / 2;
logo.y = Window.GetY() + Window.GetHeight() / 2 - logo.image.GetHeight() / 2;
logo.sprite.SetPosition(logo.x, logo.y, 10000);

progress_box.image = Image("progress_box.png");
progress_box.sprite = Sprite(progress_box.image);
progress_box.x = Window.GetX() + Window.GetWidth() / 2 - progress_box.image.GetWidth() / 2;
progress_box.y = Window.GetY() + Window.GetHeight() * 0.75;
progress_box.sprite.SetPosition(progress_box.x, progress_box.y, 10000);

progress_bar.original_image = Image("progress_bar.png");
progress_bar.sprite = Sprite();
progress_bar.x = progress_box.x + 10;
progress_bar.y = progress_box.y + 5;
progress_bar.sprite.SetPosition(progress_bar.x, progress_bar.y, 10001);

fun progress_callback (duration, progress) {
    if (progress_bar.original_image) {
        progress_bar.image = progress_bar.original_image.Scale(progress_bar.original_image.GetWidth() * progress, progress_bar.original_image.GetHeight());
        progress_bar.sprite.SetImage(progress_bar.image);
    }
}

Plymouth.SetBootProgressFunction(progress_callback);

# Message handling
message_sprite = Sprite();
message_sprite.SetPosition(Window.GetX() + 20, Window.GetY() + Window.GetHeight() - 60, 10000);

fun message_callback (text) {
    message_image = Image.Text(text, 1, 1, 1);
    message_sprite.SetImage(message_image);
}

Plymouth.SetMessageFunction(message_callback);
EOF

# Create Plymouth assets
print_section "Creating Plymouth Assets"
# Copy unicorn logo if exists, otherwise create default
if [ -f "$WALLPAPER_SOURCE/unicorn.svg" ]; then
    convert -background none -resize 128x128 "$WALLPAPER_SOURCE/unicorn.svg" \
        /usr/share/plymouth/themes/unicorncommander/logo.png
else
    convert -size 128x128 xc:transparent \
        -fill "#8B5CF6" -draw "circle 64,64 64,10" \
        -fill "#A78BFA" -draw "circle 64,64 54,10" \
        -fill "#C4B5FD" -draw "circle 64,64 44,10" \
        /usr/share/plymouth/themes/unicorncommander/logo.png
fi

convert -size 300x20 xc:transparent \
    -fill "#4C1D95" -draw "roundrectangle 0,0 300,20 10,10" \
    /usr/share/plymouth/themes/unicorncommander/progress_box.png
convert -size 280x10 xc:transparent \
    -fill "#8B5CF6" -draw "roundrectangle 0,0 280,10 5,5" \
    /usr/share/plymouth/themes/unicorncommander/progress_bar.png

# Create Global Theme Package
print_section "Creating Global Theme Package"
cat << EOF | sudo tee /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/metadata.json
{
    "KPackageStructure": "Plasma/LookAndFeel",
    "KPlugin": {
        "Authors": [{
            "Email": "team@unicorncommander.ai",
            "Name": "UnicornCommander Team"
        }],
        "Category": "",
        "Description": "UnicornCommander Desktop Experience - A complete theme with purple cosmic aesthetics",
        "Id": "org.kde.unicorncommander.desktop",
        "License": "GPL-3.0",
        "Name": "UnicornCommander",
        "Version": "1.0",
        "Website": "https://unicorncommander.ai"
    },
    "X-KDE-PluginInfo-Name": "org.kde.unicorncommander.desktop",
    "X-Plasma-API-Minimum-Version": "6.0"
}
EOF

# Create look and feel defaults
cat << EOF | sudo tee /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/defaults
[kdeglobals][KDE]
widgetStyle=Breeze

[kdeglobals][General]
ColorScheme=UnicornCommander

[kdeglobals][Icons]
Theme=Papirus-Dark

[plasmarc][Theme]
name=unicorncommander

[kcminputrc][Mouse]
cursorTheme=Breeze_Snow

[kwinrc][WindowSwitcher]
LayoutName=org.kde.breeze.desktop

[kwinrc][DesktopSwitcher]
LayoutName=org.kde.breeze.desktop

[kwinrc][org.kde.kdecoration2]
library=org.kde.breeze
theme=UnicornCommander

[kwinrc][Effect-overview]
BorderActivate=9

[kwinrc][Effect-windowview]
BorderActivateAll=9

[kwinrc][Plugins]
blurEnabled=true
contrastEnabled=true
magiclampEnabled=true
wobblywindowsEnabled=false
dimscreenEnabled=true
EOF

# Create lock screen configuration
print_section "Creating Lock Screen Theme"
cat << 'EOF' | sudo tee /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/lockscreen/LockScreenUi.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root
    anchors.fill: parent
    
    Image {
        id: background
        anchors.fill: parent
        source: "/usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    
    FastBlur {
        anchors.fill: background
        source: background
        radius: 64
        transparentBorder: true
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#60000000"
    }
    
    Column {
        anchors.centerIn: parent
        spacing: PlasmaCore.Units.largeSpacing * 2
        
        Image {
            id: logo
            source: Qt.resolvedUrl("../splash/images/logo.png")
            sourceSize: Qt.size(128, 128)
            anchors.horizontalCenter: parent.horizontalCenter
            
            DropShadow {
                anchors.fill: logo
                source: logo
                horizontalOffset: 0
                verticalOffset: 0
                radius: 20
                samples: 41
                color: "#808B5CF6"
                transparentBorder: true
            }
        }
        
        PlasmaComponents3.Label {
            text: "UnicornCommander"
            color: "white"
            font.pixelSize: 28
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        PlasmaComponents3.Label {
            text: "Authenticated Access Only"
            color: "#D8B4FE"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
EOF

# Copy logo to lock screen
if [ -f "$WALLPAPER_SOURCE/unicorn.svg" ]; then
    mkdir -p /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/splash/images
    convert -background none -resize 128x128 "$WALLPAPER_SOURCE/unicorn.svg" \
        /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/splash/images/logo.png
else
    mkdir -p /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/splash/images
    cp /usr/share/plymouth/themes/unicorncommander/logo.png \
        /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/splash/images/
fi

# Create window decorations
print_section "Creating Window Decorations"

# Create Aurorae metadata
cat << EOF | sudo tee /usr/share/aurorae/themes/UnicornCommander/metadata.desktop
[Desktop Entry]
Name=UnicornCommander
Comment=Purple-themed window decoration with glow effects
X-KDE-PluginInfo-Author=UnicornCommander Team
X-KDE-PluginInfo-Email=team@unicorncommander.ai
X-KDE-PluginInfo-Name=UnicornCommander
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=https://unicorncommander.ai
X-KDE-PluginInfo-Category=
X-KDE-PluginInfo-Depends=
X-KDE-PluginInfo-License=GPL-3.0
X-KDE-PluginInfo-EnabledByDefault=true
X-Plasma-API=5.0
EOF

# Create Aurorae theme config
cat << EOF | sudo tee /usr/share/aurorae/themes/UnicornCommander/UnicornCommanderrc
[General]
ActiveTextColor=255,255,255
InactiveTextColor=189,195,199
TitleAlignment=Center
TitleVerticalAlignment=Center
UseTextShadow=true
ActiveTextShadowColor=107,70,193
InactiveTextShadowColor=0,0,0
TextShadowOffsetX=0
TextShadowOffsetY=1
HaloActive=true
ActiveHaloColor=139,92,246

[Layout]
BorderLeft=4
BorderRight=4
BorderBottom=4
TitleEdgeTop=4
TitleEdgeBottom=4
TitleEdgeLeft=4
TitleEdgeRight=4
TitleBorderLeft=4
TitleBorderRight=4
TitleHeight=30
ButtonWidth=24
ButtonHeight=24
ButtonSpacing=8
ButtonMarginTop=3
ExplicitButtonSpacer=0
PaddingTop=8
PaddingBottom=8
PaddingRight=8
PaddingLeft=8
EOF

# Create window control buttons
# Close button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/close.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <defs>
    <filter id="glow">
      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <circle cx="12" cy="12" r="10" fill="#DC2626" filter="url(#glow)"/>
  <path d="M8 8l8 8M16 8l-8 8" stroke="white" stroke-width="2" stroke-linecap="round"/>
</svg>
EOF

# Minimize button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/minimize.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <defs>
    <filter id="glow">
      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <circle cx="12" cy="12" r="10" fill="#F59E0B" filter="url(#glow)"/>
  <line x1="8" y1="12" x2="16" y2="12" stroke="white" stroke-width="2" stroke-linecap="round"/>
</svg>
EOF

# Maximize button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/maximize.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <defs>
    <filter id="glow">
      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <circle cx="12" cy="12" r="10" fill="#10B981" filter="url(#glow)"/>
  <rect x="8" y="8" width="8" height="8" fill="none" stroke="white" stroke-width="2" rx="1"/>
</svg>
EOF

# Restore button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/restore.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <defs>
    <filter id="glow">
      <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  <circle cx="12" cy="12" r="10" fill="#10B981" filter="url(#glow)"/>
  <path d="M10 10v6h6v-6h-6z M8 8h6v6M10 10h6v6" fill="none" stroke="white" stroke-width="1.5"/>
</svg>
EOF

# All desktops button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/alldesktops.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="#8B5CF6" opacity="0.8"/>
  <rect x="7" y="7" width="4" height="4" fill="white"/>
  <rect x="13" y="7" width="4" height="4" fill="white"/>
  <rect x="7" y="13" width="4" height="4" fill="white"/>
  <rect x="13" y="13" width="4" height="4" fill="white"/>
</svg>
EOF

# Keep above button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/keepabove.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="#8B5CF6" opacity="0.8"/>
  <path d="M12 8l4 5h-8z" fill="white"/>
  <line x1="8" y1="15" x2="16" y2="15" stroke="white" stroke-width="2"/>
</svg>
EOF

# Keep below button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/keepbelow.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="#8B5CF6" opacity="0.8"/>
  <path d="M12 16l4-5h-8z" fill="white"/>
  <line x1="8" y1="9" x2="16" y2="9" stroke="white" stroke-width="2"/>
</svg>
EOF

# Shade button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/shade.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="#8B5CF6" opacity="0.8"/>
  <path d="M8 14l4-4 4 4" fill="none" stroke="white" stroke-width="2" stroke-linecap="round"/>
</svg>
EOF

# Help button
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/help.svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="#8B5CF6" opacity="0.8"/>
  <text x="12" y="16" text-anchor="middle" fill="white" font-size="12" font-weight="bold">?</text>
</svg>
EOF

# Create decoration SVG
cat << 'EOF' | sudo tee /usr/share/aurorae/themes/UnicornCommander/decoration.svg
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <linearGradient id="titlebar-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#7C3AED;stop-opacity:0.95"/>
      <stop offset="100%" style="stop-color:#6B46C1;stop-opacity:0.95"/>
    </linearGradient>
    <linearGradient id="titlebar-inactive-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#4B5563;stop-opacity:0.85"/>
      <stop offset="100%" style="stop-color:#374151;stop-opacity:0.85"/>
    </linearGradient>
  </defs>
  
  <g id="decoration">
    <rect width="100" height="100" fill="url(#titlebar-gradient)"/>
  </g>
  
  <g id="decoration-inactive">
    <rect width="100" height="100" fill="url(#titlebar-inactive-gradient)"/>
  </g>
</svg>
EOF

# Create notification sounds
print_section "Creating Notification Sounds"
if command -v sox &> /dev/null; then
    # Notification sound
    sox -n -r 44100 /usr/share/sounds/unicorncommander/notification.wav \
        synth 0.15 sine 880 sine 1320 fade 0 0.15 0.05 norm -3
    
    # Login sound
    sox -n -r 44100 /usr/share/sounds/unicorncommander/login.wav \
        synth 0.5 sine 523.25 sine 783.99 sine 1046.50 fade 0 0.5 0.2 norm -3
    
    # Logout sound
    sox -n -r 44100 /usr/share/sounds/unicorncommander/logout.wav \
        synth 0.5 sine 1046.50 sine 783.99 sine 523.25 fade 0 0.5 0.2 norm -3
    
    # Error sound
    sox -n -r 44100 /usr/share/sounds/unicorncommander/error.wav \
        synth 0.2 sine 200 sine 150 tremolo 10 50 fade 0 0.2 0.05 norm -3
fi

# Create splash screen
print_section "Creating Splash Screen"
cat << 'EOF' | sudo tee /usr/share/plasma/look-and-feel/org.kde.unicorncommander.desktop/contents/splash/Splash.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#1E1B4B"
    
    property int stage: 0
    
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1E1B4B" }
            GradientStop { position: 0.5; color: "#6B46C1" }
            GradientStop { position: 1.0; color: "#3B82F6" }
        }
    }
    
    Image {
        id: logo
        anchors.centerIn: parent
        source: "images/logo.png"
        sourceSize: Qt.size(200, 200)
        smooth: true
        antialiasing: true
        
        RotationAnimation on rotation {
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 3000
            running: true
        }
        
        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 1.1; duration: 1500; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.1; to: 1; duration: 1500; easing.type: Easing.InOutQuad }
        }
    }
    
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo.bottom
        anchors.topMargin: 30
        text: "UnicornCommander"
        color: "white"
        font.pixelSize: 36
        font.bold: true
        font.family: "Ubuntu"
    }
    
    ProgressBar {
        id: progressBar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.4
        height: 6
        value: stage / 7
        
        background: Rectangle {
            color: "#40FFFFFF"
            radius: 3
        }
        
        contentItem: Rectangle {
            width: progressBar.visualPosition * progressBar.width
            height: parent.height
            radius: 3
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#8B5CF6" }
                GradientStop { position: 1.0; color: "#60A5FA" }
            }
        }
    }
    
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: progressBar.top
        anchors.bottomMargin: 10
        text: {
            switch(stage) {
                case 0: return "Initializing quantum matrix..."
                case 1: return "Loading neural networks..."
                case 2: return "Establishing secure connections..."
                case 3: return "Calibrating unicorn horn..."
                case 4: return "Syncing with command center..."
                case 5: return "Preparing user interface..."
                case 6: return "Welcome to UnicornCommander!"
                default: return "Loading..."
            }
        }
        color: "#D8B4FE"
