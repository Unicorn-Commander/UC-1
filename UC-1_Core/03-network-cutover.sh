#!/bin/bash
# Unified Network Fix for KDE6: Auto-Connect + Display Management
# Combines ethernet autoconnect fix with KDE network display enhancements

set -e

# Colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}=== Unified Network Fix for KDE6 ===${NC}"
echo -e "${YELLOW}This will fix ethernet auto-connect and improve network display${NC}"
echo

# Section 1: Fix Ethernet Auto-Connect
echo -e "${BLUE}=== Part 1: Fixing Ethernet Auto-Connect ===${NC}"

# Check current connection status
echo -e "${BLUE}Current connections:${NC}"
nmcli con show | grep -E "ethernet|Primary|Secondary|Wired" || true

# Find and enable autoconnect for ethernet connections
echo -e "\n${YELLOW}Enabling auto-connect for ethernet interfaces...${NC}"

# Method 1: Fix by connection name patterns
for pattern in "Primary Ethernet" "UC-1 Primary" "Wired" "eno1" "Ethernet"; do
    CONNECTION=$(nmcli -t -f NAME con show | grep -i "$pattern" | head -1)
    if [ -n "$CONNECTION" ]; then
        echo "Found connection: $CONNECTION"
        sudo nmcli con mod "$CONNECTION" connection.autoconnect yes
        sudo nmcli con mod "$CONNECTION" connection.autoconnect-priority 100
    fi
done

# Method 2: Fix by interface name
if ip link show eno1 >/dev/null 2>&1; then
    # Find any connection bound to eno1
    CONNECTION=$(nmcli -t -f NAME,DEVICE con show | grep ":eno1$" | cut -d: -f1)
    if [ -n "$CONNECTION" ]; then
        echo "Enabling autoconnect for eno1 connection: $CONNECTION"
        sudo nmcli con mod "$CONNECTION" connection.autoconnect yes
        sudo nmcli con mod "$CONNECTION" connection.autoconnect-priority 100
    else
        # No connection exists for eno1, create one
        echo "Creating new auto-connect profile for eno1..."
        sudo nmcli con add type ethernet ifname eno1 con-name "Primary Network" \
            connection.autoconnect yes \
            connection.autoconnect-priority 100 \
            ipv4.method auto \
            ipv6.method auto
    fi
fi

# Method 3: Fix all ethernet connections
echo -e "\n${BLUE}Updating all ethernet connections:${NC}"
nmcli -t -f UUID,TYPE con show | grep "802-3-ethernet" | cut -d: -f1 | while read uuid; do
    NAME=$(nmcli -g connection.id con show "$uuid" 2>/dev/null || echo "unknown")
    # Skip Docker/virtual interfaces
    if [[ ! "$NAME" =~ ^(docker|veth|br-) ]]; then
        echo "Enabling autoconnect for: $NAME"
        sudo nmcli con mod "$uuid" connection.autoconnect yes 2>/dev/null || true
    fi
done

