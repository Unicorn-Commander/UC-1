#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander KDE Desktop Setup${NC}"
echo -e "${BLUE}Installing KDE Plasma 6 with AMD 780M iGPU optimizations...${NC}"

# Ensure running as ucadmin (not root) with sudo privileges
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️ This script should NOT be run with sudo. Run as ucadmin user directly.${NC}"
    echo -e "${YELLOW}   Example: ./02-kde_desktop_setup.sh${NC}"
    exit 1
else
    echo -e "${YELLOW}⚠️ AI environment not found - run hardware script else
    echo -e "${YELLOW}⚠️ UnicornCommander not found - check UC-1_Core directory${NC}"
first${NC}"
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

# Check if hardware setup was completed
print_section "Checking Prerequisites"
if [ ! -f "/usr/local/bin/uc-monitor" ]; then
    echo -e "${YELLOW}⚠️ Hardware setup not detected. Please run 01-hardware_ai_setup.sh first${NC}"
    exit 1
fi

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

# Transition from systemd-networkd to NetworkManager for KDE
print_section "Configuring Network Management for KDE"
if systemctl is-active --quiet systemd-networkd; then
    echo -e "${BLUE}Transitioning from systemd-networkd to NetworkManager for KDE integration...${NC}"
    
    # Install NetworkManager first
    sudo apt install -y network-manager plasma-nm network-manager-openvpn network-manager-vpnc
    
    # Stop and disable systemd-networkd services
    sudo systemctl stop systemd-networkd
    sudo systemctl disable systemd-networkd
    sudo systemctl mask systemd-networkd-wait-online.service
    
    # Enable and start NetworkManager
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
    
    echo -e "${GREEN}✅ Successfully transitioned to NetworkManager${NC}"
else
    echo -e "${GREEN}✅ NetworkManager already active${NC}"
    # Still install KDE network integration if missing
    if ! dpkg -l | grep -q plasma-nm; then
        sudo apt install -y plasma-nm network-manager-openvpn network-manager-vpnc
    fi
fi

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

sudo apt install -y \
    code \
    git \
    cmake \
    extra-cmake-modules \
    qt6-declarative-dev \
    libplasma-dev

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
    gimp
# Configure SDDM for KDE Plasma 6 with Wayland (default on Ubuntu 25.04)
print_section "Configuring SDDM"
sudo mkdir -p /etc/sddm.conf.d

# Ubuntu 25.04 + Kernel 6.14 has native AMD 780M support - use Wayland by default
echo -e "${GREEN}✅ Ubuntu 25.04 with kernel 6.14 - using Wayland (KDE Plasma 6 default)${NC}"
DISPLAY_SERVER="wayland"

cat << EOF | sudo tee /etc/sddm.conf.d/kde_settings.conf
[General]
DisplayServer=${DISPLAY_SERVER}
Numlock=on

[Wayland]
SessionDir=/usr/share/wayland-sessions
CompositorCommand=kwin_wayland

[X11]
SessionDir=/usr/share/xsessions
EOF

# Enable SDDM service
sudo systemctl enable sddm

# Configure firewall (avoid conflicts with existing setup)
print_section "Configuring Firewall"
if ! systemctl is-enabled ufw >/dev/null 2>&1; then
    sudo apt install -y ufw
    sudo ufw --force enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    echo -e "${GREEN}✅ UFW firewall configured${NC}"
else
    echo -e "${GREEN}✅ UFW firewall already configured${NC}"
fi

# Configure automatic updates
print_section "Configuring Automatic Updates"
if ! dpkg -l | grep -q unattended-upgrades; then
    sudo apt install -y unattended-upgrades
    sudo dpkg-reconfigure -f noninteractive unattended-upgrades
    echo -e "${GREEN}✅ Automatic updates configured${NC}"
else
    echo -e "${GREEN}✅ Automatic updates already configured${NC}"
fi

# Install Papirus icon theme and additional themes
print_section "Installing Themes and Icons"
sudo apt install -y \
    papirus-icon-theme \
    breeze-cursor-theme \
    oxygen-cursor-theme \
    adwaita-icon-theme

