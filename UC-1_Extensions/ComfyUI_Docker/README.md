# ComfyUI Docker Extension

This document provides details on the ComfyUI Docker setup within the Unicorn Commander UC-1 system.

## 1. Purpose

ComfyUI is a powerful and flexible stable diffusion GUI, allowing users to design and execute complex stable diffusion workflows using a node-based interface. This Docker extension provides a containerized environment for running ComfyUI, optimized for your AMD GPU.

## 2. Location

The Docker Compose setup for ComfyUI is located at:
`/home/ucadmin/UC-1/UC-1_Extensions/ComfyUI_Docker/`

## 3. Network Integration

ComfyUI is configured to connect to the shared `unicorn-network`.

*   **Network Name:** `unicorn-network`
*   **Type:** External (shared with the core Docker stack)

This allows ComfyUI to communicate with other services on the `unicorn-network` if needed, although its primary function is typically self-contained GPU inference.

## 4. Access

ComfyUI is accessible via its exposed port:

*   **Port:** `8188`
*   **Access URLs:**
    *   `http://localhost:8188`
    *   `http://<your_host_ip>:8188`
    *   `http://host.docker.internal:8188` (from within other Docker containers)

## 5. Startup and Management

To manage the ComfyUI container, navigate to its directory and use `docker compose` commands:

```bash
cd /home/ucadmin/UC-1/UC-1_Extensions/ComfyUI_Docker

# Start ComfyUI in detached mode
docker compose up -d

# Stop ComfyUI
docker compose down

# Restart ComfyUI
docker compose restart

# View logs
docker compose logs -f
```

## 6. Key Configuration & Notes

*   **GPU Acceleration:** The `docker-compose.yaml` passes through `/dev/dri` and `/dev/kfd` devices and sets `HSA_OVERRIDE_GFX_VERSION=11.0.3` to enable AMD GPU (ROCm) acceleration for ComfyUI.
*   **Data Persistence:** ComfyUI data (models, custom nodes, workflows) is persisted via a bind mount:
    `- ./comfyui-data:/app/ComfyUI`
    This means the `comfyui-data` directory in the `ComfyUI_Docker` folder on your host machine will contain all your ComfyUI files.
*   **Optimization:** While Vulkan is mentioned, ComfyUI primarily leverages ROCm for GPU acceleration on AMD hardware. The current setup is optimized for ROCm.
