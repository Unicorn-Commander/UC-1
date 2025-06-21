#!/bin/bash
# 02-rocm_ryzenai_setup.sh - Complete ROCm 6.4.1, Ryzen AI, and Vulkan Setup
# For AMD Ryzen 9 8945HS with Radeon 780M iGPU and XDNA 2 NPU on Ubuntu 25.04
# Version: 2.0 - Production Ready

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_FILE="/home/$USER/rocm_setup_$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="/home/$USER/rocm_setup_backup"
ROCM_VERSION="6.4.1"
UBUNTU_VERSION=$(lsb_release -rs)
UBUNTU_CODENAME=$(lsb_release -cs)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# Check for test mode
TEST_MODE=false
if [[ "${1:-}" == "--test" || "${1:-}" == "--dry-run" ]]; then
    TEST_MODE=true
    info "Running in test mode - no actual installations will be performed"
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root!"
   exit 1
fi

# System verification
log "Starting ROCm + Ryzen AI Complete Setup"
log "System: Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME)"
log "Target: AMD Ryzen 9 8945HS with Radeon 780M + XDNA 2 NPU"

# Backup existing configurations
backup_configs() {
    log "Backing up existing configurations..."
    
    # Backup sources.list
    if [ -f /etc/apt/sources.list ]; then
        sudo cp /etc/apt/sources.list "$BACKUP_DIR/sources.list.bak"
    fi
    
    # Backup existing ROCm configs
    if [ -d /etc/apt/sources.list.d ]; then
        sudo cp -r /etc/apt/sources.list.d "$BACKUP_DIR/" 2>/dev/null || true
    fi
    
    # Backup grub
    if [ -f /etc/default/grub ]; then
        sudo cp /etc/default/grub "$BACKUP_DIR/grub.bak"
    fi
}

# Step 1: System Prerequisites
install_prerequisites() {
    log "Installing system prerequisites..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would update system and install packages"
        return 0
    fi
    
    # Update system
    sudo apt update >> "$LOG_FILE" 2>&1
    
    # Install essential packages
    sudo apt install -y \
        linux-firmware \
        linux-headers-$(uname -r) \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        libdrm-dev \
        libelf-dev \
        llvm \
        clang \
        lld \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        curl \
        wget \
        git \
        gnupg2 \
        software-properties-common \
        lsb-release \
        cpufrequtils \
        radeontop \
        htop \
        nvtop \
        mesa-utils \
        libgl1-mesa-dri \
        libgles2-mesa-dev \
        ocl-icd-libopencl1 \
        opencl-headers \
        clinfo >> "$LOG_FILE" 2>&1
    
    log "Prerequisites installed successfully"
}

# Step 2: Add kernel parameters for Radeon 780M
configure_kernel_parameters() {
    log "Configuring kernel parameters for Radeon 780M..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would configure kernel parameters"
        return 0
    fi
    
    GRUB_PARAMS="amdgpu.noretry=0 amdgpu.vm_fragment_size=9 amdgpu.mcbp=1 amdgpu.dpm=1 amdgpu.dc=1"
    
    if ! grep -q "amdgpu.noretry" /etc/default/grub; then
        sudo cp /etc/default/grub "$BACKUP_DIR/grub.bak"
        sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_PARAMS /" /etc/default/grub
        sudo update-grub >> "$LOG_FILE" 2>&1
        log "Kernel parameters added - reboot required"
    else
        log "Kernel parameters already configured"
    fi
}

