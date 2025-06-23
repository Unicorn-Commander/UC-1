#!/bin/bash
# UC-1 Network Cutover Script for KDE6/Wayland
# Ubuntu Server 25.04 → KDE Plasma Desktop with NetworkManager
# Features: Clone prevention, KDE6 integration, Wayland support
set -e

# Arguments handling
NO_CLONE=false
for arg in "$@"; do
    case "$arg" in
        --no-clone) NO_CLONE=true ;;
        *) echo "Unknown option: $arg" && exit 1 ;;
    esac
done

# Output colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${PURPLE}🦄 UC-1 Network Transition${NC}"
echo -e "${BLUE}Ubuntu 25.04 | KDE6 Plasma | Wayland | AMD 8945HS${NC}"
echo -e "${BLUE}Clone Prevention: ${GREEN}$([ "$NO_CLONE" = true ] && echo "DISABLED" || echo "ENABLED")${NC}"

# Check user and sudo
[ "$EUID" -eq 0 ] && echo -e "${YELLOW}⚠️ Run as user: ./network-cutover.sh${NC}" && exit 1
[ "$(whoami)" != "ucadmin" ] && echo -e "${YELLOW}⚠️ Run as ucadmin${NC}" && exit 1
! sudo -n true 2>/dev/null && echo -e "${YELLOW}⚠️ Sudo required${NC}" && exit 1

print_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

# Pre-flight check
print_section "Pre-flight Check"
echo "Detected Interfaces: $(ip -o link show | awk -F': ' '{print $2}' | grep -E 'eno1|enp3s0|wlan0' | xargs)"
echo "Current Hostname: $(hostname)"
echo "Current Primary IP: $(hostname -I | awk '{print $1}')"
echo -e "${YELLOW}This will reset ALL network connections${NC}"
read -p "Continue? (y/N) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# Install critical dependencies
print_section "Installing Dependencies"
sudo apt install -y network-manager plasma-nm iwd kdeplasma-addons kio-extras qdbus-qt5
echo -e "${GREEN}✅ Network components installed${NC}"

# Comprehensive backup
print_section "Creating Backup"
BACKUP_DIR="/home/ucadmin/network-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup all configurations
sudo cp -r /etc/netplan "$BACKUP_DIR/" 2>/dev/null || true
sudo cp -r /etc/NetworkManager "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/hostname "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/hosts "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/machine-id "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /var/lib/dbus/machine-id "$BACKUP_DIR/" 2>/dev/null || true
nmcli con show > "$BACKUP_DIR/connections.txt"
echo -e "${GREEN}✅ Backup saved: $BACKUP_DIR${NC}"

# Clone prevention (skip if --no-clone specified)
if [ "$NO_CLONE" = false ]; then
    print_section "Clone Prevention Configuration"
    
    # Generate unique hostname based on MAC
    PRIMARY_MAC=$(ip link show eno1 | awk '/ether/ {print $2}' | tr -d ':')
    UNIQUE_SUFFIX=$(echo "$PRIMARY_MAC" | tail -c 6)
    NEW_HOSTNAME="UC-1-${UNIQUE_SUFFIX}"
    
    # Update hostname
    echo "Generating unique hostname: $NEW_HOSTNAME"
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"
    sudo sed -i "s/127.0.0.1.*/127.0.0.1\tlocalhost $NEW_HOSTNAME/" /etc/hosts
    echo "$NEW_HOSTNAME" | sudo tee /etc/hostname >/dev/null
    
    # Generate new machine IDs
    echo "Generating new machine IDs..."
    sudo rm -f /etc/machine-id /var/lib/dbus/machine-id
    sudo systemd-machine-id-setup
    sudo dbus-uuidgen --ensure
    
    # Wipe existing WiFi configurations
    echo "Removing saved WiFi profiles..."
    nmcli -t -f UUID con show | while read -r uuid; do
        if nmcli -t -f connection.type con show "$uuid" | grep -q wireless; then
            nmcli con delete "$uuid"
        fi
    done
    
    echo -e "${GREEN}✅ Clone prevention configured${NC}"
fi

# Clean up ALL existing connections
print_section "Cleaning Network Configurations"
echo "Removing existing connections..."

# Remove all connections except Docker-related
nmcli -t -f UUID con show | while read -r uuid; do
    con_name=$(nmcli -t -f connection.id con show "$uuid")
    if [[ ! "$con_name" =~ docker|veth|br- ]]; then
        echo "  Removing: $con_name"
        sudo nmcli con delete "$uuid" 2>/dev/null || true
    fi
