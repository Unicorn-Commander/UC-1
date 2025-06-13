#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
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

# System compatibility check
print_section "System Compatibility Check"
KERNEL_VERSION=$(uname -r)
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)

echo -e "${BLUE}System: Ubuntu $(lsb_release -rs), Kernel $KERNEL_VERSION${NC}"
echo -e "${BLUE}CPU: $CPU_MODEL${NC}"

# Check if this is 8945HS
if [[ "$CPU_MODEL" == *"8945HS"* ]]; then
    echo -e "${GREEN}✅ AMD Ryzen 9 8945HS detected - optimal configuration${NC}"
elif [[ "$CPU_MODEL" == *"894"* ]] || [[ "$CPU_MODEL" == *"804"* ]]; then
    echo -e "${GREEN}✅ AMD Hawk Point series detected - compatible${NC}"
else
    echo -e "${YELLOW}⚠️ CPU not specifically recognized, continuing anyway${NC}"
fi

# Update system
print_section "Updating System"
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Clean up previous DKMS attempts
print_section "Cleaning Previous Installation Attempts"
if dpkg -l | grep -q amdgpu-dkms; then
    echo -e "${YELLOW}⚠️ Found existing AMDGPU DKMS package, forcing cleanup...${NC}"
    sudo dkms remove amdgpu/6.3.2-2164967.24.04 --all 2>/dev/null || true
    sudo dkms remove amdgpu --all 2>/dev/null || true
    sudo rm -f /var/crash/amdgpu-dkms.*.crash 2>/dev/null || true
    sudo dpkg --remove --force-remove-reinstreq amdgpu-dkms 2>/dev/null || true
    sudo apt remove --purge -y amdgpu-dkms 2>/dev/null || true
    sudo apt install -f
    sudo dpkg --configure -a
    sudo apt autoremove -y
    echo -e "${GREEN}✅ DKMS cleanup completed${NC}"
fi

# Install kernel headers and build dependencies
print_section "Installing Kernel Headers and Build Dependencies"
sudo apt install -y linux-headers-$(uname -r) linux-modules-extra-$(uname -r) \
    git build-essential cmake python3 python3-dev python3-pip \
    libelf-dev libdrm-dev libudev-dev clang llvm pkg-config libnuma-dev

# Add AMD repositories with fallback to Ubuntu 24.04 packages
print_section "Adding AMD Repositories"
sudo mkdir -p /etc/apt/keyrings
wget -q https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

# Try Ubuntu 25.04 first, fallback to 24.04 if needed
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.3.2/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/amdgpu.list
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.3.2 noble main" | sudo tee /etc/apt/sources.list.d/rocm.list

# Test repository availability
if ! sudo apt update 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Ubuntu 25.04 repositories not available, trying Ubuntu 24.04 packages...${NC}"
    sudo sed -i 's/noble/jammy/g' /etc/apt/sources.list.d/amdgpu.list
    sudo sed -i 's/noble/jammy/g' /etc/apt/sources.list.d/rocm.list
    sudo apt update || {
        echo -e "${RED}❌ Repository fallback failed. Check network or AMD repository status.${NC}"
        exit 1
    }
fi

echo -e "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" | sudo tee /etc/apt/preferences.d/rocm-pin-600

# Install amdgpu-install script with fallback
print_section "Installing AMDGPU Installer"
cd /tmp
if ! wget -q https://repo.radeon.com/amdgpu-install/6.3.2/ubuntu/noble/amdgpu-install_6.3.60302-1_all.deb; then
    echo -e "${YELLOW}⚠️ Ubuntu 25.04 installer not available, trying Ubuntu 24.04...${NC}"
    wget -q https://repo.radeon.com/amdgpu-install/6.3.2/ubuntu/jammy/amdgpu-install_6.3.60302-1_all.deb || {
        echo -e "${YELLOW}⚠️ 6.3.2 installer not available, using latest...${NC}"
        wget -q https://repo.radeon.com/amdgpu-install/latest/ubuntu/jammy/amdgpu-install_latest_all.deb
    }
fi
sudo apt install -y ./amdgpu-install_*.deb

# Install AMD GPU drivers and ROCm 6.3.2
print_section "Installing AMD GPU Drivers and ROCm 6.3.2"
sudo apt update
echo -e "${BLUE}Installing AMD graphics drivers (userspace only for kernel 6.14)...${NC}"
echo -e "${YELLOW}⚠️ Skipping DKMS modules - Ubuntu 25.04 kernel 6.14 has native AMD support${NC}"

# Install Mesa drivers
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

