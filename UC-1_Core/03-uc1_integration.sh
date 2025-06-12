#!/bin/bash
set -e

# ... [rest of initial script remains unchanged] ...

# Create AI development environment
print_section "Setting up AI Development Environment"
if [ ! -d "/home/ucadmin/ai-env" ]; then
    echo -e "${BLUE}Creating AI Python environment...${NC}"
    
    # Add deadsnakes PPA for Python 3.11
    if ! grep -q "deadsnakes" /etc/apt/sources.list.d/*; then
        echo -e "${BLUE}Adding deadsnakes PPA for Python 3.11...${NC}"
        sudo add-apt-repository ppa:deadsnakes/ppa -y
        sudo apt update
    fi
    
    sudo apt install -y python3.11 python3.11-venv python3-pip libpq-dev build-essential
    
    # Create environment with Python 3.11
    python3.11 -m venv /home/ucadmin/ai-env
    source /home/ucadmin/ai-env/bin/activate
    
    pip install --upgrade pip --quiet
    pip install \
        torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/rocm6.3.2 \
        jupyterlab==4.2.5 \
        gradio==4.44.0 \
        streamlit==1.38.0 \
        transformers==4.44.2 \
        numpy==1.26.4 \
        pandas==2.2.2 \
        matplotlib==3.9.2 || {
        echo -e "${YELLOW}⚠️ Failed to install PyTorch, check network or ROCm compatibility${NC}"
        echo -e "${BLUE}Python version in environment: $(python --version)${NC}"
        deactivate
        exit 1
    }
    deactivate
else
    echo -e "${GREEN}✅ AI environment already exists${NC}"
    source /home/ucadmin/ai-env/bin/activate
    
    # Verify Python version first
    PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if [[ "$PYTHON_VERSION" != "3.8" && "$PYTHON_VERSION" != "3.9" && 
          "$PYTHON_VERSION" != "3.10" && "$PYTHON_VERSION" != "3.11" ]]; then
        echo -e "${YELLOW}⚠️ Unsupported Python version $PYTHON_VERSION for PyTorch 2.3.1${NC}"
        echo -e "${BLUE}Recreating environment with Python 3.11...${NC}"
        deactivate
        rm -rf /home/ucadmin/ai-env
        
        # Ensure deadsnakes PPA is available
        if ! grep -q "deadsnakes" /etc/apt/sources.list.d/*; then
            echo -e "${BLUE}Adding deadsnakes PPA for Python 3.11...${NC}"
            sudo add-apt-repository ppa:deadsnakes/ppa -y
            sudo apt update
        fi
        
        sudo apt install -y python3.11 python3.11-venv
        python3.11 -m venv /home/ucadmin/ai-env
        source /home/ucadmin/ai-env/bin/activate
    fi
    
    pip install --upgrade pip --quiet
    
    # ... [rest of this section remains unchanged] ...

fi

# ... [rest of script remains unchanged] ...
