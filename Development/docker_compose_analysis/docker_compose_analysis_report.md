# Docker Compose Stack Analysis Report

This report analyzes the `docker-compose.yml` file for the UC-1_Core stack, providing observations, recommendations for optimization, and potential improvements.

## General Observations & Best Practices

### Image Tagging

**Observation:** Several services use the `:latest` tag (e.g., `qdrant:latest`, `searxng/searxng:latest`). While convenient for development, this can lead to unexpected breaking changes in production environments when new images are pulled.

**Recommendation:** Pin specific image versions (e.g., `redis:7.2.4-alpine`, `postgres:16.3-alpine`, `qdrant/qdrant:1.9.0`, `searxng/searxng:1.2.0`). This ensures consistent deployments and makes it easier to track and manage updates.

### Resource Limits

**Observation:** No CPU or memory limits are defined for any of the services.

**Recommendation:** Implement resource limits (`deploy.resources.limits` and `deploy.resources.reservations`) for each service, especially in a production environment. This prevents a single service from consuming all available resources and impacting other services or the host system. For example:

```yaml
  redis:
    # ... existing configuration ...
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 1g
        reservations:
          cpus: '0.25'
          memory: 512m
```

### Environment Variables and Secrets

**Observation:** Environment variables are loaded from the host environment (e.g., `${POSTGRES_USER}`, `${WEBUI_SECRET_KEY}`). While this works, for sensitive information, Docker Secrets or a dedicated `.env` file (explicitly loaded via `env_file`) are generally more secure and manageable.

**Recommendation:** Consider using Docker Secrets for sensitive variables like `WEBUI_SECRET_KEY`, `POSTGRES_PASSWORD`, and `SEARXNG_SECRET`. For non-sensitive but configurable variables, explicitly define an `env_file` in your `docker-compose.yml`.

### Health Checks

**Observation:** Only `unicorn-searxng` has a health check defined.

**Recommendation:** Implement health checks for all critical services (e.g., `redis`, `postgresql`, `qdrant`, `ollama`, `open-webui`). Health checks allow Docker Compose to understand the true state of a service (whether it's ready to accept connections) and can be used by `depends_on` with `condition: service_healthy` for more robust startup sequences.

### Logging

**Observation:** Default logging drivers are used.

**Recommendation:** For production deployments, consider configuring logging drivers (e.g., `json-file` with `max-size` and `max-file` or a centralized logging solution) to manage log volume and facilitate debugging.

## Service-Specific Analysis

### redis

**Image:** `redis:7-alpine` - Good, uses a specific major version and a lightweight base image.

**Memory Policy:** `--maxmemory 4gb --maxmemory-policy allkeys-lru` - This is a good optimization for Redis, preventing it from consuming excessive memory and ensuring older keys are evicted when memory limits are reached.

**Client Output Buffer Limit:** `pubsub 256mb 128mb 180` - This is a specific tuning for pub/sub clients. Ensure these values are appropriate for your expected pub/sub traffic.

**Recommendation:** Consider adding a health check for Redis.

### postgresql

**Image:** `postgres:16-alpine` - Good, uses a specific major version and a lightweight base image.

**Environment Variables:** Uses `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`. As mentioned, consider Docker Secrets for the password.

**Recommendation:** Add a health check for PostgreSQL.

### qdrant

**Image:** `qdrant/qdrant:latest` - **Recommendation:** Pin a specific version (e.g., `qdrant/qdrant:1.9.0`).

**Recommendation:** Add a health check for Qdrant.

### ollama

**Image:** `ollama/ollama:rocm` - Good, uses a specific tag for ROCm support.

**Devices:** `/dev/kfd:/dev/kfd` and `/dev/dri:/dev/dri` - Essential for GPU passthrough with ROCm.

**Environment Variables:** `HSA_OVERRIDE_GFX_VERSION` is set, which is often necessary for ROCm compatibility. `OLLAMA_MAX_LOADED_MODELS` is a good optimization.

**Recommendation:** Add a health check for Ollama. This might involve a simple `curl` to its API endpoint.

### open-webui

**Image:** `ghcr.io/open-webui/open-webui:main` - **Recommendation:** Pin a specific version or a more stable tag than `main` if available, as `main` can be volatile.

**Dependencies:** `depends_on` is correctly used for `postgresql`, `redis`, and `qdrant`. However, for more robust startup, consider using `condition: service_healthy` in conjunction with health checks on the dependent services.

**Environment Variables:** Many environment variables are configured, linking to other services. This is well-structured.

**Recommendation:** Add a health check for Open WebUI.

### unicorn-tika

**Build Context:** `build: ./tika-ocr` - This indicates a custom Dockerfile. Ensure the Dockerfile is optimized and secure.

**Environment Variables:** `TESSDATA_PREFIX` is set, which is important for Tesseract OCR.

**Volumes:** `tika_data:/data` - Ensures persistent storage for Tika data.

**Recommendation:** Review the `tika-ocr/Dockerfile` for best practices (e.g., multi-stage builds, minimizing image size, security scanning).

### unicorn-kokoro

**Image:** `ghcr.io/remsky/kokoro-fastapi-cpu` - Good, uses a specific image.

**Devices:** `/dev/kfd:/dev/kfd` and `/dev/dri:/dev/dri` - Indicates potential GPU usage, even though the image name suggests CPU. If GPU is intended, ensure the image supports it and the devices are correctly passed.

**Environment Variables:** `HSA_OVERRIDE_GFX_VERSION` is set.

**Recommendation:** Clarify if this service is intended to use GPU or CPU. If CPU, the `devices` mapping might be unnecessary. Add a health check.

### unicorn-searxng

**Image:** `searxng/searxng:latest` - **Recommendation:** Pin a specific version (e.g., `searxng/searxng:1.2.0`).

**Volumes:** `./searxng:/etc/searxng:rw` - Mounts the local `searxng` directory, allowing for custom configurations.

**Environment Variables:** Many specific configurations for SearXNG are set via environment variables. `SEARXNG_SECRET` should be handled securely.

**Capabilities:** `cap_drop: ALL` and `cap_add: CHOWN, SETGID, SETUID` - This is a good security practice, dropping unnecessary capabilities and only adding those required.

**Health Check:** A health check is already defined, which is excellent.

**Redis URL:** `SEARXNG_REDIS_URL=redis://unicorn-redis:6379/0` - Explicitly setting the correct Redis URL format is good.

## Overall Recommendations Summary

1.  **Pin Image Versions:** Replace `:latest` tags with specific versions for all services to ensure stability and reproducibility.
2.  **Implement Resource Limits:** Define CPU and memory limits for all services to prevent resource exhaustion.
3.  **Enhance Security for Secrets:** Use Docker Secrets for sensitive environment variables.
4.  **Add Comprehensive Health Checks:** Implement health checks for all critical services to ensure robust startup and monitoring.
5.  **Review Custom Dockerfiles:** Optimize `tika-ocr/Dockerfile` for size and security.
6.  **Refine `depends_on`:** Utilize `condition: service_healthy` with `depends_on` for more reliable service startup.
7.  **Logging Configuration:** Consider configuring logging drivers for better log management.

By implementing these recommendations, the Docker Compose stack can be made more robust, secure, and performant for production deployments.