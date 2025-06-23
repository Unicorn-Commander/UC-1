#!/bin/bash
# Fix KDE Network Display while keeping Docker interfaces unmanaged

set -e

# Colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}=== Fixing KDE Network Display ===${NC}"

# Update NetworkManager configuration to restore information display
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
# Re-enable connectivity check for better status display
enabled=true
uri=http://connectivity-check.ubuntu.com/
interval=300

[logging]
# Keep moderate logging for managed devices
level=INFO
domains=CORE,DEVICE,ETHER,WIFI,DHCP4,DHCP6,IP4,IP6
EOF

# Update KDE network management settings for better display
mkdir -p ~/.config/networkmanagement

cat > ~/.config/networkmanagement/networkmanagementrc <<'EOF'
[General]
# Show notifications only for managed devices
ShowNotifications=true

[Notifications]
# Enable notifications for important events only
DeviceStateChangedNotification=false
ConnectionStateChangedNotification=true
EOF

# Create a more specific notification filter for plasma-nm
mkdir -p ~/.config/plasma-nm
cat > ~/.config/plasma-nm/plasma-nm.conf <<'EOF'
[General]
# Show details in tooltip
ShowConnectionDetails=true
ShowAddressDetails=true
ShowTrafficDetails=true

[Notifications]
# Filter out unmanaged devices from notifications
FilterUnmanagedDevices=true
EOF

# Update the NetworkManager permissions for KDE integration
sudo tee /etc/NetworkManager/conf.d/40-kde-integration.conf >/dev/null <<'EOF'
[main]
# Allow KDE to get full network information
auth-polkit=true

[device-mac-randomization]
# Disable MAC randomization for ethernet (can interfere with DHCP)
ethernet.scan-rand-mac-address=no
ethernet.generate-mac-address-mask=preserve

[connection-mac-randomization]
# Keep stable MAC addresses for connections
ethernet.cloned-mac-address=preserve
wifi.cloned-mac-address=stable

[misc]
# Enable all state information for GUI
state-change-details=true
EOF

# Restart NetworkManager to apply changes
echo -e "${YELLOW}Restarting NetworkManager...${NC}"
sudo systemctl restart NetworkManager

# Wait for NetworkManager to stabilize
sleep 3

# Force plasma-nm to refresh
if pgrep plasmashell >/dev/null; then
    echo -e "${YELLOW}Refreshing KDE network display...${NC}"
    # Restart the network manager plasmoid
    kquitapp5 plasmashell 2>/dev/null || true
    sleep 2
    kstart5 plasmashell >/dev/null 2>&1 &
    
    # Alternative lighter refresh (comment out the above and use this if full restart is too disruptive)
    # qdbus org.kde.plasma-nm /modules/networkmanagement org.kde.plasma-nm.reloadConnections 2>/dev/null || true
fi

# Verify the fix
echo -e "\n${BLUE}=== Verification ===${NC}"

# Check if primary interface has IP info
PRIMARY_IP=$(ip -4 addr show eno1 | grep inet | awk '{print $2}' | cut -d/ -f1)
if [ -n "$PRIMARY_IP" ]; then
    echo -e "${GREEN}✅ Primary interface has IP: $PRIMARY_IP${NC}"
else
    echo -e "${YELLOW}⚠️  No IP on primary interface yet${NC}"
fi

# Check NetworkManager state
echo -e "\n${BLUE}NetworkManager connectivity:${NC}"
nmcli networking connectivity

echo -e "\n${BLUE}Connection details:${NC}"
nmcli -f GENERAL,IP4 dev show eno1 | grep -E "DEVICE|STATE|ADDRESS|GATEWAY|DNS"

echo -e "\n${GREEN}✅ Configuration updated!${NC}"
echo
echo -e "${BLUE}What changed:${NC}"
echo "• Re-enabled connectivity checking (for status display)"
echo "• Enabled state change details"
echo "• Updated KDE integration settings"
echo "• Docker interfaces still unmanaged (no spam)"
echo
echo -e "${BLUE}In KDE you should now see:${NC}"
echo "• IP addresses in network tooltip"
echo "• Connection speed/status"
echo "• Gateway and DNS info in details"
echo
echo -e "${YELLOW}Note:${NC} You may need to:"
echo "1. Click the network icon to refresh"
echo "2. Or logout/login for full effect"
echo "3. The network plasmoid was restarted automatically"

# Create a manual refresh script for testing
cat > ~/refresh-network-display.sh <<'EOF'
#!/bin/bash
# Manual network display refresh
echo "Refreshing network display..."
qdbus org.kde.kded5 /modules/networkmanagement reload 2>/dev/null || echo "Could not refresh via dbus"
kquitapp5 plasmashell && kstart5 plasmashell >/dev/null 2>&1 &
EOF
chmod +x ~/refresh-network-display.sh

echo -e "\n${BLUE}If display doesn't update, run:${NC}"
echo "~/refresh-network-display.sh"