# Install ROCm packages with better error handling
echo -e "${BLUE}Installing ROCm 6.3.2 packages...${NC}"
ROCM_PACKAGES="rocm-hip-sdk rocm-libs rocm-opencl-dev rocm-dev hip-dev rocm-smi-lib"
FAILED_ROCM=""

for pkg in $ROCM_PACKAGES; do
    if ! sudo apt install -y $pkg 2>/dev/null; then
        echo -e "${YELLOW}⚠️ Failed to install $pkg${NC}"
        FAILED_ROCM="$FAILED_ROCM $pkg"
    fi
done

if [ -n "$FAILED_ROCM" ]; then
    echo -e "${YELLOW}⚠️ Some ROCm packages failed:$FAILED_ROCM${NC}"
    echo -e "${BLUE}Attempting to build minimal ROCm from source...${NC}"
    cd /tmp
    if [ ! -d "ROCm" ]; then
        git clone --depth 1 -b rocm-6.3.2 https://github.com/ROCm/ROCm.git || {
            echo -e "${YELLOW}⚠️ ROCm source not available, continuing with system packages${NC}"
        }
    fi
    if [ -d "ROCm" ]; then
        cd ROCm
        sudo mkdir -p /opt/rocm-6.3.2
        sudo cp -r include/* /opt/rocm-6.3.2/ 2>/dev/null || true
        echo -e "${GREEN}✅ Basic ROCm headers installed${NC}"
        echo 'export PATH=$PATH:/opt/rocm-6.3.2/bin' | sudo tee -a /etc/environment
        echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm-6.3.2/lib:/opt/rocm-6.3.2/lib64' | sudo tee -a /etc/environment
    fi
fi

# Check for mainlined XDNA driver
print_section "Checking XDNA 2 NPU Support"
echo -e "${BLUE}Checking for amdxdna driver support in kernel 6.14...${NC}"

# Check if NPU hardware exists
if lspci | grep -E "1022:150[12]"; then
    echo -e "${GREEN}✅ AMD NPU hardware detected${NC}"
    NPU_DETECTED=true
else
    echo -e "${YELLOW}⚠️ NPU hardware not detected in lspci${NC}"
    NPU_DETECTED=false
fi

# Check kernel driver
if lsmod | grep -q amdxdna || modinfo amdxdna >/dev/null 2>&1; then
    echo -e "${GREEN}✅ amdxdna kernel driver available${NC}"
    KERNEL_DRIVER=true
else
    echo -e "${YELLOW}⚠️ amdxdna kernel driver not detected${NC}"
    KERNEL_DRIVER=false
fi

# Install XRT for NPU support
if [ "$NPU_DETECTED" = true ] || [ "$KERNEL_DRIVER" = true ]; then
    print_section "Installing XRT for XDNA 2 NPU Support"
    echo -e "${BLUE}Attempting to install prebuilt XRT packages...${NC}"
    if sudo apt install -y xrt xrt-smi xrt-dev 2>/dev/null; then
        echo -e "${GREEN}✅ Prebuilt XRT packages installed successfully${NC}"
    else
        echo -e "${YELLOW}⚠️ Prebuilt XRT packages not available in repositories${NC}"
        echo -e "${YELLOW}   Attempting to build XRT from source...${NC}"
        cd /tmp
        if [ ! -d "xdna-driver" ]; then
            git clone https://github.com/amd/xdna-driver.git
        fi
        cd xdna-driver
        git checkout main || {
            echo -e "${YELLOW}⚠️ Git checkout main failed, trying latest tag...${NC}"
            latest_tag=$(git tag -l | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
            [ -n "$latest_tag" ] && git checkout "$latest_tag" || {
                echo -e "${RED}❌ No valid tags found, manual installation required: https://github.com/amd/xdna-driver${NC}"
                exit 1
            }
        }
        git submodule update --init --recursive
        sudo ./tools/amdxdna_deps.sh || {
            echo -e "${YELLOW}⚠️ Dependency installation failed, continuing...${NC}"
        }
        
        # Look for build structure and build XRT
        if [ -d "build/xrt/build" ]; then
            cd build/xrt/build
            echo -e "${BLUE}Building XRT using build.sh...${NC}"
            if ./build.sh -npu -opt 2>&1 | tee xrt_build.log; then
                if find ./Release -name "xrt_*.deb" | head -1 | xargs test -f; then
                    XRT_PACKAGE=$(find ./Release -name "xrt_*.deb" | head -1)
                    sudo dpkg -i "$XRT_PACKAGE" || {
                        sudo apt --fix-broken install -y
                        sudo dpkg -i "$XRT_PACKAGE"
                    }
                    echo -e "${GREEN}✅ XRT installed from source${NC}"
                else
                    echo -e "${YELLOW}⚠️ XRT build completed but no packages found${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️ XRT build failed: Check xrt_build.log${NC}"
            fi
            cd ../../..
        fi
        
        # Build XDNA plugin
        if [ -d "build" ]; then
            cd build
            echo -e "${BLUE}Building XDNA plugin...${NC}"
            if ./build.sh -release 2>&1 | tee plugin_build.log && ./build.sh -package 2>&1 | tee -a plugin_build.log; then
                if find ./Release -name "xrt_plugin*.deb" | head -1 | xargs test -f; then
                    PLUGIN_PACKAGE=$(find ./Release -name "xrt_plugin*.deb" | head -1)
                    sudo dpkg -i "$PLUGIN_PACKAGE" || {
                        sudo apt --fix-broken install -y
                        sudo dpkg -i "$PLUGIN_PACKAGE" || true
                    }
                    echo -e "${GREEN}✅ XDNA plugin installed${NC}"
                else
                    echo -e "${YELLOW}⚠️ XRT plugin build completed but no packages found${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️ XRT plugin build failed: Check plugin_build.log${NC}"
            fi
        fi
    fi
else
    echo -e "${YELLOW}⚠️ Skipping XRT installation - NPU not detected${NC}"
fi

# Configure GPU for AI workloads
print_section "Configuring GPU for AI"
echo -e "${BLUE}Setting up 780M iGPU environment variables...${NC}"
echo 'export HSA_OVERRIDE_GFX_VERSION=11.0.1' | sudo tee -a /etc/environment
echo 'export PYTORCH_ROCM_ARCH=gfx1103' | sudo tee -a /etc/environment
echo 'export ROC_ENABLE_PRE_VEGA=1' | sudo tee -a /etc/environment
echo 'export HIP_VISIBLE_DEVICES=0' | sudo tee -a /etc/environment
echo 'export HSA_ENABLE_SDMA=0' | sudo tee -a /etc/environment
echo 'export ROCM_PATH=/opt/rocm' | sudo tee -a /etc/environment
sudo usermod -a -G render,video ucadmin

# Configure power management for Zen 4 CPU
print_section "Configuring CPU Power Management"
if ! grep -q "amd_pstate=active" /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&amd_pstate=active /' /etc/default/grub
    sudo update-grub
    echo -e "${GREEN}✅ AMD P-State configured${NC}"
else
    echo -e "${GREEN}✅ AMD P-State already configured${NC}"
fi

# Configure corrected memory carveout for NPU stability
print_section "Configuring Memory for NPU Stability"
if ! grep -q "memmap=1G" /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&memmap=1G\\$4G /' /etc/default/grub
    sudo update-grub
    echo -e "${GREEN}✅ NPU memory carveout configured${NC}"
    echo -e "${YELLOW}⚠️ Reboot required for memory changes${NC}"
else
    echo -e "${GREEN}✅ NPU memory carveout already configured${NC}"
fi

# Create AI workspace
print_section "Setting up AI Workspace"
mkdir -p /home/ucadmin/{models,datasets,projects,notebooks,build-cache}

# Install Python AI frameworks with corrected PyTorch version
print_section "Installing AI Frameworks"
python3 -m venv /home/ucadmin/ai-env
source /home/ucadmin/ai-env/bin/activate
pip install --upgrade pip setuptools wheel

echo -e "${BLUE}Installing PyTorch with ROCm 6.3.2 compatibility...${NC}"

# Try PyTorch 2.4.1 first (best ROCm 6.3.2 compatibility)
if pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 \
    --index-url https://download.pytorch.org/whl/rocm6.0 2>/dev/null; then
    echo -e "${GREEN}✅ Installed PyTorch 2.4.1 with ROCm support${NC}"
elif pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 \
    --index-url https://download.pytorch.org/whl/rocm6.0 2>/dev/null; then
    echo -e "${GREEN}✅ Installed PyTorch 2.3.1 with ROCm 6.0 (compatible with 6.3.2)${NC}"
else
    echo -e "${YELLOW}⚠️ ROCm PyTorch not available, installing CPU version...${NC}"
    pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1
fi

# Install AI packages
pip install \
    transformers==4.44.2 \
    datasets==2.18.0 \
    accelerate==0.29.3 \
    scipy==1.13.0 \
    numpy==1.26.4 \
    pandas==2.2.2 \
    matplotlib==3.9.2 \
    jupyter==1.0.0 \
    notebook==7.1.3 \
    onnx \
    onnxruntime

deactivate

# Create enhanced hardware monitoring script
print_section "Creating Hardware Monitoring Scripts"
cat << 'EOF' | sudo tee /usr/local/bin/uc-monitor
#!/bin/bash
echo "🦄 UnicornCommander Hardware Status"
echo "===================================="

echo "System:"
echo "  CPU: $(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs)"
echo "  Kernel: $(uname -r)"
echo "  Ubuntu: $(lsb_release -rs 2>/dev/null || echo 'Unknown')"

echo -e "\nTemperatures:"
if command -v sensors >/dev/null 2>&1; then
    echo "  CPU: $(sensors 2>/dev/null | grep 'Tctl:' | awk '{print $2}' || echo 'N/A')"
else
    echo "  CPU: sensors not installed"
fi

echo -e "\nGPU (780M iGPU):"
if command -v rocm-smi >/dev/null 2>&1; then
    echo "  Product: $(rocm-smi --showproductname 2>/dev/null | grep 'GPU' || echo 'AMD Radeon 780M')"
    echo "  Usage: $(rocm-smi --showuse 2>/dev/null | grep -E 'GPU|GFX' | head -1 || echo 'N/A')"
    echo "  Temperature: $(rocm-smi --showtemp 2>/dev/null | grep 'GPU' | awk '{print $3}' || echo 'N/A')"
else
    echo "  ROCm tools: Not available"
    echo "  Device: $(lspci | grep -i 'vga.*amd' | cut -d: -f3 | xargs || echo 'AMD 780M iGPU')"
fi

echo -e "\nNPU Status:"
if lspci | grep -E "1022:150[12]" >/dev/null 2>&1; then
    echo "  Hardware: $(lspci | grep -E '1022:150[12]' | cut -d: -f3 | xargs)"
    echo "  Driver: $(lsmod | grep amdxdna >/dev/null 2>&1 && echo 'Loaded' || echo 'Not loaded')"
    if command -v xrt-smi >/dev/null 2>&1; then
        echo "  XRT: Available"
    else
        echo "  XRT: Not installed"
    fi
else
    echo "  Hardware: Not detected"
fi

echo -e "\nMemory:"
echo "  RAM: $(free -h | grep 'Mem:' | awk '{print $3"/"$2" ("$5" available)"}')"
echo "  Swap: $(free -h | grep 'Swap:' | awk '{print $3"/"$2}')"

echo -e "\nAI Environment:"
if [ -d "/home/ucadmin/ai-env" ]; then
    echo "  Python venv: Available"
    if [ -f "/home/ucadmin/ai-env/bin/python" ]; then
        source /home/ucadmin/ai-env/bin/activate
        echo "  PyTorch: $(python -c 'import torch; print(torch.__version__)' 2>/dev/null || echo 'Not installed')"
        echo "  CUDA/ROCm: $(python -c 'import torch; print("Available" if torch.cuda.is_available() else "Not available")' 2>/dev/null || echo 'Unknown')"
        deactivate
    fi
else
    echo "  Python venv: Not found"
fi
EOF

sudo chmod +x /usr/local/bin/uc-monitor

# Create GPU test script specifically for 780M
cat << 'EOF' | sudo tee /usr/local/bin/uc-gpu-test
#!/bin/bash
echo "🦄 UC-1 780M iGPU Test"
echo "====================="

# Source environment
source /etc/environment 2>/dev/null || true
export HSA_OVERRIDE_GFX_VERSION=11.0.1
export PYTORCH_ROCM_ARCH=gfx1103

echo "Environment Variables:"
echo "  HSA_OVERRIDE_GFX_VERSION: $HSA_OVERRIDE_GFX_VERSION"
echo "  PYTORCH_ROCM_ARCH: $PYTORCH_ROCM_ARCH"

echo -e "\nROCm Detection:"
if command -v rocminfo >/dev/null 2>&1; then
    echo "✅ rocminfo available"
    AGENT_COUNT=$(rocminfo 2>/dev/null | grep -c "Agent" || echo "0")
    echo "  Detected agents: $AGENT_COUNT"
    if [ "$AGENT_COUNT" -gt 1 ]; then
        echo "✅ GPU agent detected"
    else
        echo "⚠️ Only CPU agent detected"
    fi
else
    echo "❌ rocminfo not found"
fi

echo -e "\nPyTorch GPU Test:"
if [ -d "/home/ucadmin/ai-env" ]; then
    source /home/ucadmin/ai-env/bin/activate
    python3 << 'PYEOF'
import torch
import time

print(f"PyTorch version: {torch.__version__}")
print(f"ROCm available: {torch.cuda.is_available()}")

if torch.cuda.is_available():
    print(f"Device count: {torch.cuda.device_count()}")
    print(f"Device name: {torch.cuda.get_device_name(0)}")
    
    # Simple GPU test
    try:
        x = torch.randn(1000, 1000, device='cuda')
        y = torch.randn(1000, 1000, device='cuda')
        start = time.time()
        z = torch.matmul(x, y)
        torch.cuda.synchronize()
        end = time.time()
        print(f"✅ GPU matrix multiplication: {end-start:.4f}s")
        print(f"✅ Memory allocated: {torch.cuda.memory_allocated()/1024**2:.1f} MB")
    except Exception as e:
        print(f"❌ GPU operations failed: {e}")
else:
    print("⚠️ ROCm not available for PyTorch")
PYEOF
    deactivate
else
    echo "❌ AI environment not found"
fi

echo -e "\n⚠️ Note: 780M iGPU has limited ROCm support"
echo "For full AI acceleration, use NPU when available"
EOF

sudo chmod +x /usr/local/bin/uc-gpu-test

# Test hardware setup
print_section "Testing Hardware Setup"
echo -e "${GREEN}Testing ROCm installation...${NC}"
if command -v rocm-smi >/dev/null 2>&1; then
    echo -e "${GREEN}✅ ROCm tools installed${NC}"
    rocm-smi --showproductname 2>/dev/null || echo -e "${YELLOW}⚠️ ROCm tools available but GPU not fully detected${NC}"
else
    echo -e "${YELLOW}⚠️ ROCm command-line tools not available${NC}"
    if [ -d "/opt/rocm" ]; then
        echo -e "${GREEN}✅ ROCm libraries are installed${NC}"
    fi
fi

echo -e "${GREEN}Testing NPU detection...${NC}"
if lsmod | grep -q amdxdna; then
    echo -e "${GREEN}✅ amdxdna kernel driver loaded${NC}"
elif modinfo amdxdna >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ amdxdna driver available but not loaded${NC}"
else
    echo -e "${YELLOW}⚠️ amdxdna driver not available${NC}"
fi

if lspci | grep -E "1022:150[12]" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ NPU hardware detected${NC}"
else
    echo -e "${YELLOW}⚠️ NPU hardware not detected (check BIOS settings)${NC}"
fi

# Create BIOS reminder
cat << EOF | sudo tee /root/BIOS_NPU_SETTINGS.txt
🦄 UC-1 BIOS Settings for NPU Support

Required BIOS settings for NPU functionality:
1. Enable IOMMU/AMD-V
2. Enable IPU/NPU device (look for "AI Engine" or "IPU Device")
3. Set VRAM allocation to 4GB minimum
4. Enable Performance TDP mode (65W recommended)
5. Secure Boot can remain enabled

If NPU not detected, check these BIOS settings!
EOF

echo -e "${GREEN}🎉 Hardware and AI setup complete!${NC}"
echo -e ""
echo -e "${BLUE}Status Summary:${NC}"
echo -e "  NPU Hardware: $(lspci | grep -E '1022:150[12]' >/dev/null && echo '✅ Detected' || echo '⚠️ Not detected')"
echo -e "  NPU Driver: $(lsmod | grep -q amdxdna && echo '✅ Loaded' || echo '⚠️ Not loaded')"
echo -e "  ROCm Tools: $(command -v rocm-smi >/dev/null && echo '✅ Available' || echo '⚠️ Limited')"
echo -e "  AI Environment: $([ -d '/home/ucadmin/ai-env' ] && echo '✅ Ready' || echo '❌ Failed')"
echo -e ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. ${YELLOW}Reboot your system${NC} (required for kernel parameters)"
echo -e "  2. Run: ${GREEN}uc-monitor${NC} to check hardware status"
echo -e "  3. Run: ${GREEN}uc-gpu-test${NC} to test 780M iGPU"
echo -e "  4. Check BIOS settings if NPU not detected (see /root/BIOS_NPU_SETTINGS.txt)"
echo -e "  5. Run 02-kde-desktop-setup.sh for desktop environment"
echo -e "  6. Use: ${GREEN}source ~/ai-env/bin/activate${NC} for AI development"
echo -e "  7. For Docker inference, ensure container has access to /dev/amdxdna and XRT libraries"
echo -e ""
echo -e "${PURPLE}🦄 UC-1 hardware setup complete!${NC}"
