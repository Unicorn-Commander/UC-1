#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander Theme Customization${NC}"
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
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Create theme directories
print_section "Creating Theme Directory Structure"
sudo mkdir -p \
    /usr/share/wallpapers/unicorncommander/contents/images \
    /usr/share/sddm/themes/unicorncommander \
    /usr/share/plasma/desktoptheme/unicorncommander \
    /usr/share/plasma/desktoptheme/unicorncommander-professional \
    /usr/share/plymouth/themes/unicorncommander \
    /usr/share/sounds/unicorncommander \
    /usr/share/pixmaps/unicorncommander \
    /usr/share/plasma/look-and-feel/org.kde.unicorncommander/contents

# Create global theme symlinks
sudo ln -s /usr/share/plasma/desktoptheme/unicorncommander \
    /usr/share/plasma/look-and-feel/org.kde.unicorncommander/contents/plasma
sudo ln -s /usr/share/wallpapers/unicorncommander \
    /usr/share/plasma/look-and-feel/org.kde.unicorncommander/contents/wallpapers
sudo ln -s /usr/share/sddm/themes/unicorncommander \
    /usr/share/plasma/look-and-feel/org.kde.unicorncommander/contents/sddm

# Set permissions
sudo chown -R ucadmin:ucadmin \
    /usr/share/wallpapers/unicorncommander \
    /usr/share/sddm/themes/unicorncommander \
    /usr/share/plasma/desktoptheme/unicorncommander* \
    /usr/share/plasma/look-and-feel/org.kde.unicorncommander \
    /usr/share/sounds/unicorncommander \
    /usr/share/pixmaps/unicorncommander

# Deploy wallpapers
print_section "Deploying Wallpapers"
WALLPAPER_SOURCE="/home/ucadmin/UC-1/assets"
WALLPAPER_TARGET="/usr/share/wallpapers/unicorncommander/contents/images"

# Copy all resolution variants
find "$WALLPAPER_SOURCE" -name 'unicorncommander_*x*.jpg' -exec sudo cp {} "$WALLPAPER_TARGET" \;

# Check if any wallpapers were copied
if [ -z "$(ls -A "$WALLPAPER_TARGET")" ]; then
    echo -e "${YELLOW}⚠️ No wallpapers found, creating fallback gradients...${NC}"
    sudo apt-get install -y imagemagick
    RESOLUTIONS=("1920x1080" "2560x1440" "3840x2160" "5120x2880" "7680x4320")
    for res in "${RESOLUTIONS[@]}"; do
        sudo convert -size "$res" gradient:"#6B46C1-#3B82F6" \
            "$WALLPAPER_TARGET/unicorncommander_$res.jpg"
    done
fi

# Create wallpaper metadata
print_section "Creating Wallpaper Metadata"
cat << EOF | sudo tee /usr/share/wallpapers/unicorncommander/metadata.desktop
[Desktop Entry]
Name=UnicornCommander
X-KDE-PluginInfo-Name=unicorncommander
X-KDE-PluginInfo-Author=UnicornCommander Team
X-KDE-PluginInfo-Email=team@unicorncommander.ai
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=https://unicorncommander.ai
EOF

# Create SDDM theme
print_section "Creating SDDM Login Theme"
cat << EOF | sudo tee /usr/share/sddm/themes/unicorncommander/theme.conf
[General]
type=image
color=#6B46C1
fontSize=10
background=/usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg
needsFullUserModel=false
partialBlur=false
fullBlur=false
enableHidpi=true

[Main]
avatar_color=#FFFFFF
icon_color=#FFFFFF
text_color=#FFFFFF

[Input]
color=#FFFFFF
borderColor=#8B5CF6
backgroundColor=#1E1B4B

[Wayland]
EnableHiDPI=true
ScaleMethod=integer
EOF

