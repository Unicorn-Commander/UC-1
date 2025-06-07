# ComfyUI Docker Environment

A comprehensive Docker setup for running ComfyUI with AMD GPU support, full filesystem access, and easy customization.

## Features

- 🎨 **Complete ComfyUI Installation**: Full access to modify source code and add custom nodes
- 🚀 **AMD GPU Support**: Optimized for AMD GPUs with ROCm and Vulkan support
- 📁 **Full File Access**: Direct access to all ComfyUI files, models, and configurations
- 🔧 **Easy Customization**: Modify ComfyUI source code directly from your host system
- 📦 **Model Management**: Organized directory structure for all model types
- 🌐 **Network Ready**: Configured for external network access

## Quick Start

1. **Clone and Setup**:
   ```bash
   chmod +x setup_comfyui.sh
   ./setup_comfyui.sh
   ```

2. **Access ComfyUI**:
   - Open your browser to: http://localhost:8188
   - ComfyUI should be running and ready to use

## What the Setup Does

The `setup_comfyui.sh` script:
1. Clones the ComfyUI repository to `./comfyui-data/`
2. Creates all necessary model directories
3. Sets up proper permissions
4. Builds and starts the Docker container
5. Mounts the entire ComfyUI installation for full access

## Directory Structure

After setup, you'll have full access to:

```
comfyui-data/
├── main.py                    # ComfyUI main application
├── requirements.txt           # Python dependencies
├── models/                    # All your AI models
│   ├── checkpoints/          # Stable Diffusion models
│   ├── loras/               # LoRA models
│   ├── vae/                 # VAE models
│   ├── controlnet/          # ControlNet models
│   ├── upscale_models/      # Upscaling models
│   └── [other model types]
├── custom_nodes/            # Custom ComfyUI nodes
├── input/                   # Input images
├── output/                  # Generated images
├── web/                     # Web interface files
├── user/                    # User data
├── my_workflows/           # Your custom workflows
├── temp/                   # Temporary files
└── config.yaml             # ComfyUI configuration
```

## Managing Models

Simply drag and drop your models into the appropriate directories:

- **Stable Diffusion Models**: `./comfyui-data/models/checkpoints/`
- **LoRA Models**: `./comfyui-data/models/loras/`
- **VAE Models**: `./comfyui-data/models/vae/`
- **ControlNet Models**: `./comfyui-data/models/controlnet/`
- **Upscaling Models**: `./comfyui-data/models/upscale_models/`

## Custom Nodes

To add custom nodes:
1. Clone or copy the custom node into `./comfyui-data/custom_nodes/`
2. Restart the container: `docker-compose restart comfyui`

## Configuration

Edit configuration files directly:
- **Main Config**: `./comfyui-data/config.yaml`
- **Model Paths**: `./comfyui-data/extra_model_paths.yaml`

## Docker Commands

### Basic Operations
```bash
# Start ComfyUI
docker-compose up -d

# Stop ComfyUI
docker-compose down

# Restart ComfyUI
docker-compose restart comfyui

# View logs
docker-compose logs -f comfyui

# Check status
docker-compose ps
```

### Development & Debugging
```bash
# Access container shell
docker-compose exec comfyui bash

# Rebuild container (after major changes)
docker-compose up --build -d

# Force rebuild (clear cache)
docker-compose build --no-cache
docker-compose up -d
```

## Customizing ComfyUI

Since the entire ComfyUI repository is mounted as a volume, you can:

1. **Modify Source Code**: Edit any Python file in `./comfyui-data/` directly
2. **Add Dependencies**: Edit `./comfyui-data/requirements.txt` and restart container
3. **Update ComfyUI**: 
   ```bash
   cd comfyui-data
   git pull origin main
   docker-compose restart comfyui
   ```

## GPU Configuration

The setup is optimized for AMD GPUs with:
- **ROCm Support**: For AMD GPU acceleration
- **Vulkan Support**: For additional GPU compute options
- **Device Access**: Direct access to GPU devices (`/dev/dri`, `/dev/kfd`)

### Environment Variables (already configured):
- `HSA_OVERRIDE_GFX_VERSION=11.0.0`
- `VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/amd_icd64.json`
- `ROC_ENABLE_PRE_VEGA=1`

## Network Configuration

ComfyUI runs on the `unicorn-network` external network. Ensure this network exists:

```bash
# Create network if it doesn't exist
docker network create unicorn-network
```

## Troubleshooting

### Container Won't Start
```bash
# Check logs for errors
docker-compose logs comfyui

# Rebuild container
docker-compose down
docker-compose up --build -d
```

### Permission Issues
```bash
# Fix permissions
chmod -R 755 comfyui-data
```

### GPU Not Detected
```bash
# Verify GPU access
docker-compose exec comfyui ls -la /dev/dri
```

### Python Dependencies Issues
```bash
# Reinstall dependencies
docker-compose exec comfyui pip3 install -r requirements.txt
```

### Reset Everything
```bash
# Complete reset (will lose local changes)
docker-compose down
rm -rf comfyui-data
./setup_comfyui.sh
```

## Advanced Usage

### Custom Network
To use a different network, edit `docker-compose.yaml`:
```yaml
networks:
  your-network:
    external: true
```

### Different Repository
To use a different ComfyUI fork, edit `setup_comfyui.sh`:
```bash
git clone https://github.com/your-username/ComfyUI.git comfyui-data
```

### Port Changes
To use a different port, edit `docker-compose.yaml`:
```yaml
ports:
  - "8189:8188"  # Change 8189 to your desired port
```

## File Persistence

All files in `./comfyui-data/` persist between container restarts, including:
- Generated images
- Installed models
- Custom nodes
- Configuration changes
- Source code modifications

## Security Notes

- ComfyUI runs with host file system access
- Models and generated content are stored locally
- Container runs with necessary GPU device access
- Network is isolated to the `unicorn-network`

## Support

For ComfyUI-specific issues, refer to the [official ComfyUI documentation](https://github.com/comfyanonymous/ComfyUI).

For Docker setup issues, check the troubleshooting section above.