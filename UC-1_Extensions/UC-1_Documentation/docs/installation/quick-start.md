# Quick Start Installation Guide

Get UC-1 running in under 10 minutes with our automated installation script.

## Prerequisites

!!! warning "System Requirements"
    - **OS**: Ubuntu 20.04+ or compatible Linux distribution
    - **RAM**: Minimum 16GB, Recommended 32GB+
    - **Storage**: 100GB+ free space
    - **Network**: Internet connection for initial setup
    - **Privileges**: sudo access required

## One-Command Installation

```bash
# Clone and install UC-1 in one command
git clone https://github.com/Unicorn-Commander/UC-1.git && cd UC-1 && ./install_UC-1.sh
```

That's it! The script will:
1. Install all system dependencies
2. Set up Docker and Docker Compose
3. Configure user permissions
4. Clone and install The Colonel (Open Interpreter fork)
5. Start all UC-1 services automatically

## What Gets Installed

### Core System Components
- **Python 3.11**: Latest Python with optimizations
- **Docker Engine**: Container runtime with GPU support
- **Docker Compose v2**: Service orchestration
- **Open Interpreter (The Colonel)**: Our enhanced fork
- **Redis Memory Fix**: System optimization for containers

### UC-1 Services
After installation, these services will be running:

| Service | URL | Description |
|---------|-----|-------------|
| **Open WebUI** | http://localhost:8080 | Main chat interface |
| **SearXNG** | http://localhost:8888 | Privacy-focused search |
| **Embedding Server** | http://localhost:8001 | Vector embeddings API |
| **Documentation** | http://localhost:8000 | This documentation site |
| **Qdrant** | http://localhost:6333 | Vector database |

## Verification

### Check Services
```bash
# View all running containers
docker ps

# Check UC-1 specific services
docker ps --filter \"name=unicorn-\"

# View service logs
docker logs unicorn-searxng
```

### Test APIs
```bash
# Test embedding server
curl -X POST http://localhost:8001/v1/embeddings \\
  -H \"Content-Type: application/json\" \\
  -d '{\"input\": \"Hello UC-1!\", \"model\": \"nomic\"}'

# Test Open WebUI
curl http://localhost:8080/health

# Test SearXNG
curl http://localhost:8888
```

### Access Web Interfaces
1. **Open WebUI**: Navigate to http://localhost:8080
2. **Create Account**: Follow the setup wizard
3. **SearXNG**: Visit http://localhost:8888 for search
4. **Documentation**: Access this site at http://localhost:8000

## Post-Installation Setup

### 1. Configure Open WebUI
```bash
# Access Open WebUI at http://localhost:8080
# Create your admin account (first user becomes admin)
# Configure embedding provider:
#   - Provider: OpenAI
#   - Base URL: http://localhost:8001
#   - Model: nomic-embed-text-v1.5
```

### 2. Set Up The Colonel
```bash
# The Colonel is pre-configured and available in Open WebUI
# Access it through the Tools menu
# Or via command line:
cd UC-1_Extensions/The_Colonel
source /opt/open-interpreter/Open-Interpreter/bin/activate
interpreter --help
```

### 3. Test Document Upload
1. Open http://localhost:8080
2. Upload a test document
3. Ask questions about the document content
4. Verify RAG functionality works

## Common Post-Install Tasks

### Environment Configuration
```bash
# Edit environment variables (if needed)
cd UC-1_Core
nano .env

# Restart services after changes
./start.sh
```

### Add API Keys (Optional)
```bash
# Edit the Open Interpreter environment file
nano /opt/open-interpreter/.env

# Add your API keys (optional - works locally without keys):
# OPENAI_API_KEY=your_key_here
# ANTHROPIC_API_KEY=your_key_here
```

### GPU Optimization (AMD)
```bash
# Verify GPU access
docker run --rm --device=/dev/dri -it ubuntu:22.04 ls -la /dev/dri

# Test Vulkan
vulkaninfo | grep deviceName
```

## Troubleshooting Quick Fixes

### Services Won't Start
```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker if needed
sudo systemctl restart docker

# Restart UC-1 services
cd UC-1_Core && ./start.sh
```

### Permission Issues
```bash
# Add user to docker group (if not done by installer)
sudo usermod -aG docker $USER

# Logout and login again, or use:
newgrp docker
```

### Port Conflicts
```bash
# Check what's using ports
sudo netstat -tlnp | grep ':8080\\|:8888\\|:8001'

# Stop conflicting services or change ports in docker-compose.yml
```

### Memory Issues
```bash
# Check available memory
free -h

# Check container memory usage
docker stats

# Reduce batch sizes if needed (edit docker-compose.yml)
```

## Next Steps

!!! tip "Recommended Next Actions"
    1. **[Getting Started Guide](../guides/getting-started.md)** - Learn UC-1 basics
    2. **[RAG Setup](../guides/rag-setup.md)** - Configure document intelligence
    3. **[Agent Configuration](../guides/agents.md)** - Customize The Colonel
    4. **[Component Overview](../components/stack.md)** - Understand the architecture

## Support

If you encounter issues:

1. **Check Logs**: `docker logs <container_name>`
2. **Restart Services**: `cd UC-1_Core && ./start.sh`
3. **Review Documentation**: Each component has detailed troubleshooting
4. **Community Support**: GitHub issues and discussions

---

**Installation complete! Welcome to UC-1.** 🦄

*Take Command. Conquer. Win.*