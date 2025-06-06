# Embedding API Reference

The UC-1 Embedding API provides OpenAI-compatible vector embeddings using the high-performance Unicorn Embed service.

## Base URL
```
http://localhost:8001
```

## Authentication
No authentication required for local deployment.

## Endpoints

### POST /v1/embeddings

Generate vector embeddings for text input.

#### Request Format
```json
{
  \"input\": \"Your text here\",
  \"model\": \"nomic-embed-text-v1.5\"
}
```

#### Parameters
- **`input`** (string or array): Text to embed
- **`model`** (string): Model identifier (use \"nomic\" or \"nomic-embed-text-v1.5\")
- **`encoding_format`** (optional): \"float\" (default) or \"base64\"

#### Response Format
```json
{
  \"object\": \"list\",
  \"data\": [
    {
      \"object\": \"embedding\",
      \"embedding\": [0.1, 0.2, -0.1, ...],
      \"index\": 0
    }
  ],
  \"model\": \"nomic-embed-text-v1.5\",
  \"usage\": {
    \"prompt_tokens\": 5,
    \"total_tokens\": 5
  }
}
```

## Examples

### cURL
```bash
curl -X POST http://localhost:8001/v1/embeddings \\
  -H \"Content-Type: application/json\" \\
  -d '{
    \"input\": \"UC-1 is a powerful AI platform\",
    \"model\": \"nomic-embed-text-v1.5\"
  }'
```

### Python
```python
import requests

response = requests.post(
    \"http://localhost:8001/v1/embeddings\",
    json={
        \"input\": \"UC-1 is a powerful AI platform\",
        \"model\": \"nomic-embed-text-v1.5\"
    }
)

embeddings = response.json()
vector = embeddings[\"data\"][0][\"embedding\"]
print(f\"Generated {len(vector)}-dimensional vector\")
```

### JavaScript
```javascript
const response = await fetch('http://localhost:8001/v1/embeddings', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    input: 'UC-1 is a powerful AI platform',
    model: 'nomic-embed-text-v1.5'
  })
});

const data = await response.json();
const vector = data.data[0].embedding;
console.log(`Generated ${vector.length}-dimensional vector`);
```

## Batch Processing
```json
{
  \"input\": [
    \"First document text\",
    \"Second document text\",
    \"Third document text\"
  ],
  \"model\": \"nomic-embed-text-v1.5\"
}
```

## Health Check

### GET /health
Check if the embedding service is running.

```bash
curl http://localhost:8001/health
```

Response:
```json
{\"status\": \"healthy\"}
```

## Performance Characteristics

- **Dimensions**: 768 (Nomic v1.5 model)
- **Max Input Length**: ~6000 tokens
- **Throughput**: ~500 tokens/second
- **Latency**: <500ms for typical inputs
- **GPU Memory**: ~6GB utilization

## Error Handling

### Common Errors
```json
{
  \"error\": {
    \"message\": \"Input too long\",
    \"type\": \"invalid_request_error\",
    \"code\": \"context_length_exceeded\"
  }
}
```

### Error Codes
- **400**: Invalid request format
- **413**: Input too long
- **500**: Internal server error
- **503**: Service unavailable

## Integration Examples

### With Open WebUI
Open WebUI automatically uses this endpoint when configured:
- **Provider**: OpenAI
- **Base URL**: `http://localhost:8001`
- **Model**: `nomic-embed-text-v1.5`

### With Qdrant
```python
import qdrant_client
from qdrant_client.models import VectorParams, Distance

# Create collection
client = qdrant_client.QdrantClient(\"http://localhost:6333\")
client.create_collection(
    collection_name=\"documents\",
    vectors_config=VectorParams(size=768, distance=Distance.COSINE)
)

# Store embeddings
embedding_response = requests.post(
    \"http://localhost:8001/v1/embeddings\",
    json={\"input\": \"Document text\", \"model\": \"nomic-embed-text-v1.5\"}
)
vector = embedding_response.json()[\"data\"][0][\"embedding\"]

client.upsert(
    collection_name=\"documents\",
    points=[{
        \"id\": 1,
        \"vector\": vector,
        \"payload\": {\"text\": \"Document text\"}
    }]
)
```

## Rate Limits
No rate limits for local deployment. Performance depends on hardware capabilities.

## Model Information

### Nomic Embed Text v1.5
- **Architecture**: Transformer-based
- **Training Data**: Large-scale text corpus
- **Quantization**: Q8_0 (8-bit quantized)
- **Context Window**: 6000 tokens
- **Performance**: Optimized for AMD Vulkan acceleration