# Step 3: Install ROCm
install_rocm() {
    log "Installing ROCm $ROCM_VERSION..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would install ROCm $ROCM_VERSION"
        return 0
    fi
    
    # Remove any existing ROCm installations
    if [ -d /opt/rocm ]; then
        warning "Existing ROCm installation found, cleaning up..."
        sudo apt remove -y rocm-* hip-* rocrand* rocblas* miopen* >> "$LOG_FILE" 2>&1 || true
        sudo rm -rf /opt/rocm*
    fi
    
    # Add AMD GPU repository GPG key (modern method)
    wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/rocm-archive-keyring.gpg >> "$LOG_FILE" 2>&1
    
    # Try to add repository for Ubuntu 25.04
    if [[ "$UBUNTU_VERSION" == "25.04" ]]; then
        # First try with oracular
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/rocm-archive-keyring.gpg] https://repo.radeon.com/rocm/apt/$ROCM_VERSION oracular main" | sudo tee /etc/apt/sources.list.d/rocm.list
        
        # If oracular fails, fallback to noble
        if ! sudo apt update >> "$LOG_FILE" 2>&1; then
            warning "Oracular repository not available, falling back to Noble..."
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/rocm-archive-keyring.gpg] https://repo.radeon.com/rocm/apt/$ROCM_VERSION noble main" | sudo tee /etc/apt/sources.list.d/rocm.list
            sudo apt update >> "$LOG_FILE" 2>&1
        fi
    else
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/rocm-archive-keyring.gpg] https://repo.radeon.com/rocm/apt/$ROCM_VERSION $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/rocm.list
        sudo apt update >> "$LOG_FILE" 2>&1
    fi
    
    # Install ROCm packages directly (Ubuntu 25.04 has native AMDGPU support)
    log "Installing ROCm packages directly..."
    
    # Set non-interactive mode to prevent hanging on prompts
    export DEBIAN_FRONTEND=noninteractive
    
    sudo -E apt install -y \
        rocm-dev \
        rocm-libs \
        rocm-utils \
        rocm-cmake \
        rocm-llvm \
        hip-runtime-amd \
        hip-dev \
        hipblas \
        hipfft \
        hipsparse \
        hipcub \
        rocblas \
        rocsparse \
        rocfft \
        rocrand \
        rccl \
        miopen-hip \
        rocm-smi-lib \
        roctracer-dev \
        rocprofiler-dev >> "$LOG_FILE" 2>&1
    
    ROCm_INSTALL_EXIT_CODE=$?
    if [ $ROCm_INSTALL_EXIT_CODE -eq 0 ]; then
        log "ROCm installed successfully"
    else
        error "ROCm installation failed with exit code $ROCm_INSTALL_EXIT_CODE"
        warning "Check log file for details: $LOG_FILE"
        
        # Try minimal installation as fallback
        warning "Attempting minimal ROCm installation..."
        if sudo -E apt install -y rocm-dev hip-runtime-amd rocm-libs >> "$LOG_FILE" 2>&1; then
            log "Minimal ROCm installation succeeded"
        else
            error "Both full and minimal ROCm installation failed"
            return 1
        fi
    fi
    
    # Add user to necessary groups
    sudo usermod -a -G render,video $USER
    
    
    log "ROCm installation completed"
}

# Step 4: Install Vulkan support
install_vulkan() {
    log "Installing Vulkan support for Radeon 780M..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would install Vulkan support"
        return 0
    fi
    
    sudo apt install -y \
        vulkan-tools \
        vulkan-utility-libraries-dev \
        libvulkan1 \
        libvulkan-dev \
        mesa-vulkan-drivers >> "$LOG_FILE" 2>&1
    
    log "Vulkan support installed"
}

