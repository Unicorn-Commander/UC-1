#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🦄 UnicornCommander Desktop Integration${NC}"
echo -e "${BLUE}Integrating UC-1 services with KDE Plasma 6 (Wayland) on Ubuntu 25.04...${NC}"

# Ensure running as ucadmin with sudo privileges
if [ "$(whoami)" != "ucadmin" ]; then
    echo -e "${YELLOW}⚠️ This script must be run as ucadmin. Exiting...${NC}"
    exit 1
fi

if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Sudo privileges required. Run: sudo visudo and add 'ucadmin ALL=(ALL) NOPASSWD:ALL'${NC}"
    exit 1
fi

print_section() {
    echo -e "\n${BLUE}[$1]${NC}"
}

# Install Docker and dependencies
print_section "Installing Docker"
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${BLUE}Installing Docker and Docker Compose...${NC}"
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu noble stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker ucadmin
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo -e "${GREEN}✅ Docker already installed${NC}"
fi

# Detect existing UC-1 installation
print_section "Detecting UC-1 Installation"
UC1_PATH=""
DOCKER_COMPOSE_FILE=""
for path in \
    "/home/ucadmin/UC-1/UC-1_Core" \
    "/home/ucadmin/UC-1" \
    "/home/ucadmin/UC-1_Core" \
    "/home/ucadmin/UnicornCommander"
do
    if [ -d "$path" ] && [ -r "$path/docker-compose.yaml" ]; then
        UC1_PATH="$path"
        DOCKER_COMPOSE_FILE="$path/docker-compose.yaml"
        echo -e "${GREEN}✅ Found UC-1 installation at: $UC1_PATH${NC}"
        break
    fi
done

if [ -z "$UC1_PATH" ]; then
    echo -e "${YELLOW}⚠️ UC-1 installation not found in expected locations:${NC}"
    for path in \
        "/home/ucadmin/UC-1/UC-1_Core" \
        "/home/ucadmin/UC-1" \
        "/home/ucadmin/UC-1_Core" \
        "/home/ucadmin/UnicornCommander"
    do
        [ -d "$path" ] && echo "  - Checked: $path" || echo "  - Not found: $path"
    done
    echo -e "${BLUE}Please specify the UC-1 path (default: /home/ucadmin/UC-1/UC-1_Core):${NC}"
    read -p "Enter UC-1 path: " -e -i "/home/ucadmin/UC-1/UC-1_Core" UC1_PATH
    if [ -r "$UC1_PATH/docker-compose.yaml" ]; then
        DOCKER_COMPOSE_FILE="$UC1_PATH/docker-compose.yaml"
        echo -e "${GREEN}✅ Using UC-1 path: $UC1_PATH${NC}"
    else
        echo -e "${YELLOW}⚠️ Invalid path or no docker-compose.yaml at $UC1_PATH. Exiting...${NC}"
        exit 1
    fi
fi

# Export UC1_PATH for utilities and future sessions
export UC1_PATH
grep -qxF "export UC1_PATH=$UC1_PATH" /home/ucadmin/.bashrc \
  || echo "export UC1_PATH=$UC1_PATH" >> /home/ucadmin/.bashrc
grep -qxF "export UC1_PATH=$UC1_PATH" /home/ucadmin/.zshrc \
  || echo "export UC1_PATH=$UC1_PATH" >> /home/ucadmin/.zshrc

# Detect existing start script
print_section "Detecting Start Script"
START_SCRIPT=""
for script in \
    "$UC1_PATH/start.sh" \
    "$UC1_PATH/start" \
    "$UC1_PATH/start-services.sh"
do
    if [ -x "$script" ]; then
        START_SCRIPT="$script"
        echo -e "${GREEN}✅ Found start script: $START_SCRIPT${NC}"
        break
    fi
done

# Ensure workspace folders exist
print_section "Ensuring Workspace Folders"
for dir in \
    "/home/ucadmin/models" \
    "/home/ucadmin/datasets" \
    "/home/ucadmin/projects" \
    "/home/ucadmin/scripts" \
    "$UC1_PATH/models"