# Configure terminal with Bash
print_section "Setting up Bash Terminal"
# Ensure bash is the default shell for ucadmin
if [ "$SHELL" != "/bin/bash" ]; then
    sudo chsh -s /bin/bash ucadmin
    echo -e "${GREEN}✅ Bash set as default shell for ucadmin${NC}"
else
    echo -e "${GREEN}✅ Bash already default shell${NC}"
fi

# Add neofetch for system info (if not already there)
sudo apt install -y neofetch
if ! grep -q "neofetch" /home/ucadmin/.bashrc 2>/dev/null; then
    echo 'neofetch' >> /home/ucadmin/.bashrc
    echo -e "${GREEN}✅ Added neofetch to .bashrc${NC}"
fi

# Create desktop directories
print_section "Setting up Desktop Environment"
mkdir -p /home/ucadmin/{Desktop,Documents,Downloads,Music,Pictures,Videos,Public,Templates}
xdg-user-dirs-update

# Configure Dolphin file manager with proper ownership
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
    chown ucadmin:ucadmin /home/ucadmin/.config/dolphinrc
    echo -e "${GREEN}✅ Dolphin configured${NC}"
else
    echo -e "${GREEN}✅ Dolphin already configured${NC}"
fi

# Ensure UC-1 workspace folders exist
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

# Configure KDE for better performance with AMD 780M
print_section "Optimizing KDE Performance for AMD 780M"
if [ ! -f /home/ucadmin/.config/kwinrc ]; then
    echo -e "${BLUE}Configuring KWin compositor for AMD 780M...${NC}"
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

[Wayland]
InputMethod=
VirtualKeyboard=false

[Xwayland]
Scale=1
EOF
    chown ucadmin:ucadmin /home/ucadmin/.config/kwinrc
    echo -e "${GREEN}✅ KWin configured for AMD 780M${NC}"
else
    echo -e "${GREEN}✅ KWin already configured${NC}"
fi

# NetworkManager is now managed by this script, just ensure KDE integration
print_section "Finalizing Network Configuration"
if systemctl is-active --quiet NetworkManager; then
    echo -e "${GREEN}✅ NetworkManager is active and ready for KDE${NC}"
    
    # Ensure KDE integration config exists
    sudo mkdir -p /etc/NetworkManager/conf.d
    if [ ! -f /etc/NetworkManager/conf.d/kde-integration.conf ]; then
        cat << EOF | sudo tee /etc/NetworkManager/conf.d/kde-integration.conf
[main]
plugins=keyfile
dhcp=internal

[keyfile]
unmanaged-devices=none

[device]
wifi.scan-rand-mac-address=yes
EOF
        echo -e "${GREEN}✅ NetworkManager KDE integration configured${NC}"
        # Reload NetworkManager to apply config
        sudo systemctl reload NetworkManager
    else
        echo -e "${GREEN}✅ NetworkManager KDE integration already configured${NC}"
    fi
else
    echo -e "${RED}❌ NetworkManager not active - network management may not work in KDE${NC}"
fi

# Add ucadmin to netdev group for network management (if not already)
if ! groups ucadmin | grep -q netdev; then
    sudo usermod -a -G netdev ucadmin
    echo -e "${GREEN}✅ Added ucadmin to netdev group${NC}"
else
    echo -e "${GREEN}✅ ucadmin already in netdev group${NC}"
fi

# Set up workspace shortcuts with proper ownership
if [ ! -f /home/ucadmin/.config/kglobalshortcutsrc ]; then
    cat << EOF > /home/ucadmin/.config/kglobalshortcutsrc
[kwin]
Overview=Meta+Tab,Meta+Tab,Toggle Overview
ShowDesktopGrid=Meta+F8,Meta+F8,Show Desktop Grid
Walk Through Windows=Alt+Tab,Alt+Tab,Walk Through Windows
EOF
    chown ucadmin:ucadmin /home/ucadmin/.config/kglobalshortcutsrc
    echo -e "${GREEN}✅ KDE shortcuts configured${NC}"
fi

# Configure Plymouth for better boot experience
print_section "Configuring Boot Experience"
if dpkg -l | grep -q plymouth; then
    sudo apt install -y plymouth-theme-breeze
    sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/breeze/breeze.plymouth 100
    sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/breeze/breeze.plymouth
    sudo update-initramfs -u
    echo -e "${GREEN}✅ Plymouth theme configured${NC}"
