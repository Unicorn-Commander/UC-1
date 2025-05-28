#!/usr/bin/env python3
"""
Simple llama-server wrapper for AMD 8945HS + 780M iGPU
Optimized for Vulkan acceleration
"""

import os
import time
import subprocess
import requests
import json
import asyncio
import logging
from pathlib import Path
from typing import Dict, List, Optional, Union

import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import numpy as np

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global server process
embedding_server = None
reranker_server = None

class EmbeddingRequest(BaseModel):
    input: Union[str, List[str]]
    model: str
    encoding_format: str = "float"

class RerankRequest(BaseModel):
    model: str
    query: str
    documents: List[str]
    top_k: Optional[int] = None

def start_llama_server(model_path: str, port: int, model_type: str = "embedding"):
    """Start a llama-server process for the given model"""
    logger.info(f"Starting llama-server for {model_type} on port {port}")
    
    # Conservative settings for 780M iGPU
    cmd = [
        "/app/llama-server",
        "--model", model_path,
        "--port", str(port),
        "--host", "0.0.0.0",  # Bind to all interfaces for external access
        "--embeddings",
        "--ctx-size", "2048" if model_type == "embedding" else "1024",
        "--batch-size", "256",
        "--threads", "4",
        "--n-gpu-layers", "20" if model_type == "embedding" else "15"
    ]
    
    # Set Vulkan environment
    env = os.environ.copy()
    env.update({
        "LLAMA_VULKAN": "1",
        "LLAMA_VULKAN_FORCE": "1",
        "VK_ICD_FILENAMES": "/usr/share/vulkan/icd.d/radeon_icd.x86_64.json",
        "VULKAN_DEVICE": "0",
    })
    
    try:
        process = subprocess.Popen(cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Wait for server to be ready (longer timeout for model loading)
        for i in range(120):  # 120 second timeout
            # Check if process is still alive
            if process.poll() is not None:
                logger.error(f"Server process for {model_type} died unexpectedly")
                return None
                
            try:
                response = requests.get(f"http://localhost:{port}/health", timeout=5)
                if response.status_code == 200:
                    logger.info(f"Server for {model_type} is ready on port {port}")
                    return process
            except requests.RequestException as e:
                if i % 10 == 0:  # Log every 10 seconds
                    logger.info(f"Waiting for {model_type} server (attempt {i+1}/120): {e}")
                pass
            time.sleep(1)
        
        logger.error(f"Server for {model_type} failed to start within timeout")
        process.terminate()
        return None
        
    except Exception as e:
        logger.error(f"Failed to start server for {model_type}: {e}")
        return None

def get_embedding(text: str, port: int) -> List[float]:
    """Get embedding from llama-server"""
    try:
        response = requests.post(
            f"http://localhost:{port}/embedding",
            json={"content": text},
            timeout=30
        )
        response.raise_for_status()
        data = response.json()
        
        # Handle response format: [{"embedding": [float, ...], "index": 0}]
        if isinstance(data, list) and len(data) > 0 and "embedding" in data[0]:
            embedding = data[0]["embedding"]
            
            # Handle nested array case from native server
            if isinstance(embedding, list) and len(embedding) > 0 and isinstance(embedding[0], list):
                return embedding[0]
            elif isinstance(embedding, list) and len(embedding) > 0:
                return embedding
        
        logger.error(f"Unexpected response format from llama-server: {data}")
        return []
    except Exception as e:
        logger.error(f"Error getting embedding: {e}")
        return []

app = FastAPI(title="Unicorn Embedding Server", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    """Start the llama-server processes"""
    global embedding_server, reranker_server
    
    models_dir = Path("/app/models")
    
    # Start embedding server
    embedding_model = models_dir / "embeddings" / "nomic-embed-text-v1.5.Q8_0.gguf"
    if embedding_model.exists():
        embedding_server = start_llama_server(str(embedding_model), 9991, "embedding")
    
    # Start reranker server  
    reranker_model = models_dir / "rerankers" / "bge-reranker-v2-m3-Q8_0.gguf"
    if reranker_model.exists():
        reranker_server = start_llama_server(str(reranker_model), 9992, "reranker")

@app.on_event("shutdown")
async def shutdown():
    """Stop the llama-server processes"""
    global embedding_server, reranker_server
    
    if embedding_server:
        embedding_server.terminate()
    if reranker_server:
        reranker_server.terminate()

@app.get("/")
async def root():
    return {"message": "Unicorn Embedding Server", "status": "running"}

@app.get("/health")
async def health():
    """Health check endpoint"""
    models = {
        "embedding": "healthy" if embedding_server and embedding_server.poll() is None else "stopped",
        "reranker": "healthy" if reranker_server and reranker_server.poll() is None else "stopped"
    }
    
    return {
        "status": "healthy",
        "models": models,
        "backend": "source-built-llama-cpp",
        "gpu_backend": "Vulkan (Pure/Forced)",
        "hardware": "AMD 8945HS + 780M iGPU"
    }

@app.get("/v1/models")
async def list_models():
    """List available models (OpenAI compatible)"""
    models = []
    
    if embedding_server and embedding_server.poll() is None:
        models.append({
            "id": "nomic-embed-text-v1.5",
            "object": "model",
            "created": int(time.time()),
            "owned_by": "unicorn-embed",
            "permission": [],
            "root": "nomic-embed-text-v1.5",
            "parent": None
        })
    
    if reranker_server and reranker_server.poll() is None:
        models.append({
            "id": "bge-reranker-v2-m3",
            "object": "model", 
            "created": int(time.time()),
            "owned_by": "unicorn-embed",
            "permission": [],
            "root": "bge-reranker-v2-m3",
            "parent": None
        })
    
    return {
        "object": "list",
        "data": models
    }

@app.post("/v1/embeddings")
async def create_embeddings(request: EmbeddingRequest):
    """Create embeddings (OpenAI compatible)"""
    logger.info(f"Received embedding request with {len(request.input) if isinstance(request.input, list) else 1} texts")
    
    if not embedding_server or embedding_server.poll() is not None:
        raise HTTPException(status_code=503, detail="Embedding server not available")
    
    try:
        texts = request.input if isinstance(request.input, list) else [request.input]
        
        embeddings_data = []
        for i, text in enumerate(texts):
            embedding = get_embedding(text, 9991)
            if not embedding:  # Check if embedding is empty
                # Return zero vector instead of failing completely
                logger.warning(f"Failed to generate embedding for text, returning zeros: {text[:50]}...")
                embedding = [0.0] * 768  # Nomic v1.5 has 768 dimensions
            embeddings_data.append({
                "object": "embedding",
                "embedding": embedding,
                "index": i
            })
        
        response = {
            "object": "list",
            "data": embeddings_data,
            "model": request.model,
            "usage": {
                "prompt_tokens": sum(len(text.split()) for text in texts),
                "total_tokens": sum(len(text.split()) for text in texts)
            }
        }
        
        logger.info(f"Returning {len(embeddings_data)} embeddings")
        return response
        
    except Exception as e:
        logger.error(f"Error creating embeddings: {e}")
        # Return empty response instead of raising exception
        return {
            "object": "list",
            "data": [],
            "model": request.model,
            "usage": {"prompt_tokens": 0, "total_tokens": 0}
        }

# Alternative endpoint that returns just embeddings as list (for compatibility)
@app.post("/embeddings") 
async def simple_embeddings(request: dict):
    """Simple embeddings endpoint that returns list of vectors"""
    texts = request.get("input", [])
    if isinstance(texts, str):
        texts = [texts]
    
    logger.info(f"Simple embeddings request for {len(texts)} texts")
    
    result = []
    for text in texts:
        embedding = get_embedding(text, 9991)
        if not embedding:
            logger.warning(f"Failed embedding, using zeros: {text[:50]}...")
            embedding = [0.0] * 768
        result.append(embedding)
    
    logger.info(f"Returning {len(result)} embeddings as list")
    return result

@app.post("/v1/rerank")
async def rerank_documents(request: RerankRequest):
    """Rerank documents using similarity"""
    if not reranker_server or reranker_server.poll() is not None:
        raise HTTPException(status_code=503, detail="Reranker server not available")
    
    try:
        # Get query embedding
        query_embedding = np.array(get_embedding(request.query, 9992))
        
        # Get document embeddings and calculate similarities
        results = []
        for i, doc in enumerate(request.documents):
            doc_embedding = np.array(get_embedding(doc, 9992))
            
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
        
        return {
            "model": request.model,
            "results": results,
            "usage": {
                "prompt_tokens": len(request.query.split()) + sum(len(doc.split()) for doc in request.documents),
                "total_tokens": len(request.query.split()) + sum(len(doc.split()) for doc in request.documents)
            }
        }
        
    except Exception as e:
        logger.error(f"Error reranking documents: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(
        "llama_server_wrapper:app",
        host="0.0.0.0",
        port=8000,
        workers=1,
        access_log=True
    )