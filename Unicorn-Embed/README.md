# Unicorn Embed

GPU-accelerated embedding and reranking services using llama.cpp with Vulkan support for AMD GPUs.

## Features

- **GPU Accelerated**: Runs on AMD iGPUs using Vulkan (tested on AMD 8945hs with 780m iGPU)
- **Combined Services**: Both embedding and reranking in a single container
- **Production Ready**: Integrates with OpenWebUI, Qdrant, and PostgreSQL
- **Zero CPU Usage**: Complete GPU offloading for inference

## Models

- **Embedding**: nomic-embed-text-v1.5 (137M params, Q8_0 quantization)
- **Reranking**: bge-reranker-base (278M params, Q4_K_M quantization)

## Quick Start

### Option 1: Automated Setup (Recommended)

1. **Update model URLs** in `setup.sh` with your HuggingFace repo links
2. **Run the setup script**:
   ```bash
   ./setup.sh
   ```

The script will:
- Create the models directory
- Download models (if they don't exist)
- Build and start the Docker services
- Test both endpoints

### Option 2: Manual Setup

1. **Place your models** in the `models/` directory:
   - `nomic-embed-text-v1.5-q8_0.gguf`
   - `bge-reranker-base-q4_k_m.gguf`

2. **Start the services**:
   ```bash
   docker compose up --build -d
   ```

## Testing

```bash
# Test embedding
curl -X POST "http://localhost:9991/v1/embeddings" \
  -H "Content-Type: application/json" \
  -d '{"input": "test text", "model": "text-embedding"}'

# Test reranking
curl -X POST "http://localhost:9992/v1/rerank" \
  -H "Content-Type: application/json" \
  -d '{"query": "machine learning", "documents": ["AI and ML", "cooking recipes"], "model": "reranker"}'
```

## API Endpoints

- **Embedding Service**: `http://localhost:9991/v1/embeddings`
- **Reranking Service**: `http://localhost:9992/v1/rerank`

## Requirements

- Docker with GPU support
- AMD GPU with Vulkan drivers (RADV)
- `wget` and `curl` for setup script

## Management

```bash
# Stop services
docker compose down

# View logs
docker compose logs -f

# Restart services
docker compose restart
```

## Architecture

Uses the official `ghcr.io/ggml-org/llama.cpp:server-vulkan` image with supervisor to run both services in a single container for optimal resource sharing.
