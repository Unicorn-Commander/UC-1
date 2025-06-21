#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander KDE Desktop Setup${NC}"
echo -e "${BLUE}Installing KDE Plasma 6 with AMD 780M iGPU optimizations...${NC}"

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

# Check if hardware setup was completed (optional check)
print_section "Checking Prerequisites"
if [ ! -f "/usr/local/bin/uc-monitor" ]; then
    echo -e "${YELLOW}⚠️ Hardware setup not detected (01-hardware_ai_setup.sh not run)${NC}"
    echo -e "${BLUE}This script can run independently but you may want to run hardware setup later${NC}"
    echo -e "${BLUE}Continuing with KDE desktop installation...${NC}"
else
    echo -e "${GREEN}✅ Hardware setup detected - full UC-1 integration available${NC}"
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

# Install additional KDE applications including archive support
print_section "Installing KDE Applications & Archive Support"
sudo apt install -y \
    kdevelop \
    kwrite \
    kfind \
    plasma-systemmonitor \
    kinfocenter \
    kcharselect \
    kruler \
    kcolorchooser \
    filelight \
    p7zip-full \
    p7zip-rar \
    unzip \
    zip \
    unrar \
    arj \
    lhasa

# Note: ark (already installed above) is the main KDE archive manager for KDE6
# It supports .zip, .tar, .7z, .rar and most formats when the above tools are installed
echo -e "${GREEN}✅ Archive support installed - Ark can handle .zip, .7z, .rar, .tar files${NC}"

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

# Set up workspace shortcuts with proper ownership
print_section "Configuring KDE Shortcuts"
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
if [ -d "/home/ucadmin/ai-env" ]; then
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
    chown ucadmin:ucadmin /home/ucadmin/Desktop/AI-Terminal.desktop
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
    chown ucadmin:ucadmin /home/ucadmin/Desktop/VS-Code-AI.desktop
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

# NETWORK CONFIGURATION - MOVED TO END TO AVOID MID-SCRIPT FAILURES
print_section "Preparing Network Management Configuration (Pre-Setup)"
echo -e "${BLUE}Installing NetworkManager and KDE integration packages...${NC}"

# Install NetworkManager packages but don't activate yet
sudo apt install -y network-manager plasma-nm network-manager-openvpn network-manager-vpnc

# Add ucadmin to netdev group for network management
if ! groups ucadmin | grep -q netdev; then
    sudo usermod -a -G netdev ucadmin
    echo -e "${GREEN}✅ Added ucadmin to netdev group${NC}"
else
    echo -e "${GREEN}✅ ucadmin already in netdev group${NC}"
fi

# Prepare NetworkManager configuration files (but don't apply yet)
print_section "Preparing NetworkManager Configuration Files"
sudo mkdir -p /etc/NetworkManager/conf.d

# Create NetworkManager configuration for stable DHCP behavior
if [ ! -f /etc/NetworkManager/conf.d/kde-integration.conf ]; then
    cat << 'EOF' | sudo tee /etc/NetworkManager/conf.d/kde-integration.conf
[main]
plugins=keyfile
dhcp=internal
dns=default

[connection]
# Use stable connection-specific DHCP client identifier
dhcp-client-id=stable

[keyfile]
unmanaged-devices=none

[device]
wifi.scan-rand-mac-address=yes
EOF
    echo -e "${GREEN}✅ NetworkManager configuration prepared${NC}"
else
    echo -e "${GREEN}✅ NetworkManager already configured${NC}"
fi

# Disable cloud-init network management
if [ ! -f /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg ]; then
    echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    echo -e "${GREEN}✅ Cloud-init network management disabled${NC}"
fi

# Ensure unique machine-id for DHCP uniqueness
print_section "Ensuring Unique Machine ID for DHCP"
if [ ! -s /etc/machine-id ] || [ "$(cat /etc/machine-id)" = "b08dfa6083e7567a1921a715000001fb" ]; then
    echo -e "${BLUE}Generating unique machine-id to prevent DHCP conflicts...${NC}"
    sudo rm -f /etc/machine-id /var/lib/dbus/machine-id
    sudo systemd-machine-id-setup
    sudo ln -sf /etc/machine-id /var/lib/dbus/machine-id
    echo -e "${GREEN}✅ Unique machine-id generated: $(cat /etc/machine-id | cut -c1-8)...${NC}"
else
    echo -e "${GREEN}✅ Machine-id already unique: $(cat /etc/machine-id | cut -c1-8)...${NC}"
fi