do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        chown ucadmin:ucadmin "$dir"
        echo -e "${BLUE}Created $dir${NC}"
    fi
done

# Create AI development environment
print_section "Setting up AI Development Environment"
if [ ! -d "/home/ucadmin/ai-env" ]; then
    echo -e "${BLUE}Creating AI Python environment...${NC}"
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install -y python3.11 python3.11-venv python3.11-distutils python3-pip libpq-dev build-essential

    python3.11 -m venv /home/ucadmin/ai-env
    source /home/ucadmin/ai-env/bin/activate

    pip install --upgrade pip --quiet
    pip install \
      torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 \
      --index-url https://download.pytorch.org/whl/rocm6.3.2 \
      jupyterlab==4.2.5 \
      gradio==4.44.0 \
      streamlit==1.38.0 \
      transformers==4.44.2 \
      numpy==1.26.4 \
      pandas==2.2.2 \
      matplotlib==3.9.2 || {
        echo -e "${YELLOW}⚠️ Failed to install PyTorch or other packages. Check network/ROCm.${NC}"
        deactivate
        exit 1
    }
    deactivate
else
    echo -e "${GREEN}✅ AI environment already exists${NC}"
    source /home/ucadmin/ai-env/bin/activate

    PY_VER=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if [[ "$PY_VER" != "3.11" ]]; then
        echo -e "${BLUE}Recreating AI environment with Python 3.11...${NC}"
        deactivate
        rm -rf /home/ucadmin/ai-env
        python3.11 -m venv /home/ucadmin/ai-env
        source /home/ucadmin/ai-env/bin/activate
    fi

    pip install --upgrade pip --quiet
    if python -c "import torch; print(torch.__version__)" 2>/dev/null | grep -q "^2.3.1"; then
        echo -e "${GREEN}✅ PyTorch 2.3.1 already installed${NC}"
    else
        echo -e "${BLUE}Installing PyTorch 2.3.1...${NC}"
        pip install --force-reinstall \
          torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 \
          --index-url https://download.pytorch.org/whl/rocm6.3.2
    fi
    pip install \
    
    # Verify Python version
    PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if [[ "$PYTHON_VERSION" != "3.8" && "$PYTHON_VERSION" != "3.9" && 
          "$PYTHON_VERSION" != "3.10" && "$PYTHON_VERSION" != "3.11" ]]; then
        echo -e "${YELLOW}⚠️ Unsupported Python version $PYTHON_VERSION for PyTorch 2.3.1${NC}"
        echo -e "${BLUE}Recreating environment with Python 3.11...${NC}"
        deactivate
        rm -rf /home/ucadmin/ai-env
        sudo apt install -y python3.11 python3.11-venv
        python3.11 -m venv /home/ucadmin/ai-env
        source /home/ucadmin/ai-env/bin/activate
    fi
    
    pip install --upgrade pip --quiet
    
    # Check if torch is installed and compatible
    if python -c "import torch; print(torch.__version__)" 2>/dev/null | grep -q "^2.3.1"; then
        echo -e "${GREEN}✅ PyTorch 2.3.1 already installed, skipping upgrade${NC}"
    else
        echo -e "${BLUE}Installing PyTorch 2.3.1 for ROCm 6.3.2...${NC}"
        pip install --force-reinstall \
            torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/rocm6.3.2 || {
            echo -e "${YELLOW}⚠️ Failed to install PyTorch 2.3.1${NC}"
            echo -e "${BLUE}Troubleshooting steps:${NC}"
            echo -e "1. Verify ROCm installation: 'rocminfo'"
            echo -e "2. Check network connection to PyTorch repo"
            echo -e "3. Try with different Python version (3.8-3.11)"
            deactivate
            exit 1
        }
    fi
    
    # Install other packages
    pip install \
        jupyterlab==4.2.5 \
        gradio==4.44.0 \
        streamlit==1.38.0 \
        transformers==4.44.2 \
        numpy==1.26.4 \
        pandas==2.2.2 \
        matplotlib==3.9.2
    
    deactivate
