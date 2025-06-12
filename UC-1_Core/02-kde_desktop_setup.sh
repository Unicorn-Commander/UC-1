#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander KDE Desktop Setup${NC}"
echo -e "${BLUE}Installing KDE Plasma 6 with Wayland support...${NC}"

# Ensure running as ucadmin (not root) with sudo privileges
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️ This script should NOT be run with sudo. Run as ucadmin user directly.${NC}"
    echo -e "${YELLOW}   Example: ./02-kde_desktop_setup.sh${NC}"
    exit 1
fi

if [ "$(whoami)" != "ucadmin" ]; then
    echo -e "${YELLOW}⚠️ This script must be run as ucadmin user. Current user: $(whoami)${NC}"
    exit 1
fi

if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Sudo privileges required. Run: sudo visudo and add 'ucadmin ALL=(ALL) NOPASSWD:ALL'${NC}"
    exit 1
fi

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if KDE is already installed
print_section "Checking Existing Installation"
if dpkg -l | grep -q "kde-plasma-desktop"; then
    echo -e "${GREEN}✅ KDE Plasma is already installed${NC}"
    echo -e "${BLUE}This script will update configuration and install any missing components...${NC}"
    KDE_ALREADY_INSTALLED=true
else
    echo -e "${BLUE}KDE Plasma not detected, performing fresh installation...${NC}"
    KDE_ALREADY_INSTALLED=false
fi

# Add Mozilla PPA for non-Snap Firefox (if not already configured)
print_section "Configuring Firefox Repository"
if [ ! -f /etc/apt/preferences.d/mozilla-firefox ]; then
    echo -e "${BLUE}Adding Mozilla PPA for Firefox ESR...${NC}"
    sudo add-apt-repository -y ppa:mozillateam/ppa
    echo -e "Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001" | sudo tee /etc/apt/preferences.d/mozilla-firefox
else
    echo -e "${GREEN}✅ Mozilla Firefox repository already configured${NC}"
fi

# Install KDE Plasma Desktop (minimal, no Snap packages)
print_section "Installing KDE Plasma Desktop"
sudo apt update
sudo apt install -y \
    kde-plasma-desktop \
    sddm \
    plasma-workspace \
    plasma-wayland-protocols \
    wayland-utils \
    firefox-esr \
    konsole \
    dolphin \
    kate \
    kcalc \
    kde-spectacle \
    okular \
    ark \
    vlc \
    gimp \
    plasma-nm \
    network-manager-openvpn \
    network-manager-vpnc
# Note: Removed network-manager-gnome packages to avoid pulling in GTK dependencies for a cleaner KDE install.

# Install additional KDE applications
print_section "Installing KDE Applications"
sudo apt install -y \
    kdevelop \
    kwrite \
    kfind \
    plasma-systemmonitor \
    kinfocenter \
    kcharselect \
    kruler \
    kcolorchooser

# Install development tools
print_section "Installing Development Tools"

# The 'code' package for VS Code requires Microsoft's repository.
# This section adds the repository first to ensure the package can be found.
if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
    echo -e "${BLUE}Adding Microsoft VS Code repository...${NC}"
    sudo apt-get install -y wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    sudo apt update
else
    echo -e "${GREEN}✅ Microsoft VS Code repository already configured${NC}"
fi

# Install development tools with correct packages for KDE Plasma 6 (KF6/Qt6)
# Note: The correct package for plasma shell development is 'libplasma-dev'
sudo apt install -y \
    code \
    git \
    cmake \
    extra-cmake-modules \
    qt6-declarative-dev \
    libplasma-dev

# Configure SDDM for Wayland
print_section "Configuring SDDM"
sudo mkdir -p /etc/sddm.conf.d
cat << EOF | sudo tee /etc/sddm.conf.d/kde_settings.conf
[General]
DisplayServer=wayland
Numlock=on

[Wayland]
SessionDir=/usr/share/wayland-sessions

[X11]
SessionDir=/usr/share/xsessions
EOF

# Enable SDDM service
sudo systemctl enable sddm

# Configure firewall
print_section "Configuring Firewall"
sudo apt install -y ufw
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh

# Configure automatic updates
print_section "Configuring Automatic Updates"
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

# Install Papirus icon theme and additional themes
print_section "Installing Themes and Icons"
sudo apt install -y \
    papirus-icon-theme \
    breeze-cursor-theme \
    oxygen-cursor-theme \
    adwaita-icon-theme