echo -e "${GREEN}🎉 KDE Desktop setup complete!${NC}"
echo -e "${BLUE}Desktop features installed:${NC}"
echo -e "  - KDE Plasma 6 with smart display server selection"
echo -e "  - Firefox ESR (non-Snap version)"
echo -e "  - Development tools (KDevelop, VS Code)"
echo -e "  - Archive support (Ark with .zip, .7z, .rar, .tar support)"
echo -e "  - Productivity apps (LibreOffice, GIMP, etc.)"
echo -e "  - AMD 780M optimized compositor settings"
echo -e "  - AI environment integration"
echo -e "  - UnicornCommander desktop shortcuts"
echo -e ""
echo -e "${BLUE}Archive file support:${NC}"
echo -e "  - Ark archive manager (default KDE6 app)"
echo -e "  - Supports: .zip, .7z, .rar, .tar, .gz, .bz2, .xz files"
echo -e "  - Right-click any archive → 'Extract Here'"
echo -e "  - Create archives: Select files → Right-click → 'Compress'"
echo -e ""
echo -e "${BLUE}Network configuration:${NC}"
echo -e "  - NetworkManager packages installed"
echo -e "  - Configuration files prepared"
echo -e "  - Unique machine-id configured"
echo -e "  - ${YELLOW}Network cutover will happen during reboot${NC}"
echo -e ""
echo -e "${BLUE}Current configuration:${NC}"
echo -e "  - Display server: Wayland (KDE Plasma 6 default)"
echo -e "  - Ubuntu 25.04 + Kernel 6.14 native AMD support"
echo -e "  - Network: Current network maintained until reboot"
echo -e ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  - Run 'uc-monitor' to check hardware status"
echo -e "  - Use desktop shortcuts for AI development"
echo -e "  - Test archive support with any .zip file"
echo -e "  - ${GREEN}System ready for use!${NC}"

# Network cutover instructions
echo -e ""
echo -e "${YELLOW}📡 NETWORK CUTOVER ON REBOOT:${NC}"
echo -e "  - Current network configuration will remain active"
echo -e "  - After reboot, NetworkManager will take over automatically"
echo -e "  - No network interruption during script execution"
echo -e "  - KDE network widget will be fully functional after reboot"
echo -e ""
echo -e "${YELLOW}⚠️ REBOOT REQUIRED FOR FULL FUNCTIONALITY:${NC}"
echo -e "  - Network management transition (systemd-networkd → NetworkManager)"
echo -e "  - NPU memory settings from hardware script"
echo -e "  - KDE desktop environment activation"
echo -e "  - Run: ${GREEN}sudo reboot${NC}"
echo -e ""
echo -e "${GREEN}✅ Script completed successfully - no network interruptions!${NC}"

# Create a post-reboot network cutover script that will run automatically
print_section "Creating Post-Reboot Network Transition Script"
cat << 'EOF' | sudo tee /usr/local/bin/uc-network-cutover.sh
#!/bin/bash
# UnicornCommander Network Cutover Script
# Runs once after reboot to complete NetworkManager transition

LOGFILE="/var/log/uc-network-cutover.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "$(date): Starting NetworkManager cutover..."

# Check if we need to do the cutover
if systemctl is-active --quiet NetworkManager && [ -f /etc/netplan/00-installer-config.yaml ]; then
    echo "$(date): NetworkManager already active with proper netplan"
    exit 0
fi

# Stop systemd-networkd if active
if systemctl is-active --quiet systemd-networkd; then
    echo "$(date): Stopping systemd-networkd..."
    systemctl stop systemd-networkd
    systemctl disable systemd-networkd
fi

# Remove conflicting netplan configs
find /etc/netplan -name "*.yaml" -type f 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
        if grep -q "systemd-networkd\|networkd\|renderer.*networkd" "$file" 2>/dev/null; then
            echo "$(date): Backing up conflicting netplan config: $file"
            mv "$file" "$file.backup-$(date +%s)"
        elif [ "$(basename "$file")" = "50-cloud-init.yaml" ]; then
            echo "$(date): Removing cloud-init netplan config: $file"
            mv "$file" "$file.backup-$(date +%s)"
        fi
    fi
done

# Create clean NetworkManager netplan configuration
if [ ! -f /etc/netplan/00-installer-config.yaml ]; then
    echo "$(date): Creating clean NetworkManager netplan configuration..."
    cat << 'NETPLAN_EOF' > /etc/netplan/00-installer-config.yaml
network:
  version: 2
  renderer: NetworkManager
NETPLAN_EOF
    chmod 600 /etc/netplan/00-installer-config.yaml
fi

# Apply netplan and start NetworkManager
netplan apply
systemctl enable NetworkManager
systemctl start NetworkManager

echo "$(date): NetworkManager cutover completed successfully"

# Remove this script from autostart since it only needs to run once
systemctl disable uc-network-cutover.service
rm -f /etc/systemd/system/uc-network-cutover.service

echo "$(date): Network cutover service disabled - transition complete"
EOF

chmod +x /usr/local/bin/uc-network-cutover.sh

# Create systemd service to run the cutover script once after boot
cat << 'EOF' | sudo tee /etc/systemd/system/uc-network-cutover.service
[Unit]
Description=UnicornCommander Network Cutover
After=multi-user.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/uc-network-cutover.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable uc-network-cutover.service
echo -e "${GREEN}✅ Post-reboot network cutover service configured${NC}"
echo -e "${BLUE}The network transition will complete automatically after reboot${NC}"
