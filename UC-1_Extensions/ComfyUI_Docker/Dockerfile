FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y     python3 python3-pip python3-venv git     libvulkan1 mesa-vulkan-drivers vulkan-tools     && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt

# Copy the rest of the application
COPY . .

# Expose port
EXPOSE 8188

# Run ComfyUI with CPU mode
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--cpu"]
