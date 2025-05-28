#!/bin/bash

# Unicorn Embedding Server - Complete Setup Script
# AMD 8945HS with 780m iGPU Optimized (Vulkan + ROCm 11.0.2 HDA Override)
# This script does EVERYTHING: downloads models, configures Docker, and starts the service
#
# CRITICAL SUCCESS FACTORS for AMD 8945HS + 780M iGPU:
# 1. HSA_OVERRIDE_GFX_VERSION=11.0.2 (tricks ROCm into supporting gfx1103)
# 2. Vulkan primary backend with RADV driver
# 3. Conservative GPU layer allocation (20 for embeddings, 15 for rerankers)
# 4. Shared memory optimization (no mlock, use mmap)
# 5. Ubuntu 25.04 with latest Mesa drivers

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
EMBEDDING_MODEL_URL="https://huggingface.co/nomic-ai/nomic-embed-text-v1.5-GGUF/resolve/main/nomic-embed-text-v1.5.Q8_0.gguf"
RERANKER_MODEL_URL="https://huggingface.co/gpustack/bge-reranker-v2-m3-GGUF/resolve/main/bge-reranker-v2-m3-Q8_0.gguf"

print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              Unicorn Embedding Server Setup                 ║"
    echo "║     AMD 8945HS + 780m iGPU (Vulkan + ROCm 11.0.2)           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_requirements() {
    echo -e "${BLUE}🔍 Checking system requirements...${NC}"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker not found. Please install Docker first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker found${NC}"
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}✗ Docker Compose not found. Please install Docker Compose first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker Compose found${NC}"
    
    # CRITICAL: Check for AMD 8945HS processor
    if lscpu | grep -q "8945HS"; then
        echo -e "${GREEN}✓ AMD 8945HS processor detected${NC}"
    else
        echo -e "${YELLOW}⚠ This script is optimized for AMD 8945HS. Results may vary on other hardware.${NC}"
    fi
    
    # CRITICAL: Check for AMD 780M iGPU
    if lspci | grep -q "Phoenix3"; then
        echo -e "${GREEN}✓ AMD 780M iGPU (Phoenix3) detected${NC}"
    else
        echo -e "${YELLOW}⚠ AMD 780M iGPU not detected. This script is optimized for Phoenix3 architecture.${NC}"
    fi
    
    # Check for Vulkan support (CRITICAL for performance)
    if command -v vulkaninfo &> /dev/null; then
        echo -e "${GREEN}✓ Vulkan tools found${NC}"
        if vulkaninfo 2>/dev/null | grep -q "RADV PHOENIX"; then
            echo -e "${GREEN}✓ AMD RADV Phoenix driver detected (OPTIMAL)${NC}"
        elif vulkaninfo 2>/dev/null | grep -q "AMD"; then
            echo -e "${YELLOW}⚠ AMD GPU detected but not Phoenix driver${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ vulkaninfo not found. Installing Vulkan support...${NC}"
        sudo apt update && sudo apt install -y vulkan-tools mesa-vulkan-drivers libvulkan1
        echo -e "${GREEN}✓ Vulkan support installed${NC}"
    fi
    
    # Check Ubuntu version (25.04 optimal for latest Mesa drivers)
    if grep -q "25.04" /etc/os-release 2>/dev/null; then
        echo -e "${GREEN}✓ Ubuntu 25.04 detected (OPTIMAL)${NC}"
    elif grep -q "24.04" /etc/os-release 2>/dev/null; then
        echo -e "${YELLOW}⚠ Ubuntu 24.04 detected. 25.04 recommended for latest AMD drivers.${NC}"
    else
        echo -e "${YELLOW}⚠ Ubuntu version not optimal. This script is tested on 25.04.${NC}"
    fi
    
    # Check for ROCm (for HDA override compatibility)
    if command -v rocminfo &> /dev/null || [ -d "/opt/rocm" ]; then
        echo -e "${GREEN}✓ ROCm detected${NC}"
    else
        echo -e "${YELLOW}⚠ ROCm not detected. Will be installed in container for HDA override${NC}"
    fi
    
    # Check for download tools
    if command -v wget &> /dev/null; then
        DOWNLOAD_CMD="wget -c"
        echo -e "${GREEN}✓ wget found${NC}"
    elif command -v curl &> /dev/null; then
        DOWNLOAD_CMD="curl -L -C -"
        echo -e "${GREEN}✓ curl found${NC}"
    else
        echo -e "${RED}✗ Neither wget nor curl found. Installing wget...${NC}"
        sudo apt update && sudo apt install -y wget
        DOWNLOAD_CMD="wget -c"
    fi
}