fi

# Create desktop launchers
print_section "Creating Desktop Launchers"
mkdir -p /home/ucadmin/.local/share/applications /home/ucadmin/.local/bin
chown ucadmin:ucadmin /home/ucadmin/.local/share/applications /home/ucadmin/.local/bin

# UC-1 Control Panel script
cat << EOF > /home/ucadmin/.local/bin/uc1-control.sh
#!/bin/bash
echo "🦄 UC-1 Control Panel"
echo "1) Start Services"
echo "2) Stop Services"
echo "3) View Status"
echo "4) View Logs"
read -p "Choice: " choice
case \$choice in
    1) if [ -f "\$2" ]; then "\$2"; elif [ -f "\$1/start.sh" ]; then "\$1/start.sh"; else cd "\$1" && docker compose up -d; fi ;;
    2) cd "\$1" && docker compose down ;;
    3) cd "\$1" && docker compose ps ;;
    4) cd "\$1" && docker compose logs ;;
    *) echo "Invalid choice" ;;
esac
read -p "Press Enter to continue..."
EOF
chmod +x /home/ucadmin/.local/bin/uc1-control.sh
chown ucadmin:ucadmin /home/ucadmin/.local/bin/uc1-control.sh

# UC-1 Control Panel launcher
cat << EOF > /home/ucadmin/.local/share/applications/uc1-control.desktop
[Desktop Entry]
Name=UC-1 Control Panel
Comment=UnicornCommander Control Panel
Exec=dbus-run-session konsole --workdir "$UC1_PATH" -e /home/ucadmin/.local/bin/uc1-control.sh "$UC1_PATH" "${START_SCRIPT}"
Icon=applications-system
Type=Application
Categories=Development;System;
StartupNotify=true
X-KDE-Wayland-Interfaces=org_kde_kwin_keystate,org_kde_kwin_appmenu
EOF

# Service launchers
if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    # Open-WebUI launcher
    if grep -q "open-webui\|8080:" "$DOCKER_COMPOSE_FILE"; then
        cat << EOF > /home/ucadmin/.local/share/applications/uc1-webui.desktop
[Desktop Entry]
Name=UC-1 WebUI
Comment=Open-WebUI Interface
Exec=xdg-open http://localhost:8080
Icon=applications-internet
Type=Application
Categories=Network;AI;Development;
StartupNotify=true
EOF
    fi

    # SearXNG launcher
    if grep -q "searxng\|8888:" "$DOCKER_COMPOSE_FILE"; then
        cat << EOF > /home/ucadmin/.local/share/applications/uc1-search.desktop
[Desktop Entry]
Name=UC-1 Search
Comment=Private Search Engine
Exec=xdg-open http://localhost:8888
Icon=applications-internet
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
EOF
    fi

    # Portainer launcher
    if grep -q "portainer\|9000:" "$DOCKER_COMPOSE_FILE"; then
        cat << EOF > /home/ucadmin/.local/share/applications/uc1-portainer.desktop
[Desktop Entry]
Name=UC-1 Docker
Comment=Docker Container Management
Exec=xdg-open http://localhost:9000
Icon=applications-system
Type=Application
Categories=System;Utility;Development;
StartupNotify=true
EOF
    fi
fi

# Create Konsole profile for AI environment
print_section "Creating Konsole Profiles"
mkdir -p /home/ucadmin/.local/share/konsole
cat << EOF > /home/ucadmin/.local/share/konsole/AI-Env.profile
[Appearance]
ColorScheme=Breeze
Font=DejaVu Sans Mono,10,-1,5,50,0,0,0,0,0

[General]
Command=/bin/bash -c 'export HSA_OVERRIDE_GFX_VERSION=11.0.0; source /home/ucadmin/ai-env/bin/activate && echo "AI Environment Active (ROCm 6.3.2)" && exec bash'
Name=AI Environment
Parent=FALLBACK/
EOF