# Create SDDM QML theme
cat << 'EOF' | sudo tee /usr/share/sddm/themes/unicorncommander/Main.qml
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    // Background
    Image {
        id: background
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Semi-transparent overlay
    Rectangle {
        anchors.fill: parent
        color: "#40000000"
    }

    // Logo/Title
    Text {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.2
        color: "#FFFFFF"
        font.pointSize: 36
        font.bold: true
        text: "UnicornCommander"
    }

    Text {
        id: subtitle
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: title.bottom
        anchors.topMargin: 10
        color: "#E0E7FF"
        font.pointSize: 14
        text: "AI-Powered Linux Distribution"
    }

    // Login form
    Rectangle {
        id: loginForm
        width: 400
        height: 300
        anchors.centerIn: parent
        color: "#1E1B4B"
        opacity: 0.9
        radius: 10

        Column {
            anchors.centerIn: parent
            spacing: 20

            // Username field
            Rectangle {
                width: 300
                height: 40
                color: "#312E81"
                radius: 5
                border.color: "#8B5CF6"
                border.width: 1

                TextInput {
                    id: name
                    anchors.centerIn: parent
                    width: parent.width - 20
                    color: "#FFFFFF"
                    font.pointSize: 12
                    selectByMouse: true
                    text: userModel.lastUser
                }
            }

            // Password field
            Rectangle {
                width: 300
                height: 40
                color: "#312E81"
                radius: 5
                border.color: "#8B5CF6"
                border.width: 1

                TextInput {
                    id: password
                    anchors.centerIn: parent
                    width: parent.width - 20
                    color: "#FFFFFF"
                    font.pointSize: 12
                    echoMode: TextInput.Password
                    selectByMouse: true
                    focus: true

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(name.text, password.text, sessionIndex)
                            event.accepted = true
                        }
                    }
                }
            }

            // Login button
            Rectangle {
                width: 300
                height: 40
                color: "#8B5CF6"
                radius: 5

                Text {
                    anchors.centerIn: parent
                    color: "#FFFFFF"
                    font.pointSize: 12
                    font.bold: true
                    text: "Login"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: sddm.login(name.text, password.text, sessionIndex)
                }
            }
        }
    }

    // Session selector
    Rectangle {
        id: sessionButton
        width: 200
        height: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#1E1B4B"
        opacity: 0.8
        radius: 5

        Text {
            anchors.centerIn: parent
            color: "#FFFFFF"
            font.pointSize: 10
            text: session.name
        }

        MouseArea {
            anchors.fill: parent
            onClicked: session.index = (session.index + 1) % session.count
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            password.focus = true
        }
    }
}
EOF

# Create metadata.desktop for SDDM theme
cat << EOF | sudo tee /usr/share/sddm/themes/unicorncommander/metadata.desktop
[SddmGreeterTheme]
Name=UnicornCommander
Description=UnicornCommander SDDM theme
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
Theme-Id=unicorncommander
Theme-API=2.0
EOF

# Create Plasma Desktop Theme
print_section "Creating Plasma Desktop Theme"
cat << EOF | sudo tee /usr/share/plasma/desktoptheme/unicorncommander/metadata.json
{
    "KPlugin": {
        "Id": "unicorncommander",
        "Name": "UnicornCommander",
        "Version": "1.0",
        "Website": "https://unicorncommander.ai",
        "Category": "Plasma Theme",
        "EnabledByDefault": true
    }
}
EOF

# Create colors file for Plasma theme
cat << EOF | sudo tee /usr/share/plasma/desktoptheme/unicorncommander/colors
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[Colors:Button]
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
activeBackground=49,54,59
activeForeground=252,252,252
inactiveBackground=42,46,50
inactiveForeground=189,195,199
EOF

# Configure Plymouth boot theme
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

cat << 'EOF' | sudo tee /usr/share/plymouth/themes/unicorncommander/unicorncommander.script
# UnicornCommander Plymouth Theme Script

Window.SetBackgroundTopColor(0.42, 0.27, 0.76);    # Purple
Window.SetBackgroundBottomColor(0.23, 0.51, 0.96); # Blue