fi

# Create KDE-specific shortcuts for AI environment
print_section "Setting up AI Environment Integration"
if [ -d "/home/ucladmin/ai-env" ]; then
    # Create desktop shortcut for AI environment terminal
    cat << EOF > /home/ucadmin/Desktop/AI-Terminal.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=AI Development Terminal
Comment=Terminal with AI environment activated
Exec=konsole --hold -e bash -c "source ~/ai-env/bin/activate && echo '🦄 AI Environment Activated' && bash"
Icon=utilities-terminal
Terminal=false
Categories=Development;
EOF
    chmod +x /home/ucadmin/Desktop/AI-Terminal.desktop
    chown ucadmin:ucadmin /home/ucladmin/Desktop/AI-Terminal.desktop
    echo -e "${GREEN}✅ AI environment desktop shortcut created${NC}"
    
    # Create VS Code shortcut that uses AI environment
    cat << EOF > /home/ucadmin/Desktop/VS-Code-AI.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=VS Code (AI Environment)
Comment=VS Code with AI Python environment
Exec=bash -c "source ~/ai-env/bin/activate && code"
Icon=code
Terminal=false
Categories=Development;
EOF
    chmod +x /home/ucadmin/Desktop/VS-Code-AI.desktop
    chown ucadmin:ucadmin /home/ucladmin/Desktop/VS-Code-AI.desktop
    echo -e "${GREEN}✅ VS Code AI shortcut created${NC}"
fi

# Create UnicornCommander desktop shortcut
if [ -d "/home/ucadmin/UC-1/UC-1_Core" ] && [ -f "/home/ucadmin/UC-1/UC-1_Core/start.sh" ]; then
    cat << EOF > /home/ucadmin/Desktop/UnicornCommander.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=UnicornCommander
Comment=Start UnicornCommander stack
Exec=konsole --hold -e bash -c "cd ~/UC-1/UC-1_Core && ./start.sh"
Icon=applications-development
Terminal=false
Categories=Development;
EOF
    chmod +x /home/ucadmin/Desktop/UnicornCommander.desktop
    chown ucadmin:ucadmin /home/ucadmin/Desktop/UnicornCommander.desktop
    echo -e "${GREEN}✅ UnicornCommander desktop shortcut created${NC}"
fi

# Fix all file ownership in .config and Desktop
chown -R ucadmin:ucadmin /home/ucadmin/.config /home/ucadmin/Desktop 2>/dev/null || true

echo -e "${GREEN}🎉 KDE Desktop setup complete!${NC}"
echo -e "${BLUE}Desktop features installed:${NC}"
echo -e "  - KDE Plasma 6 with smart display server selection"
echo -e "  - Firefox ESR (non-Snap version)"
echo -e "  - Development tools (KDevelop, VS Code)"
echo -e "  - Productivity apps (LibreOffice, GIMP, etc.)"
echo -e "  - AMD 780M optimized compositor settings"
echo -e "  - AI environment integration"
echo -e "  - UnicornCommander desktop shortcuts"
echo -e ""
echo -e "${BLUE}Current configuration:${NC}"
echo -e "  - Display server: Wayland (KDE Plasma 6 default)"
echo -e "  - Ubuntu 25.04 + Kernel 6.14 native AMD support"
echo -e "  - Network: NetworkManager (cloud-init configured)"
echo -e ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  - Run 'uc-monitor' to check hardware status"
echo -e "  - Use desktop shortcuts for AI development"
echo -e "  - ${GREEN}System ready for use!${NC}"

# Provide reboot reminder if needed
if grep -q "memmap=1G" /etc/default/grub 2>/dev/null; then
    echo -e ""
    echo -e "${YELLOW}⚠️ REBOOT RECOMMENDED:${NC}"
    echo -e "  - NPU memory settings from hardware script need reboot to be active"
    echo -e "  - Run: ${GREEN}sudo reboot${NC}"
else
    echo -e ""
    echo -e "${GREEN}✅ System ready! You can start using KDE immediately${NC}"
    echo -e "  - Optional: Reboot for best performance"
fi