# AI Terminal launcher
cat << EOF > /home/ucadmin/.local/share/applications/uc1-ai-terminal.desktop
[Desktop Entry]
Name=AI Terminal
Comment=Terminal with AI Environment (ROCm 6.3.2)
Exec=dbus-run-session konsole --profile AI-Env
Icon=utilities-terminal
Type=Application
Categories=Development;AI;System;
StartupNotify=true
X-KDE-Wayland-Interfaces=org_kde_kwin_keystate,org_kde_kwin_appmenu
EOF

# Jupyter Lab launcher
cat << EOF > /home/ucadmin/.local/share/applications/uc1-jupyter.desktop
[Desktop Entry]
Name=UC-1 Jupyter
Comment=AI Development Environment
Exec=bash -c "source /home/ucadmin/ai-env/bin/activate && QT_QPA_PLATFORM=wayland jupyter-lab --ip=0.0.0.0 --port=8888 --no-browser & sleep 2 && xdg-open http://localhost:8888"
Icon=applications-development
Type=Application
Categories=Development;AI;Science;
StartupNotify=true
EOF

# UC-Monitor launcher
cat << EOF > /home/ucadmin/.local/share/applications/uc-monitor.desktop
[Desktop Entry]
Name=UC Monitor
Comment=System Hardware Monitor
Exec=dbus-run-session konsole -e /usr/local/bin/uc-monitor
Icon=system-monitor
Type=Application
Categories=System;Monitor;
StartupNotify=true
X-KDE-Wayland-Interfaces=org_kde_kwin_keystate
EOF

# Create system utilities
print_section "Creating System Utilities"

# UC-1 Status utility
cat << EOF | sudo tee /usr/local/bin/uc-status
#!/bin/bash
echo "🦄 UnicornCommander Status"
echo "========================="

UC1_PATH="$UC1_PATH"
if [ -d "\$UC1_PATH" ] && [ -f "\$UC1_PATH/docker-compose.yaml" ]; then
    echo "Installation: \$UC1_PATH"
    cd "\$UC1_PATH"
    echo ""
    echo "Services:"
    docker compose ps 2>/dev/null || echo "Services not running"
    echo ""
    echo "System Resources:"
    echo "Memory: \$(free -h | grep 'Mem:' | awk '{print \$3"/"\$2}')"
    echo "Disk: \$(df -h / | tail -1 | awk '{print \$3"/"\$2" ("\$5" used)"}')"
    echo "Load: \$(uptime | cut -d',' -f3-)"
    echo ""
    echo "NPU Status:"
    if command -v rocm-smi >/dev/null 2>&1; then
        rocm-smi --showproductname 2>/dev/null || echo "NPU not detected"
    else
        echo "rocm-smi not installed; NPU status unavailable"
    fi
else
    echo "UC-1 installation not found at \$UC1_PATH"
fi
EOF

# UC-1 Launch utility
cat << EOF | sudo tee /usr/local/bin/uc-launch
#!/bin/bash
echo "🦄 UnicornCommander Launcher"
echo "============================"

UC1_PATH="$UC1_PATH"
if [ -d "\$UC1_PATH" ] && [ -f "\$UC1_PATH/docker-compose.yaml" ]; then
    cd "\$UC1_PATH"
    if [ -f "${START_SCRIPT}" ]; then
        echo "Starting UC-1 services with ${START_SCRIPT}..."
        ${START_SCRIPT}
    elif [ -f "./start.sh" ]; then
        echo "Starting UC-1 services with start.sh..."
        ./start.sh
    else
        echo "Starting services with docker compose..."
        docker compose up -d
    fi
    echo "Services started! Check status with: uc-status"
else
    echo "UC-1 installation not found at \$UC1_PATH"
fi
EOF

# UC-1 Models utility
cat << EOF | sudo tee /usr/local/bin/uc-models
#!/bin/bash
echo "🦄 UnicornCommander Models"
echo "========================="

