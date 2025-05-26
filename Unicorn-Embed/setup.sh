#!/bin/bash

set -e

echo "🦄 Unicorn Embed Setup"
echo "======================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
EMBEDDING_MODEL_URL="https://huggingface.co/magicunicorn/nomic-embed-text-v1.5-Q8_0-GGUF/resolve/main/nomic-embed-text-v1.5-q8_0.gguf?download=true"
RERANKING_MODEL_URL="https://huggingface.co/magicunicorn/bge-reranker-base-Q8_0-GGUF/resolve/main/bge-reranker-base-q8_0.gguf"

EMBEDDING_MODEL_FILE="models/nomic-embed-text-v1.5-q8_0.gguf"
RERANKING_MODEL_FILE="models/bge-reranker-base-q8_0.gguf"

# Create models directory
echo -e "${YELLOW}📁 Creating models directory...${NC}"
mkdir -p models

# Download embedding model if it doesn't exist
if [ \! -f "$EMBEDDING_MODEL_FILE" ]; then
    echo -e "${YELLOW}📥 Downloading embedding model...${NC}"
    wget -O "$EMBEDDING_MODEL_FILE" "$EMBEDDING_MODEL_URL"
    echo -e "${GREEN}✅ Embedding model downloaded${NC}"
else
    echo -e "${GREEN}✅ Embedding model already exists${NC}"
fi

# Download reranking model if it doesn't exist
if [ \! -f "$RERANKING_MODEL_FILE" ]; then
    echo -e "${YELLOW}📥 Downloading reranking model...${NC}"
    wget -O "$RERANKING_MODEL_FILE" "$RERANKING_MODEL_URL"
    echo -e "${GREEN}✅ Reranking model downloaded${NC}"
else
    echo -e "${GREEN}✅ Reranking model already exists${NC}"
fi

# Build and start services
echo -e "${YELLOW}🐳 Building and starting Docker services...${NC}"
docker compose down 2>/dev/null || true
docker compose up --build -d

# Wait for services to be ready
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 15

# Test services
echo -e "${YELLOW}🧪 Testing services...${NC}"

# Test embedding service
if curl -s -X POST "http://localhost:9991/v1/embeddings" \
   -H "Content-Type: application/json" \
   -d '{"input": "test", "model": "text-embedding"}' > /dev/null; then
    echo -e "${GREEN}✅ Embedding service is working${NC}"
else
    echo -e "${RED}❌ Embedding service failed${NC}"
fi

# Test reranking service  
if curl -s -X POST "http://localhost:9992/v1/rerank" \
   -H "Content-Type: application/json" \
   -d '{"query": "test", "documents": ["doc1", "doc2"], "model": "reranker"}' > /dev/null; then
    echo -e "${GREEN}✅ Reranking service is working${NC}"
else
    echo -e "${RED}❌ Reranking service failed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Setup complete\!${NC}"
echo ""
echo "Services available at:"
echo "  • Embedding: http://localhost:9991/v1/embeddings"
echo "  • Reranking: http://localhost:9992/v1/rerank"
echo ""
echo "To stop services: docker compose down"
echo "To view logs: docker compose logs -f"
EOFSCRIPT < /dev/null
