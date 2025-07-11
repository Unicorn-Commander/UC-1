# n8n Docker Extension

This document provides details on the n8n Docker setup within the Unicorn Commander UC-1 system.

## 1. Purpose

n8n is a powerful workflow automation tool that allows you to connect various applications and services to automate tasks, build custom integrations, and create complex data pipelines. It's an excellent tool for automating AI-driven workflows, data processing, and general productivity tasks.

## 2. Location

The Docker Compose setup for n8n is located at:
`/home/ucadmin/UC-1/UC-1_Extensions/n8n/`

## 3. Network Integration

n8n and its PostgreSQL database are configured to connect to the shared `unicorn-network`.

*   **Network Name:** `unicorn-network`
*   **Type:** External (shared with the core Docker stack)

This allows n8n to communicate seamlessly with other services on the `unicorn-network`, such as your `ollama` instance for AI automation, or `qdrant` for vector database operations.

## 4. Access

n8n is accessible via its exposed port:

*   **Port:** `5678`
*   **Access URLs:**
    *   `http://localhost:5678`
    *   `http://<your_host_ip>:5678`
    *   `http://host.docker.internal:5678` (from within other Docker containers)

*Initial Login Credentials:*
*   **Username:** `user`
*   **Password:** `password`
*   **IMPORTANT:** It is highly recommended to change these default credentials immediately after your first login for security reasons. You can modify them in the `docker-compose.yml` file or within the n8n UI after setup.

## 5. Startup and Management

To manage the n8n container, navigate to its directory and use `docker compose` commands:

```bash
cd /home/ucadmin/UC-1/UC-1_Extensions/n8n

# Start n8n and its PostgreSQL database in detached mode
docker compose up -d

# Stop n8n and its PostgreSQL database
docker compose down

# Restart n8n
docker compose restart n8n

# View logs for n8n
docker compose logs -f n8n

# View logs for n8n's PostgreSQL database
docker compose logs -f n8n_postgres
```

## 6. Key Configuration & Notes

*   **Database:** n8n uses a dedicated PostgreSQL database (`n8n_postgres`) for data persistence. This is a more robust solution than the default SQLite database.
*   **Data Persistence:** n8n's configuration and workflow data are persisted in the `./n8n_data` volume, and the PostgreSQL data in `./postgres_data` within the `n8n` directory on your host machine.
*   **Environment Variables:** Key configurations like database connection details, basic authentication credentials, and webhook URL are set via environment variables in the `docker-compose.yml`. Remember to update `N8N_BASIC_AUTH_USER` and `N8N_BASIC_AUTH_PASSWORD` for production use.
*   **Timezone:** The `GENERIC_TIMEZONE` and `TZ` environment variables are set to `America/New_York`. Adjust this to your local timezone as needed.
*   **Ollama Integration:** Within n8n workflows, you can use the HTTP Request node or specific AI nodes (if available) to interact with your `ollama` service at `http://ollama:11434` (or `http://unicorn-ollama:11434` if you prefer to use the service name directly from the core stack).