# Configure terminal with Zsh and Oh My Zsh
print_section "Setting up Enhanced Terminal"
sudo apt install -y zsh curl

# Install Oh My Zsh for ucadmin (if not already installed)
if [ ! -d "/home/ucadmin/.oh-my-zsh" ]; then
    echo -e "${BLUE}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    sudo chsh -s /usr/bin/zsh ucadmin
else
    echo -e "${GREEN}✅ Oh My Zsh already installed${NC}"
fi

# Add neofetch for system info
sudo apt install -y neofetch
if ! grep -q "neofetch" /home/ucadmin/.zshrc 2>/dev/null; then
    echo 'neofetch' >> /home/ucadmin/.zshrc
fi

# Create desktop directories
print_section "Setting up Desktop Environment"
mkdir -p /home/ucadmin/{Desktop,Documents,Downloads,Music,Pictures,Videos,Public,Templates}
xdg-user-dirs-update

# Configure Dolphin file manager
mkdir -p /home/ucadmin/.config
if [ ! -f /home/ucadmin/.config/dolphinrc ]; then
    echo -e "${BLUE}Configuring Dolphin file manager...${NC}"
    cat << EOF > /home/ucadmin/.config/dolphinrc
[General]
ShowFullPath=true
ShowSpaceInfo=true

[DetailsMode]
PreviewSize=32

[IconsMode]
PreviewSize=64
EOF
else
    echo -e "${GREEN}✅ Dolphin already configured${NC}"
fi

# Create UC-1 workspace folders
mkdir -p /home/ucadmin/{UC-1,models,datasets,projects,scripts}

# Install additional productivity software
print_section "Installing Productivity Software"
sudo apt install -y \
    libreoffice \
    thunderbird \
    transmission-gtk \
    audacity \
    inkscape \
    obs-studio

# Configure KDE for better performance
print_section "Optimizing KDE Performance"
mkdir -p /home/ucadmin/.config
if [ ! -f /home/ucadmin/.config/kwinrc ]; then
    echo -e "${BLUE}Configuring KWin compositor...${NC}"
    cat << EOF > /home/ucadmin/.config/kwinrc
[Compositing]
Enabled=true
Backend=OpenGL
GLCore=true
HiddenPreviews=5
OpenGLIsUnsafe=false

[Effect-Overview]
BorderActivate=9

[Effect-DesktopGrid]
BorderActivate=1
EOF
else
    echo -e "${GREEN}✅ KWin already configured${NC}"
fi

# Ensure NetworkManager is properly configured for KDE
print_section "Configuring Network Management"
sudo systemctl enable NetworkManager
sudo systemctl disable systemd-networkd || true
sudo systemctl disable systemd-resolved || true

# Add ucadmin to netdev group for network management
sudo usermod -a -G netdev ucadmin

# Configure NetworkManager for better KDE integration
sudo mkdir -p /etc/NetworkManager/conf.d
cat << EOF | sudo tee /etc/NetworkManager/conf.d/kde-integration.conf
[main]
plugins=keyfile
dhcp=internal

[keyfile]
unmanaged-devices=none

[device]
wifi.scan-rand-mac-address=yes
EOF

# Set up workspace shortcuts
cat << EOF > /home/ucadmin/.config/kglobalshortcutsrc
[kwin]
Overview=Meta+Tab,Meta+Tab,Toggle Overview
ShowDesktopGrid=Meta+F8,Meta+F8,Show Desktop Grid
Walk Through Windows=Alt+Tab,Alt+Tab,Walk Through Windows
EOF

echo -e "${GREEN}🎉 KDE Desktop setup complete!${NC}"
echo -e "${BLUE}Desktop features installed:${NC}"
echo -e "  - KDE Plasma 6 with Wayland support"
echo -e "  - Firefox ESR (non-Snap version)"
echo -e "  - Development tools (KDevelop, VS Code)"
echo -e "  - Productivity apps (LibreOffice, GIMP, etc.)"
echo -e "  - Zsh with Oh My Zsh"
echo -e "  - Enhanced file manager and terminal"
echo -e ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  - Run '03-uc1-integration.sh' to set up UC-1 services"
echo -e "  - Run '04-theme-customization.sh' to apply custom branding"
echo -e "  - Reboot to start KDE: sudo reboot"