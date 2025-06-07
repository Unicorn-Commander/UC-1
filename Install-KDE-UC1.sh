#!/bin/bash

# KDE Plasma 6 Installation Script for UnicornCommander
# Ubuntu Server 25.04 (KDE 6.x) with custom theming

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
USER_HOME="/home/ucadmin"
WALLPAPER_DIR="$USER_HOME/.local/share/wallpapers/UnicornCommander"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if running as ucadmin
if [ "$USER" != "ucadmin" ]; then
    echo -e "${RED}Error: This script must be run as ucadmin user${NC}"
    echo "Please log in as ucadmin and run this script again."
    exit 1
fi

echo -e "${BLUE}🦄 UnicornCommander KDE Plasma 6 Installation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo "Installing KDE desktop environment on Ubuntu Server 25.04"
echo

print_section "Updating System"
sudo apt update
sudo apt upgrade -y

print_section "Installing KDE Plasma 6 Desktop"
echo "Installing KDE Plasma 6 and essential components..."

# Install KDE Plasma Desktop (minimal but complete)
sudo apt install -y \
    kde-plasma-desktop \
    plasma-workspace \
    plasma-desktop \
    plasma-pa \
    plasma-nm \
    plasma-discover \
    plasma-systemmonitor \
    sddm \
    sddm-theme-breeze

echo -e "${GREEN}✅ KDE Plasma 6 installed${NC}"

print_section "Installing Essential Desktop Applications"

# Core desktop applications
echo "Installing essential applications..."
sudo apt install -y \
    firefox \
    dolphin \
    konsole \
    kate \
    ark \
    okular \
    vlc \
    kcalc \
    gwenview \
    kwrite \
    kfind \
    kcharselect \
    kruler \
    kcolorchooser

# Install screenshot tool (try spectacle, fallback to alternatives)
echo "Installing screenshot tool..."
if sudo apt install -y spectacle 2>/dev/null; then
    echo "✅ Spectacle installed"
elif sudo apt install -y kde-spectacle 2>/dev/null; then
    echo "✅ KDE Spectacle installed"  
elif sudo apt install -y gnome-screenshot 2>/dev/null; then
    echo "✅ GNOME Screenshot installed as fallback"
else
    echo "⚠️ No screenshot tool found, will use Print Screen key"
fi

# File management and utilities
sudo apt install -y \
    filelight \
    sweeper \
    partitionmanager

echo -e "${GREEN}✅ Desktop applications installed${NC}"

print_section "Installing Media Support and Codecs"
echo "Installing multimedia codecs and fonts..."

sudo apt install -y \
    ubuntu-restricted-extras \
    libavcodec-extra \
    fonts-liberation \
    fonts-liberation2 \
    fonts-ubuntu \
    fonts-dejavu-core \
    fonts-noto \
    fonts-noto-color-emoji

echo -e "${GREEN}✅ Media support installed${NC}"

print_section "Installing System Utilities"
echo "Installing additional system tools..."

sudo apt install -y \
    htop \
    neofetch \
    tree \
    curl \
    wget \
    git \
    vim \
    synaptic \
    gparted \
    software-properties-gtk

echo -e "${GREEN}✅ System utilities installed${NC}"

print_section "Configuring SDDM Display Manager"
echo "Setting up SDDM for graphical login..."

# Enable SDDM and set graphical target
sudo systemctl enable sddm
sudo systemctl set-default graphical.target

# Configure SDDM
sudo mkdir -p /etc/sddm.conf.d
cat << 'EOF' | sudo tee /etc/sddm.conf.d/kde_settings.conf
[Autologin]
User=
Session=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze

[Users]
MaximumUid=60513
MinimumUid=500
RememberLastUser=true
EOF

echo -e "${GREEN}✅ SDDM configured${NC}"

print_section "Installing Icon Themes and Visual Components"
echo "Installing modern icon themes..."

# Install popular icon themes
sudo apt install -y \
    papirus-icon-theme \
    breeze-icon-theme

# Install cursor themes
sudo apt install -y \
    breeze-cursor-theme

# Download and install Flat-Remix icons (popular modern theme)
echo "Installing Flat-Remix icon theme..."
cd /tmp
wget -q https://github.com/daniruiz/flat-remix/archive/refs/heads/master.tar.gz -O flat-remix.tar.gz
tar -xzf flat-remix.tar.gz
mkdir -p "$USER_HOME/.local/share/icons"
cp -r flat-remix-master/Flat-Remix* "$USER_HOME/.local/share/icons/"
rm -rf flat-remix-master flat-remix.tar.gz