# Step 5: Build and Install XRT from Source for XDNA NPU support
install_xrt_npu() {
    log "Building and installing XRT from source for XDNA NPU support..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would build and install XRT from source"
        return 0
    fi
    
    # Ubuntu 25.04 kernel 6.14 has native AMDXDNA support
    log "Ubuntu 25.04 has native AMDXDNA NPU support in kernel 6.14"
    
    # Check if XDNA driver is loaded
    if lsmod | grep -q amdxdna; then
        log "AMDXDNA kernel driver detected"
    else
        warning "AMDXDNA kernel driver not loaded - NPU may not be available"
    fi
    
    # Install XRT build dependencies
    log "Installing XRT build dependencies..."
    sudo apt install -y \
        build-essential \
        cmake \
        ninja-build \
        git \
        libboost-all-dev \
        libssl-dev \
        libudev-dev \
        libxml2-dev \
        libyaml-dev \
        libelf-dev \
        libncurses5-dev \
        libtinfo-dev \
        libprotobuf-dev \
        protobuf-compiler \
        libcurl4-openssl-dev \
        python3-dev \
        python3-pip \
        python3-pybind11 \
        uuid-dev \
        ocl-icd-opencl-dev \
        opencl-headers \
        dkms >> "$LOG_FILE" 2>&1
    
    # Create build directory
    BUILD_DIR="/tmp/xrt-build"
    XRT_INSTALL_DIR="/opt/xilinx/xrt"
    
    # Remove existing installation
    if [ -d "$XRT_INSTALL_DIR" ]; then
        log "Removing existing XRT installation..."
        sudo rm -rf "$XRT_INSTALL_DIR"
    fi
    
    # Clean up any previous build
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Clone XDNA driver repository with XRT submodule
    log "Cloning AMD XDNA driver repository with XRT submodule..."
    git clone --recursive https://github.com/amd/xdna-driver.git >> "$LOG_FILE" 2>&1
    
    if [ $? -ne 0 ]; then
        error "Failed to clone XDNA driver repository"
        return 1
    fi
    
    cd xdna-driver
    
    # Install XDNA dependencies
    log "Installing XDNA dependencies..."
    sudo ./tools/amdxdna_deps.sh >> "$LOG_FILE" 2>&1
    
    # Build XRT base package
    log "Building XRT base package (this may take 30-60 minutes)..."
    cd xrt/build
    
    # Configure build with NPU support
    ./build.sh -npu -opt >> "$LOG_FILE" 2>&1
    
    if [ $? -ne 0 ]; then
        error "XRT base build failed"
        return 1
    fi
    
    # Install XRT base package
    log "Installing XRT base package..."
    XRT_BASE_DEB=$(find Release -name "xrt_*-amd64-base.deb" | head -1)
    if [ -f "$XRT_BASE_DEB" ]; then
        sudo apt install -y "./$XRT_BASE_DEB" >> "$LOG_FILE" 2>&1
        log "XRT base package installed successfully"
    else
        error "XRT base package not found"
        return 1
    fi
    
    # Build XDNA driver and plugin
    log "Building XDNA driver and XRT plugin..."
    cd ../../build
    
    ./build.sh -release >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        error "XDNA driver build failed"
        return 1
    fi
    
    ./build.sh -package >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        error "XDNA plugin package build failed"
        return 1
    fi
    
    # Install XDNA plugin package
    log "Installing XDNA plugin package..."
    XRT_PLUGIN_DEB=$(find Release -name "xrt_plugin*-amdxdna.deb" | head -1)
    if [ -f "$XRT_PLUGIN_DEB" ]; then
        sudo apt install -y "./$XRT_PLUGIN_DEB" >> "$LOG_FILE" 2>&1
        log "XRT XDNA plugin installed successfully"
    else
        error "XRT XDNA plugin package not found"
        return 1
    fi
    
    # Clean up build directory
    cd /
    rm -rf "$BUILD_DIR"
    
    # Verify installation
    if [ -f "$XRT_INSTALL_DIR/setup.sh" ]; then
        log "XRT source build and installation completed successfully"
    else
        error "XRT installation verification failed"
        return 1
    fi
}

