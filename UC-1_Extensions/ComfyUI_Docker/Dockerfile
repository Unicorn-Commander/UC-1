FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including Vulkan and ROCm support
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv git wget \
    libvulkan1 mesa-vulkan-drivers vulkan-tools \
    libnuma1 libdrm2 libelf1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone ComfyUI from your fork
RUN git clone https://github.com/Unicorn-Commander/ComfyUI.git .

# Install ComfyUI's requirements and add missing packages
RUN pip3 install --upgrade pip && \
    pip3 install -r requirements.txt && \
    pip3 install comfyui-frontend-package

# Create directories for models and outputs
RUN mkdir -p /app/models /app/input /app/output /app/custom_nodes \
             /app/user /app/my_workflows /app/temp /app/cache \
             /app/web/extensions /app/web/user

# Expose port
EXPOSE 8188

# Run ComfyUI with GPU support (AMD/Vulkan)
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