# Ensure NetworkManager autoconnect is not globally disabled
echo -e "\n${BLUE}Checking NetworkManager settings:${NC}"
if grep -q "autoconnect-retries=0" /etc/NetworkManager/conf.d/* 2>/dev/null; then
    echo "Found autoconnect disabled in config, fixing..."
    sudo sed -i '/autoconnect-retries=0/d' /etc/NetworkManager/conf.d/*.conf
fi

# Create autoconnect configuration
echo -e "${YELLOW}Creating autoconnect configuration...${NC}"
sudo tee /etc/NetworkManager/conf.d/50-autoconnect-fix.conf >/dev/null <<'EOF'
[main]
# Ensure autoconnect works

[connection]
# Don't set this to 0!
connection.autoconnect-retries=4

[device]
# Managed devices should autoconnect
managed=true
EOF

# Section 2: Network Display Fix
echo -e "\n${BLUE}=== Part 2: Improving Network Display ===${NC}"

# Create primary NetworkManager configuration
echo -e "${YELLOW}Creating NetworkManager configuration...${NC}"
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

# Create KDE integration configuration
echo -e "${YELLOW}Creating KDE integration settings...${NC}"
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

# Update KDE network settings
echo -e "${YELLOW}Updating KDE network configuration...${NC}"
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

# Single NetworkManager restart
echo -e "\n${YELLOW}Restarting NetworkManager...${NC}"
sudo systemctl restart NetworkManager
sleep 3  # Allow time for services to stabilize

# Post-restart activation
echo -e "${YELLOW}Attempting to connect now...${NC}"
if ! nmcli -t -f DEVICE,STATE dev | grep -q "eno1:connected"; then
    CONNECTION=$(nmcli -t -f NAME,DEVICE con show | grep ":eno1$" | cut -d: -f1 | head -1)
    [ -z "$CONNECTION" ] && CONNECTION=$(nmcli -t -f NAME con show | grep -i "primary\|eno1\|ethernet" | head -1)
    
    if [ -n "$CONNECTION" ]; then
        echo "Activating connection: $CONNECTION"
        nmcli con up "$CONNECTION" 2>/dev/null || true
    fi
fi

# Create autostart entry
echo -e "\n${YELLOW}Creating login autostart entry...${NC}"
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/ensure-network-connection.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Ensure Network Connection
Comment=Make sure ethernet connects at login
Exec=sh -c "sleep 5; nmcli con up 'Primary Ethernet' 2>/dev/null || nmcli con up 'Primary Network' 2>/dev/null || nmcli device connect eno1 2>/dev/null || true"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
EOF

# Refresh KDE interface
echo -e "\n${YELLOW}Refreshing KDE interface...${NC}"
if pgrep plasmashell >/dev/null; then
    # Lightweight refresh
    qdbus org.kde.plasma-nm /modules/networkmanagement org.kde.plasma-nm.reloadConnections 2>/dev/null || true
    
    # Full restart if lightweight fails
    if [ $? -ne 0 ]; then
        kquitapp5 plasmashell 2>/dev/null || true
        sleep 2
        kstart5 plasmashell >/dev/null 2>&1 &
    fi
fi

# Verification
echo -e "\n${BLUE}=== Verification ===${NC}"

# Connection status
echo -e "${BLUE}Connection status:${NC}"
nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev | grep -E "eno1|enp3s0|ethernet" | column -t -s:'

# IP information
PRIMARY_IP=$(ip -4 addr show eno1 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1)
if [ -n "$PRIMARY_IP" ]; then
    echo -e "${GREEN}✅ Primary interface has IP: $PRIMARY_IP${NC}"
else
    echo -e "${YELLOW}⚠️  No IP on primary interface yet${NC}"
fi

# Autoconnect status
echo -e "\n${BLUE}Autoconnect status:${NC}"
for conn in $(nmcli -t -f NAME con show | grep -v -E "docker|veth|br-"); do
    AUTOCONNECT=$(nmcli -g connection.autoconnect con show "$conn" 2>/dev/null || echo "unknown")
    echo "$conn: autoconnect=$AUTOCONNECT"
done

# NetworkManager status
echo -e "\n${BLUE}NetworkManager connectivity:${NC}"
nmcli networking connectivity

# Create manual refresh script
echo -e "\n${YELLOW}Creating manual refresh script...${NC}"
cat > ~/refresh-network-display.sh <<'EOF'
#!/bin/bash
# Manual network display refresh
echo "Refreshing network display..."
qdbus org.kde.kded5 /modules/networkmanagement reload 2>/dev/null || echo "Could not refresh via dbus"
kquitapp5 plasmashell 2>/dev/null && sleep 1 && kstart5 plasmashell >/dev/null 2>&1 &
EOF
chmod +x ~/refresh-network-display.sh

# Final report
echo -e "\n${GREEN}✅ Network configuration successfully updated!${NC}"
echo
echo -e "${BLUE}Summary of changes:${NC}"
echo "• Enabled ethernet auto-connect with high priority"
echo "• Created new connection profile if needed"
echo "• Fixed NetworkManager configuration"
echo "• Improved KDE network display and notifications"
echo "• Created failsafe autostart entry"
echo "• Docker interfaces remain unmanaged"
echo
echo -e "${BLUE}To check:${NC}"
echo "1. IP/gateway should show in network tooltip"
echo "2. 'Connect automatically' should be enabled in connections"
echo "3. System Settings → Connections should show correct config"
echo
echo -e "${YELLOW}If the network display doesn't update:${NC}"
echo "- Log out and back in"
echo "- Or run: ~/refresh-network-display.sh"
echo
echo -e "${GREEN}Unified network fix completed successfully!${NC}"