FOUND=false
for path in "/home/ucadmin/models" "$UC1_PATH/models"; do
    if [ -d "\$path" ]; then
        echo "Models in \$path:"
        ls -lh "\$path" 2>/dev/null || echo "No models found"
        echo ""
        FOUND=true
    fi
done
if [ "\$FOUND" = false ]; then
    echo "No model directories found"
fi

echo "AI Environment Status:"
if [ -d "/home/ucadmin/ai-env" ]; then
    echo "✅ AI environment available at /home/ucadmin/ai-env"
else
    echo "❌ AI environment not found"
fi
EOF

sudo chmod 755 /usr/local/bin/uc-status /usr/local/bin/uc-launch /usr/local/bin/uc-models
sudo chown root:root /usr/local/bin/uc-status /usr/local/bin/uc-launch /usr/local/bin/uc-models

# Configure file manager integration
print_section "Configuring File Manager Integration"
mkdir -p /home/ucadmin/.local/share
chown ucadmin:ucadmin /home/ucadmin/.local/share

if [ ! -f /home/ucadmin/.local/share/user-places.xbel ]; then
    cat << EOF > /home/ucadmin/.local/share/user-places.xbel
<?xml version="1.0" encoding="UTF-8"?>
<xbel>
 <bookmark href="file://$UC1_PATH">
  <title>UC-1 Core</title>
  <info>
   <metadata owner="http://www.kde.org">
    <kde_places_version>4</kde_places_version>
   </metadata>
  </info>
 </bookmark>
 <bookmark href="file:///home/ucadmin/models">
  <title>AI Models</title>
  <info>
   <metadata owner="http://www.kde.org">
    <kde_places_version>4</kde_places_version>
   </metadata>
  </info>
 </bookmark>
 <bookmark href="file:///home/ucadmin/projects">
  <title>Projects</title>
  <info>
   <metadata owner="http://www.kde.org">
    <kde_places_version>4</kde_places_version>
   </metadata>
  </info>
 </bookmark>
</xbel>
EOF
    chown ucadmin:ucadmin /home/ucadmin/.local/share/user-places.xbel
fi

# Configure Dolphin for KDE6
mkdir -p /home/ucadmin/.config
cat << EOF > /home/ucadmin/.config/dolphinrc
[General]
ShowFullPath=true
ShowSpaceInfo=true
RememberOpenedTabs=false

[DetailsMode]
PreviewSize=32

[IconsMode]
PreviewSize=64
EOF

# Add shell aliases
print_section "Configuring Shell Integration"
if [ -f /home/ucadmin/.zshrc ]; then
    if ! grep -q "UC-1 aliases" /home/ucadmin/.zshrc; then
        cp /home/ucadmin/.zshrc /home/ucadmin/.zshrc.backup
        echo -e "${GREEN}✅ Backed up .zshrc to .zshrc.backup${NC}"
        cat << EOF >> /home/ucadmin/.zshrc

# UC-1 aliases
alias uc='uc-status'
alias ucstart='uc-launch'
alias ucstop='cd "$UC1_PATH" && docker compose down'
alias uclogs='cd "$UC1_PATH" && docker compose logs -f'
alias ucai='source /home/ucadmin/ai-env/bin/activate'
EOF
    else
        echo -e "${GREEN}✅ UC-1 aliases already configured${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ .zshrc not found, creating basic configuration${NC}"
    echo "# UC-1 aliases" > /home/ucadmin/.zshrc
    echo "alias uc='uc-status'" >> /home/ucadmin/.zshrc
    echo "alias ucstart='uc-launch'" >> /home/ucadmin/.zshrc
    echo "alias ucstop='cd \"$UC1_PATH\" && docker compose down'" >> /home/ucadmin/.zshrc
    echo "alias uclogs='cd \"$UC1_PATH\" && docker compose logs -f'" >> /home/ucadmin/.zshrc
    echo "alias ucai='source /home/ucadmin/ai-env/bin/activate'" >> /home/ucadmin/.zshrc
fi