echo -e "${GREEN}✅ Icon themes installed${NC}"

print_section "Setting Up Custom Wallpaper Directory"
echo "Creating wallpaper directory structure..."

# Create wallpaper directories
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$USER_HOME/.local/share/plasma/wallpapers"

# Create a placeholder wallpaper (you can replace this)
echo "Creating default wallpaper setup..."

# If script directory has wallpapers folder, copy them
if [ -d "$SCRIPT_DIR/wallpapers" ]; then
    echo "Found wallpapers directory, copying custom wallpapers..."
    cp -r "$SCRIPT_DIR/wallpapers/"* "$WALLPAPER_DIR/"
    echo -e "${GREEN}✅ Custom wallpapers installed${NC}"
else
    echo -e "${YELLOW}📝 No wallpapers directory found.${NC}"
    echo -e "${YELLOW}   Create a 'wallpapers' folder next to this script and add your custom wallpapers there.${NC}"
    echo -e "${YELLOW}   Supported formats: .jpg, .png${NC}"
    
    # Create a simple gradient as placeholder
    if command -v convert >/dev/null 2>&1; then
        echo "Creating placeholder wallpaper..."
        convert -size 1920x1080 gradient:#1a1a2e-#16213e "$WALLPAPER_DIR/default.png"
    else
        echo "Install ImageMagick to auto-generate placeholder: sudo apt install imagemagick"
    fi
fi

# Set correct ownership
chown -R ucadmin:ucadmin "$USER_HOME/.local"

echo -e "${GREEN}✅ Wallpaper directory created: $WALLPAPER_DIR${NC}"

print_section "Installing AMD GPU Optimizations"
echo "Installing AMD GPU support and optimizations..."

# Install Mesa and Vulkan for AMD
sudo apt install -y \
    mesa-utils \
    mesa-vulkan-drivers \
    vulkan-tools \
    libvulkan1 \
    radeontop \
    clinfo

# Set AMD-specific environment variables
echo "Configuring AMD GPU environment..."
cat >> "$USER_HOME/.profile" << 'EOF'

# AMD GPU optimizations for Radeon 780M
export RADV_PERFTEST=aco
export AMD_VULKAN_ICD=RADV
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
EOF

echo -e "${GREEN}✅ AMD GPU support configured${NC}"

print_section "Applying KDE Configuration"
echo "Setting up default KDE configuration..."

# Create KDE config directory
mkdir -p "$USER_HOME/.config"

# Set dark theme by default
kwriteconfig5 --file "$USER_HOME/.config/kdeglobals" \
    --group "KDE" --key "LookAndFeelPackage" "org.kde.breezedark.desktop"

# Set icon theme to Flat-Remix (if installed)
if [ -d "$USER_HOME/.local/share/icons/Flat-Remix-Blue-Dark" ]; then
    kwriteconfig5 --file "$USER_HOME/.config/kdeglobals" \
        --group "Icons" --key "Theme" "Flat-Remix-Blue-Dark"
else
    kwriteconfig5 --file "$USER_HOME/.config/kdeglobals" \
        --group "Icons" --key "Theme" "breeze-dark"
fi

# Disable notification sounds (good for workstation)
kwriteconfig5 --file "$USER_HOME/.config/plasmanotifyrc" \
    --group "Sounds" --key "Enable" "false"

# Configure power management (don't sleep/lock for AI workstation)
kwriteconfig5 --file "$USER_HOME/.config/powermanagementprofilesrc" \
    --group "AC" --group "Display" --key "turnOffDisplayIdleTimeoutSec" "0"

# Disable automatic screen locking
kwriteconfig5 --file "$USER_HOME/.config/kscreenlockerrc" \
    --group "Daemon" --key "Autolock" "false"

# Configure Dolphin file manager
kwriteconfig5 --file "$USER_HOME/.config/dolphinrc" \
    --group "General" --key "BrowseThroughArchives" "true"
kwriteconfig5 --file "$USER_HOME/.config/dolphinrc" \
    --group "General" --key "ShowFullPath" "true"

echo -e "${GREEN}✅ KDE configuration applied${NC}"

