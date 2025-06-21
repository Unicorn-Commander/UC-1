#!/bin/bash
set -e

# Output colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander Network Transition${NC}"
echo -e "${BLUE}Ubuntu 25.04 | KDE6 | Wayland | AMD 8945HS${NC}"

# Check user and sudo
[ "$EUID" -eq 0 ] && echo -e "${YELLOW}⚠️ Run as user: ./03-network-cutover.sh${NC}" && exit 1
[ "$(whoami)" != "ucadmin" ] && echo -e "${YELLOW}⚠️ Run as ucadmin${NC}" && exit 1
! sudo -n true 2>/dev/null && echo -e "${YELLOW}⚠️ Sudo required${NC}" && exit 1

print_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

# Install critical dependencies
print_section "Installing Dependencies"
sudo apt install -y network-manager plasma-nm iwd
echo -e "${GREEN}✅ Network components installed${NC}"

# Backup configuration
print_section "Backup Creation"
BACKUP_DIR="/home/ucadmin/network-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
sudo cp -r /etc/netplan "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/NetworkManager/NetworkManager.conf "$BACKUP_DIR/" 2>/dev/null || true
sudo cp /etc/machine-id "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✅ Backup saved: $BACKUP_DIR${NC}"

# Ensure unique machine-ID
print_section "Machine ID Setup"
[ ! -f /etc/machine-id ] && sudo systemd-machine-id-setup

# Configure NetworkManager
print_section "NetworkManager Configuration"
sudo tee /etc/NetworkManager/conf.d/10-unicorn.conf >/dev/null <<EOF
[main]
plugins=keyfile
dhcp=internal

[keyfile]
unmanaged-devices=none

[device]
# Ensure all interfaces are managed
managed=true
EOF

# Create Netplan configuration
print_section "Netplan Configuration"
sudo tee /etc/netplan/01-network-manager.yaml >/dev/null <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    # Explicitly declare all physical interfaces
    enp1s0: {}
    enp2s0: {}
    eth0: {}
    eth1: {}
  wifis:
    # Declare Wi-Fi interfaces
    wlan0: {}
    wlp1s0: {}
    wlp2s0: {}
EOF

# Stop conflicting services
print_section "Stopping Services"
sudo systemctl stop systemd-networkd || true
sudo systemctl disable systemd-networkd || true
sudo systemctl mask systemd-networkd || true

# Apply configuration
print_section "Applying Configuration"
sudo netplan generate
sudo netplan apply
sudo systemctl enable --now NetworkManager

# Force manage all interfaces
print_section "Interface Management"
for iface in $(ip -o link show | awk -F': ' '!/lo/ {print $2}'); do
  sudo nmcli dev set "$iface" managed yes
done

# Wait for services
print_section "Stabilizing Network"
for i in {1..8}; do sleep 1; echo -n "."; done; echo

# Verify configuration
print_section "Verification"
echo -e "${BLUE}NetworkManager Status:${NC}"
systemctl status NetworkManager --no-pager

echo -e "\n${BLUE}Managed Devices:${NC}"
nmcli -t -f DEVICE,TYPE,STATE,MANAGED dev status | grep -v unmanaged

echo -e "\n${BLUE}KDE Network Status:${NC}"
qdbus org.kde.plasmanetworkmanagement /org/kde/plasmanetworkmanagement org.kde.plasmanetworkmanagement.activeConnections

# Create rollback script
print_section "Creating Rollback"
sudo tee "$BACKUP_DIR/rollback.sh" >/dev/null <<EOF
#!/bin/bash
sudo rm -f /etc/netplan/01-network-manager.yaml
sudo cp -r "$BACKUP_DIR/netplan" /etc/
sudo systemctl unmask systemd-networkd
sudo systemctl enable --now systemd-networkd
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo netplan apply
echo -e "${GREEN}✅ Network restored${NC}"
EOF
sudo chmod +x "$BACKUP_DIR/rollback.sh"

# Final instructions
print_section "Transition Complete"
echo -e "${GREEN}✅ KDE can now manage all network interfaces${NC}"
echo -e "\n${BLUE}Access network settings:${NC}"
echo "1. Open KDE System Settings"
echo "2. Go to Connections"
echo "3. Configure Ethernet/Wi-Fi"
echo -e "\n${YELLOW}If issues occur, run rollback:${NC}"
echo "$BACKUP_DIR/rollback.sh"
