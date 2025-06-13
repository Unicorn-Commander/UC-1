#!/bin/bash

# Color setup for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Exit immediately on any error
set -e

# Check for sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}⚠️ Elevating with sudo...${NC}"
    exec sudo "$0" "$@"
fi

# Dependency installation
echo -e "${BLUE}Installing system dependencies...${NC}"
apt update && apt install -y \
    git build-essential dkms cmake libudev-dev libpci-dev libnuma-dev \
    libboost-all-dev libprotobuf-dev protobuf-compiler libssl-dev \
    libjsoncpp-dev python3-dev libxrt-dev libelf-dev lsb-release \
    libncurses5-dev libxml2-dev libtinfo-dev linux-headers-$(uname -r) \
    || {
        echo -e "${RED}❌ Dependency installation failed${NC}"
        echo -e "${YELLOW}Check your internet connection and package repositories${NC}"
        exit 1
    }

# Create working directory
WORK_DIR=/opt/amd_xdna_build
mkdir -p $WORK_DIR
cd $WORK_DIR || {
    echo -e "${RED}❌ Failed to access $WORK_DIR${NC}"
    exit 1
}

# Clone repository
if [ ! -d "$WORK_DIR/xdna-driver" ]; then
    echo -e "${BLUE}Cloning AMD xdna-driver repository...${NC}"
    git clone --recursive https://github.com/amd/xdna-driver.git || {
        echo -e "${RED}❌ Clone failed${NC}"
        echo -e "${YELLOW}Check network connection and git accessibility${NC}"
        exit 1
    }
fi

cd xdna-driver || {
    echo -e "${RED}❌ Failed to enter driver directory${NC}"
    exit 1
}

# Build main driver
echo -e "${BLUE}Building XDNA driver...${NC}"
if [ -f "build.sh" ]; then
    ./build.sh || {
        echo -e "${RED}❌ Driver build failed${NC}"
        echo -e "${YELLOW}Troubleshooting:"
        echo "1. Check last 50 lines of build output:"
        tail -n 50 build.log 2>/dev/null || echo "No build log available"
        echo -e "2. Verify kernel headers match running kernel (uname -r: $(uname -r))"
        echo -e "3. Check for updated instructions: https://github.com/amd/xdna-driver${NC}"
        exit 1
    }
else
    echo -e "${RED}❌ build.sh not found in repository${NC}"
    echo -e "${YELLOW}Possible reasons:"
    echo -e "  - Repository structure changed"
    echo -e "  - Clone incomplete (use --recursive flag)"
    echo -e "Manual installation required: https://github.com/amd/xdna-driver${NC}"
    exit 1
fi

# Build XRT plugin
echo -e "${BLUE}Building XRT plugin...${NC}"
cd ..
if [ -f "build.sh" ]; then
    ./build.sh -release && ./build.sh -package || {
        echo -e "${RED}❌ XRT plugin compilation failed${NC}"
        echo -e "${YELLOW}Last 50 lines of build log:${NC}"
        tail -n 50 build.log 2>/dev/null || echo "No build log available"
        echo -e "${YELLOW}Solutions:"
        echo -e "  - Check HIP runtime installation (rocminfo)"
        echo -e "  - Verify XRT version compatibility (xbutil examine)"
        echo -e "  - Manual build guidance: https://github.com/amd/xdna-driver${NC}"
        exit 1
    }
    
    # Install generated package
    PKG=$(find ./Release -name 'xrt_plugin*.deb' -print -quit)
    if [ -n "$PKG" ]; then
        echo -e "${GREEN}✅ Package found: $PKG${NC}"
        apt install -y ./$PKG || {
            echo -e "${RED}❌ Installation failed${NC}"
            echo -e "${YELLOW}Common fixes:"
            echo -e "  - Check dependencies: dpkg -I $PKG | grep Depends"
            echo -e "  - Resolve conflicts with: apt --fix-broken install"
            echo -e "  - Manual installation: dpkg -i $PKG${NC}"
            exit 1
        }
    else
        echo -e "${RED}❌ DEB package not found${NC}"
        echo "Generated files in Release directory:"
        find ./Release -type f | head -n 20
        echo -e "${YELLOW}Rebuild with debug: ./build.sh -debug and check logs${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ build.sh not found for XRT plugin${NC}"
    echo "Current directory: $(pwd)"
    echo "Directory contents:"
    ls -la
    echo -e "${YELLOW}Solutions:"
    echo -e "  - Re-clone with: git clone --recursive"
    echo -e "  - Check repository updates at AMD's GitHub${NC}"
    exit 1
fi

# Verification
echo -e "${GREEN}✅ Installation completed successfully${NC}"
echo -e "${BLUE}Verifying components...${NC}"
{
    echo "Kernel module status:"
    lsmod | grep amdxdna || modinfo amdxdna
    
    echo -e "\nXRT devices:"
    xbutil examine || true
    
    echo -e "\nRuntime status:"
    systemctl status amdxdna
} | tee /var/log/amdxdna_install.log

echo -e "${GREEN}Installation log saved to /var/log/amdxdna_install.log${NC}"
echo -e "${YELLOW}Next steps:"
echo -e "1. Reboot to load kernel modules"
echo -e "2. Run 'xbutil examine' to verify device detection"
echo -e "3. Check systemd service: systemctl status amdxdna${NC}"
