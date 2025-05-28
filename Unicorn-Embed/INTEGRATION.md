# Unicorn Open-WebUI Integration Guide

## ✅ Current Status - Native Implementation

Your embedding server is now running with native llama.cpp:
- **Embedding Model**: nomic-embed-text-v1.5.Q8_0.gguf (✅ Working)
- **Embedding Endpoint**: http://localhost:8001/v1/embeddings
- **Reranking Model**: bge-reranker-v2-m3.Q8_0.gguf (⚠️ Configuration issues)
- **Architecture**: Native llama.cpp servers with Vulkan acceleration

## 🔗 Integrating with Your Unicorn Stack

### Current Working Configuration

#### Option 1: OpenAI Provider (Recommended)
Configure Open-WebUI to use the native embedding server:

1. **Access Open-WebUI Admin Settings**
2. **Navigate to**: Settings → Admin Settings → External Services
3. **Configure Embedding Provider**:
   - Provider: `OpenAI`
   - Base URL: `http://localhost:8001`
   - API Key: `not-required` (any value)
   - Model: `nomic-embed-text-v1.5`

#### Option 2: Environment Variables
Add to your Open-WebUI container environment:

```yaml
unicorn-open-webui:
  environment:
    # Embedding configuration
    - RAG_EMBEDDING_ENGINE=openai
    - RAG_EMBEDDING_MODEL=nomic-embed-text-v1.5
    - OPENAI_API_BASE_URL=http://localhost:8001
    - OPENAI_API_KEY=not-required
```

### Alternative: Direct Docker Network
If using docker network references:
```yaml
- OPENAI_API_BASE_URL=http://unicorn-embedding-native:8080
```

## 🧪 Testing

### Test Native Embedding Endpoint
```bash
# Test health
curl http://localhost:8001/health

# Test embeddings
curl -X POST http://localhost:8001/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"input": "test document", "model": "nomic"}'

# Check available models
curl http://localhost:8001/v1/models
```

### Test Open-WebUI Integration
1. Upload a document to Open-WebUI
2. Verify it processes without errors
3. Test RAG functionality with queries

## 🔧 Service Management

### Start Services
```bash
cd /home/ucadmin/UC-1/Unicorn-Embed

# Start embedding server (stable)
docker compose -f docker-compose-native.yml up -d embedding-server

# Optional: Start problematic reranker (for debugging)
docker compose -f docker-compose-native.yml up -d reranker-server
```

### Monitor Services
```bash
# Check container status
docker ps --filter "name=unicorn-"

# View embedding server logs
docker logs -f unicorn-embedding-native

# View reranker logs (if debugging)
docker logs -f unicorn-reranker-native
```

### Restart Services
```bash
# Restart embedding server
docker compose -f docker-compose-native.yml restart embedding-server

# Full restart
docker compose -f docker-compose-native.yml restart
```

## 📊 Monitoring & Health Checks

### Native Server Health
- **Embedding**: http://localhost:8001/health
- **Reranker**: http://localhost:8002/health (when working)

### Performance Metrics
- GPU utilization via `nvidia-smi` or `radeontop`
- Container resource usage: `docker stats`
- Response times via curl timing

### Log Monitoring
```bash
# Tail logs for both services
docker compose -f docker-compose-native.yml logs -f

# Check startup issues
docker logs unicorn-embedding-native --tail 50
```

## ⚠️ Known Issues & Workarounds

### Reranking Configuration Conflict
**Issue**: Native reranker fails with environment conflicts
**Error**: `either --embedding or --reranking can be specified, but not both`
**Workaround**: Use embedding similarity for document reranking
**Status**: Under investigation

### Startup Warnings
**Issue**: `LLAMA_ARG_HOST environment variable` warnings
**Impact**: Cosmetic only, servers function normally
**Status**: Known Docker image issue

## 🚀 Performance Optimization

### Current Configuration (96GB RAM)
- **Context Size**: 6000 tokens (stability optimized)
- **Batch Size**: 512 (high throughput)
- **GPU Layers**: -1 (all layers on GPU)
- **Threads**: 4 (balanced for 8945HS)

### For Different RAM Configurations
```yaml
# 32GB Systems
--batch-size 256
--n-gpu-layers 15

# 64GB Systems  
--batch-size 384
--n-gpu-layers 20

# 96GB+ Systems (current)
--batch-size 512
--n-gpu-layers -1
```

## 🔮 Future Enhancements

### Planned Improvements
1. **Resolve Native Reranking**: Source compilation approach
2. **Add Metrics**: Prometheus/Grafana integration
3. **Multi-Model Support**: Additional embedding models
4. **Load Balancing**: Multiple server instances

### Alternative Solutions
1. **Lightweight Reranking Service**: Python microservice using embeddings
2. **Similarity-Based Reranking**: Cosine similarity calculations
3. **Hybrid Approach**: Native embeddings + Python reranking

## 📋 Troubleshooting

### Common Issues

#### 1. Embedding Server Not Responding
```bash
# Check if running
docker ps --filter "name=unicorn-embedding"

# Check logs
docker logs unicorn-embedding-native

# Restart if needed
docker compose -f docker-compose-native.yml restart embedding-server
```

#### 2. Open-WebUI Can't Connect
```bash
# Test from Open-WebUI container
docker exec unicorn-open-webui curl http://localhost:8001/health

# Check network connectivity
docker network inspect unicorn-network
```

#### 3. Poor Performance
```bash
# Check GPU utilization
radeontop

# Monitor container resources
docker stats unicorn-embedding-native

# Review configuration for your RAM size
```

## 📄 File Structure

```
Unicorn-Embed/
├── README.md                          # Main documentation
├── PROJECT_STATUS.md                  # Detailed project status  
├── INTEGRATION.md                     # This integration guide
├── docker-compose-native.yml          # Native llama.cpp setup
├── models/
│   ├── embeddings/
│   │   └── nomic-embed-text-v1.5.Q8_0.gguf
│   └── rerankers/
│       └── bge-reranker-v2-m3-Q8_0.gguf
└── logs/                              # Server logs
```

This integration guide reflects the current native implementation status and provides practical configuration steps for the working embedding functionality.