# Step 6: Create environment configuration
create_environment() {
    log "Creating ROCm environment configuration..."
    
    cat > "$HOME/rocm_env.sh" << 'EOF'
#!/bin/bash
# ROCm environment for AMD Radeon 780M (gfx1103) and XDNA 2 NPU
# Updated for source-built XRT installation

# ROCm paths
export ROCM_PATH=/opt/rocm
export ROCM_HOME=$ROCM_PATH
export PATH=$ROCM_PATH/bin:$ROCM_PATH/llvm/bin:$PATH
export LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib64:$ROCM_PATH/llvm/lib:$LD_LIBRARY_PATH

# HIP Configuration
export HIP_PATH=$ROCM_PATH/hip
export HIP_PLATFORM=amd
export HIP_RUNTIME=rocclr
export HIP_COMPILER=clang

# 780M iGPU support (gfx1103)
export HSA_OVERRIDE_GFX_VERSION=11.0.3
export HSA_ENABLE_SDMA=0
export HIP_VISIBLE_DEVICES=0
export GPU_MAX_HW_QUEUES=8

# XRT Environment (Source Build)
export XILINX_XRT=/opt/xilinx/xrt
export XRT_ROOT=$XILINX_XRT

# XRT paths and libraries
if [ -d "$XILINX_XRT" ]; then
    export PATH=$XILINX_XRT/bin:$PATH
    export LD_LIBRARY_PATH=$XILINX_XRT/lib:$LD_LIBRARY_PATH
    export PYTHONPATH=$XILINX_XRT/python:$PYTHONPATH
    
    # Source XRT setup script if available
    if [ -f "$XILINX_XRT/setup.sh" ]; then
        source $XILINX_XRT/setup.sh
    fi
    
    # XRT plugin for XDNA
    if [ -d "$XILINX_XRT/lib" ]; then
        export LD_LIBRARY_PATH=$XILINX_XRT/lib:$LD_LIBRARY_PATH
    fi
fi

# XDNA/NPU Configuration
export XDNA_DEVICE_PATH=/dev/accel/accel0
export XDNA_LOG_LEVEL=1

# NPU Runtime Environment
export XLNX_ENABLE_FINGERPRINT_CHECK=0
export XLNX_ENABLE_CACHE=1

# Performance optimizations
export OMP_NUM_THREADS=16
export MKL_NUM_THREADS=16
export OPENBLAS_NUM_THREADS=16

# OpenCL
export OCL_ICD_VENDORS=/etc/OpenCL/vendors/

# Vulkan
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json

# Status reporting
echo "ROCm environment loaded for Radeon 780M + XDNA 2 NPU"
echo "ROCm Path: $ROCM_PATH"
echo "HIP Platform: $HIP_PLATFORM"
echo "HSA Override: $HSA_OVERRIDE_GFX_VERSION"
echo "XRT Path: $XILINX_XRT"
echo "XRT Available: $(command -v xrt-smi >/dev/null && echo 'Yes' || echo 'No')"
echo "XDNA Device: $([ -e "$XDNA_DEVICE_PATH" ] && echo 'Found' || echo 'Not Found')"
EOF

    chmod +x "$HOME/rocm_env.sh"
    
    # Add to bashrc
    if ! grep -q "rocm_env.sh" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# ROCm environment" >> "$HOME/.bashrc"
        echo "[ -f $HOME/rocm_env.sh ] && source $HOME/rocm_env.sh" >> "$HOME/.bashrc"
    fi
    
    log "Environment configuration created"
}

# Step 7: System optimizations
apply_system_optimizations() {
    log "Applying system optimizations for AI workloads..."
    
    if [[ "$TEST_MODE" == "true" ]]; then
        info "TEST MODE: Would apply system optimizations"
        return 0
    fi
    
    # CPU governor
    echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils >> "$LOG_FILE"
    sudo systemctl enable cpufrequtils >> "$LOG_FILE" 2>&1
    
    # Sysctl optimizations
    cat << EOF | sudo tee /etc/sysctl.d/99-rocm-ai.conf >> "$LOG_FILE"
# ROCm and AI workload optimizations
vm.swappiness=10
vm.nr_hugepages=2048
vm.max_map_count=262144
vm.overcommit_memory=1
kernel.shmmax=68719476736
kernel.shmall=16777216
kernel.numa_balancing=0
vm.zone_reclaim_mode=0
EOF

    sudo sysctl -p /etc/sysctl.d/99-rocm-ai.conf >> "$LOG_FILE" 2>&1
    
    log "System optimizations applied"
}

