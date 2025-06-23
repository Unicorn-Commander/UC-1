#!/bin/bash
set -e

# Output colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${PURPLE}🦄 UC-1 Network Transition${NC}"
echo -e "${BLUE}Ubuntu 25.04 | KDE6 | Wayland | AMD 8945HS${NC}"
echo -e "${BLUE}Detected: eno1, enp3s0 (Intel igc), wlan0 (Intel WiFi)${NC}"

# Check user and sudo
[ "$EUID" -eq 0 ] && echo -e "${YELLOW}⚠️ Run as user: ./uc1-network-cutover.sh${NC}" && exit 1
[ "$(whoami)" != "ucadmin" ] && echo -e "${YELLOW}⚠️ Run as ucadmin${NC}" && exit 1
! sudo -n true 2>/dev/null && echo -e "${YELLOW}⚠️ Sudo required${NC}" && exit 1

print_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

# Pre-flight check
print_section "Pre-flight Check"
echo "Current primary connection: $(nmcli -g GENERAL.CONNECTION dev show eno1)"
echo "Current IP: $(ip -4 addr show eno1 | grep inet | awk '{print $2}')"
echo -e "${YELLOW}This script will reset ALL network connections.${NC}"
read -p "Continue? (y/N) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# Install critical dependencies
print_section "Installing Dependencies"
sudo apt install -y network-manager plasma-nm iwd uuid-runtime ethtool
echo -e "${GREEN}✅ Network components installed${NC}"

# Comprehensive backup
print_section "Creating Comprehensive Backup"
BACKUP_DIR="/home/ucadmin/network-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup all network configurations
sudo cp -r /etc/netplan "$BACKUP_DIR/" 2>/dev/null || true
sudo cp -r /etc/NetworkManager "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/hostname "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/hosts "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/machine-id "$BACKUP_DIR/" 2>/dev/null || true

# Save current network state
nmcli con show > "$BACKUP_DIR/connections.txt"
ip addr show > "$BACKUP_DIR/ip_addresses.txt"
echo -e "${GREEN}✅ Backup saved: $BACKUP_DIR${NC}"

# Clean up ALL existing connections
print_section "Cleaning ALL Network Connections"
echo "Removing orphaned connections..."

# Remove all wired connections first
for uuid in $(nmcli -t -f UUID,TYPE con show | grep "802-3-ethernet" | cut -d: -f1); do
    name=$(nmcli -g connection.id con show "$uuid" 2>/dev/null || echo "unknown")
    echo "  Removing: $name"
    sudo nmcli con delete "$uuid" 2>/dev/null || true
done

# Remove wireless connections
for uuid in $(nmcli -t -f UUID,TYPE con show | grep "802-11-wireless" | cut -d: -f1); do
    name=$(nmcli -g connection.id con show "$uuid" 2>/dev/null || echo "unknown")
    echo "  Removing: $name"
    sudo nmcli con delete "$uuid" 2>/dev/null || true
done

# Clean up old netplan files (but keep docker ones)
print_section "Cleaning Netplan Configuration"
sudo rm -f /etc/netplan/90-NM-*.yaml
sudo rm -f /etc/netplan/01-network-manager.yaml
sudo rm -f /etc/netplan/50-cloud-init.yaml
echo -e "${GREEN}✅ Cleaned up old configurations${NC}"

# Configure DHCP client for UniFi compatibility
print_section "Configuring DHCP for UniFi Network"
sudo tee /etc/NetworkManager/conf.d/00-dhcp-unifi.conf >/dev/null <<EOF
[main]
# Use internal DHCP client for better control
dhcp=internal

[connection]
# Each connection gets unique DHCP client ID based on MAC
ipv4.dhcp-client-id=mac
ipv6.dhcp-duid=ll

[ipv4]
# Send hostname to DHCP server
dhcp-send-hostname=true
EOF

# Configure NetworkManager
print_section "NetworkManager Configuration"
sudo tee /etc/NetworkManager/conf.d/10-uc1.conf >/dev/null <<EOF
[main]
plugins=keyfile
# Prevent automatic connection creation
no-auto-default=*
# Use iwd for WiFi if available
wifi.backend=iwd

[keyfile]
# Don't ignore any devices
unmanaged-devices=none

[device]
# All interfaces are managed
managed=true
# But don't touch Docker interfaces
match-device=type:ethernet,!interface-name:veth*,!interface-name:docker*,!interface-name:br-*

