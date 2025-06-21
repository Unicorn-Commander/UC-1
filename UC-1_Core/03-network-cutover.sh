#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander Network Management Transition${NC}"
echo -e "${BLUE}Transitioning to NetworkManager for KDE6 integration${NC}"
echo -e "${YELLOW}Ubuntu 25.04 | KDE Plasma 6 | Wayland${NC}"

# Ensure running as ucadmin with sudo
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️ Do not run with sudo. Run as: ./03-network-cutover.sh${NC}"
    exit 1
fi

if [ "$(whoami)" != "ucadmin" ]; then
    echo -e "${YELLOW}⚠️ Must be run as ucadmin user${NC}"
    exit 1
fi

if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Sudo privileges required${NC}"
    exit 1
fi

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check prerequisites
print_section "Checking Prerequisites"

# KDE6-specific check
if ! dpkg -l | grep -q "plasma-nm"; then
    echo -e "${RED}❌ KDE6 network management (plasma-nm) not installed${NC}"
    echo -e "${YELLOW}Run 02-kde_desktop_setup.sh first${NC}"
    exit 1
fi

# Network status check
print_section "Network Status Check"
NM_ACTIVE=$(systemctl is-active NetworkManager || true)
NETWORKD_ACTIVE=$(systemctl is-active systemd-networkd || true)

echo -e "${BLUE}NetworkManager: $NM_ACTIVE"
echo -e "systemd-networkd: $NETWORKD_ACTIVE${NC}"

# Backup current network configuration
print_section "Backing Up Network Configuration"
BACKUP_DIR="/home/ucadmin/network-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup netplan configs
if [ -d /etc/netplan ]; then
    sudo cp -r /etc/netplan "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Netplan configuration backed up${NC}"
fi

# Save current network state
ip addr show > "$BACKUP_DIR/ip-addresses.txt"
ip route show > "$BACKUP_DIR/ip-routes.txt"
ip -6 route show > "$BACKUP_DIR/ip6-routes.txt" 2>/dev/null || true
sudo cp /etc/resolv.conf "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/machine-id "$BACKUP_DIR/" 2>/dev/null || true

echo -e "${GREEN}✅ Network configuration backed up to: $BACKUP_DIR${NC}"

# Ensure unique machine-id (prevents DHCP conflicts)
print_section "Verifying Machine ID"
CURRENT_MACHINE_ID=$(cat /etc/machine-id 2>/dev/null || echo "none")
if [ "$CURRENT_MACHINE_ID" = "b08dfa6083e7567a1921a715000001fb" ] || [ ! -s /etc/machine-id ]; then
    echo -e "${BLUE}Generating unique machine-id...${NC}"
    sudo rm -f /etc/machine-id /var/lib/dbus/machine-id
    sudo systemd-machine-id-setup
    sudo ln -sf /etc/machine-id /var/lib/dbus/machine-id
    echo -e "${GREEN}✅ Unique machine-id generated${NC}"
else
    echo -e "${GREEN}✅ Machine-id is already unique${NC}"
fi

# Create NetworkManager configuration
print_section "Configuring NetworkManager"
sudo mkdir -p /etc/NetworkManager/conf.d

# KDE6/Wayland compatible configuration
cat << 'EOF' | sudo tee /etc/NetworkManager/conf.d/10-uc-settings.conf >/dev/null
[main]
plugins=keyfile
dhcp=internal
dns=systemd-resolved

[connection]
dhcp-client-id=stable
ipv6.dhcp-duid=ll
ipv6.dhcp-iaid=mac

[keyfile]
unmanaged-devices=none

[device-managed]
match-device=interface-name:eth*,enp*,eno*,ens*
managed=true

[device]
wifi.scan-rand-mac-address=yes
wifi.backend=iwd

[logging]
level=WARN
EOF

echo -e "${GREEN}✅ NetworkManager configuration created${NC}"