# Load logo
logo.image = Image("logo.png");
logo.sprite = Sprite(logo.image);
logo.x = Window.GetX() + (Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.y = Window.GetY() + (Window.GetHeight() / 2 - logo.image.GetHeight() / 2);
logo.sprite.SetPosition(logo.x, logo.y, 10000);

# Text
text.image = Image.Text("UnicornCommander", 1, 1, 1);
text.sprite = Sprite(text.image);
text.x = Window.GetX() + (Window.GetWidth() / 2 - text.image.GetWidth() / 2);
text.y = logo.y + logo.image.GetHeight() + 20;
text.sprite.SetPosition(text.x, text.y, 10000);

# Progress bar
progress_box.image = Image("progress_box.png");
progress_box.sprite = Sprite(progress_box.image);
progress_box.x = Window.GetX() + (Window.GetWidth() / 2 - progress_box.image.GetWidth() / 2);
progress_box.y = Window.GetY() + Window.GetHeight() * 0.75;
progress_box.sprite.SetPosition(progress_box.x, progress_box.y, 10000);

progress_bar.original_image = Image("progress_bar.png");
progress_bar.sprite = Sprite();
progress_bar.x = progress_box.x + (progress_box.image.GetWidth() / 2 - progress_bar.original_image.GetWidth() / 2);
progress_bar.y = progress_box.y + (progress_box.image.GetHeight() / 2 - progress_bar.original_image.GetHeight() / 2);
progress_bar.sprite.SetPosition(progress_bar.x, progress_bar.y, 10000);

fun progress_callback(duration, progress) {
    if (progress_bar.image.GetWidth() != Math.Int(progress_bar.original_image.GetWidth() * progress)) {
        progress_bar.image = progress_bar.original_image.Scale(progress_bar.original_image.GetWidth(progress) * progress, progress_bar.original_image.GetHeight());
        progress_bar.sprite.SetImage(progress_bar.image);
    }
}

# Wayland boot compatibility
if (Plymouth.GetMode() == "boot") {
    Plymouth.SetRefreshFunction(progress_callback);
}

Plymouth.SetBootProgressFunction(progress_callback);
EOF

# Create placeholder Plymouth assets
sudo convert -size 128x128 xc:transparent -fill "#8B5CF6" -draw "circle 64,64 64,32" \
    /usr/share/plymouth/themes/unicorncommander/logo.png
sudo convert -size 300x20 xc:"#4C1D95" \
    /usr/share/plymouth/themes/unicorncommander/progress_box.png
sudo convert -size 280x10 xc:"#8B5CF6" \
    /usr/share/plymouth/themes/unicorncommander/progress_bar.png

# Create Global Theme Package
print_section "Creating Global Theme Package"
cat << EOF | sudo tee /usr/share/plasma/look-and-feel/org.kde.unicorncommander/metadata.desktop
[Desktop Entry]
Name=UnicornCommander
Comment=UnicornCommander Desktop Experience
X-KDE-PluginInfo-Name=org.kde.unicorncommander
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=https://unicorncommander.ai
X-KDE-PluginInfo-Category=
X-KDE-PluginInfo-Depends=
X-KDE-PluginInfo-License=GPLv3
X-KDE-PluginInfo-EnabledByDefault=true
X-Plasma-MainScript=ui/main.qml
X-KDE-PluginInfo-Author=UnicornCommander Team
EOF

# Create Professional Theme Variant
print_section "Creating Professional Theme Variant"
cat << EOF | sudo tee /usr/share/plasma/desktoptheme/unicorncommander-professional/metadata.json
{
    "KPlugin": {
        "Id": "unicorncommander-professional",
        "Name": "UnicornCommander Professional",
        "Version": "1.0",
        "Website": "https://unicorncommander.ai",
        "Category": "Plasma Theme",
        "EnabledByDefault": true
    }
}
EOF

cat << EOF | sudo tee /usr/share/plasma/desktoptheme/unicorncommander-professional/colors
[Colors:Button]
BackgroundAlternate=45,45,45
BackgroundNormal=35,35,35
DecorationFocus=70,130,180
DecorationHover=100,149,237
ForegroundActive=135,206,250
ForegroundInactive=169,169,169
ForegroundLink=70,130,180
ForegroundNegative=220,20,60
ForegroundNeutral=255,165,0
ForegroundNormal=240,240,240
ForegroundPositive=50,205,50
ForegroundVisited=147,112,219

[Colors:Selection]
BackgroundAlternate=25,25,40
BackgroundNormal=70,130,180
DecorationFocus=70,130,180
DecorationHover=100,149,237
ForegroundActive=255,255,255
ForegroundInactive=200,200,200
ForegroundLink=173,216,230
ForegroundNegative=220,20,60
ForegroundNeutral=255,165,0
ForegroundNormal=255,255,255
ForegroundPositive=50,205,50
ForegroundVisited=200,200,200

[Colors:View]
BackgroundAlternate=40,40,40
BackgroundNormal=28,28,28
DecorationFocus=70,130,180
DecorationHover=100,149,237
ForegroundActive=135,206,250
ForegroundInactive=169,169,169
ForegroundLink=70,130,180
ForegroundNegative=220,20,60
ForegroundNeutral=255,165,0
ForegroundNormal=240,240,240
ForegroundPositive=50,205,50
ForegroundVisited=147,112,219

[Colors:Window]
BackgroundAlternate=45,45,45
BackgroundNormal=35,35,35
DecorationFocus=70,130,180
DecorationHover=100,149,237
ForegroundActive=135,206,250
ForegroundInactive=169,169,169
ForegroundLink=70,130,180
ForegroundNegative=220,20,60
ForegroundNeutral=255,165,0
ForegroundNormal=240,240,240
ForegroundPositive=50,205,50
ForegroundVisited=147,112,219

[General]
ColorScheme=UnicornCommander Professional
Name=UnicornCommander Professional
shadeSortColumn=true

[WM]
activeBackground=35,35,35
activeForeground=240,240,240
inactiveBackground=28,28,28
inactiveForeground=169,169,169
EOF

# Create Theme Switcher
print_section "Creating Theme Switcher"
cat << 'EOF' | sudo tee /usr/local/bin/uc-theme-switch
#!/bin/bash
echo "🦄 UnicornCommander Theme Switcher"
echo "1. Cosmic (Purple/Blue gradient)"
echo "2. Professional (Dark blue/steel)"
echo ""
read -p "Select theme (1-2): " choice

case $choice in
    1)
        echo "Switching to Cosmic theme..."
        kwriteconfig6 --file plasmarc --group Theme --key name "unicorncommander"
        kwriteconfig6 --file kdeglobals --group General --key ColorScheme "UnicornCommander"
        kwriteconfig6 --file plasmarc --group Wallpapers --key defaultWallpaper "/usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg"
        sudo sed -i 's/Current=.*/Current=unicorncommander/' /etc/sddm.conf.d/theme.conf
        lookandfeeltool -a org.kde.unicorncommander
        echo "✅ Cosmic theme applied."
        ;;
    2)
        echo "Switching to Professional theme..."
        kwriteconfig6 --file plasmarc --group Theme --key name "unicorncommander-professional"
        kwriteconfig6 --file kdeglobals --group General --key ColorScheme "UnicornCommander Professional"
        kwriteconfig6 --file plasmarc --group Wallpapers --key defaultWallpaper "/usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg"
        sudo sed -i 's/Current=.*/Current=unicorncommander/' /etc/sddm.conf.d/theme.conf
        lookandfeeltool -a org.kde.unicorncommander
        echo "✅ Professional theme applied."
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