[connection]
# Stable connection IDs
connection.stable-id=\${DEVICE}
# Lower priority for auto-created connections
connection.autoconnect-priority=-999

[connectivity]
# Disable connectivity checking
enabled=false

[logging]
# Useful for debugging
level=INFO
EOF

# Create minimal netplan for NetworkManager
print_section "Creating Netplan Configuration"
sudo tee /etc/netplan/01-network-manager.yaml >/dev/null <<EOF
# UC-1 Network Configuration
# Generated: $(date)
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    eno1:
      dhcp4: true
      dhcp-identifier: mac
      optional: true
      dhcp4-overrides:
        hostname: UC-1
    enp3s0:
      dhcp4: true
      dhcp-identifier: mac
      optional: true
      dhcp4-overrides:
        hostname: UC-1-secondary
        use-routes: false
        route-metric: 200
  wifis:
    wlan0:
      dhcp4: true
      dhcp-identifier: mac
      optional: true
      access-points: {}
EOF

# Set proper permissions
sudo chmod 600 /etc/netplan/01-network-manager.yaml

# Stop and disable systemd-networkd
print_section "Disabling systemd-networkd"
sudo systemctl stop systemd-networkd || true
sudo systemctl disable systemd-networkd || true
sudo systemctl mask systemd-networkd || true

# Apply configuration
print_section "Applying Network Configuration"
echo -e "${YELLOW}⚠️  Network will restart. You may lose connectivity briefly.${NC}"
if [ -n "$SSH_CONNECTION" ]; then
    echo -e "${YELLOW}    SSH session detected - you may need to reconnect.${NC}"
    echo "    Waiting 10 seconds..."
    sleep 10
fi

# Generate and apply netplan
sudo netplan generate
sudo netplan apply

# Restart NetworkManager
sudo systemctl enable NetworkManager
sudo systemctl restart NetworkManager

# Wait for NetworkManager
print_section "Waiting for NetworkManager"
for i in {1..15}; do 
    if nmcli general status >/dev/null 2>&1; then
        echo -e "${GREEN}✅ NetworkManager is ready${NC}"
        break
    fi
    sleep 1
    echo -n "."
done
echo

# Force manage our interfaces (ignore Docker)
print_section "Configuring Network Interfaces"
for iface in eno1 enp3s0 wlan0; do
    if ip link show "$iface" >/dev/null 2>&1; then
        echo "Setting $iface as managed..."
        sudo nmcli dev set "$iface" managed yes 2>/dev/null || true
    fi
done

# Create proper connections with UniFi-friendly settings
print_section "Creating Network Connections"

# Primary ethernet (eno1) - highest priority
echo "Creating primary connection for eno1..."
MAC_ENO1=$(ip link show eno1 | awk '/link\/ether/ {print $2}')
sudo nmcli con add type ethernet ifname eno1 con-name "UC-1 Primary" \
    connection.autoconnect yes \
    connection.autoconnect-priority 100 \
    ipv4.method auto \
    ipv4.dhcp-client-id "01:${MAC_ENO1}" \
    ipv4.dhcp-hostname "UC-1" \
    ipv4.dhcp-send-hostname yes \
    ipv6.method auto \
    ipv6.addr-gen-mode stable-privacy 2>/dev/null || true

# Secondary ethernet (enp3s0) - lower priority, no default route
echo "Creating secondary connection for enp3s0..."
MAC_ENP3S0=$(ip link show enp3s0 | awk '/link\/ether/ {print $2}')
sudo nmcli con add type ethernet ifname enp3s0 con-name "UC-1 Secondary" \
    connection.autoconnect no \
    connection.autoconnect-priority 50 \
    ipv4.method auto \
    ipv4.dhcp-client-id "01:${MAC_ENP3S0}" \
    ipv4.dhcp-hostname "UC-1-port2" \
    ipv4.dhcp-send-hostname yes \
    ipv4.never-default yes \
    ipv4.route-metric 200 \
    ipv6.method auto \
    ipv6.addr-gen-mode stable-privacy 2>/dev/null || true

# WiFi connection template
echo "Creating WiFi template..."
sudo nmcli con add type wifi ifname wlan0 con-name "UC-1 WiFi" ssid "placeholder" \
    connection.autoconnect no \
    wifi.hidden no \
    ipv4.method auto \
    ipv4.dhcp-hostname "UC-1-wifi" \
    ipv6.method auto 2>/dev/null || true

