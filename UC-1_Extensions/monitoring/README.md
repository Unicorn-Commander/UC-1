# Prometheus and Grafana Docker Extension

This document provides details on the Prometheus and Grafana Docker setup within the Unicorn Commander UC-1 system.

## 1. Purpose

Prometheus is an open-source monitoring system with a flexible data model and a powerful query language (PromQL). Grafana is an open-source platform for monitoring and observability, allowing you to visualize your data through customizable dashboards. Together, they provide a robust solution for monitoring the health and performance of your Docker containers and host system.

## 2. Location

The Docker Compose setup for Prometheus and Grafana is located at:
`/home/ucadmin/UC-1/UC-1_Extensions/monitoring/`

## 3. Network Integration

Both Prometheus and Grafana are configured to connect to the shared `unicorn-network`.

*   **Network Name:** `unicorn-network`
*   **Type:** External (shared with the core Docker stack)

This allows Prometheus to discover and scrape metrics from other services running on the `unicorn-network`, and Grafana to connect to Prometheus as a data source.

## 4. Access

### Prometheus

Prometheus is accessible via its exposed port:

*   **Port:** `9090`
*   **Access URLs:**
    *   `http://localhost:9090`
    *   `http://<your_host_ip>:9090`
    *   `http://host.docker.internal:9090` (from within other Docker containers)

### Grafana

Grafana is accessible via its exposed port:

*   **Port:** `3000`
*   **Access URLs:**
    *   `http://localhost:3000`
    *   `http://<your_host_ip>:3000`
    *   `http://host.docker.internal:3000` (from within other Docker containers)

*Initial Login Credentials:*
*   **Username:** `admin`
*   **Password:** `admin`
*   **IMPORTANT:** Change these default credentials immediately after your first login for security reasons.

## 5. Startup and Management

To manage the Prometheus and Grafana containers, navigate to their directory and use `docker compose` commands:

```bash
cd /home/ucadmin/UC-1/UC-1_Extensions/monitoring

# Start Prometheus and Grafana in detached mode
docker compose up -d

# Stop Prometheus and Grafana
docker compose down

# Restart Prometheus and Grafana
docker compose restart

# View logs for Prometheus
docker compose logs -f prometheus

# View logs for Grafana
docker compose logs -f grafana
```

## 6. Key Configuration & Notes

*   **Prometheus Configuration:** The `prometheus.yml` file (located in `./prometheus/prometheus.yml` relative to the `docker-compose.yml`) defines what targets Prometheus scrapes. By default, it scrapes itself. You will need to add configurations to scrape other services (e.g., `cAdvisor` for container metrics, `node_exporter` for host metrics).
*   **Grafana Data Source:** After starting Grafana, you will need to add Prometheus as a data source. In the Grafana UI, go to `Configuration` -> `Data Sources` -> `Add data source` -> `Prometheus`. The URL for Prometheus will be `http://prometheus:9090` (since they are on the same `unicorn-network`).
*   **Dashboards:** You can import pre-built dashboards from Grafana Labs (e.g., for Docker, Node Exporter) or create your own to visualize your metrics.
*   **Data Persistence:** Prometheus and Grafana data are persisted using Docker volumes (`prometheus_data` and `grafana_data`).
