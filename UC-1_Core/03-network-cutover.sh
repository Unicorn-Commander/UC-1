#!/bin/bash
set -e

# Output colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander Production Network Setup${NC}"
echo -e "${BLUE}Preparing system for cloning/imaging${NC}"

# Check user and sudo
[ "$EUID" -eq 0 ] && echo -e "${YELLOW}⚠️ Run as user: ./uc-production-network.sh${NC}" && exit 1
! sudo -n true 2>/dev/null && echo -e "${YELLOW}⚠️ Sudo required${NC}" && exit 1

print_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

# Command line arguments
CLEANUP_MODE=false
if [ "$1" = "--pre-clone" ]; then
    CLEANUP_MODE=true
    echo -e "${YELLOW}Running in pre-clone cleanup mode${NC}"
fi

# Install dependencies
print_section "Installing Dependencies"
sudo apt install -y network-manager plasma-nm iwd uuid-runtime

# Create backup
print_section "Creating Backup"
BACKUP_DIR="/home/$(whoami)/network-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
sudo cp -r /etc/netplan "$BACKUP_DIR/" 2>/dev/null || true
sudo cp -r /etc/NetworkManager "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✅ Backup saved: $BACKUP_DIR${NC}"

# Clean existing connections
print_section "Cleaning Network Connections"
# Remove all non-docker NetworkManager connections
for uuid in $(nmcli -t -f UUID,NAME con show | grep -v -E "docker|bridge|veth|br-" | cut -d: -f1); do
    sudo nmcli con delete "$uuid" 2>/dev/null || true
done

# Configure NetworkManager to ignore Docker interfaces
print_section "Configuring NetworkManager"

# Main configuration
sudo tee /etc/NetworkManager/conf.d/10-unicorn-production.conf >/dev/null <<'EOF'
[main]
plugins=keyfile
dhcp=internal
# Don't create default connections
no-auto-default=*

[keyfile]
# Explicitly unmanage Docker and virtual interfaces
unmanaged-devices=interface-name:docker*;interface-name:veth*;interface-name:br-*;interface-name:vnet*;interface-name:virbr*

[device]
# Only manage real hardware interfaces
match-device=type:ethernet,!interface-name:veth*,!interface-name:docker*,!interface-name:br-*
match-device=type:wifi

[connection]
# Stable IDs based on interface
connection.stable-id=${DEVICE}
# Don't store timestamps (important for cloning)
connection.timestamp=0

[connectivity]
enabled=false

[logging]
level=WARN
EOF

# DHCP configuration for UniFi
sudo tee /etc/NetworkManager/conf.d/20-dhcp-unifi.conf >/dev/null <<'EOF'
[connection]
# Unique DHCP client ID per interface
ipv4.dhcp-client-id=mac
ipv6.dhcp-duid=ll

[ipv4]
dhcp-send-hostname=true
EOF

# Disable notifications for unmanaged devices
sudo tee /etc/NetworkManager/conf.d/30-no-notifications.conf >/dev/null <<'EOF'
[main]
# Suppress notifications for device state changes
[logging]
# Reduce verbosity for unmanaged devices
domains=DEVICE:ERROR,SETTINGS:ERROR
EOF

# Create a systemd service to suppress KDE notifications for veth interfaces
print_section "Creating Notification Filter"
sudo tee /etc/systemd/user/network-notification-filter.service >/dev/null <<'EOF'
[Unit]
Description=Filter Network Notifications
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/local/bin/network-notification-filter.sh
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

# Create the filter script
sudo tee /usr/local/bin/network-notification-filter.sh >/dev/null <<'EOF'
#!/bin/bash
# This would need to be implemented based on KDE's notification system
# For now, we'll rely on NetworkManager configuration to not manage these interfaces
# This is a placeholder for future notification filtering if needed

while true; do
    # Monitor and suppress veth notifications if they still occur
    sleep 60
done
EOF
sudo chmod +x /usr/local/bin/network-notification-filter.sh

