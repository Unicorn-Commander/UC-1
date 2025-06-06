#!/usr/bin/env python3
"""
Minimal reranking service that uses native llama-server embeddings
"""

import requests
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

app = FastAPI(title="Unicorn Reranking Service", version="1.0.0")

class RerankRequest(BaseModel):
    model: str
    query: str
    documents: List[str]
    top_k: Optional[int] = None

def get_embedding_from_native(text: str, server_url: str) -> List[float]:
    """Get embedding from native llama-server"""
    try:
        response = requests.post(
            f"{server_url}/v1/embeddings",
            json={"input": text, "model": "model"},
            timeout=30
        )
        response.raise_for_status()
        data = response.json()
        return data["data"][0]["embedding"]
    except Exception as e:
        print(f"Error getting embedding: {e}")
        return [0.0] * 768  # Return zero vector as fallback

@app.post("/v1/rerank")
async def rerank_documents(request: RerankRequest):
    """Rerank documents using cosine similarity"""
    try:
        # Get embeddings from native reranker server
        reranker_url = "http://localhost:8002"
        
        # Get query embedding
        query_embedding = np.array(get_embedding_from_native(request.query, reranker_url))
        
        # Get document embeddings and calculate similarities
        results = []
        for i, doc in enumerate(request.documents):
            doc_embedding = np.array(get_embedding_from_native(doc, reranker_url))
            
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
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "reranking"}

if __name__ == "__main__":
    uvicorn.run("rerank_service:app", host="0.0.0.0", port=8003, workers=1)