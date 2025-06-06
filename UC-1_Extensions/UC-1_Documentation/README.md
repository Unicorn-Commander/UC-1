# UC-1 Documentation Service

Self-hosted documentation site for the UC-1 platform using MkDocs with Material theme.

## Quick Start

```bash
# Start the documentation service
./start-docs.sh

# Access at http://localhost:7911
```

## Features

- **Beautiful Interface**: Material Design theme with dark/light mode
- **Comprehensive Content**: Complete UC-1 documentation
- **Self-Hosted**: Runs locally on your UC-1 system
- **Searchable**: Full-text search across all documentation
- **Live Reload**: Updates automatically during development
- **Responsive**: Works on desktop, tablet, and mobile

## Service Details

- **Container Name**: `unicorn-docs`
- **Port**: 7911
- **Network**: `unicorn-network` (connects to other UC-1 services)
- **Technology**: MkDocs with Material theme

## Management Commands

```bash
# Start documentation
./start-docs.sh

# Stop documentation
docker-compose down

# Restart documentation
docker-compose restart

# View logs
docker logs -f unicorn-docs

# Rebuild and restart
docker-compose up -d --build

# Check status
docker ps --filter "name=unicorn-docs"
```

## Access Methods

- **Localhost**: http://localhost:7911
- **Container Network**: http://unicorn-docs:8000 (from other containers)
- **Host IP**: http://[your-ip]:7911 (from network devices)

## Development

### Editing Documentation
1. Edit files in the `docs/` directory
2. Changes are automatically reflected (live reload)
3. No restart needed for content changes

### Adding New Pages
1. Create new `.md` files in `docs/`
2. Update `mkdocs.yml` navigation if needed
3. Use Material theme features and extensions

### Custom Styling
- Modify `mkdocs.yml` for theme configuration
- Add custom CSS in `docs/assets/` if needed
- Use Material theme color schemes and features

## Troubleshooting

### Documentation Won't Start
```bash
# Check if port 7911 is in use
sudo netstat -tlnp | grep :7911

# Check Docker network
docker network inspect unicorn-network

# Rebuild container
docker-compose up -d --build
```

### Can't Access Documentation
```bash
# Check container status
docker ps --filter "name=unicorn-docs"

# Check logs for errors
docker logs unicorn-docs

# Verify network connectivity
curl http://localhost:7911
```

### Updates Not Showing
```bash
# Hard refresh browser (Ctrl+Shift+R)
# Or restart container
docker-compose restart
```

## Integration with UC-1

The documentation service integrates seamlessly with the UC-1 ecosystem:
- **Shared Network**: Connects to `unicorn-network` for service discovery
- **Consistent Ports**: Follows UC-1 port conventions
- **Health Checks**: Monitored like other UC-1 services
- **Docker Management**: Uses same patterns as other services

## File Structure

```
UC-1_Documentation/
├── docker-compose.yml          # Standalone service definition
├── Dockerfile                  # Documentation container build
├── mkdocs.yml                  # MkDocs configuration
├── requirements.txt            # Python dependencies
├── start-docs.sh              # Startup script
├── README.md                  # This file
└── docs/                      # Documentation content
    ├── index.md               # Homepage
    ├── about/                 # About UC-1 and Magic Unicorn
    ├── installation/          # Installation guides
    ├── components/            # Component documentation
    ├── guides/                # User guides and tutorials
    ├── api/                   # API reference
    ├── config/                # Configuration guides
    ├── development/           # Development docs
    └── support/               # Support and troubleshooting
```

## Contributing

To contribute to the documentation:
1. Edit the relevant `.md` files
2. Test locally with `./start-docs.sh`
3. Submit pull requests for improvements
4. Follow the existing structure and style

---

**Part of the UC-1 ecosystem by Magic Unicorn Unconventional Technology & Stuff Inc.** 🦄