# Configure KDE to reduce network notifications
if [ -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config/networkmanagement"
    cat > "$HOME/.config/networkmanagement/networkmanagementrc" <<'EOF'
[General]
ShowNotifications=false

[Notifications]
# Disable notifications for device state changes
DeviceStateChangedNotification=false
EOF
fi

# Create netplan configuration
print_section "Creating Netplan Configuration"
sudo tee /etc/netplan/01-network-manager.yaml >/dev/null <<'EOF'
# UnicornCommander Network Configuration
network:
  version: 2
  renderer: NetworkManager
EOF

# Clean up old netplan files
sudo rm -f /etc/netplan/90-NM-*.yaml
sudo rm -f /etc/netplan/50-cloud-init.yaml

# Disable systemd-networkd
print_section "Disabling systemd-networkd"
sudo systemctl stop systemd-networkd || true
sudo systemctl disable systemd-networkd || true
sudo systemctl mask systemd-networkd || true

# Restart NetworkManager with new config
print_section "Applying Configuration"
sudo netplan generate
sudo netplan apply
sudo systemctl restart NetworkManager

# Wait for NetworkManager
sleep 3

# Create hardware-specific connections
print_section "Creating Network Profiles"

# Function to create connection with clone-friendly settings
create_connection() {
    local IFACE=$1
    local NAME=$2
    local PRIORITY=$3
    local IS_PRIMARY=$4
    
    if ip link show "$IFACE" >/dev/null 2>&1; then
        echo "Creating connection for $IFACE..."
        
        # Base connection
        sudo nmcli con add type ethernet ifname "$IFACE" con-name "$NAME" \
            connection.autoconnect yes \
            connection.autoconnect-priority "$PRIORITY" \
            connection.permissions "" \
            ipv4.method auto \
            ipv6.method auto \
            ipv6.addr-gen-mode stable-privacy
        
        # Configure as secondary if not primary
        if [ "$IS_PRIMARY" = "false" ]; then
            sudo nmcli con mod "$NAME" \
                ipv4.never-default yes \
                ipv4.route-metric 200
        fi
        
        # Don't activate automatically during setup
        sudo nmcli con mod "$NAME" connection.autoconnect no
    fi
}

# Create connections for detected hardware
create_connection "eno1" "Primary Ethernet" 100 true
create_connection "enp3s0" "Secondary Ethernet" 50 false

# Create WiFi template
if ip link show wlan0 >/dev/null 2>&1; then
    sudo nmcli con add type wifi ifname wlan0 con-name "WiFi Template" ssid "CHANGE_ME" \
        connection.autoconnect no \
        wifi.hidden no \
        ipv4.method auto \
        ipv6.method auto
fi

# Pre-clone cleanup mode
if [ "$CLEANUP_MODE" = true ]; then
    print_section "Pre-Clone Cleanup"
    
    # Remove machine-specific data
    echo "Removing machine-specific identifiers..."
    
    # Clear machine-id (will regenerate on next boot)
    sudo truncate -s 0 /etc/machine-id
    
    # Remove SSH host keys (will regenerate)
    sudo rm -f /etc/ssh/ssh_host_*
    
    # Clear NetworkManager state
    sudo rm -rf /var/lib/NetworkManager/*
    
    # Remove any DHCP leases
    sudo rm -f /var/lib/NetworkManager/*.lease
    sudo rm -f /var/lib/dhcp/*.leases
    
    # Clear system logs
    sudo journalctl --vacuum-time=1s
    
    # Remove bash history
    rm -f ~/.bash_history
    history -c
    
    echo -e "${GREEN}✅ System prepared for cloning${NC}"
    echo -e "${YELLOW}Image the system now before next boot${NC}"
    exit 0
fi

# Create first-boot script for cloned systems
print_section "Creating First-Boot Configuration"
sudo tee /usr/local/bin/unicorn-first-boot.sh >/dev/null <<'EOF'
#!/bin/bash
# UnicornCommander First Boot Configuration
# This runs on first boot after cloning

MARKER_FILE="/var/lib/unicorn-commander/.first-boot-complete"

if [ -f "$MARKER_FILE" ]; then
    exit 0
fi

echo "Running UnicornCommander first boot configuration..."

# Generate unique hostname based on MAC address
PRIMARY_MAC=$(ip link show eno1 2>/dev/null | grep ether | awk '{print $2}' | tr -d ':' | tail -c 6)
if [ -n "$PRIMARY_MAC" ]; then
    NEW_HOSTNAME="UC-${PRIMARY_MAC}"
    hostnamectl set-hostname "$NEW_HOSTNAME"
    
    # Update DHCP hostnames in connections
    nmcli con mod "Primary Ethernet" ipv4.dhcp-hostname "$NEW_HOSTNAME" 2>/dev/null || true
    nmcli con mod "Secondary Ethernet" ipv4.dhcp-hostname "${NEW_HOSTNAME}-port2" 2>/dev/null || true
    nmcli con mod "WiFi Template" ipv4.dhcp-hostname "${NEW_HOSTNAME}-wifi" 2>/dev/null || true
fi

# Enable primary network connection
nmcli con mod "Primary Ethernet" connection.autoconnect yes 2>/dev/null || true
nmcli con up "Primary Ethernet" 2>/dev/null || true

# Create marker
mkdir -p /var/lib/unicorn-commander
touch "$MARKER_FILE"

echo "First boot configuration complete. Hostname: $NEW_HOSTNAME"
EOF
sudo chmod +x /usr/local/bin/unicorn-first-boot.sh

# Create systemd service for first boot
sudo tee /etc/systemd/system/unicorn-first-boot.service >/dev/null <<'EOF'
[Unit]
Description=UnicornCommander First Boot Configuration
After=network-pre.target
Before=NetworkManager.service
ConditionPathExists=!/var/lib/unicorn-commander/.first-boot-complete

[Service]
Type=oneshot
ExecStart=/usr/local/bin/unicorn-first-boot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable unicorn-first-boot.service

# Verify configuration
print_section "Verification"
echo -e "${BLUE}NetworkManager Status:${NC}"
systemctl status NetworkManager --no-pager | head -n 5

echo -e "\n${BLUE}Managed Devices (should NOT include veth/docker):${NC}"
nmcli device status | grep -v -E "veth|docker|br-" | head -10

echo -e "\n${BLUE}Unmanaged Devices (should include all veth):${NC}"
nmcli device status | grep unmanaged | head -5

# Final instructions
print_section "Setup Complete!"
echo -e "${GREEN}✅ Network configured for production imaging${NC}"
echo
echo -e "${BLUE}What's been done:${NC}"
echo "• NetworkManager ignores Docker/veth interfaces (no more notifications!)"
echo "• Network profiles created but not activated"
echo "• First-boot script will set unique hostname"
echo "• System ready for cloning"
echo
echo -e "${BLUE}Before creating image:${NC}"
echo "1. Test that notifications are gone"
echo "2. Verify network connectivity works"
echo "3. Run: ${YELLOW}$0 --pre-clone${NC}"
echo "4. Shutdown and create image"
echo
echo -e "${BLUE}After cloning:${NC}"
echo "• Each system gets unique hostname (UC-XXXXXX)"
echo "• Network automatically configures on first boot"
echo "• UniFi sees each clone as unique device"
echo
echo -e "${YELLOW}Rollback if needed:${NC}"
echo "sudo $BACKUP_DIR/rollback.sh"

# Create the rollback script
cat <<'ROLLBACK' | sudo tee "$BACKUP_DIR/rollback.sh" >/dev/null
#!/bin/bash
echo "Rolling back network configuration..."
sudo rm -f /etc/NetworkManager/conf.d/10-unicorn-production.conf
sudo rm -f /etc/NetworkManager/conf.d/20-dhcp-unifi.conf
sudo rm -f /etc/NetworkManager/conf.d/30-no-notifications.conf
sudo rm -f /usr/local/bin/unicorn-first-boot.sh
sudo rm -f /usr/local/bin/network-notification-filter.sh
sudo systemctl disable unicorn-first-boot.service
sudo rm -f /etc/systemd/system/unicorn-first-boot.service
[ -d "$BACKUP_DIR/NetworkManager" ] && sudo cp -r "$BACKUP_DIR/NetworkManager"/* /etc/NetworkManager/
[ -d "$BACKUP_DIR/netplan" ] && sudo cp -r "$BACKUP_DIR/netplan"/* /etc/netplan/
sudo systemctl unmask systemd-networkd
sudo netplan apply
sudo systemctl restart NetworkManager
echo "Rollback complete"
ROLLBACK
sudo chmod +x "$BACKUP_DIR/rollback.sh"
