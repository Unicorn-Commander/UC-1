# Use the official llama.cpp server with Vulkan support
FROM ghcr.io/ggml-org/llama.cpp:server-vulkan

# Set environment variables for AMD 780M iGPU optimization (VULKAN-ONLY)
ENV LLAMA_VULKAN=1
ENV LLAMA_VULKAN_FORCE=1
ENV VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
ENV VULKAN_DEVICE=0
# Note: ROCm intentionally NOT installed - pure Vulkan performance

# Install curl for health checks and Python for the API wrapper
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install minimal Python dependencies for API wrapper
RUN pip3 install --break-system-packages fastapi uvicorn aiofiles requests numpy pydantic

# Create app directory
WORKDIR /app

# Copy application files
COPY llama_server_wrapper.py /app/
COPY models/ /app/models/

# Expose port
EXPOSE 8000

# Health check with longer timeout for model loading
HEALTHCHECK --interval=30s --timeout=15s --start-period=180s --retries=5 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the Python wrapper that manages multiple llama-server instances
ENTRYPOINT ["python3", "/app/llama_server_wrapper.py"]