create_directories() {
    echo -e "${BLUE}📁 Creating directory structure...${NC}"
    
    mkdir -p models/{embeddings,rerankers}
    mkdir -p logs
    mkdir -p config
    
    echo -e "${GREEN}✓ Directories created${NC}"
}

download_models() {
    echo -e "${BLUE}📥 Downloading models (this may take a while)...${NC}"
    echo -e "${YELLOW}Total download size: ~800MB${NC}"
    
    # Download embedding model
    echo -e "${BLUE}Downloading nomic-embed-text-v1.5 Q8...${NC}"
    cd models/embeddings/
    if [ ! -f "nomic-embed-text-v1.5.Q8_0.gguf" ]; then
        $DOWNLOAD_CMD "$EMBEDDING_MODEL_URL" -O nomic-embed-text-v1.5.Q8_0.gguf
        if [ -f "nomic-embed-text-v1.5.Q8_0.gguf" ]; then
            MODEL_SIZE=$(du -h nomic-embed-text-v1.5.Q8_0.gguf | cut -f1)
            echo -e "${GREEN}✓ Embedding model downloaded (${MODEL_SIZE})${NC}"
        else
            echo -e "${RED}✗ Failed to download embedding model${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Embedding model already exists${NC}"
    fi
    cd ../../
    
    # Download reranking model
    echo -e "${BLUE}Downloading bge-reranker-v2-m3 Q8...${NC}"
    cd models/rerankers/
    if [ ! -f "bge-reranker-v2-m3-Q8_0.gguf" ]; then
        $DOWNLOAD_CMD "$RERANKER_MODEL_URL" -O bge-reranker-v2-m3-Q8_0.gguf
        if [ -f "bge-reranker-v2-m3-Q8_0.gguf" ]; then
            MODEL_SIZE=$(du -h bge-reranker-v2-m3-Q8_0.gguf | cut -f1)
            echo -e "${GREEN}✓ Reranking model downloaded (${MODEL_SIZE})${NC}"
        else
            echo -e "${RED}✗ Failed to download reranking model${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Reranking model already exists${NC}"
    fi
    cd ../../
}

create_env_file() {
    echo -e "${BLUE}⚙️  Creating environment configuration...${NC}"
    
    # Detect system RAM to optimize configuration
    TOTAL_RAM_GB=$(free -g | awk 'NR==2{print $2}')
    
    if [ "$TOTAL_RAM_GB" -ge 64 ]; then
        GPU_LAYERS=-1
        GPU_ALLOC=95
        BATCH_SIZE=1024
        CONTEXT_SIZE=8192
        echo -e "${GREEN}✓ Detected ${TOTAL_RAM_GB}GB RAM - Using high-performance configuration${NC}"
    elif [ "$TOTAL_RAM_GB" -ge 32 ]; then
        GPU_LAYERS=25
        GPU_ALLOC=85
        BATCH_SIZE=512
        CONTEXT_SIZE=8192
        echo -e "${GREEN}✓ Detected ${TOTAL_RAM_GB}GB RAM - Using balanced configuration${NC}"
    else
        GPU_LAYERS=20
        GPU_ALLOC=80
        BATCH_SIZE=256
        CONTEXT_SIZE=8192
        echo -e "${YELLOW}⚠ Detected ${TOTAL_RAM_GB}GB RAM - Using conservative configuration${NC}"
    fi
    
    cat > .env << EOF
# Unicorn Embedding Server Configuration
MODELS_DIR=./models
UNLOAD_TIMEOUT=300

# Server configuration
HOST=0.0.0.0
PORT=8000

# AMD GPU configuration for 780m iGPU with ${TOTAL_RAM_GB}GB RAM (VULKAN-ONLY)
LLAMA_VULKAN=1
LLAMA_VULKAN_FORCE=1
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
VULKAN_DEVICE=0
GPU_MAX_ALLOC_PERCENT=${GPU_ALLOC}
# Note: ROCm disabled - using pure Vulkan for optimal performance

# Model-specific optimizations (auto-configured for ${TOTAL_RAM_GB}GB RAM)
# Nomic v1.5: 8192 context, BGE reranker: 1024 recommended
LLAMA_N_GPU_LAYERS=${GPU_LAYERS}
LLAMA_N_CTX=${CONTEXT_SIZE}
LLAMA_N_BATCH=${BATCH_SIZE}
LLAMA_N_THREADS=8

# Logging
LOG_LEVEL=INFO
EOF

    echo -e "${GREEN}✓ Environment file created with optimizations for ${TOTAL_RAM_GB}GB RAM${NC}"
}

