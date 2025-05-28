# Unicorn Embedding Server

High-performance embedding server optimized for AMD 8945HS + 780M iGPU using native llama.cpp with pure Vulkan acceleration.

## Overview

This project provides OpenAI-compatible embedding APIs using native llama.cpp servers with optimal hardware acceleration for AMD systems. No Python wrapper overhead - direct native performance.

## Hardware Specifications

- **CPU**: AMD 8945HS processor
- **iGPU**: 780M (Phoenix3 architecture, RDNA 3)
- **RAM**: 96GB (auto-configured for high performance)
- **Acceleration**: Pure Vulkan (RADV Phoenix driver)

## Features

- ✅ Native llama.cpp embedding server
- ✅ OpenAI-compatible `/v1/embeddings` API
- ✅ Pure Vulkan acceleration (no ROCm dependencies)
- ✅ Auto-configured for 96GB RAM systems
- ✅ Nomic v1.5 embedding model (768 dimensions)
- ✅ BGE reranker model support
- ✅ Docker containerization with GPU access
- ✅ Health monitoring and auto-restart

## Current Status

### ✅ Working
- **Embedding Server**: Native llama.cpp on port 8001
- **API Endpoint**: `http://localhost:8001/v1/embeddings`
- **Model**: Nomic Embed Text v1.5 (Q8_0 quantization)
- **Performance**: Direct GPU acceleration, no wrapper overhead
- **Compatibility**: Full OpenAI API compatibility

### ⚠️ In Progress
- **Reranking Server**: BGE reranker model configured but environment conflicts
- **Native Rerank API**: `/v1/rerank` endpoint has configuration issues

### 🔧 Workaround
- Use embedding similarity for reranking functionality
- Simple Python reranking service available as fallback

## Quick Start

```bash
# Start the native embedding server
cd /home/ucadmin/UC-1/Unicorn-Embed
docker compose -f docker-compose-native.yml up -d embedding-server

# Test the embedding endpoint
curl -X POST http://localhost:8001/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"input": "test", "model": "nomic"}'
```

## API Endpoints

### Embedding API
- **URL**: `http://localhost:8001/v1/embeddings`
- **Method**: POST
- **Format**: OpenAI-compatible

```json
{
  "input": "Your text here",
  "model": "nomic-embed-text-v1.5"
}
```

**Response**:
```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [0.1, 0.2, ...],  // 768 dimensions
      "index": 0
    }
  ],
  "model": "nomic-embed-text-v1.5",
  "usage": {
    "prompt_tokens": 2,
    "total_tokens": 2
  }
}
```

### Health Check
- **URL**: `http://localhost:8001/health`
- **Method**: GET

## Configuration

### Docker Compose (Native)
```yaml
# Uses pure native llama.cpp servers
docker compose -f docker-compose-native.yml up -d
```

### Environment Variables
- `LLAMA_VULKAN=1` - Enable Vulkan backend
- `LLAMA_VULKAN_FORCE=1` - Force Vulkan-only mode
- `VULKAN_DEVICE=0` - Use first GPU device

### Model Configuration
- **Context Size**: 6000 tokens (reduced for stability)
- **Batch Size**: 512 (optimized for 96GB RAM)
- **GPU Layers**: -1 (all layers on GPU)
- **Threads**: 4 (balanced for 8945HS)

## Integration with Open WebUI

Configure Open WebUI embedding settings:
- **Provider**: OpenAI
- **Base URL**: `http://localhost:8001`
- **Model**: `nomic-embed-text-v1.5`
- **API Key**: Not required

## Troubleshooting

### Common Issues

1. **Port 8001 not accessible**
   ```bash
   # Check if container is running
   docker ps --filter "name=unicorn-embedding"
   
   # Check logs
   docker logs unicorn-embedding-native
   ```

2. **GPU not detected**
   ```bash
   # Verify Vulkan setup
   docker exec unicorn-embedding-native vulkaninfo
   ```

3. **Model loading fails**
   ```bash
   # Check model file exists
   ls -la models/embeddings/
   ```

### Performance Tuning

For different RAM configurations:
- **32GB**: Set `--batch-size 256`, `--n-gpu-layers 15`
- **64GB**: Set `--batch-size 384`, `--n-gpu-layers 20` 
- **96GB+**: Current settings optimal

## File Structure

```
Unicorn-Embed/
├── README.md                           # This file
├── PROJECT_STATUS.md                   # Detailed project status
├── docker-compose-native.yml           # Native llama.cpp setup
├── models/
│   ├── embeddings/
│   │   └── nomic-embed-text-v1.5.Q8_0.gguf
│   └── rerankers/
│       └── bge-reranker-v2-m3-Q8_0.gguf
├── logs/                               # Server logs
└── simple_rerank.py                    # Fallback reranking service
```

## Contributing

This project is part of the UC-1 ecosystem. See the main UC-1 repository for contribution guidelines.

## License

See the main UC-1 project license.