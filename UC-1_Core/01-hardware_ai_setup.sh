#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander Hardware & AI Setup${NC}"
echo -e "${BLUE}Setting up AMD Ryzen 9 8945HS, Radeon 780M, and XDNA 2 NPU on Ubuntu 25.04...${NC}"

# Ensure running as ucadmin (not root) with sudo privileges
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️ This script should NOT be run with sudo. Run as ucadmin user directly.${NC}"
    echo -e "${YELLOW}   Example: ./01-hardware_ai_setup.sh${NC}"
    exit 1
fi

if [ "$(whoami)" != "ucadmin" ]; then
    echo -e "${YELLOW}⚠️ This script must be run as ucadmin user. Current user: $(whoami)${NC}"
    exit 1
fi

if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Sudo privileges required. Run: sudo visudo and add 'ucadmin ALL=(ALL) NOPASSWD:ALL'${NC}"
    exit 1
fi

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Update system first
print_section "Updating System"
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Clean up any broken DKMS packages from previous attempts
print_section "Cleaning Previous Installation Attempts"
if dpkg -l | grep -q amdgpu-dkms; then
    echo -e "${YELLOW}⚠️ Found existing AMDGPU DKMS package, forcing cleanup...${NC}"
    
    # Remove all DKMS modules
    sudo dkms remove amdgpu/6.12.12-2164967.24.04 --all 2>/dev/null || true
    sudo dkms remove amdgpu --all 2>/dev/null || true
    
    # Clean up crash reports
    sudo rm -f /var/crash/amdgpu-dkms.*.crash 2>/dev/null || true
    
    # Force remove the broken package
    sudo dpkg --remove --force-remove-reinstreq amdgpu-dkms 2>/dev/null || true
    sudo apt remove --purge -y amdgpu-dkms 2>/dev/null || true
    
    # Clean up package database
    sudo apt install -f
    sudo dpkg --configure -a
    sudo apt autoremove -y
    
    echo -e "${GREEN}✅ DKMS cleanup completed${NC}"
fi

# Install kernel headers for kernel 6.14
print_section "Installing Kernel Headers"
sudo apt install -y linux-headers-$(uname -r) linux-modules-extra-$(uname -r)

# Add AMD repositories (AMDGPU and ROCm 6.4.1)
print_section "Adding AMD Repositories"
sudo mkdir -p /etc/apt/keyrings
wget -q https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

# Add AMDGPU repository
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.4.1/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/amdgpu.list

# Add ROCm 6.4.1 repository
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.4.1 noble main" | sudo tee /etc/apt/sources.list.d/rocm.list

# Add pinning to prioritize AMD repositories
echo -e "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" | sudo tee /etc/apt/preferences.d/rocm-pin-600

# Install amdgpu-install script
print_section "Installing AMDGPU Installer"
cd /tmp
wget -q https://repo.radeon.com/amdgpu-install/6.4.1/ubuntu/noble/amdgpu-install_6.4.60401-1_all.deb || {
    echo -e "${YELLOW}⚠️ Failed to download amdgpu-install, trying latest version...${NC}"
    wget -q https://repo.radeon.com/amdgpu-install/latest/ubuntu/noble/amdgpu-install_latest_all.deb
}
sudo apt install -y ./amdgpu-install_*.deb

# Install AMD GPU drivers and ROCm (no DKMS)
print_section "Installing AMD GPU Drivers and ROCm 6.4.1"
sudo apt update
echo -e "${BLUE}Installing AMD graphics drivers (userspace only for kernel 6.14)...${NC}"
echo -e "${YELLOW}⚠️ Skipping DKMS modules - Ubuntu 25.04 kernel 6.14 has native AMD support${NC}"

# Install userspace AMD drivers
sudo apt install -y \
    mesa-vulkan-drivers \
    libdrm-amdgpu1 \
    libegl-mesa0 \
    libgl1-mesa-dri \
    libglx-mesa0 \
    xserver-xorg-video-amdgpu || {
    echo -e "${YELLOW}⚠️ Some Mesa packages not available, installing minimal set...${NC}"
    sudo apt install -y mesa-vulkan-drivers libdrm-amdgpu1 || true
}

# Install ROCm packages
echo -e "${BLUE}Installing ROCm 6.4.1 packages...${NC}"
sudo apt install -y \
    rocm-hip-sdk \
    rocm-libs \
    rocm-opencl-dev \
    rocm-dev \
    hip-dev \
    rocm-smi || {
    echo -e "${YELLOW}⚠️ Some ROCm packages failed to install, installing minimal set...${NC}"
    sudo apt install -y rocm-smi hip-dev || echo -e "${YELLOW}⚠️ Minimal ROCm installation only${NC}"
}

# Install XRT for XDNA NPU support
print_section "Installing XRT for XDNA 2 NPU Support"
echo -e "${BLUE}Checking for amdxdna driver support in kernel 6.14...${NC}"

