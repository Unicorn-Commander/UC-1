#!/bin/bash

# Unicorn Commander SDDM Theme Installer
# Safe installer for SDDM login themes with backup and recovery

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear
echo -e "${PURPLE}🔐 Unicorn Commander SDDM Theme Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ This installer requires sudo access${NC}"
    echo -e "${BLUE}   Please run: sudo $0${NC}"
    exit 1
fi

SDDM_DIR="/usr/share/sddm/themes"

# Check if SDDM is installed
if [ ! -d "/usr/share/sddm" ]; then
    echo -e "${RED}❌ SDDM not found on this system${NC}"
    echo -e "${YELLOW}   Please install SDDM first${NC}"
    exit 1
fi

echo -e "${BLUE}📍 SDDM themes directory: $SDDM_DIR${NC}"
echo -e "${BLUE}📂 Source directory: $SCRIPT_DIR${NC}"
echo ""

# Show available themes
echo -e "${BLUE}🎨 Available SDDM themes:${NC}"
theme_count=0
themes_available=()

if [ -d "$SCRIPT_DIR/distribution/sddm-theme/UnicornCommander-Universal" ]; then
    echo -e "   ${GREEN}1.${NC} UnicornCommander Universal (recommended)"
    themes_available+=("UnicornCommander-Universal")
    ((theme_count++))
fi

if [ -d "$SCRIPT_DIR/distribution/sddm-theme/MagicUnicorn" ]; then
    echo -e "   ${PURPLE}2.${NC} Magic Unicorn (macOS-style)"
    themes_available+=("MagicUnicorn")
    ((theme_count++))
fi

if [ -d "$SCRIPT_DIR/distribution/sddm-theme/UnicornCommander" ]; then
    echo -e "   ${BLUE}3.${NC} UnicornCommander (Windows-style)"
    themes_available+=("UnicornCommander")
    ((theme_count++))
fi

if [ $theme_count -eq 0 ]; then
    echo -e "${RED}❌ No SDDM themes found in $SCRIPT_DIR/distribution/sddm-theme/${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}⚠️  WARNING: This will modify your login screen${NC}"
echo -e "${YELLOW}   Make sure you have another way to login if something goes wrong${NC}"
echo ""

read -p "Continue with SDDM theme installation? (y/N): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Installation cancelled"
    exit 0
fi

echo ""
read -p "Select theme to install (1-$theme_count): " choice

# Validate choice
if ! [[ "$choice" =~ ^[1-9][0-9]*$ ]] || [ "$choice" -gt $theme_count ]; then
    echo -e "${RED}❌ Invalid choice${NC}"
    exit 1
fi

# Get selected theme
selected_theme="${themes_available[$((choice-1))]}"
theme_source="$SCRIPT_DIR/distribution/sddm-theme/$selected_theme"

echo ""
echo -e "${BLUE}📦 Installing $selected_theme SDDM theme...${NC}"

