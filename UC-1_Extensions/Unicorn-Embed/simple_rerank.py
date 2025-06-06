#!/usr/bin/env python3
"""
Simple reranking service using the native embedding server
"""

import requests
import numpy as np
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

app = FastAPI(title="Simple Reranking Service")

class RerankRequest(BaseModel):
    model: str
    query: str
    documents: List[str]
    top_n: Optional[int] = None

def get_embedding(text: str) -> List[float]:
    """Get embedding from the native embedding server"""
    try:
        response = requests.post(
            "http://localhost:8001/v1/embeddings",
            json={"input": text, "model": "nomic"},
            timeout=30
        )
        response.raise_for_status()
        data = response.json()
        return data["data"][0]["embedding"]
    except Exception as e:
        print(f"Embedding error: {e}")
        return [0.0] * 768

@app.post("/v1/rerank")
async def rerank(request: RerankRequest):
    """Rerank documents using cosine similarity"""
    # Get query embedding
    query_emb = np.array(get_embedding(request.query))
    
    # Get document embeddings and calculate similarities
    results = []
    for i, doc in enumerate(request.documents):
        doc_emb = np.array(get_embedding(doc))
        
        # Cosine similarity
        similarity = np.dot(query_emb, doc_emb) / (np.linalg.norm(query_emb) * np.linalg.norm(doc_emb))
        
        results.append({
            "index": i,
            "document": doc,
            "relevance_score": float(similarity)
        })
    
    # Sort by relevance
    results.sort(key=lambda x: x["relevance_score"], reverse=True)
    
    # Apply top_n if specified
    if request.top_n:
        results = results[:request.top_n]
    
    return {
        "model": request.model,
        "results": results
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run("simple_rerank:app", host="0.0.0.0", port=8002, reload=False)