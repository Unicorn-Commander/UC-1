#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting UC-1 Documentation Server${NC}"

# Directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if unicorn-network exists
if ! docker network inspect unicorn-network >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Creating unicorn-network (UC-1 Core services not running)${NC}"
    docker network create unicorn-network
fi

# Check which docker compose command is available
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "Error: Neither docker-compose nor docker compose is available"
    exit 1
fi

echo "📚 Building and starting documentation service..."
$DOCKER_COMPOSE up -d --build

# Wait a moment for the service to start
sleep 3

# Check if the service is running
if docker ps | grep -q unicorn-docs; then
    echo -e "${GREEN}✅ UC-1 Documentation is now running!${NC}"
    echo -e "${GREEN}🌐 Access documentation at: http://localhost:7911${NC}"
    echo -e "${GREEN}🐳 Container name: unicorn-docs${NC}"
    echo -e "${GREEN}🌐 Network: unicorn-network${NC}"
    echo ""
    echo "Management commands:"
    echo "  View logs: docker logs -f unicorn-docs"
    echo "  Stop docs: $DOCKER_COMPOSE down"
    echo "  Restart:   $DOCKER_COMPOSE restart"
else
    echo -e "${YELLOW}⚠️ Documentation container may not have started properly${NC}"
    echo "Check logs with: docker logs unicorn-docs"
fi