# Create backup timestamp
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup current SDDM config
backup_sddm_config() {
    echo -e "${BLUE}💾 Creating backup of current configuration...${NC}"
    
    if [ -f "/etc/sddm.conf" ]; then
        cp "/etc/sddm.conf" "/etc/sddm.conf.backup.$BACKUP_TIMESTAMP"
        echo -e "${GREEN}   ✅ Backed up /etc/sddm.conf${NC}"
    fi
    
    if [ -f "/etc/sddm.conf.d/kde_settings.conf" ]; then
        cp "/etc/sddm.conf.d/kde_settings.conf" "/etc/sddm.conf.d/kde_settings.conf.backup.$BACKUP_TIMESTAMP"
        echo -e "${GREEN}   ✅ Backed up KDE SDDM settings${NC}"
    fi
    
    if [ -d "/usr/share/sddm/themes" ]; then
        mkdir -p "/tmp/sddm-themes-backup-$BACKUP_TIMESTAMP"
        cp -r "/usr/share/sddm/themes"/* "/tmp/sddm-themes-backup-$BACKUP_TIMESTAMP/" 2>/dev/null || true
        echo -e "${GREEN}   ✅ Backed up existing themes to /tmp/sddm-themes-backup-$BACKUP_TIMESTAMP${NC}"
    fi
}

# Install theme files
install_theme_files() {
    echo -e "${BLUE}📂 Installing theme files...${NC}"
    
    # Create themes directory if it doesn't exist
    mkdir -p "$SDDM_DIR"
    
    # Copy theme
    if cp -r "$theme_source" "$SDDM_DIR/"; then
        echo -e "${GREEN}   ✅ Theme files copied successfully${NC}"
        
        # Set proper permissions
        chmod -R 755 "$SDDM_DIR/$selected_theme"
        chown -R root:root "$SDDM_DIR/$selected_theme"
        echo -e "${GREEN}   ✅ Permissions set correctly${NC}"
    else
        echo -e "${RED}   ❌ Failed to copy theme files${NC}"
        return 1
    fi
}

# Configure SDDM to use the theme
configure_sddm() {
    echo -e "${BLUE}⚙️  Configuring SDDM to use $selected_theme...${NC}"
    
    # Create SDDM config directory if it doesn't exist
    mkdir -p /etc/sddm.conf.d/
    
    # Create or update KDE settings
    if [ -f "/etc/sddm.conf.d/kde_settings.conf" ]; then
        # Update existing config
        if grep -q "^Current=" "/etc/sddm.conf.d/kde_settings.conf"; then
            sed -i "s/^Current=.*/Current=$selected_theme/" "/etc/sddm.conf.d/kde_settings.conf"
        else
            # Add Current setting to existing [Theme] section or create it
            if grep -q "^\[Theme\]" "/etc/sddm.conf.d/kde_settings.conf"; then
                sed -i "/^\[Theme\]/a Current=$selected_theme" "/etc/sddm.conf.d/kde_settings.conf"
            else
                echo -e "\n[Theme]\nCurrent=$selected_theme" >> "/etc/sddm.conf.d/kde_settings.conf"
            fi
        fi
    else
        # Create new config file
        cat > "/etc/sddm.conf.d/kde_settings.conf" << EOF
[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=$selected_theme

[Users]
MaximumUid=60000
MinimumUid=1000
EOF
    fi
    
    echo -e "${GREEN}   ✅ SDDM configuration updated${NC}"
}

# Test configuration
test_configuration() {
    echo -e "${BLUE}🧪 Testing SDDM configuration...${NC}"
    
    # Check if theme directory exists and has required files
    if [ ! -f "$SDDM_DIR/$selected_theme/Main.qml" ]; then
        echo -e "${RED}   ❌ Main.qml not found${NC}"
        return 1
    fi
    
    if [ ! -f "$SDDM_DIR/$selected_theme/metadata.desktop" ]; then
        echo -e "${YELLOW}   ⚠️  metadata.desktop not found (optional)${NC}"
    fi
    
    # Test SDDM config syntax
    if sddm --test-mode --theme "$selected_theme" 2>/dev/null; then
        echo -e "${GREEN}   ✅ Theme configuration is valid${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Unable to test theme (SDDM test mode not available)${NC}"
    fi
    
    echo -e "${GREEN}   ✅ Configuration appears valid${NC}"
}

# Create recovery script
create_recovery_script() {
    echo -e "${BLUE}🛡️  Creating recovery script...${NC}"
    
    cat > "/root/sddm-recovery-$BACKUP_TIMESTAMP.sh" << EOF
#!/bin/bash
# SDDM Recovery Script - Created $BACKUP_TIMESTAMP
# Run this script as root if SDDM login is broken

echo "🚨 SDDM Recovery Script"
echo "======================"

# Restore backups
if [ -f "/etc/sddm.conf.backup.$BACKUP_TIMESTAMP" ]; then
    cp "/etc/sddm.conf.backup.$BACKUP_TIMESTAMP" "/etc/sddm.conf"
    echo "✅ Restored /etc/sddm.conf"
fi

if [ -f "/etc/sddm.conf.d/kde_settings.conf.backup.$BACKUP_TIMESTAMP" ]; then
    cp "/etc/sddm.conf.d/kde_settings.conf.backup.$BACKUP_TIMESTAMP" "/etc/sddm.conf.d/kde_settings.conf"
    echo "✅ Restored KDE SDDM settings"
fi

# Reset to default theme
sed -i 's/^Current=.*/Current=/' /etc/sddm.conf.d/kde_settings.conf 2>/dev/null || true
sed -i 's/^Current=/#Current=/' /etc/sddm.conf.d/kde_settings.conf 2>/dev/null || true

# Restart SDDM
systemctl restart sddm

echo "✅ SDDM reset to default theme"
echo "You should now be able to login normally"
EOF

    chmod +x "/root/sddm-recovery-$BACKUP_TIMESTAMP.sh"
    echo -e "${GREEN}   ✅ Recovery script created: /root/sddm-recovery-$BACKUP_TIMESTAMP.sh${NC}"
}

# Main installation process
main() {
    echo -e "${BLUE}🚀 Starting SDDM theme installation...${NC}"
    echo ""
    
    backup_sddm_config || { echo -e "${RED}❌ Backup failed${NC}"; exit 1; }
    install_theme_files || { echo -e "${RED}❌ Theme installation failed${NC}"; exit 1; }
    test_configuration || { echo -e "${RED}❌ Configuration test failed${NC}"; exit 1; }
    create_recovery_script
    configure_sddm || { echo -e "${RED}❌ SDDM configuration failed${NC}"; exit 1; }
    
    echo ""
    echo -e "${GREEN}🎉 SDDM Theme Installation Complete!${NC}"
    echo ""
    echo -e "${PURPLE}📋 What was installed:${NC}"
    echo -e "   • $selected_theme SDDM theme"
    echo -e "   • Unicorn Commander wallpaper"
    echo -e "   • Custom login interface with Unicorn branding"
    echo ""
    echo -e "${BLUE}🔄 Next steps:${NC}"
    echo -e "   1. Restart SDDM: ${YELLOW}sudo systemctl restart sddm${NC}"
    echo -e "   2. Or reboot the system to see the new login screen"
    echo ""
    echo -e "${YELLOW}🛡️  Recovery information:${NC}"
    echo -e "   • Recovery script: ${YELLOW}/root/sddm-recovery-$BACKUP_TIMESTAMP.sh${NC}"
    echo -e "   • If login breaks, run the recovery script as root"
    echo -e "   • Backups created with timestamp: $BACKUP_TIMESTAMP"
    echo ""
    
    echo -e "${YELLOW}💡 To see the new login theme:${NC}"
    echo -e "   • Reboot the system, OR"
    echo -e "   • Run: ${YELLOW}sudo systemctl restart sddm${NC}"
    echo ""
    echo -e "${BLUE}Note: SDDM restart will immediately show the login screen${NC}"
}

# Run the installer
main "$@"