# Check if amdxdna kernel module is available
if lsmod | grep -q amdxdna || modinfo amdxdna >/dev/null 2>&1; then
    echo -e "${GREEN}✅ amdxdna kernel driver is available${NC}"
    
    # Install build dependencies for XRT
    sudo apt install -y git build-essential cmake libudev-dev libdrm-dev
    
    # Try installing prebuilt XRT packages
    echo -e "${BLUE}Attempting to install prebuilt XRT packages...${NC}"
    sudo apt install -y xrt xrt-smi xrt-dev 2>/dev/null || {
        echo -e "${YELLOW}⚠️ Prebuilt XRT packages not available in repositories${NC}"
        echo -e "${YELLOW}   Attempting to build XRT from source...${NC}"
        cd /tmp
        if [ ! -d "xdna-driver" ]; then
            git clone https://github.com/amd/xdna-driver.git
        fi
        cd xdna-driver
        git submodule update --init --recursive
        sudo ./tools/amdxdna_deps.sh || echo -e "${YELLOW}⚠️ Dependency installation failed, continuing...${NC}"
        cd build/xrt/build
        ./build.sh -npu -opt && sudo apt reinstall -y ./Release/xrt_*.deb || {
            echo -e "${YELLOW}⚠️ XRT build failed${NC}"
            echo -e "${YELLOW}   Manual installation required: https://github.com/amd/xdna-driver${NC}"
        }
        cd ../../..
        ./build.sh -release && ./build.sh -package && sudo apt reinstall -y ./Release/xrt_plugin.*.deb || {
            echo -e "${YELLOW}⚠️ XRT plugin build failed${NC}"
            echo -e "${YELLOW}   Check https://github.com/amd/xdna-driver for updated instructions${NC}"
        }
    }
else
    echo -e "${YELLOW}⚠️ amdxdna kernel driver not detected${NC}"
    echo -e "${YELLOW}   NPU support requires kernel 6.14+ with amdxdna driver${NC}"
    echo -e "${BLUE}Checking kernel version: $(uname -r)${NC}"
fi

# Configure GPU for AI workloads
print_section "Configuring GPU for AI"
# Set HSA override for Radeon 780M (RDNA 3)
echo 'export HSA_OVERRIDE_GFX_VERSION=11.0.0' | sudo tee -a /etc/environment
echo 'export ROC_ENABLE_PRE_VEGA=1' | sudo tee -a /etc/environment
echo 'export HIP_VISIBLE_DEVICES=0' | sudo tee -a /etc/environment

# Add user to render and video groups for GPU access
sudo usermod -a -G render,video ucadmin

# Configure power management for Zen 4 CPU
print_section "Configuring CPU Power Management"
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&amd_pstate=active /' /etc/default/grub
sudo update-grub

# Create AI workspace
print_section "Setting up AI Workspace"
mkdir -p /home/ucadmin/{models,datasets,projects,notebooks}

# Install Python AI frameworks with ROCm support
print_section "Installing AI Frameworks"
python3 -m venv /home/ucadmin/ai-env
source /home/ucadmin/ai-env/bin/activate
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4
pip install \
    transformers \
    datasets \
    accelerate \
    bitsandbytes \
    scipy \
    numpy \
    pandas \
    matplotlib \
    jupyter \
    notebook

# Create hardware monitoring script
print_section "Creating Hardware Monitoring Scripts"
cat << 'EOF' | sudo tee /usr/local/bin/uc-monitor
#!/bin/bash
echo "=== UnicornCommander Hardware Status ==="
echo "CPU: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs)"
echo "CPU Temp: $(sensors | grep 'Tctl:' | awk '{print $2}' || echo 'N/A')"
echo "GPU: $(rocm-smi --showproductname | grep 'GPU' || echo 'AMD Radeon 780M')"
echo "GPU Usage: $(rocm-smi --showuse 2>/dev/null | grep -E 'GPU|GFX' | head -1 || echo 'N/A')"
echo "NPU Status: $(lspci | grep -i amd | grep -i npu || echo 'N/A')"
echo "Memory: $(free -h | grep 'Mem:' | awk '{print $3"/"$2}')"
echo "Swap: $(free -h | grep 'Swap:' | awk '{print $3"/"$2}')"
EOF
sudo chmod +x /usr/local/bin/uc-monitor

# Test hardware setup
print_section "Testing Hardware Setup"
echo -e "${GREEN}Testing ROCm installation...${NC}"
if command -v rocm-smi >/dev/null 2>&1; then
    echo -e "${GREEN}✅ ROCm installed successfully${NC}"
    rocm-smi --showproductname 2>/dev/null || echo -e "${YELLOW}⚠️ ROCm tools installed but GPU not detected${NC}"
else
    echo -e "${YELLOW}⚠️ ROCm command-line tools not available${NC}"
    if [ -d "/opt/rocm" ] || ls /opt/rocm-* >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ROCm libraries are installed${NC}"
    fi
fi

echo -e "${GREEN}Testing NPU detection...${NC}"
if lsmod | grep -q amdxdna || modinfo amdxdna >/dev/null 2>&1; then
    echo -e "${GREEN}✅ amdxdna kernel driver detected${NC}"
else
    echo -e "${YELLOW}⚠️ NPU (amdxdna) not detected; manual installation may be required${NC}"
fi

echo -e "${GREEN}🎉 Hardware and AI setup complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "  - Run '02-kde-desktop-setup.sh' to install KDE Plasma"
echo -e "  - Use 'source ~/ai-env/bin/activate' to enter AI environment"
echo -e "  - Run 'uc-monitor' to check hardware status"
echo -e "  - Reboot recommended: sudo reboot"
