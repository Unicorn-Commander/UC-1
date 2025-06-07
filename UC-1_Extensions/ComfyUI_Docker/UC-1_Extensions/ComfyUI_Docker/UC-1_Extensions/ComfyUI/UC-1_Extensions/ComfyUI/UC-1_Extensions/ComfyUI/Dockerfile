FROM python:3.11-slim

# Install Vulkan and AMD GPU dependencies
RUN apt-get update && apt-get install -y 
    vulkan-utils 
    mesa-vulkan-drivers 
    libvulkan1 
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy ComfyUI source
COPY ./ /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Environment variables for Vulkan and AMD GPU
ENV LLAMA_VULKAN=1 
    LLAMA_VULKAN_FORCE=1 
    VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json 
    VULKAN_DEVICE=0

# Expose port (assuming 8188 for ComfyUI web UI, adjust if needed)
EXPOSE 8188

# Command to run ComfyUI server
CMD ["python", "server.py"]