# Activate primary connection
print_section "Activating Primary Network"
sudo nmcli con up "UC-1 Primary" 2>/dev/null || true

# Give DHCP time to settle
sleep 3

# Verify configuration
print_section "Network Status Verification"

echo -e "${BLUE}Active Connections:${NC}"
nmcli -t -f NAME,TYPE,DEVICE,STATE con show --active | column -t -s ':'

echo -e "\n${BLUE}Device Status:${NC}"
nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev | grep -E "eno1|enp3s0|wlan0" | column -t -s ':'

echo -e "\n${BLUE}IP Configuration:${NC}"
ip -4 addr show | grep -E "eno1|enp3s0|wlan0|inet " | grep -v "127.0.0.1"

echo -e "\n${BLUE}DHCP Settings:${NC}"
echo "eno1: $(nmcli -g ipv4.dhcp-client-id con show "UC-1 Primary" 2>/dev/null || echo "N/A")"
echo "enp3s0: $(nmcli -g ipv4.dhcp-client-id con show "UC-1 Secondary" 2>/dev/null || echo "N/A")"

# Check for conflicts
print_section "Checking for Issues"
# Check duplicate IPs
DUPLICATE_IPS=$(ip -4 addr show | grep inet | grep -v "127.0.0.1\|172.17.\|172.18." | awk '{print $2}' | cut -d/ -f1 | sort | uniq -d)
if [ -n "$DUPLICATE_IPS" ]; then
    echo -e "${RED}⚠️  WARNING: Duplicate IP addresses detected:${NC}"
    echo "$DUPLICATE_IPS"
else
    echo -e "${GREEN}✅ No duplicate IP addresses${NC}"
fi

# Check KDE integration
if pgrep -x plasmashell >/dev/null; then
    echo -e "${GREEN}✅ KDE Plasma is running${NC}"
    echo "   Network icon should appear in system tray after logout/login"
else
    echo -e "${YELLOW}⚠️  KDE Plasma not detected - start desktop first${NC}"
fi

# Create rollback script
print_section "Creating Rollback Script"
cat <<'ROLLBACK' | sudo tee "$BACKUP_DIR/rollback.sh" >/dev/null
#!/bin/bash
# UC-1 Network Rollback Script
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${YELLOW}⚠️  Starting network rollback...${NC}"
echo "This will restore network configuration from: $BACKUP_DIR"
read -p "Continue? (y/N) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# Remove current NetworkManager configs
sudo rm -f /etc/NetworkManager/conf.d/00-dhcp-unifi.conf
sudo rm -f /etc/NetworkManager/conf.d/10-uc1.conf

# Restore backups
sudo cp -r "$BACKUP_DIR/NetworkManager"/* /etc/NetworkManager/ 2>/dev/null || true
sudo rm -f /etc/netplan/01-network-manager.yaml
sudo cp -r "$BACKUP_DIR/netplan"/* /etc/netplan/ 2>/dev/null || true

# Restart services
sudo systemctl unmask systemd-networkd 2>/dev/null || true
sudo netplan apply
sudo systemctl restart NetworkManager

echo -e "${GREEN}✅ Network configuration restored${NC}"
echo "You may need to reconfigure your connections."
ROLLBACK

sudo sed -i "s|\$BACKUP_DIR|$BACKUP_DIR|g" "$BACKUP_DIR/rollback.sh"
sudo chmod +x "$BACKUP_DIR/rollback.sh"

# Final summary
print_section "Setup Complete! 🎉"
echo -e "${GREEN}✅ Network has been reconfigured for KDE management${NC}"
echo
echo -e "${BLUE}What's configured:${NC}"
echo "• eno1: Primary connection (active) - 'UC-1 Primary'"
echo "• enp3s0: Secondary connection (inactive) - 'UC-1 Secondary'"
echo "• wlan0: WiFi ready for configuration - 'UC-1 WiFi'"
echo "• Each interface has unique DHCP identity for UniFi"
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
echo -e "${BLUE}Your UniFi controller should now see:${NC}"
echo "• UC-1 (primary ethernet)"
echo "• UC-1-port2 (when secondary is activated)"
echo "• UC-1-wifi (when WiFi is connected)"