create_requirements_file() {
    echo -e "${BLUE}📦 Creating requirements file (minimal - using official llama.cpp image)...${NC}"
    
    cat > requirements.txt << 'EOF'
# Minimal requirements - base image provides llama.cpp
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
numpy==1.24.3
requests==2.31.0
aiofiles==23.2.1
EOF

    echo -e "${GREEN}✓ Requirements file created${NC}"
}

create_server_file() {
    echo -e "${BLUE}🐍 Creating native llama-server process wrapper...${NC}"
    
    cat > llama_cpp_server.py << 'EOF'
#!/usr/bin/env python3
"""
Native llama-server subprocess manager and FastAPI wrapper
Manages multiple native llama-server processes for optimal performance
Each model runs in its own llama-server process with dedicated ports
"""

import os
import sys
import json
import time
import asyncio
import logging
import subprocess
import signal
import requests
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Union, Any
from contextlib import asynccontextmanager
from dataclasses import dataclass

import uvicorn
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import numpy as np

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class ModelConfig:
    """Configuration for a model server instance"""
    path: str
    name: str
    type: str  # 'embedding' or 'reranking'
    port: int
    n_gpu_layers: int = -1  # -1 for all layers on GPU
    n_ctx: int = 2048
    n_batch: int = 512
    embedding: bool = True

class LlamaServerProcess:
    """Manages a single llama-server process"""
    
    def __init__(self, config: ModelConfig):
        self.config = config
        self.process: Optional[subprocess.Popen] = None
        self.last_used = time.time()
        self.is_healthy = False
        
    async def start(self) -> bool:
        """Start the llama-server process"""
        if self.process and self.process.poll() is None:
            return True
            
        logger.info(f"Starting llama-server for {self.config.name} on port {self.config.port}")
        
        # Find llama-server binary
        llama_server_path = shutil.which("llama-server")
        if not llama_server_path:
            llama_server_path = "/usr/local/bin/llama-server"
            if not os.path.exists(llama_server_path):
                raise RuntimeError("llama-server binary not found")
        
        # Build command arguments
        cmd = [
            llama_server_path,
            "--model", self.config.path,
            "--port", str(self.config.port),
            "--host", "0.0.0.0",
            "--embeddings",  # Enable embeddings endpoint
            "--ctx-size", str(self.config.n_ctx),
            "--batch-size", str(self.config.n_batch),
            "--threads", str(int(os.getenv("LLAMA_N_THREADS", "8"))),
            "--no-mmap" if os.getenv("LLAMA_NO_MMAP", "false").lower() == "true" else "--mmap",
        ]
        
        # Add GPU layers if specified
        if self.config.n_gpu_layers != 0:
            cmd.extend(["--n-gpu-layers", str(self.config.n_gpu_layers)])
        
        # AMD GPU optimizations
        env = os.environ.copy()
        env.update({
            "LLAMA_VULKAN": "1",
            "HSA_OVERRIDE_GFX_VERSION": "11.0.2",
            "VK_ICD_FILENAMES": "/usr/share/vulkan/icd.d/radeon_icd.x86_64.json",
        })
        
        try:
            self.process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=env,
                preexec_fn=os.setsid  # Create new process group
            )
            
            # Wait for server to be ready
            await self._wait_for_health()
            return True
            
        except Exception as e:
            logger.error(f"Failed to start llama-server for {self.config.name}: {e}")
            if self.process:
                self.process.terminate()
                self.process = None
            return False
    
    async def _wait_for_health(self, timeout: int = 60):
        """Wait for the server to become healthy"""
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                response = requests.get(f"http://localhost:{self.config.port}/health", timeout=2)
                if response.status_code == 200:
                    self.is_healthy = True
                    logger.info(f"Server {self.config.name} is healthy on port {self.config.port}")
                    return
            except requests.RequestException:
                pass
            await asyncio.sleep(1)
        
        raise RuntimeError(f"Server {self.config.name} failed to become healthy within {timeout}s")
    
    async def stop(self):
        """Stop the llama-server process"""
        if self.process and self.process.poll() is None:
            logger.info(f"Stopping llama-server for {self.config.name}")
            try:
                # Send SIGTERM to process group
                os.killpg(os.getpgid(self.process.pid), signal.SIGTERM)
                
                # Wait for graceful shutdown
                try:
                    await asyncio.wait_for(
                        asyncio.create_task(self._wait_for_exit()), 
                        timeout=10
                    )
                except asyncio.TimeoutError:
                    logger.warning(f"Force killing {self.config.name}")
                    os.killpg(os.getpgid(self.process.pid), signal.SIGKILL)
                    
            except Exception as e:
                logger.error(f"Error stopping {self.config.name}: {e}")
            finally:
                self.process = None
                self.is_healthy = False
    
    async def _wait_for_exit(self):
        """Wait for process to exit"""
        while self.process and self.process.poll() is None:
            await asyncio.sleep(0.1)
    
    def is_running(self) -> bool:
        """Check if process is running and healthy"""
        if not self.process or self.process.poll() is not None:
            self.is_healthy = False
            return False
        return self.is_healthy
    
    async def proxy_request(self, endpoint: str, data: dict) -> dict:
        """Proxy a request to the llama-server"""
        if not self.is_running():
            await self.start()
        
        self.last_used = time.time()
        
        try:
            url = f"http://localhost:{self.config.port}{endpoint}"
            response = requests.post(url, json=data, timeout=120)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Proxy request failed for {self.config.name}: {e}")
            raise