# Step 8: Create verification script
create_verification_script() {
    log "Creating verification script..."
    
    cat > "$HOME/test_rocm.sh" << 'EOF'
#!/bin/bash
source $HOME/rocm_env.sh

echo "=== ROCm + XRT Installation Test ==="
echo "Date: $(date)"
echo "Kernel: $(uname -r)"
echo ""

# Check kernel modules
echo "=== Kernel Modules ==="
echo "AMD GPU module:"
lsmod | grep amdgpu || echo "amdgpu module not loaded"
echo "XDNA NPU module:"
lsmod | grep amdxdna || echo "amdxdna module not loaded"
echo ""

# ROCm Info
echo "=== ROCm Information ==="
if command -v rocminfo >/dev/null 2>&1; then
    rocminfo | grep -E "(Name:|Marketing Name:|Compute Unit:|Memory Size:|Chip ID:|ASIC Revision:)" | head -20
else
    echo "rocminfo not found - ROCm may not be properly installed"
fi
echo ""

# HIP Info
echo "=== HIP Configuration ==="
if command -v hipconfig >/dev/null 2>&1; then
    hipconfig --full
else
    echo "HIP Platform: $HIP_PLATFORM"
    echo "HIP Runtime: $HIP_RUNTIME"
    echo "HIP Path: $HIP_PATH"
fi
echo ""

# XRT Installation Verification
echo "=== XRT Installation Status ==="
echo "XRT Path: $XILINX_XRT"
echo "XRT Installation: $([ -d "$XILINX_XRT" ] && echo 'Found' || echo 'Not Found')"
echo "XRT Setup Script: $([ -f "$XILINX_XRT/setup.sh" ] && echo 'Found' || echo 'Not Found')"
echo "XRT Libraries: $([ -d "$XILINX_XRT/lib" ] && echo 'Found' || echo 'Not Found')"
echo ""

# XRT Commands Test
echo "=== XRT Tools Test ==="
if command -v xrt-smi >/dev/null 2>&1; then
    echo "xrt-smi version:"
    xrt-smi version 2>/dev/null || echo "xrt-smi version failed"
    echo ""
    echo "xrt-smi examine:"
    xrt-smi examine 2>/dev/null || echo "xrt-smi examine failed"
else
    echo "xrt-smi not found in PATH"
fi

if command -v xbutil >/dev/null 2>&1; then
    echo ""
    echo "xbutil scan:"
    xbutil scan 2>/dev/null || echo "xbutil scan failed"
else
    echo "xbutil not found in PATH"
fi
echo ""

# NPU Device Status
echo "=== NPU Device Status ==="
echo "XDNA Device Path: $XDNA_DEVICE_PATH"
echo "XDNA Device Status: $([ -e "$XDNA_DEVICE_PATH" ] && echo 'Found' || echo 'Not Found')"
if [ -e "$XDNA_DEVICE_PATH" ]; then
    ls -la "$XDNA_DEVICE_PATH"
fi
echo ""

# OpenCL Info
echo "=== OpenCL Devices ==="
if command -v clinfo >/dev/null 2>&1; then
    clinfo -l 2>/dev/null || echo "No OpenCL devices found"
else
    echo "clinfo not installed"
fi
echo ""

# Vulkan Info
echo "=== Vulkan Devices ==="
if command -v vulkaninfo >/dev/null 2>&1; then
    vulkaninfo --summary 2>/dev/null | grep -E "(deviceName|deviceType|driverVersion)" | head -10
else
    echo "vulkaninfo not available"
fi
echo ""

# GPU/NPU devices
echo "=== Hardware Devices ==="
echo "DRI devices:"
ls -la /dev/dri/ 2>/dev/null || echo "No DRI devices found"
echo "KFD device:"
ls -la /dev/kfd 2>/dev/null || echo "No KFD device found"
echo "ACCEL devices (NPU):"
ls -la /dev/accel/ 2>/dev/null || echo "No ACCEL devices found"
echo ""

# Memory info
echo "=== Memory Information ==="
free -h
echo ""
echo "Huge Pages:"
cat /proc/meminfo | grep Huge
echo ""

# Environment Variables Summary
echo "=== Environment Summary ==="
echo "ROCM_PATH: $ROCM_PATH"
echo "XILINX_XRT: $XILINX_XRT"
echo "HIP_PLATFORM: $HIP_PLATFORM"
echo "HSA_OVERRIDE_GFX_VERSION: $HSA_OVERRIDE_GFX_VERSION"
echo "XDNA_LOG_LEVEL: $XDNA_LOG_LEVEL"
EOF

    chmod +x "$HOME/test_rocm.sh"
    
    log "Verification script created"
}