done

# Clean up old netplan files
sudo rm -f /etc/netplan/90-NM-*.yaml
sudo rm -f /etc/netplan/01-network-manager.yaml
sudo rm -f /etc/netplan/50-cloud-init.yaml
echo -e "${GREEN}✅ Cleaned up old configurations${NC}"

# Configure NetworkManager
print_section "NetworkManager Configuration"
sudo tee /etc/NetworkManager/conf.d/10-uc1-kde6.conf >/dev/null <<'EOF'
[main]
plugins=keyfile
dhcp=internal
no-auto-default=*
wifi.backend=iwd

[device]
# Managed devices
managed=true
# Exclude Docker interfaces
match-device=type:ethernet,!interface-name:veth*,!interface-name:docker*,!interface-name:br-*

[connection]
# Unique connection IDs
connection.stable-id=${CONNECTION}-${MAC}
# Clone prevention
ipv4.dhcp-client-id=mac
ipv6.dhcp-duid=ll
ipv4.dhcp-hostname=${HOSTNAME}
ipv4.dhcp-send-hostname=true

[keyfile]
# Enable KDE access
unmanaged-devices=none

[logging]
level=INFO
EOF

# Create minimal netplan for NetworkManager
print_section "Creating Netplan Configuration"
sudo tee /etc/netplan/01-network-manager.yaml >/dev/null <<'EOF'
network:
  version: 2
  renderer: NetworkManager
EOF

# Disable conflicting services
print_section "Disabling Conflicting Services"
sudo systemctl stop systemd-networkd || true
sudo systemctl disable systemd-networkd || true
sudo systemctl mask systemd-networkd || true
sudo systemctl enable NetworkManager iwd

# Apply configuration
print_section "Applying Network Configuration"
echo -e "${YELLOW}⚠️ Network will restart - may lose connectivity briefly${NC}"
if [ -n "$SSH_CONNECTION" ]; then
    echo -e "${YELLOW}    SSH session detected - may need to reconnect${NC}"
    sleep 10
fi

sudo netplan generate
sudo netplan apply
sudo systemctl restart NetworkManager

# Wait for NetworkManager
print_section "Waiting for NetworkManager"
for i in {1..15}; do 
    if nmcli general status >/dev/null 2>&1; then
        echo -e "${GREEN}✅ NetworkManager ready${NC}"
        break
    fi
    sleep 1
    echo -n "."
done
echo

# Create connections with unique identifiers
print_section "Creating Network Connections"

create_connection() {
    local iface=$1
    local conn_name=$2
    local priority=$3
    local extra_args=$4
    
    echo "Creating $conn_name for $iface..."
    local mac_addr=$(ip link show $iface | awk '/ether/ {print $2}')
    
    sudo nmcli con add type ethernet ifname $iface con-name "$conn_name" \
        connection.autoconnect yes \
        connection.autoconnect-priority $priority \
        ipv4.method auto \
        ipv4.dhcp-client-id "mac" \
        ipv4.dhcp-hostname "$(hostname)" \
        ipv6.method auto \
        $extra_args 2>/dev/null || true
}

# Primary connection
create_connection eno1 "UC-1 Primary" 100 ""

# Secondary connection (no default route)
create_connection enp3s0 "UC-1 Secondary" 50 "ipv4.never-default yes ipv4.route-metric 200"

# WiFi connection
if ip link show wlan0 >/dev/null 2>&1; then
    echo "Creating WiFi connection template..."
    sudo nmcli con add type wifi ifname wlan0 con-name "UC-1 WiFi" ssid "placeholder" \
        connection.autoconnect no \
        wifi.hidden no \
        ipv4.method auto \
        ipv4.dhcp-hostname "$(hostname)-wifi" \
        ipv6.method auto 2>/dev/null || true
fi

# Activate primary connection
print_section "Activating Primary Network"
sudo nmcli con up "UC-1 Primary" || echo -e "${YELLOW}⚠️ Primary activation failed - may need manual setup${NC}"

# KDE6/Wayland specific configuration
print_section "Configuring KDE6 Integration"

# Create KDE configs
mkdir -p ~/.config/plasma-nm
cat > ~/.config/plasma-nm/plasma-nm.conf <<'EOF'
[General]
ShowConnectionDetails=true
ShowAddressDetails=true
ShowTrafficDetails=true
ShowWifiSignalStrength=true

[Notifications]
FilterUnmanagedDevices=true
EOF