# Add same aliases to .bashrc
if [ -f /home/ucadmin/.bashrc ]; then
    if ! grep -q "UC-1 aliases" /home/ucadmin/.bashrc; then
        cat << EOF >> /home/ucadmin/.bashrc

# UC-1 aliases
alias uc='uc-status'
alias ucstart='uc-launch'
alias ucstop='cd "$UC1_PATH" && docker compose down'
alias uclogs='cd "$UC1_PATH" && docker compose logs -f'
alias ucai='source /home/ucadmin/ai-env/bin/activate'
EOF
    fi
fi

# Auto-start configuration
print_section "Auto-start Configuration"
read -p "Would you like UC-1 services to start automatically on login? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p /home/ucadmin/.config/autostart
    chown ucadmin:ucadmin /home/ucadmin/.config/autostart
    cat << EOF > /home/ucadmin/.config/autostart/uc1-services.desktop
[Desktop Entry]
Type=Application
Name=UC-1 Services
Comment=Start UnicornCommander services on login
Exec=/usr/local/bin/uc-launch
Hidden=false
NoDisplay=false
X-KDE-autostart-phase=2
X-KDE-StartupNotify=false
X-KDE-Wayland-Interfaces=org_kde_kwin_keystate
EOF
    chown ucadmin:ucadmin /home/ucadmin/.config/autostart/uc1-services.desktop
    echo -e "${GREEN}✅ Auto-start configured${NC}"
else
    echo -e "${BLUE}Auto-start skipped. Start services manually with 'uc-launch'${NC}"
fi

# Refresh KDE services cache
print_section "Refreshing KDE Services"
kbuildsycoca6 &> /dev/null || true
echo -e "${GREEN}✅ KDE services cache updated${NC}"

# Verify setup
print_section "Verifying Setup"
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is installed${NC}"
    systemctl is-active --quiet docker && echo -e "${GREEN}✅ Docker service is running${NC}" || echo -e "${YELLOW}⚠️ Docker service is not running${NC}"
else
    echo -e "${YELLOW}⚠️ Docker is not installed${NC}"
fi

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${GREEN}✅ Docker Compose file found at $DOCKER_COMPOSE_FILE${NC}"
else
    echo -e "${YELLOW}⚠️ Docker Compose file not found${NC}"
fi

if [ -d "/home/ucadmin/ai-env" ]; then
    echo -e "${GREEN}✅ AI environment is set up${NC}"
else
    echo -e "${YELLOW}⚠️ AI environment not found${NC}"
fi

# Verify ROCm installation
echo -e "\n${BLUE}Verifying ROCm Support:${NC}"
if command -v rocm-smi >/dev/null 2>&1; then
    echo -e "${GREEN}✅ ROCm tools installed${NC}"
    rocm-smi --showproductname || echo -e "${YELLOW}⚠️ ROCm installed but GPU not detected${NC}"
else
    echo -e "${YELLOW}⚠️ ROCm tools not found${NC}"
fi

echo -e "${GREEN}🎉 UC-1 Desktop Integration complete!${NC}"
echo -e "${BLUE}Available commands:${NC}"
echo -e "  - uc-status  : Check UC-1 status"
echo -e "  - uc-launch  : Start UC-1 services"
echo -e "  - uc-models  : View available models"
echo -e "  - uc         : Quick status (alias)"
echo -e "  - ucstart    : Quick start (alias)"
echo -e "  - ucstop     : Stop services (alias)"
echo -e "  - uclogs     : View logs (alias)"
echo -e "  - ucai       : Activate AI environment (alias)"
echo -e ""
echo -e "${BLUE}Desktop launchers added to Applications menu under:${NC}"
echo -e "  - Development > UC-1 Control Panel, UC-1 Jupyter, AI Terminal"
echo -e "  - Network > UC-1 WebUI, UC-1 Search"
echo -e "  - System > UC-1 Docker, UC Monitor"
echo -e ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  - Start services: uc-launch"
echo -e "  - Check status: uc-status"