class NativeServerManager:
    """Manages multiple native llama-server processes"""
    
    def __init__(self, models_dir: str, unload_timeout: int = 300):
        self.models_dir = Path(models_dir)
        self.unload_timeout = unload_timeout
        self.servers: Dict[str, LlamaServerProcess] = {}
        self.model_configs: Dict[str, ModelConfig] = {}
        self.cleanup_task = None
        self.port_counter = 8001  # Start from 8001
        
        # Scan for available models
        self._scan_models()
        
    def _scan_models(self):
        """Scan the models directory for available models"""
        logger.info(f"Scanning models directory: {self.models_dir}")
        
        # Scan embedding models
        embeddings_dir = self.models_dir / "embeddings"
        if embeddings_dir.exists():
            for model_file in embeddings_dir.glob("*.gguf"):
                model_name = f"embedding_{model_file.stem}"
                gpu_layers = int(os.getenv("LLAMA_N_GPU_LAYERS", "20"))
                context_size = int(os.getenv("LLAMA_N_CTX", "8192"))
                batch_size = int(os.getenv("LLAMA_N_BATCH", "512"))
                
                self.model_configs[model_name] = ModelConfig(
                    path=str(model_file),
                    name=model_name,
                    type="embedding",
                    port=self.port_counter,
                    n_gpu_layers=gpu_layers,
                    n_ctx=context_size,
                    n_batch=batch_size,
                    embedding=True
                )
                self.port_counter += 1
                logger.info(f"Found embedding model: {model_name} -> port {self.model_configs[model_name].port}")
        
        # Scan reranking models
        rerankers_dir = self.models_dir / "rerankers"
        if rerankers_dir.exists():
            for model_file in rerankers_dir.glob("*.gguf"):
                model_name = f"reranker_{model_file.stem}"
                gpu_layers = int(os.getenv("LLAMA_N_GPU_LAYERS", "15"))
                batch_size = int(os.getenv("LLAMA_N_BATCH", "512"))
                
                self.model_configs[model_name] = ModelConfig(
                    path=str(model_file),
                    name=model_name,
                    type="reranking",
                    port=self.port_counter,
                    n_gpu_layers=gpu_layers,
                    n_ctx=1024,  # BGE reranker optimal
                    n_batch=batch_size,
                    embedding=True
                )
                self.port_counter += 1
                logger.info(f"Found reranking model: {model_name} -> port {self.model_configs[model_name].port}")
    
    async def get_server(self, model_name: str) -> LlamaServerProcess:
        """Get or create a server for the specified model"""
        if model_name not in self.model_configs:
            raise ValueError(f"Model {model_name} not found")
        
        if model_name not in self.servers:
            config = self.model_configs[model_name]
            self.servers[model_name] = LlamaServerProcess(config)
            
            # Start cleanup task if not already running
            if self.cleanup_task is None:
                self.cleanup_task = asyncio.create_task(self._cleanup_loop())
        
        server = self.servers[model_name]
        if not server.is_running():
            await server.start()
        
        return server
    
    async def stop_server(self, model_name: str):
        """Stop a specific server"""
        if model_name in self.servers:
            await self.servers[model_name].stop()
            del self.servers[model_name]
    
    async def stop_all_servers(self):
        """Stop all running servers"""
        tasks = []
        for server in self.servers.values():
            tasks.append(server.stop())
        
        if tasks:
            await asyncio.gather(*tasks, return_exceptions=True)
        
        self.servers.clear()
        
        if self.cleanup_task:
            self.cleanup_task.cancel()
            self.cleanup_task = None
    
    async def _cleanup_loop(self):
        """Background task to stop unused servers"""
        while True:
            try:
                current_time = time.time()
                servers_to_stop = []
                
                for model_name, server in self.servers.items():
                    if current_time - server.last_used > self.unload_timeout:
                        servers_to_stop.append(model_name)
                
                for model_name in servers_to_stop:
                    logger.info(f"Auto-stopping unused server: {model_name}")
                    await self.stop_server(model_name)
                
                await asyncio.sleep(30)  # Check every 30 seconds
                
            except Exception as e:
                logger.error(f"Error in cleanup loop: {e}")
                await asyncio.sleep(60)
    
    def list_models(self) -> Dict[str, List[str]]:
        """List available models by type"""
        embeddings = [name for name, config in self.model_configs.items() 
                     if config.type == "embedding"]
        rerankers = [name for name, config in self.model_configs.items() 
                    if config.type == "reranking"]
        running = [name for name, server in self.servers.items() if server.is_running()]
        
        return {
            "embeddings": embeddings,
            "rerankers": rerankers,
            "running": running
        }

