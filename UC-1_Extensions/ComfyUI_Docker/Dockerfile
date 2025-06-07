FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including Vulkan and ROCm support
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv git wget \
    libvulkan1 mesa-vulkan-drivers vulkan-tools \
    libnuma1 libdrm2 libelf1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app/ComfyUI

# Expose port
EXPOSE 8188

# Install requirements and run ComfyUI when container starts
CMD pip3 install --upgrade pip && \
    pip3 install -r requirements.txt && \
    pip3 install comfyui-frontend-package && \
    python3 main.py --listen 0.0.0.0 --port 8188