# Configure Wayland environment
sudo tee /etc/environment.d/90kde-wayland.conf >/dev/null <<'EOF'
QT_QPA_PLATFORM=wayland
KWIN_COMPOSE=O2
EOF

# Refresh KDE services
print_section "Refreshing KDE Services"
if pgrep plasmashell >/dev/null; then
    # Rebuild system configuration cache
    kbuildsycoca6 2>/dev/null || true
    
    # Reload network module
    qdbus org.kde.kded6 /kded org.kde.kded6.loadModule networkmanagement 2>/dev/null || true
    
    # Restart network applet
    pkill plasma-nm || true
    kstart plasmashell >/dev/null 2>&1 &
    echo -e "${GREEN}✅ KDE network services refreshed${NC}"
else
    echo -e "${YELLOW}⚠️ KDE not running - restart desktop for full integration${NC}"
fi

# Verification
print_section "Network Status Verification"

# Check for duplicate IPs
echo -e "${BLUE}Checking for duplicate IPs:${NC}"
ip -4 addr | grep inet | awk '{print $2}' | sort | uniq -d | while read ip; do
    echo -e "${RED}⚠️ DUPLICATE IP DETECTED: $ip${NC}"
    echo "  Associated interfaces:"
    ip -o addr show | grep "$ip" | awk '{print "    - " $2}'
done

# Connection status
echo -e "\n${BLUE}Active Connections:${NC}"
nmcli -t -f NAME,DEVICE,STATE con show --active | column -t -s ':'

# Device status
echo -e "\n${BLUE}Device Status:${NC}"
nmcli -t -f DEVICE,TYPE,STATE dev | grep -E "eno1|enp3s0|wlan0" | column -t -s ':'

# Create rollback script
print_section "Creating Rollback Script"
cat <<ROLLBACK | sudo tee "$BACKUP_DIR/rollback.sh" >/dev/null
#!/bin/bash
# UC-1 Network Rollback Script
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${YELLOW}⚠️ Starting network rollback...${NC}"
echo "Restoring from: $BACKUP_DIR"

# Restore critical files
sudo cp -f "$BACKUP_DIR/hostname" /etc/hostname 2>/dev/null || true
sudo cp -f "$BACKUP_DIR/hosts" /etc/hosts 2>/dev/null || true
sudo cp -f "$BACKUP_DIR/machine-id" /etc/machine-id 2>/dev/null || true
sudo cp -f "$BACKUP_DIR/machine-id" /var/lib/dbus/machine-id 2>/dev/null || true

# Restore configurations
sudo rm -rf /etc/netplan/*
sudo cp -r "$BACKUP_DIR/netplan"/* /etc/netplan/ 2>/dev/null || true

sudo rm -rf /etc/NetworkManager/*
sudo cp -r "$BACKUP_DIR/NetworkManager"/* /etc/NetworkManager/ 2>/dev/null || true

# Restart services
sudo systemctl unmask systemd-networkd
sudo systemctl enable systemd-networkd
sudo systemctl stop NetworkManager
sudo netplan apply
sudo systemctl restart systemd-networkd

echo -e "${GREEN}✅ Network configuration restored${NC}"
echo "Original hostname: $(cat "$BACKUP_DIR/hostname" 2>/dev/null || echo 'unknown')"
echo "Reboot recommended for full restoration"
ROLLBACK

sudo chmod +x "$BACKUP_DIR/rollback.sh"

# Final summary
print_section "Setup Complete! 🎉"
echo -e "${GREEN}✅ Network cutover successful${NC}"
echo -e "${BLUE}Hostname:${NC} $(hostname)"
echo -e "${BLUE}Primary IP:${NC} $(hostname -I | awk '{print $1}')"
echo
echo -e "${BLUE}KDE Network Management:${NC}"
echo "1. Click the network icon in system tray"
echo "2. Or go to System Settings → Connections"
echo "3. For WiFi: Edit 'UC-1 WiFi' and set your SSID/password"
echo
echo -e "${YELLOW}To activate secondary ethernet:${NC}"
echo "nmcli con up 'UC-1 Secondary'"
echo
echo -e "${YELLOW}If problems occur:${NC}"
echo "sudo $BACKUP_DIR/rollback.sh"
echo
echo -e "${GREEN}UniFi controller should now see:${NC}"
echo "• $(hostname) (primary)"
echo "• $(hostname)-port2 (secondary when activated)"
echo "• $(hostname)-wifi (WiFi when connected)"
echo
echo -e "${PURPLE}Reboot recommended for full KDE/Wayland integration${NC}"