print_section "Creating Desktop Shortcuts for UC-1 Services"
echo "Setting up desktop shortcuts for AI services..."

# Create Desktop directory
mkdir -p "$USER_HOME/Desktop"

# UC-1 Control Panel (Portainer)
cat > "$USER_HOME/Desktop/UC-1-Control-Panel.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=UC-1 Control Panel
Comment=Manage UnicornCommander Docker Containers
Exec=firefox http://localhost:9000
Icon=applications-system
Terminal=false
Categories=System;Development;
EOF

# Open-WebUI (AI Chat Interface)
cat > "$USER_HOME/Desktop/Open-WebUI.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Open-WebUI
Comment=AI Chat Interface - ChatGPT-like Interface
Exec=firefox http://localhost:8080
Icon=applications-internet
Terminal=false
Categories=Network;Development;AI;
EOF

# SearXNG (Private Search)
cat > "$USER_HOME/Desktop/SearXNG-Search.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=SearXNG Search
Comment=Private Search Engine
Exec=firefox http://localhost:8888
Icon=applications-internet
Terminal=false
Categories=Network;
EOF

# System Monitor
cat > "$USER_HOME/Desktop/System-Monitor.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=System Monitor
Comment=Monitor CPU, RAM, and GPU usage
Exec=plasma-systemmonitor
Icon=utilities-system-monitor
Terminal=false
Categories=System;Monitor;
EOF

# UC-1 Terminal (for managing containers)
cat > "$USER_HOME/Desktop/UC-1-Terminal.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=UC-1 Terminal
Comment=Terminal in UC-1_Core directory
Exec=konsole --workdir /home/ucadmin/UC-1/UC-1_Core
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF

# Make desktop files executable
chmod +x "$USER_HOME/Desktop"/*.desktop

echo -e "${GREEN}✅ Desktop shortcuts created${NC}"

print_section "Final System Configuration"
echo "Applying final configurations..."

# Set correct ownership for all user files
sudo chown -R ucadmin:ucadmin "$USER_HOME"

# Update desktop database
sudo update-desktop-database

# Update icon cache
sudo gtk-update-icon-cache -f -t /usr/share/icons/* 2>/dev/null || true

# Create a system info script
cat > "$USER_HOME/Desktop/System-Info.sh" << 'EOF'
#!/bin/bash
echo "🦄 UnicornCommander System Information"
echo "═══════════════════════════════════════"
echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "GPU: $(lspci | grep VGA | cut -d: -f3 | xargs)"
echo "RAM: $(free -h | grep Mem | awk '{print $2}') total, $(free -h | grep Mem | awk '{print $3}') used"
echo "Disk: $(df -h / | tail -1 | awk '{print $2}') total, $(df -h / | tail -1 | awk '{print $3}') used"
echo ""
echo "🐳 Docker Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "🌐 UC-1 Services:"
echo "• Portainer:   http://localhost:9000"
echo "• Open-WebUI:  http://localhost:8080"
echo "• SearXNG:     http://localhost:8888"
read -p "Press Enter to close..."
EOF

chmod +x "$USER_HOME/Desktop/System-Info.sh"

print_section "Installation Complete!"
echo -e "${GREEN}🎉 KDE Plasma 6 installation completed successfully!${NC}"
echo
echo -e "${BLUE}What was installed:${NC}"
echo "• KDE Plasma 6 Desktop Environment"
echo "• Essential applications (Firefox, Dolphin, Kate, VLC, etc.)"
echo "• Modern icon themes (Flat-Remix, Papirus)"
echo "• AMD GPU optimizations"
echo "• Desktop shortcuts for UC-1 services"
echo "• Custom wallpaper directory structure"
echo
echo -e "${BLUE}Custom wallpapers:${NC}"
echo "• Location: $WALLPAPER_DIR"
echo "• To add your wallpapers:"
echo "  1. Copy .jpg/.png files to: $WALLPAPER_DIR"
echo "  2. Right-click desktop > Configure Desktop > Wallpaper"
echo "  3. Browse to the UnicornCommander folder"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Reboot to start KDE: sudo reboot"
echo "2. Log in graphically with ucadmin / MagicUnicorn!8-)"
echo "3. Customize appearance in System Settings"
echo "4. UC-1 services should already be running"
echo
echo -e "${YELLOW}Note: First KDE login may take a few extra seconds to initialize.${NC}"

exit 0
