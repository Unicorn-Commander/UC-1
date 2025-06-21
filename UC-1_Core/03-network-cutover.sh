#!/bin/bash
set -e

# ... [color definitions unchanged] ...

# ... [user permission checks unchanged] ...

# ... [print_section function unchanged] ...

# Check prerequisites
print_section "Checking Prerequisites"

# Enhanced KDE check
if ! dpkg -l | grep -q "plasma-nm"; then
    echo -e "${RED}❌ KDE network management (plasma-nm) not installed${NC}"
    echo -e "${YELLOW}Run 02-kde_desktop_setup.sh first${NC}"
    exit 1
fi

# Enhanced network manager check
print_section "Current Network Status"
NM_ACTIVE=$(systemctl is-active NetworkManager || true)
NETWORKD_ACTIVE=$(systemctl is-active systemd-networkd || true)

echo -e "${BLUE}NetworkManager: $NM_ACTIVE"
echo -e "systemd-networkd: $NETWORKD_ACTIVE${NC}"

# ... [backup code unchanged] ...

# ... [machine-id code unchanged] ...

# Enhanced NetworkManager configuration
print_section "Configuring NetworkManager"
sudo mkdir -p /etc/NetworkManager/conf.d

cat << 'EOF' | sudo tee /etc/NetworkManager/conf.d/10-uc-settings.conf >/dev/null
[main]
plugins=keyfile
dhcp=internal
dns=default

[connection]
dhcp-client-id=stable

# ADDED: Explicitly manage all devices
[keyfile]
unmanaged-devices=none

# ADDED: Explicit management rules
[device-managed]
match-device=interface-name:*
managed=true

[device]
wifi.scan-rand-mac-address=yes

[logging]
level=WARN
EOF

# ... [cloud-init disable unchanged] ...

# Enhanced netplan configuration
print_section "Preparing Netplan for NetworkManager"

# ... [netplan backup/removal unchanged] ...

# Create NetworkManager netplan with explicit interface handling
cat << 'EOF' | sudo tee /etc/netplan/01-network-manager-all.yaml >/dev/null
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    # ADDED: Explicitly declare all ethernet interfaces
    eth0: {}
    eth1: {}
    enp1s0: {}
    enp2s0: {}
EOF

sudo chmod 600 /etc/netplan/01-network-manager-all.yaml
echo -e "${GREEN}✅ Netplan configuration prepared${NC}"

# ... [transition warning unchanged] ...

# Enhanced transition process
print_section "Performing Network Transition"

# Stop systemd-networkd
if [ "$NETWORKD_ACTIVE" = "active" ]; then
    echo -e "${BLUE}Stopping systemd-networkd...${NC}"
    sudo systemctl stop systemd-networkd
    sudo systemctl disable systemd-networkd
fi

# Apply netplan
echo -e "${BLUE}Applying netplan configuration...${NC}"
sudo netplan apply

# Start NetworkManager
if [ "$NM_ACTIVE" != "active" ]; then
    echo -e "${BLUE}Enabling NetworkManager...${NC}"
    sudo systemctl enable --now NetworkManager
else
    echo -e "${BLUE}Restarting NetworkManager...${NC}"
    sudo systemctl restart NetworkManager
fi

# ADDED: Explicitly manage all interfaces
print_section "Forcing Interface Management"
for iface in $(ip link show | awk -F': ' '/^[0-9]+: (eth|enp)/ {print $2}' | cut -d'@' -f1); do
    echo -e "${BLUE}Managing interface: $iface${NC}"
    sudo nmcli dev set "$iface" managed yes
done

# ... [stabilization wait unchanged] ...

# Enhanced verification
print_section "Verifying Transition"

# ... [basic verification unchanged] ...

# ADDED: Check interface management status
echo -e "${BLUE}NetworkManager device status:${NC}"
nmcli device status

# ADDED: Check specific interface details
for iface in $(nmcli -t -f DEVICE device status | grep -E 'eth|enp'); do
    echo -e "${BLUE}Interface details for $iface:${NC}"
    nmcli device show "$iface" | grep -E 'GENERAL\.STATE|GENERAL\.CONNECTION|IP4\.ADDRESS'
done

# ... [connectivity test unchanged] ...

# ... [rollback script unchanged] ...

# Enhanced final summary
print_section "Network Transition Complete"

echo -e "${GREEN}🎉 Network management transition completed!${NC}"
echo -e ""
echo -e "${BLUE}Summary:${NC}"
echo -e "  - NetworkManager is now managing network connections"
echo -e "  - KDE Plasma network widget should now work"
echo -e "  - Network configuration backed up to: $BACKUP_DIR"
echo -e ""
echo -e "${BLUE}If KDE still doesn't show interfaces:${NC}"
echo -e "  1. Open KDE System Settings → Connections"
echo -e "  2. Check if interfaces appear under 'Available Connections'"
echo -e "  3. If not visible, try restarting Plasma: ${GREEN}kquitapp5 plasmashell && kstart5 plasmashell${NC}"
echo -e ""
echo -e "${BLUE}Diagnostic commands:${NC}"
echo -e "  - NetworkManager status: ${GREEN}systemctl status NetworkManager${NC}"
echo -e "  - Interface details: ${GREEN}nmcli device show${NC}"
echo -e "  - Connection list: ${GREEN}nmcli connection show${NC}"
echo -e ""

# ... [status update unchanged] ...