# Disable cloud-init network management
if [ -d /etc/cloud ]; then
    echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg >/dev/null
    echo -e "${GREEN}✅ Cloud-init network management disabled${NC}"
fi

# Prepare new netplan configuration
print_section "Preparing Netplan for NetworkManager"

# Find and backup existing netplan files
NETPLAN_DIR="/etc/netplan"
if [ -d "$NETPLAN_DIR" ]; then
    # Remove systemd-networkd configs
    for file in "$NETPLAN_DIR"/*.yaml; do
        if [ -f "$file" ]; then
            if grep -q "renderer.*networkd\|systemd-networkd" "$file" 2>/dev/null; then
                echo -e "${BLUE}Removing networkd config: $(basename "$file")${NC}"
                sudo mv "$file" "$BACKUP_DIR/$(basename "$file").networkd"
            fi
        fi
    done
fi

# Create NetworkManager netplan with explicit interface handling
cat << 'EOF' | sudo tee /etc/netplan/01-network-manager-all.yaml >/dev/null
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    # Explicitly declare common ethernet interface patterns
    eth0: {}
    eth1: {}
    eno1: {}
    eno2: {}
    enp1s0: {}
    enp2s0: {}
    enp3s0: {}
    enp4s0: {}
    ens1: {}
    ens2: {}
EOF

sudo chmod 600 /etc/netplan/01-network-manager-all.yaml
echo -e "${GREEN}✅ Netplan configuration prepared${NC}"

# Transition warning
print_section "Ready to Transition"
echo -e "${YELLOW}⚠️ Network Transition Warning${NC}"
echo -e "${BLUE}This will:${NC}"
echo -e "  1. Stop systemd-networkd"
echo -e "  2. Apply new netplan configuration"  
echo -e "  3. Start NetworkManager"
echo -e "  4. May briefly interrupt network connectivity"
echo -e ""
echo -e "${BLUE}Backup location: $BACKUP_DIR${NC}"
echo -e ""
read -p "Proceed with network transition? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Transition cancelled${NC}"
    exit 0
fi

# Perform the transition
print_section "Performing Network Transition"

# Stop systemd-networkd
if [ "$NETWORKD_ACTIVE" = "active" ]; then
    echo -e "${BLUE}Stopping systemd-networkd...${NC}"
    sudo systemctl stop systemd-networkd
    sudo systemctl disable systemd-networkd
fi

# Apply netplan
echo -e "${BLUE}Applying netplan configuration...${NC}"
sudo netplan generate
sudo netplan apply

# Start NetworkManager
if [ "$NM_ACTIVE" != "active" ]; then
    echo -e "${BLUE}Enabling NetworkManager...${NC}"
    sudo systemctl enable --now NetworkManager
else
    echo -e "${BLUE}Restarting NetworkManager...${NC}"
    sudo systemctl restart NetworkManager
fi

# Explicitly manage all interfaces
print_section "Forcing Interface Management"
for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -E '^eth|^enp|^eno|^ens'); do
    echo -e "${BLUE}Managing interface: $iface${NC}"
    sudo nmcli dev set "$iface" managed yes
done

# Give NetworkManager time to establish connections
echo -e "${BLUE}Waiting for network to stabilize...${NC}"
for i in {1..10}; do
    echo -n "."
    sleep 1
done
echo

# Verify the transition
print_section "Verifying Transition"

if systemctl is-active --quiet NetworkManager; then
    echo -e "${GREEN}✅ NetworkManager is active${NC}"
else
    echo -e "${RED}❌ NetworkManager failed to start${NC}"
    echo -e "${YELLOW}Check logs: sudo journalctl -xe -u NetworkManager${NC}"
fi

# Check network connectivity
echo -e "${BLUE}Current network status:${NC}"
ip -br a

# Check interface management status
echo -e "${BLUE}NetworkManager device status:${NC}"
nmcli device status

# Test connectivity with multiple endpoints
test_connectivity() {
    echo -e "${BLUE}Testing connectivity to multiple endpoints...${NC}"
    success=false
    
    endpoints=(
        "8.8.8.8" 
        "1.1.1.1" 
        "www.google.com" 
        "www.cloudflare.com"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if ping -c 1 -W 2 "$endpoint" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Reachable: $endpoint${NC}"
            success=true
            break
        else
            echo -e "${YELLOW}⚠️ Unreachable: $endpoint${NC}"
        fi
    done
    
    if [ "$success" = false ]; then
        echo -e "${YELLOW}⚠️ Internet connectivity not verified${NC}"
        echo -e "${BLUE}This might be temporary while NetworkManager establishes connections${NC}"
        echo -e "${BLUE}Check network settings in KDE Plasma System Settings → Connections${NC}"
    else
        echo -e "${GREEN}✅ Internet connectivity verified${NC}"
    fi
}

test_connectivity

# Clean up systemd-networkd if transition successful
if systemctl is-active --quiet NetworkManager; then
    echo -e "${BLUE}Disabling systemd-networkd...${NC}"
    sudo systemctl disable systemd-networkd 2>/dev/null || true
    sudo systemctl stop systemd-networkd 2>/dev/null || true
    echo -e "${GREEN}✅ systemd-networkd disabled${NC}"
fi

# Create comprehensive rollback script
print_section "Creating Rollback Script"
cat << EOF > "$BACKUP_DIR/rollback-network.sh"
#!/bin/bash
# Network configuration rollback script
echo -e "\033[0;35m🦄 UnicornCommander Network Rollback\033[0m"
echo -e "\033[0;34mRestoring network configuration from backup...\033[0m"

# Restore netplan files
sudo rm -f /etc/netplan/*.yaml
sudo cp -r "$BACKUP_DIR/netplan"/* /etc/netplan/ 2>/dev/null || true

# Restore critical network files
sudo cp "$BACKUP_DIR/resolv.conf" /etc/resolv.conf 2>/dev/null || true
sudo cp "$BACKUP_DIR/machine-id" /etc/machine-id 2>/dev/null || true

# Re-enable systemd-networkd
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd

# Disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

# Apply netplan
sudo netplan apply

echo -e "\033[0;32m✅ Rollback complete\033[0m"
echo -e "\033[0;34mNetwork should be restored to previous state. Reboot recommended.\033[0m"
EOF

chmod +x "$BACKUP_DIR/rollback-network.sh"
echo -e "${GREEN}✅ Rollback script created: $BACKUP_DIR/rollback-network.sh${NC}"

# Final summary
print_section "Network Transition Complete"

echo -e "${GREEN}🎉 Network management transition completed!${NC}"
echo -e ""
echo -e "${BLUE}Summary:${NC}"
echo -e "  - NetworkManager is now managing network connections"
echo -e "  - KDE Plasma 6 network widget should now work"
echo -e "  - Network configuration backed up to: $BACKUP_DIR"
echo -e ""
echo -e "${BLUE}If KDE still doesn't show interfaces:${NC}"
echo -e "  1. Open KDE System Settings → Connections"
echo -e "  2. Check if interfaces appear under 'Available Connections'"
echo -e "  3. If not visible, try restarting Plasma:"
echo -e "     ${GREEN}plasmashell --replace &>/dev/null & disown${NC}"
echo -e "  4. Alternatively, log out and back in"
echo -e ""
echo -e "${BLUE}Diagnostic commands:${NC}"
echo -e "  - NetworkManager status: ${GREEN}systemctl status NetworkManager${NC}"
echo -e "  - Interface details: ${GREEN}nmcli device show${NC}"
echo -e "  - Connection list: ${GREEN}nmcli connection show${NC}"
echo -e "  - KDE version: ${GREEN}plasmashell --version${NC}"
echo -e "  - Qt version: ${GREEN}qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.version${NC}"
echo -e ""

# Update system status
echo "network_migrated_to_nm=$(date)" >> /home/ucadmin/.uc1-prep-status

echo -e "${GREEN}✅ Script completed successfully!${NC}"
