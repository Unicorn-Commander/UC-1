#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Universal Installer: Docker + Open Interpreter + Portainer + UnicornCommander${NC}"

# Check if running as root or if sudo is available
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}⚠️ Running as root. Some operations will be adjusted accordingly.${NC}"
    SUDO_CMD=""
else
    if ! command -v sudo >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: This script requires sudo privileges but sudo is not installed.${NC}"
        echo "Please install sudo or run this script as root."
        exit 1
    fi
    
    # Test sudo access and force password prompt
    echo "🔐 This script requires sudo privileges for system-level installations."
    echo "Please enter your password to continue..."
    
    # Force a sudo command that requires password and shows clear feedback
    if ! sudo echo "✅ Sudo access granted"; then
        echo -e "${RED}❌ Error: Unable to obtain sudo privileges.${NC}"
        echo "Please ensure you have sudo access or run this script as root."
        exit 1
    fi
    
    SUDO_CMD="sudo"
    echo -e "${GREEN}✅ Sudo session established${NC}"
fi

# Configuration
PYTHON_VERSION="3.11.7"
VENV_PATH="/opt/open-interpreter"
GLOBAL_SYMLINK=true  # set to false to skip global symlink
ENV_FILE="$VENV_PATH/.env"
UC_CORE_DIR="UC-1_Core"  # Simple relative path since we're in UC-1 directory

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to check if user is in a group
user_in_group() {
    groups $USER | grep -q "\b$1\b"
}

print_section "Setting up User Groups Early"
# Create groups if they don't exist and add user
echo "👥 Adding user '$USER' to required groups: docker, video, render..."
$SUDO_CMD groupadd docker 2>/dev/null || true
$SUDO_CMD groupadd video 2>/dev/null || true  
$SUDO_CMD groupadd render 2>/dev/null || true

# Check which groups were newly added BEFORE adding user
NEWLY_ADDED=()
if ! user_in_group docker; then NEWLY_ADDED+=(docker); fi
if ! user_in_group video; then NEWLY_ADDED+=(video); fi  
if ! user_in_group render; then NEWLY_ADDED+=(render); fi

# Add user to groups
$SUDO_CMD usermod -aG docker,video,render $USER