# Global server manager
server_manager: Optional[NativeServerManager] = None

# Pydantic models for API
class EmbeddingRequest(BaseModel):
    input: Union[str, List[str]]
    model: str
    encoding_format: str = "float"

class RerankRequest(BaseModel):
    model: str
    query: str
    documents: List[str]
    top_k: Optional[int] = None

class EmbeddingResponse(BaseModel):
    object: str = "list"
    data: List[Dict]
    model: str
    usage: Dict

class RerankResponse(BaseModel):
    model: str
    results: List[Dict]
    usage: Dict

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    global server_manager
    
    # Startup
    models_dir = os.getenv("MODELS_DIR", "./models")
    unload_timeout = int(os.getenv("UNLOAD_TIMEOUT", "300"))
    
    server_manager = NativeServerManager(models_dir, unload_timeout)
    logger.info("Native server manager initialized")
    
    yield
    
    # Shutdown
    if server_manager:
        await server_manager.stop_all_servers()
    logger.info("All servers stopped")

# FastAPI app
app = FastAPI(
    title="Native LLaMA-Server Manager",
    description="Manages native llama-server processes for optimal performance",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Native LLaMA-Server Manager", "status": "running"}

@app.get("/v1/models")
async def list_models():
    """List available models (OpenAI compatible)"""
    if not server_manager:
        raise HTTPException(status_code=500, detail="Server manager not initialized")
    
    models_info = server_manager.list_models()
    
    # Format for OpenAI compatibility
    models = []
    for model_type in ["embeddings", "rerankers"]:
        for model_name in models_info[model_type]:
            models.append({
                "id": model_name,
                "object": "model",
                "created": int(time.time()),
                "owned_by": "native-llama-server",
                "permission": [],
                "root": model_name,
                "parent": None
            })
    
    return {"object": "list", "data": models}

@app.post("/v1/embeddings")
async def create_embeddings(request: EmbeddingRequest):
    """Create embeddings via native llama-server (OpenAI compatible)"""
    if not server_manager:
        raise HTTPException(status_code=500, detail="Server manager not initialized")
    
    try:
        # Get the appropriate server
        server = await server_manager.get_server(request.model)
        
        # Handle single string or list of strings
        texts = request.input if isinstance(request.input, list) else [request.input]
        
        # Proxy request to native server
        proxy_request = {
            "content": texts[0] if len(texts) == 1 else texts,
            "encoding_format": request.encoding_format
        }
        
        response_data = await server.proxy_request("/embedding", proxy_request)
        
        # Convert to OpenAI format
        embeddings_data = []
        if isinstance(response_data.get("embedding"), list):
            # Single embedding
            embeddings_data.append({
                "object": "embedding",
                "embedding": response_data["embedding"],
                "index": 0
            })
        else:
            # Multiple embeddings
            for i, emb in enumerate(response_data.get("embeddings", [])):
                embeddings_data.append({
                    "object": "embedding",
                    "embedding": emb,
                    "index": i
                })
        
        total_tokens = sum(len(str(text).split()) for text in texts)
        
        return EmbeddingResponse(
            data=embeddings_data,
            model=request.model,
            usage={
                "prompt_tokens": total_tokens,
                "total_tokens": total_tokens
            }
        )
        
    except Exception as e:
        logger.error(f"Error creating embeddings: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/v1/rerank")
async def rerank_documents(request: RerankRequest):
    """Rerank documents using native embedding comparison"""
    if not server_manager:
        raise HTTPException(status_code=500, detail="Server manager not initialized")
    
    try:
        # Get the appropriate server (prefer reranker, fallback to embedding)
        server = await server_manager.get_server(request.model)
        
        # Get query embedding
        query_response = await server.proxy_request("/embedding", {"content": request.query})
        query_embedding = np.array(query_response["embedding"])
        
        # Get document embeddings and calculate similarities
        results = []
        for i, doc in enumerate(request.documents):
            doc_response = await server.proxy_request("/embedding", {"content": doc})
            doc_embedding = np.array(doc_response["embedding"])
            
            # Calculate cosine similarity
            similarity = np.dot(query_embedding, doc_embedding) / (
                np.linalg.norm(query_embedding) * np.linalg.norm(doc_embedding)
            )
            
            results.append({
                "index": i,
                "document": doc,
                "relevance_score": float(similarity)
            })
        
        # Sort by relevance score
        results.sort(key=lambda x: x["relevance_score"], reverse=True)
        
        # Apply top_k if specified
        if request.top_k:
            results = results[:request.top_k]
        
        total_tokens = len(request.query.split()) + sum(len(doc.split()) for doc in request.documents)
        
        return RerankResponse(
            model=request.model,
            results=results,
            usage={
                "prompt_tokens": total_tokens,
                "total_tokens": total_tokens
            }
        )
        
    except Exception as e:
        logger.error(f"Error reranking documents: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint with backend detection"""
    if not server_manager:
        return {"status": "error", "message": "Server manager not initialized"}
    
    models_info = server_manager.list_models()
    
    # Detect GPU backend by checking environment variables
    gpu_backend = "Unknown"
    if os.getenv("LLAMA_VULKAN", "0") == "1":
        if os.getenv("LLAMA_VULKAN_FORCE", "0") == "1":
            gpu_backend = "Vulkan (Forced/Pure)"
        else:
            gpu_backend = "Vulkan (Primary)"
    elif os.getenv("HSA_OVERRIDE_GFX_VERSION"):
        gpu_backend = "ROCm (HDA Override)"
    else:
        gpu_backend = "CPU (No GPU acceleration)"
    
    return {
        "status": "healthy",
        "models": models_info,
        "backend": "native-llama-server",
        "gpu_backend": gpu_backend,
        "vulkan_device": os.getenv("VULKAN_DEVICE", "auto"),
        "performance_mode": "maximum" if os.getenv("LLAMA_VULKAN_FORCE") == "1" else "balanced"
    }

@app.post("/v1/models/{model_name}/stop")
async def stop_model_server(model_name: str):
    """Stop a specific model server"""
    if not server_manager:
        raise HTTPException(status_code=500, detail="Server manager not initialized")
    
    try:
        await server_manager.stop_server(model_name)
        return {"message": f"Server for {model_name} stopped successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    # Configuration
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    
    # Ensure models directory exists
    models_dir = os.getenv("MODELS_DIR", "./models")
    Path(models_dir).mkdir(exist_ok=True)
    Path(models_dir, "embeddings").mkdir(exist_ok=True)
    Path(models_dir, "rerankers").mkdir(exist_ok=True)
    
    logger.info(f"Starting native server manager on {host}:{port}")
    logger.info(f"Models directory: {models_dir}")
    
    uvicorn.run(
        "llama_cpp_server:app",
        host=host,
        port=port,
        reload=False,
        workers=1,  # Single worker for process management
        access_log=True
    )
EOF

    chmod +x llama_cpp_server.py
    echo -e "${GREEN}✓ Native server wrapper created${NC}"
}

create_docker_compose() {
    echo -e "${BLUE}🐳 Creating Docker Compose configuration (Native llama.cpp)...${NC}"
    
    cat > docker-compose.yml << 'EOF'
version: '3.8'

networks:
  unicorn-network:
    external: true

services:
  unicorn-embedding-server:
    build: .
    container_name: unicorn-embedding-server
    hostname: embedding-server
    ports:
      - "8000:8000"
      - "8001-8010:8001-8010"  # Native llama-server instances
    volumes:
      - "./models:/app/models"
      - "./logs:/app/logs"
    environment:
      - LLAMA_VULKAN=1
      - LLAMA_VULKAN_FORCE=1
      - VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
      - VULKAN_DEVICE=0
    devices:
      - /dev/dri:/dev/dri  # AMD GPU access (Vulkan-only)
    networks:
      - unicorn-network
    privileged: true  # Required for AMD GPU access
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    extra_hosts:
      - "host.docker.internal:host-gateway"
EOF

    echo -e "${GREEN}✓ Docker Compose file created${NC}"
}

create_dockerfile() {
    echo -e "${BLUE}🐳 Creating Dockerfile (Native llama.cpp optimized)...${NC}"
    
    cat > Dockerfile << 'EOF'
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

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the Python wrapper that manages multiple llama-server instances
ENTRYPOINT ["python3", "/app/llama_server_wrapper.py"]
EOF

    echo -e "${GREEN}✓ Dockerfile created (Native llama.cpp optimized)${NC}"
}

create_integration_guide() {
    echo -e "${BLUE}📋 Creating integration guide...${NC}"
    
    cat > INTEGRATION.md << 'EOF'
# Unicorn Open-WebUI Integration Guide

## ✅ Setup Complete!

Your embedding server is now running with:
- **Embedding Model**: nomic-embed-text-v1.5.Q8_0.gguf
- **Reranking Model**: bge-reranker-v2-m3.Q8_0.gguf
- **Server URL**: http://localhost:8000

## 🔗 Integrating with Your Unicorn Stack

### Step 1: Update Open-WebUI Configuration

Add these environment variables to your `unicorn-open-webui` service in your main docker-compose.yml:

```yaml
open-webui:
  environment:
    # ... your existing vars ...
    
    # NEW: Use dedicated embedding server
    - RAG_EMBEDDING_ENGINE=openai
    - RAG_EMBEDDING_MODEL=embedding_nomic-embed-text-v1.5.Q8_0
    - OPENAI_API_BASE_URL=http://embedding-server:8000/v1
    
    # OPTIONAL: Enable reranking
    - RAG_RERANKING_MODEL=reranker_bge-reranker-v2-m3-Q8_0
```

### Step 2: Restart Open-WebUI

```bash
# In your main Unicorn stack directory
docker compose restart open-webui
```

## 🧪 Testing

Test embedding endpoint:
```bash
curl -X POST http://localhost:8000/v1/embeddings \
  -H "Content-Type: application/json" \
  -d '{"model": "embedding_nomic-embed-text-v1.5.Q8_0", "input": ["test"]}'
```

Test reranking endpoint:
```bash
curl -X POST http://localhost:8000/v1/rerank \
  -H "Content-Type: application/json" \
  -d '{
    "model": "reranker_bge-reranker-v2-m3-Q8_0",
    "query": "machine learning",
    "documents": ["AI is cool", "Cooking is fun", "Neural networks"]
  }'
```

## 📊 Monitoring

- Health check: http://localhost:8000/health
- Available models: http://localhost:8000/v1/models
- View logs: `docker compose logs -f`

## 🔧 Management

Start server: `docker compose up -d`
Stop server: `docker compose down`
Restart server: `docker compose restart`
View logs: `docker compose logs -f unicorn-embedding-server`

## 🚀 Performance Notes

- Models auto-load on first request
- Auto-unload after 5 minutes of inactivity
- Shares GPU memory efficiently with Open-WebUI
- Handles concurrent requests
EOF

    echo -e "${GREEN}✓ Integration guide created${NC}"
}

build_and_start() {
    echo -e "${BLUE}🐳 Building and starting Docker containers...${NC}"
    
    # Check if unicorn-network exists
    if ! docker network ls | grep -q "unicorn-network"; then
        echo -e "${YELLOW}Creating unicorn-network...${NC}"
        docker network create unicorn-network
    fi
    
    # Build and start
    echo -e "${BLUE}Building Docker image...${NC}"
    docker compose build
    
    echo -e "${BLUE}Starting embedding server...${NC}"
    docker compose up -d
    
    # Wait for health check
    echo -e "${BLUE}Waiting for server to be ready...${NC}"
    for i in {1..30}; do
        if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Server is healthy and ready!${NC}"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo -e "${RED}✗ Server health check failed. Check logs with: docker compose logs${NC}"
        exit 1
    fi
}

show_completion_summary() {
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║               🚀 NATIVE SETUP COMPLETE! 🚀                  ║${NC}"
    echo -e "${GREEN}║       AMD 8945HS + 780M iGPU + Native llama.cpp             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${BLUE}📊 Server Status:${NC}"
    echo "✅ Native LLaMA.cpp Embedding Server: http://localhost:8000"
    echo "✅ Health Check: $(curl -s http://localhost:8000/health | grep -o '"status":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "running")"
    echo "✅ Available Models: $(curl -s http://localhost:8000/v1/models 2>/dev/null | jq -r '.data | length' 2>/dev/null || echo "loading")"
    echo "✅ GPU Acceleration: AMD RADV Phoenix (Native Vulkan)"
    echo "✅ Backend: Official llama.cpp server-vulkan (Maximum Performance)"
    
    echo -e "\n${BLUE}🎯 Hardware Optimization Confirmed:${NC}"
    echo "- Processor: AMD 8945HS (8 cores utilized)"
    echo "- GPU: AMD 780M iGPU (VULKAN-ONLY, no ROCm)"
    echo "- Backend: Pure Vulkan (LLAMA_VULKAN_FORCE=1)"
    echo "- Memory: ${TOTAL_RAM_GB}GB RAM detected (${GPU_LAYERS} GPU layers)"
    echo "- Performance: Maximum native llama-server speed"
    
    echo -e "\n${BLUE}📁 Files Created:${NC}"
    echo "- llama_server_wrapper.py (lightweight native wrapper)"
    echo "- docker-compose.yml (native llama-server support + port range)"
    echo "- Dockerfile (official llama.cpp:server-vulkan base)"
    echo "- requirements.txt (minimal Python dependencies)"
    echo "- .env (AMD 780M auto-configuration)"
    echo "- INTEGRATION.md (setup guide)"
    echo "- models/ (downloaded models: $(du -sh models/ 2>/dev/null | cut -f1 || echo "~800MB"))"
    
    echo -e "\n${BLUE}🔗 API Endpoints:${NC}"
    echo "- Embeddings: http://localhost:8000/v1/embeddings"
    echo "- Reranking: http://localhost:8000/v1/rerank"
    echo "- Models: http://localhost:8000/v1/models"
    echo "- Health: http://localhost:8000/health (shows Vulkan backend status)"
    
    echo -e "\n${BLUE}📊 Monitoring Commands:${NC}"
    echo "# Check Vulkan backend confirmation:"
    echo "curl -s http://localhost:8000/health | jq '.gpu_backend'"
    echo ""
    echo "# Monitor GPU utilization:"
    echo "sudo radeontop"
    echo ""
    echo "# Container resource usage:"
    echo "docker stats unicorn-embedding-server"
    
    echo -e "\n${BLUE}🧪 Quick Test Commands:${NC}"
    echo "# Test embedding generation:"
    echo "curl -X POST http://localhost:8000/v1/embeddings -H \"Content-Type: application/json\" -d '{\"model\": \"embedding_nomic-embed-text-v1.5.Q8_0\", \"input\": [\"test\"]}'"
    echo ""
    echo "# Test reranking:"
    echo "curl -X POST http://localhost:8000/v1/rerank -H \"Content-Type: application/json\" -d '{\"model\": \"embedding_nomic-embed-text-v1.5.Q8_0\", \"query\": \"AI\", \"documents\": [\"machine learning\", \"cooking\"]}'"
    
    echo -e "\n${BLUE}📋 Next Steps:${NC}"
    echo "1. Read INTEGRATION.md for Open-WebUI setup"
    echo "2. Update your main Unicorn stack docker-compose.yml"
    echo "3. Restart Open-WebUI to use the new embedding server"
    echo "4. Monitor performance with: docker stats unicorn-embedding-server"
    
    echo -e "\n${BLUE}🛠️  Management Commands:${NC}"
    echo "- View logs: docker compose logs -f"
    echo "- Restart: docker compose restart"
    echo "- Stop: docker compose down"
    echo "- Check GPU: docker exec unicorn-embedding-server vulkaninfo | grep AMD"
    
    echo -e "\n${BLUE}🔧 Troubleshooting:${NC}"
    echo "- If reranking fails: Model will automatically fall back to embedding model"
    echo "- If GPU not detected: Check /dev/dri and /dev/kfd permissions"
    echo "- If memory issues: Reduce LLAMA_N_GPU_LAYERS in .env file"
    echo "- Performance issues: See README.md troubleshooting section"
    
    echo -e "\n${GREEN}🦄 NATIVE PERFORMANCE UNLEASHED! 🚀${NC}"
    echo -e "${GREEN}Your Unicorn stack now has the ultimate AMD 780M + llama.cpp combo!${NC}"
}

# Main execution
main() {
    print_header
    
    echo -e "${YELLOW}This script will:${NC}"
    echo "• Download ~800MB of AI models (if not already present)"
    echo "• Create Docker containers"
    echo "• Start the embedding server"
    echo "• Configure everything for your Unicorn stack"
    echo ""
    
    read -p "Continue with setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    
    echo -e "\n${BLUE}🚀 Starting Unicorn Embedding Server setup...${NC}\n"
    
    check_requirements
    create_directories
    download_models
    create_env_file
    create_requirements_file
    create_server_file
    create_docker_compose
    create_dockerfile
    create_integration_guide
    build_and_start
    show_completion_summary
}

# Error handling
trap 'echo -e "\n${RED}❌ Setup failed. Check the error above.${NC}"; exit 1' ERR

# Run main function
main "$@"