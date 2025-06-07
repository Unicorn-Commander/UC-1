#!/bin/bash

echo "🎨 Setting up ComfyUI Docker environment..."

# Create main ComfyUI data directory
echo "📁 Creating ComfyUI data directory..."
mkdir -p comfyui-data

# Create main directories inside comfyui-data
echo "📂 Creating main directories..."
mkdir -p comfyui-data/{input,output,custom_nodes,user,my_workflows,temp,cache}
mkdir -p comfyui-data/web/{extensions,user}

# Create all model subdirectories based on ComfyUI structure
echo "🤖 Creating model subdirectories..."
mkdir -p comfyui-data/models/{checkpoints,loras,vae,text_encoders,diffusion_models,clip_vision,style_models,embeddings,diffusers,vae_approx,controlnet,gligen,upscale_models,hypernetworks,photomaker,classifiers}

# Create config files if they don't exist
echo "⚙️ Creating config files..."
touch comfyui-data/config.yaml
touch comfyui-data/extra_model_paths.yaml

# Set proper permissions (important for Docker)
echo "🔐 Setting permissions..."
chmod -R 755 comfyui-data
chmod 644 comfyui-data/*.yaml 2>/dev/null || true

# Display directory structure
echo ""
echo "✅ Setup complete! Directory structure:"
echo ""
tree comfyui-data -L 2 2>/dev/null || ls -la comfyui-data

echo ""
echo "📋 Starting ComfyUI..."
echo "Building and starting containers..."
docker-compose up --build -d

echo ""
echo "⏳ Waiting for ComfyUI to start..."
sleep 10

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎉 ComfyUI should be running at: http://localhost:8188"
echo "📊 Check container status: docker-compose ps"
echo "📜 View logs: docker-compose logs -f comfyui"
echo ""
echo "🗂️ Your model directories:"
echo "  - Checkpoints: ./comfyui-data/models/checkpoints/"
echo "  - LoRAs: ./comfyui-data/models/loras/"
echo "  - VAE: ./comfyui-data/models/vae/"
echo "  - ControlNet: ./comfyui-data/models/controlnet/"
echo "  - And more under ./comfyui-data/models/"