# Restart Plasma properly
kquitapp6 plasmashell 2>/dev/null
kstart6 plasmashell 2>/dev/null
echo "Theme change complete! Restart for SDDM changes to take effect."
EOF

sudo chmod +x /usr/local/bin/uc-theme-switch

# Configure KDE to use custom theme
print_section "Configuring KDE Plasma Theme"
mkdir -p /home/ucadmin/.config

# Set default theme
kwriteconfig6 --file plasmarc --group Theme --key name "unicorncommander"
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "UnicornCommander"
kwriteconfig6 --file plasmarc --group Wallpapers --key defaultWallpaper \
    "/usr/share/wallpapers/unicorncommander/contents/images/unicorncommander_1920x1080.jpg"

# Set SDDM theme
echo "[Theme]
Current=unicorncommander" | sudo tee /etc/sddm.conf.d/theme.conf

# Set Plymouth theme
sudo plymouth-set-default-theme unicorncommander
sudo update-initramfs -u

# Install icon theme
print_section "Installing Icon Theme"
sudo apt install -y papirus-icon-theme
kwriteconfig6 --file kdeglobals --group Icons --key Theme "Papirus-Dark"

# Install cursor theme
print_section "Installing Cursor Theme"
sudo apt install -y breeze-cursor-theme
kwriteconfig6 --file kdeglobals --group Cursors --key Theme "Breeze_Snow"

# Configure Konsole theme
print_section "Configuring Terminal Theme"
mkdir -p /home/ucadmin/.local/share/konsole
cat << 'EOF' > /home/ucadmin/.local/share/konsole/UnicornCommander.profile
[Appearance]
ColorScheme=UnicornCommander
Font=Hack,11,-1,5,50,0,0,0,0,0
BlurBackground=true
Opacity=0.92

[General]
Name=UnicornCommander
Parent=FALLBACK/

[Interaction Options]
AutoCopySelectedText=true
TrimTrailingSpacesInSelectedText=true

[Scrolling]
ScrollBarPosition=2

[Terminal Features]
BlinkingCursorEnabled=true
EOF

cat << 'EOF' > /home/ucadmin/.local/share/konsole/UnicornCommander.colorscheme
[Background]
Color=30,27,75

[BackgroundFaint]
Color=49,46,129

[BackgroundIntense]
Color=49,46,129

[Color0]
Color=40,40,40

[Color0Faint]
Color=40,40,40

[Color0Intense]
Color=104,104,104

[Color1]
Color=218,68,83

[Color1Faint]
Color=218,68,83

[Color1Intense]
Color=231,76,60

[Color2]
Color=39,174,96

