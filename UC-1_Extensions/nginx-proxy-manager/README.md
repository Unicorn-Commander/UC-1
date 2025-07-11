# Nginx Proxy Manager Docker Extension

This document provides details on the Nginx Proxy Manager (NPM) Docker setup within the Unicorn Commander UC-1 system.

## 1. Purpose

Nginx Proxy Manager provides an easy-to-use web interface for managing Nginx proxy hosts with a focus on simplicity and security. It allows you to easily expose your web-based Docker services (like Open WebUI, ComfyUI, bolt.diy, etc.) to the internet with custom domains and free SSL certificates from Let's Encrypt.

## 2. Location

The Docker Compose setup for Nginx Proxy Manager is located at:
`/home/ucadmin/UC-1/UC-1_Extensions/nginx-proxy-manager/`

## 3. Network Integration

Nginx Proxy Manager is configured to connect to the shared `unicorn-network`.

*   **Network Name:** `unicorn-network`
*   **Type:** External (shared with the core Docker stack)

This is crucial as it allows NPM to route traffic to any service running on the `unicorn-network`.

## 4. Access

Nginx Proxy Manager exposes the following ports on your host machine:

*   **`80` (HTTP):** For incoming HTTP traffic and ACME (Let's Encrypt) challenges.
*   **`443` (HTTPS):** For incoming HTTPS traffic.
*   **`81` (NPM Admin UI):** For accessing the Nginx Proxy Manager web interface.

*   **Access URLs for Admin UI:**
    *   `http://localhost:81`
    *   `http://<your_host_ip>:81`
    *   `http://host.docker.internal:81` (from within other Docker containers)

    *Initial Login Credentials:*
    *   **Email:** `admin@example.com`
    *   **Password:** `changeme`
    *   **IMPORTANT:** Change these credentials immediately after your first login.

## 5. Startup and Management

To manage the Nginx Proxy Manager container, navigate to its directory and use `docker compose` commands:

```bash
cd /home/ucadmin/UC-1/UC-1_Extensions/nginx-proxy-manager

# Start Nginx Proxy Manager in detached mode
docker compose up -d

# Stop Nginx Proxy Manager
docker compose down

# Restart Nginx Proxy Manager
docker compose restart

# View logs
docker compose logs -f
```

## 6. Key Configuration & Notes

*   **Data Persistence:** NPM data (configurations, SSL certificates) is persisted via bind mounts:
    *   `./data:/data`
    *   `./letsencrypt:/etc/letsencrypt`
    These directories will be created in the `nginx-proxy-manager` folder on your host machine.
*   **Reverse Proxy Setup:** After starting NPM, access its admin UI (e.g., `http://localhost:81`). You can then create new proxy hosts, specifying the domain name and the internal Docker service name (e.g., `unicorn-open-webui`) and its port (e.g., `8080`).
*   **SSL Certificates:** NPM simplifies obtaining and renewing Let's Encrypt SSL certificates for your domains.
