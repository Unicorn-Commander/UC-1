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
            # Try common locations for llama.cpp server
            possible_paths = [
                "/app/llama-server",
                "/usr/local/bin/llama-server", 
                "/usr/bin/llama-server"
            ]
            for path in possible_paths:
                if os.path.exists(path):
                    llama_server_path = path
                    break
            else:
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
        
        # AMD GPU optimizations (Vulkan-only)
        env = os.environ.copy()
        env.update({
            "LLAMA_VULKAN": "1",
            "LLAMA_VULKAN_FORCE": "1",
            "VK_ICD_FILENAMES": "/usr/share/vulkan/icd.d/radeon_icd.x86_64.json",
            "VULKAN_DEVICE": "0",
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
    
    async def _wait_for_health(self, timeout: int = 180):
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
        
        # The native server returns {"embedding": [float, float, ...]} for single embedding
        if "embedding" in response_data and isinstance(response_data["embedding"], list):
            # Single embedding response
            embeddings_data.append({
                "object": "embedding",
                "embedding": response_data["embedding"],
                "index": 0
            })
        elif "embeddings" in response_data:
            # Multiple embeddings response (if batch processing)
            for i, emb in enumerate(response_data["embeddings"]):
                embeddings_data.append({
                    "object": "embedding",
                    "embedding": emb,
                    "index": i
                })
        else:
            # Fallback - invalid response format
            raise ValueError(f"Invalid embedding response format: {response_data}")
        
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
        "llama_server_wrapper:app",
        host=host,
        port=port,
        reload=False,
        workers=1,  # Single worker for process management
        access_log=True
    )