# Step 9: Create uninstall script
create_uninstall_script() {
    cat > "$HOME/uninstall_rocm.sh" << 'EOF'
#!/bin/bash
echo "=== ROCm + XRT Uninstall Script ==="
echo "This will remove ROCm, source-built XRT, and related components."
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing ROCm packages..."
    # Remove ROCm packages
    sudo apt remove --purge -y rocm-* hip-* hsa-* amd-* rocblas* rocsparse* rocfft* miopen* rccl* roctracer* rocprofiler* >> /dev/null 2>&1
    
    echo "Removing XRT packages..."
    # Remove XRT packages (both base and plugin)
    sudo apt remove --purge -y xrt_* >> /dev/null 2>&1
    
    echo "Removing XRT installation directory..."
    # Remove XRT installation directory (source-built)
    sudo rm -rf /opt/xilinx
    
    echo "Cleaning up repositories..."
    # Remove repository files
    sudo rm -f /etc/apt/sources.list.d/rocm.list
    sudo rm -f /etc/apt/sources.list.d/amdgpu.list
    sudo rm -f /usr/share/keyrings/rocm-archive-keyring.gpg
    
    echo "Removing environment files..."
    # Remove environment files
    rm -f $HOME/rocm_env.sh
    sed -i '/rocm_env.sh/d' $HOME/.bashrc
    
    echo "Removing system configurations..."
    # Remove system configuration files
    sudo rm -f /etc/sysctl.d/99-rocm-ai.conf
    sudo rm -f /etc/default/cpufrequtils
    
    echo "Restoring GRUB configuration..."
    # Restore GRUB if backup exists
    if [ -f "$HOME/rocm_setup_backup/grub.bak" ]; then
        sudo cp "$HOME/rocm_setup_backup/grub.bak" /etc/default/grub
        sudo update-grub
    fi
    
    echo "Cleaning up packages..."
    # Clean up
    sudo apt autoremove -y
    sudo apt autoclean
    
    echo ""
    echo "Uninstall complete!"
    echo "Please reboot your system to complete the removal."
fi
EOF
    chmod +x "$HOME/uninstall_rocm.sh"
}

# Main installation flow
main() {
    log "=== Starting Complete ROCm + Ryzen AI Installation ==="
    
    # Create backup
    backup_configs
    
    # Install prerequisites
    install_prerequisites
    
    # Configure kernel
    configure_kernel_parameters
    
    # Install components
    install_rocm
    install_vulkan
    install_xrt_npu
    
    # Configure environment
    create_environment
    
    # Apply optimizations
    apply_system_optimizations
    
    # Create utility scripts
    create_verification_script
    create_uninstall_script
    
    # Final summary
    log ""
    log "=== Installation Complete ==="
    log ""
    log "Installed components:"
    log "  ✓ ROCm $ROCM_VERSION"
    log "  ✓ HIP Runtime and Development Tools"
    log "  ✓ Vulkan support for Radeon 780M"
    log "  ✓ XRT built from source for XDNA 2 NPU"
    log "  ✓ XDNA driver and XRT plugin"
    log "  ✓ OpenCL support"
    log "  ✓ System optimizations"
    log "  ✓ Verification scripts"
    log ""
    log "Created scripts:"
    log "  • $HOME/rocm_env.sh - Environment setup (auto-loaded)"
    log "  • $HOME/test_rocm.sh - Test ROCm + XRT installation"
    log "  • $HOME/uninstall_rocm.sh - Complete uninstall script"
    log ""
    log "XRT Installation Details:"
    log "  • XRT built from AMD XDNA driver repository"
    log "  • Base XRT package: /opt/xilinx/xrt"
    log "  • XDNA plugin for NPU support included"
    log "  • Source build provides latest NPU compatibility"
    log ""
    log "Next steps:"
    log "  1. Reboot your system: sudo reboot"
    log "  2. After reboot, test installation: ./test_rocm.sh"
    log "  3. Verify XRT tools: xrt-smi version && xrt-smi examine"
    log ""
    log "Log file: $LOG_FILE"
    log "Backup directory: $BACKUP_DIR"
    
    # Check if reboot is needed
    if grep -q "amdgpu.noretry" /proc/cmdline; then
        info "Kernel parameters already active"
    else
        warning "IMPORTANT: Reboot required to activate kernel parameters!"
    fi
}

# Run main installation
main

# Exit successfully
exit 0