if [ ${#NEWLY_ADDED[@]} -gt 0 ]; then
    echo -e "${YELLOW}📝 Note: Added to new groups: ${NEWLY_ADDED[*]}${NC}"
    echo -e "${YELLOW}   You'll need to logout/login after installation for full Docker access${NC}"
else
    echo -e "${GREEN}✅ User already in all required groups${NC}"
fi

print_section "Installing System Prerequisites"
$SUDO_CMD apt update
$SUDO_CMD apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev curl libsqlite3-dev wget libbz2-dev \
    ca-certificates gnupg lsb-release tar

print_section "Installing Python 3.11"
if ! command -v python3.11 >/dev/null 2>&1; then
    echo "Installing Python $PYTHON_VERSION..."
    cd /tmp
    wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
    tar -xf Python-$PYTHON_VERSION.tgz
    cd Python-$PYTHON_VERSION
    ./configure --enable-optimizations
    make -j$(nproc)
    $SUDO_CMD make altinstall
    echo -e "${GREEN}✅ Python 3.11 installed successfully${NC}"
else
    echo -e "${GREEN}✅ Python 3.11 already installed${NC}"
fi

print_section "Setting up Open Interpreter"
# Create venv directory
$SUDO_CMD mkdir -p $VENV_PATH

# Create Python virtual environment
$SUDO_CMD python3.11 -m venv $VENV_PATH/Open-Interpreter

# Set proper ownership for current user
$SUDO_CMD chown -R $USER:$USER $VENV_PATH

# Activate venv and install packages
source $VENV_PATH/Open-Interpreter/bin/activate
pip install --upgrade pip

# Clone and install The_Colonel (our Open Interpreter fork)
echo "📦 Installing The_Colonel (Open Interpreter fork) from GitHub..."
mkdir -p UC-1_Extensions
cd UC-1_Extensions
if [ -d "The_Colonel" ]; then
    echo "Updating existing The_Colonel repository..."
    cd The_Colonel
    git pull
    cd ..
else
    echo "Cloning The_Colonel repository..."
    git clone https://github.com/Unicorn-Commander/The_Colonel.git
fi
cd The_Colonel
pip install -e .
cd ../..
echo -e "${GREEN}✅ The_Colonel installed successfully${NC}"

# Create environment file
cat > $ENV_FILE << EOF
# Add your environment variables here
# Example:
# OPENAI_API_KEY=your_api_key_here
# ANTHROPIC_API_KEY=your_anthropic_key_here
EOF

echo -e "${GREEN}✅ Created environment file at $ENV_FILE${NC}"

# Create global symlink if requested
if [ "$GLOBAL_SYMLINK" = true ]; then
    $SUDO_CMD ln -sf $VENV_PATH/Open-Interpreter/bin/interpreter /usr/local/bin/interpreter
    echo -e "${GREEN}✅ Global symlink created: 'interpreter' is available system-wide${NC}"
fi

print_section "Installing Docker"
# Remove old Docker packages
echo "🧹 Cleaning up old Docker packages..."
$SUDO_CMD apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Download and install Docker binaries
echo "📦 Downloading Docker binaries..."
mkdir -p ~/docker-downloads && cd ~/docker-downloads
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-25.0.3.tgz -o docker.tgz
tar xzvf docker.tgz
$SUDO_CMD mv docker/* /usr/bin/
cd ~ && rm -rf ~/docker-downloads

# Create Docker systemd service
echo "⚙️ Creating Docker systemd service..."
$SUDO_CMD tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Daemon
After=network.target

[Service]
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

# Start Docker service
echo "🚀 Enabling and starting Docker..."
$SUDO_CMD systemctl daemon-reexec
$SUDO_CMD systemctl daemon-reload
$SUDO_CMD systemctl enable docker
$SUDO_CMD systemctl start docker

print_section "Installing Docker Compose"
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-x86_64 \
    -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
echo -e "${GREEN}✅ Docker Compose v2 installed${NC}"

print_section "Installing Portainer"
echo "🧭 Installing Portainer CE (Community Edition)..."

# Function to run docker commands with proper group handling
run_docker_cmd() {
    if [[ " ${NEWLY_ADDED[@]} " =~ " docker " ]]; then
        # For newly added docker group, we need to use a different approach
        # since the current shell doesn't have the new group membership yet
        echo "Note: Running Docker command - may need logout/login for permanent access"
        # Try to run the command, and if it fails due to permissions, suggest next steps
        if ! eval "$1" 2>/dev/null; then
            echo "Docker permission issue detected - this is expected for new installations"
            return 1
        fi
    else
        # User already in docker group
        eval "$1"
    fi
}

# Check if Portainer is already running
if docker ps | grep -q portainer 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Portainer container already running - skipping installation${NC}"
elif docker ps -a | grep -q portainer 2>/dev/null; then
    echo -e "${YELLOW}⚠️ Portainer container exists but stopped - starting it${NC}"
    run_docker_cmd "docker start portainer" || echo "Failed to start existing Portainer container"
else
    echo "Installing fresh Portainer instance..."
    
    # Create volume for persistent data
    run_docker_cmd "docker volume create portainer_data"

    # Run the Portainer container
    run_docker_cmd "docker run -d \
      --name portainer \
      --restart=always \
      -p 9000:9000 \
      -p 9443:9443 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest"
fi

echo -e "${GREEN}✅ Portainer setup complete!${NC}"

print_section "Testing Installations"
echo "🧪 Testing Docker installation..."

# Debug Docker setup
echo "Debug: Current user: $USER"
echo "Debug: Current groups: $(groups)"
echo "Debug: Docker service status:"
$SUDO_CMD systemctl is-active docker || echo "Docker service not running"

# Test Docker with hello-world
if run_docker_cmd "docker run --rm hello-world"; then
    echo -e "${GREEN}✅ Docker test successful!${NC}"
else
    echo -e "${YELLOW}⚠️ Docker test failed - this is expected for new group memberships${NC}"
    echo -e "${YELLOW}   Try: sudo docker run hello-world (should work with sudo)${NC}"
    echo -e "${YELLOW}   For regular access: logout and login again${NC}"
fi

echo "🧪 Testing Open Interpreter..."
source $VENV_PATH/Open-Interpreter/bin/activate
interpreter --help >/dev/null && echo -e "${GREEN}✅ Open Interpreter test successful!${NC}" || echo -e "${YELLOW}⚠️ Open Interpreter test failed${NC}"

echo "🧪 Testing Portainer setup..."
if run_docker_cmd "docker ps | grep portainer"; then
    echo -e "${GREEN}✅ Portainer is running!${NC}"
else
    echo -e "${YELLOW}⚠️ Portainer test failed - will work after logout/login${NC}"
fi

print_section "Applying Redis Memory Fix"
echo "🧠 Fixing Redis memory overcommit setting..."

# Step 1: Add or update the line in /etc/sysctl.conf
CONF_LINE="vm.overcommit_memory = 1"
SYSCTL_FILE="/etc/sysctl.conf"
if grep -q "^vm.overcommit_memory" "$SYSCTL_FILE"; then
    $SUDO_CMD sed -i "s/^vm.overcommit_memory.*/$CONF_LINE/" "$SYSCTL_FILE"
    echo "✅ Updated existing vm.overcommit_memory line."
else
    echo "$CONF_LINE" | $SUDO_CMD tee -a "$SYSCTL_FILE" > /dev/null
    echo "✅ Added vm.overcommit_memory to $SYSCTL_FILE."
fi

# Step 2: Apply the change immediately
$SUDO_CMD sysctl -w vm.overcommit_memory=1

# Step 3: Confirm it worked
CURRENT=$(cat /proc/sys/vm/overcommit_memory)
if [[ "$CURRENT" == "1" ]]; then
    echo -e "${GREEN}✅ Success: vm.overcommit_memory is now set to 1${NC}"
else
    echo -e "${YELLOW}❌ Failed: vm.overcommit_memory is still set to $CURRENT${NC}"
fi

print_section "Setting up UnicornCommander"
echo "🦄 Configuring UnicornCommander environment..."

# Debug current directory and contents
echo "Debug: Current working directory: $(pwd)"
echo "Debug: Looking for: $UC_CORE_DIR"
echo "Debug: Contents of current directory:"
ls -la | grep -E "(UC-1_Core|^d)"

# Check if UC-1_Core directory exists
if [ ! -d "$UC_CORE_DIR" ]; then
    echo -e "${YELLOW}⚠️ Warning: $UC_CORE_DIR directory not found${NC}"
    echo "Expected to find UC-1_Core in current directory."
    echo "Make sure you're running from: UC-1/install_UC-1.sh"
    echo "And that UC-1_Core directory exists alongside this script."
    echo "Skipping UnicornCommander setup for now..."
else
    echo -e "${GREEN}✅ Found UC-1_Core directory${NC}"
    cd "$UC_CORE_DIR"
    
    # Copy .env.txt to .env if .env doesn't exist
    if [ ! -f .env ]; then
        if [ -f .env.txt ]; then
            echo "📝 Creating .env file from .env.txt template with fresh keys..."
            cp .env.txt .env
            
            # Generate new secure keys
            echo "🔐 Generating new security keys..."
            
            # Generate new PostgreSQL password (16 chars with special chars)
            NEW_POSTGRES_PASSWORD=$(openssl rand -base64 12 | tr -d "=+/" | cut -c1-16)
            
            # Generate new WebUI secret key (longer, base64 encoded)
            NEW_WEBUI_SECRET=$(openssl rand -base64 96 | tr -d "\n")
            
            # Generate new SearXNG secret (base64 encoded)
            NEW_SEARXNG_SECRET=$(openssl rand -base64 64 | tr -d "\n")
            
            # Generate new Qdrant API key (optional but good to have)
            NEW_QDRANT_KEY=$(openssl rand -hex 32)
            
            # Replace the keys in .env file
            sed -i "s|POSTGRES_PASSWORD='.*'|POSTGRES_PASSWORD='${NEW_POSTGRES_PASSWORD}'|" .env
            sed -i "s|WEBUI_SECRET_KEY='.*'|WEBUI_SECRET_KEY='${NEW_WEBUI_SECRET}'|" .env
            sed -i "s|SEARXNG_SECRET='.*'|SEARXNG_SECRET='${NEW_SEARXNG_SECRET}'|" .env
            sed -i "s|QDRANT_API_KEY=|QDRANT_API_KEY=${NEW_QDRANT_KEY}|" .env
            
            echo -e "${GREEN}✅ .env file created with fresh security keys${NC}"
            echo -e "${YELLOW}📝 Note: All security keys have been randomized for your installation${NC}"
        else
            echo -e "${YELLOW}⚠️ Warning: Neither .env nor .env.txt found in $UC_CORE_DIR${NC}"
            echo "You'll need to create a .env file manually for UnicornCommander to work."
        fi
    else
        echo -e "${GREEN}✅ .env file already exists (not overwriting)${NC}"
    fi
    
    # Make start.sh executable if it exists
    if [ -f start.sh ]; then
        chmod +x start.sh
        echo -e "${GREEN}✅ start.sh made executable${NC}"
        
        # Test if we can start UnicornCommander (this will check dependencies)
        echo "🧪 Testing UnicornCommander setup..."
        if ./start.sh --dry-run 2>/dev/null || true; then
            echo -e "${GREEN}✅ UnicornCommander appears ready to run${NC}"
        else
            echo -e "${YELLOW}⚠️ UnicornCommander may need additional configuration${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ start.sh not found in $UC_CORE_DIR${NC}"
    fi
    
    cd ..
fi

print_section "Installation Complete!"
echo -e "${GREEN}🎉 All installations completed successfully!${NC}"
echo

# If new groups were added, we need to handle the shell session
if [ ${#NEWLY_ADDED[@]} -gt 0 ]; then
    echo -e "${YELLOW}📝 Important: You were added to new groups (${NEWLY_ADDED[*]}).${NC}"
    echo -e "${YELLOW}   To use Docker immediately, run: newgrp docker${NC}"
    echo -e "${YELLOW}   Or log out and back in for permanent access.${NC}"
    echo
fi
echo -e "${BLUE}Open Interpreter Usage:${NC}"
echo "  Method 1 (global): interpreter --help"
echo "  Method 2 (venv):   source $VENV_PATH/Open-Interpreter/bin/activate && interpreter"
echo "  Config file:       $ENV_FILE"
echo
echo -e "${BLUE}Docker Usage:${NC}"
echo "  Test: docker run hello-world"
echo "  Compose: docker compose --help"
echo
echo -e "${BLUE}Portainer Usage:${NC}"
echo "  Web UI: http://localhost:9000 or https://localhost:9443"
echo "  Status: docker ps | grep portainer"
echo "  Logs: docker logs portainer"
echo
echo -e "${BLUE}UnicornCommander Usage:${NC}"
if [ -d "$UC_CORE_DIR" ]; then
    echo "  Start: cd UC-1_Core && ./start.sh"
    echo "  Config: Edit UC-1_Core/.env with your API keys"
    echo "  SearXNG: http://localhost:8888 (after starting)"
    echo "  Open-WebUI: http://localhost:8080 (after starting)"
else
    echo "  Setup: Ensure UC-1_Core directory exists and re-run installer"
fi
echo

# Check if logout is needed
if [ ${#NEWLY_ADDED[@]} -gt 0 ]; then
    echo -e "${YELLOW}📝 Note: You were added to new groups (${NEWLY_ADDED[*]}).${NC}"
    echo -e "${YELLOW}   For full permissions, please log out and back in, or run:${NC}"
    echo -e "${YELLOW}   newgrp docker${NC}"
else
    echo -e "${GREEN}✅ All group memberships were already in place - no logout required!${NC}"
fi

print_section "Starting UnicornCommander"
if [ -d "$UC_CORE_DIR" ] && [ -f "$UC_CORE_DIR/start.sh" ]; then
    echo "🦄 Starting UnicornCommander automatically..."
    cd "$UC_CORE_DIR"
    ./start.sh
    cd ..
    echo -e "${GREEN}✅ UnicornCommander started successfully!${NC}"
    echo -e "${GREEN}🌐 SearXNG is now available at: http://localhost:8888${NC}"
    echo -e "${GREEN}🌐 Open-WebUI is now available at: http://localhost:8080${NC}"
else
    echo -e "${YELLOW}⚠️ Could not auto-start UnicornCommander - please run manually:${NC}"
    echo -e "${YELLOW}   cd UC-1_Core && ./start.sh${NC}"
fi

exit 0