[Color2Faint]
Color=39,174,96

[Color2Intense]
Color=46,204,113

[Color3]
Color=246,116,0

[Color3Faint]
Color=246,116,0

[Color3Intense]
Color=255,127,0

[Color4]
Color=107,70,193

[Color4Faint]
Color=107,70,193

[Color4Intense]
Color=139,92,246

[Color5]
Color=155,89,182

[Color5Faint]
Color=155,89,182

[Color5Intense]
Color=142,68,173

[Color6]
Color=52,152,219

[Color6Faint]
Color=52,152,219

[Color6Intense]
Color=61,174,233

[Color7]
Color=252,252,252

[Color7Faint]
Color=252,252,252

[Color7Intense]
Color=255,255,255

[Foreground]
Color=252,252,252

[ForegroundFaint]
Color=239,240,241

[ForegroundIntense]
Color=255,255,255

[General]
Description=UnicornCommander terminal theme
Opacity=0.95
Wallpaper=
EOF

# Create theme switcher launcher
cat << 'EOF' > /home/ucadmin/.local/share/applications/uc-theme-switcher.desktop
[Desktop Entry]
Name=Theme Switcher
Comment=Switch between Cosmic and Professional themes
Exec=konsole -e /usr/local/bin/uc-theme-switch
Icon=preferences-desktop-theme
Type=Application
Categories=Settings;Appearance;
StartupNotify=true
X-KDE-Wayland-Interfaces=org_kde_kwin_keystate
EOF

# Update Zsh configuration
print_section "Configuring Zsh Theme"
cat << 'EOF' >> /home/ucadmin/.zshrc

# UnicornCommander custom prompt
PROMPT='%F{#8B5CF6}🦄%f %F{#E0E7FF}%n@%m%f:%F{#60A5FA}%~%f$ '

# Theme switching aliases
alias uc-theme="/usr/local/bin/uc-theme-switch"
alias uc-cosmic="kwriteconfig6 --file plasmarc --group Theme --key name unicorncommander && kquitapp6 plasmashell; kstart6 plasmashell"
alias uc-professional="kwriteconfig6 --file plasmarc --group Theme --key name unicorncommander-professional && kquitapp6 plasmashell; kstart6 plasmashell"

# UC-1 shortcuts
alias uc-start="cd ~/UC-1 && ./start-services.sh"
alias uc-stop="cd ~/UC-1 && ./stop-services.sh"
alias uc-status="cd ~/UC-1 && ./status-services.sh"
alias uc-monitor="/usr/local/bin/uc-monitor"
alias ai-env="source ~/ai-env/bin/activate"

# Show UC-1 status on startup
echo "🦄 Welcome to UnicornCommander!"
echo "Use 'uc-start' to begin, 'uc-monitor' for system status"
echo "Switch themes with 'uc-theme'"
EOF

# Apply global theme
print_section "Applying Global Theme"
lookandfeeltool -a org.kde.unicorncommander
sudo sed -i 's/^Current=.*/Current=unicorncommander/' /etc/sddm.conf.d/theme.conf

# Finalize
print_section "Finalizing Theme Setup"
kbuildsycoca6 2>/dev/null || true
kquitapp6 plasmashell 2>/dev/null
kstart6 plasmashell 2>/dev/null

echo -e "${GREEN}🎉 UnicornCommander theme customization complete!${NC}"
echo -e "${PURPLE}🦄 Global Theme: org.kde.unicorncommander 🦄${NC}"
echo -e "${BLUE}Components installed:${NC}"
echo -e "  - SDDM login theme with purple gradient"
echo -e "  - Plasma desktop theme with custom colors"
echo -e "  - Plymouth boot animation"
echo -e "  - Professional theme variant"
echo -e "  - Papirus-Dark icon theme"
echo -e "  - Breeze Snow cursor theme"
echo -e "  - Custom Konsole terminal theme"
echo -e "  - Wallpapers for multiple resolutions"
echo -e ""
echo -e "${BLUE}Theme switching options:${NC}"
echo -e "  - GUI: Applications → Settings → Theme Switcher"
echo -e "  - Terminal: uc-theme"
echo -e "  - Quick: uc-cosmic or uc-professional"
echo -e ""
echo -e "${BLUE}To complete setup:${NC}"
echo -e "  - Reboot to see all changes: sudo reboot"
echo -e "  - Customize assets in /usr/share/plasma/look-and-feel/org.kde.unicorncommander"
echo -e ""
echo -e "${PURPLE}🦄 UnicornCommander is ready to fly! 🦄${NC}"
