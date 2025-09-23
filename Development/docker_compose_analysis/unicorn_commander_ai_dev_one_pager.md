# Unicorn Commander AI Development Platform: One-Pager for Developers

## System Overview

This platform is a mini PC running **Ubuntu 25.04 (Plucky Puffin)** with a **KDE6 desktop environment**, specifically optimized for **local AI development and deployment**. It integrates a suite of best-of-breed open-source AI tools, aiming for seamless AI capabilities directly within the desktop experience.

## Hardware Foundation

*   **CPU:** **AMD Ryzen 9 8945HS** (8 Cores, 16 Threads) - Powerful for general compute and CPU-bound AI tasks.
*   **GPU:** Integrated **AMD Radeon 780M** (gfx1103) - A capable iGPU for accelerating AI workloads via ROCm.
*   **NPU:** Dedicated **AMD Ryzen AI Engine** (aie2) - Designed for highly efficient, low-power AI inference.
*   **RAM:** **48 GB DDR5 5600 MT/s** - Ample and fast memory for large models and concurrent AI processes.
*   **Storage:** **1.8TB NVMe SSD** - High-speed storage for quick model loading and data access.

## Software Environment & AI Stack

*   **Operating System:** Ubuntu 25.04 (Kernel 6.14.0-22-generic).
*   **GPU Drivers:** `amdgpu` kernel driver with **ROCm Runtime 1.15** for GPU acceleration.
*   **NPU Drivers:** Dedicated AMD Ryzen AI SDK/runtime is installed and functional for NPU utilization.
*   **Containerization:** All core AI services are deployed via **Docker Compose**.

### Key Docker Compose Services:

*   **`ollama`**: Local LLM serving (ROCm-enabled).
*   **`open-webui`**: Frontend for interacting with LLMs, integrating with other services.
*   **`qdrant`**: Vector database for RAG (Retrieval Augmented Generation).
*   **`redis`**: In-memory data store, used for caching and Pub/Sub (e.g., WebSocket support).
*   **`postgresql`**: Relational database for `open-webui` and other data storage needs.
*   **`unicorn-tika`**: Custom Tika OCR service for document intelligence.
*   **`unicorn-kokoro`**: Text-to-Speech (TTS) service.
*   **`unicorn-searxng`**: Self-hosted search engine for web integration.

## Key Development Considerations for AI Developers

1.  **Leverage AMD Hardware:**
    *   **GPU (Radeon 780M):** Utilize ROCm-enabled PyTorch/TensorFlow for GPU acceleration. Ensure your models are compatible with ROCm 1.15.
    *   **NPU (Ryzen AI):** Prioritize NPU for inference where possible. This typically involves using the AMD Ryzen AI SDK, converting models to optimized formats (e.g., ONNX), and using NPU-specific execution providers.

2.  **Model Optimization:**
    *   **Quantization:** Consider quantizing models (e.g., INT8, FP16) to reduce memory footprint and improve inference speed, especially for NPU deployment.
    *   **Frameworks:** Explore tools like ONNX Runtime or OpenVINO for optimizing and deploying models across CPU, GPU, and NPU.

3.  **Docker-Centric Development:**
    *   All core services are containerized. Familiarity with Docker and Docker Compose is essential for extending or modifying the AI stack.
    *   Ensure your custom Docker images are optimized for size and performance.

4.  **KDE6 Integration:**
    *   For desktop-integrated AI applications, consider efficient inter-process communication (e.g., D-Bus, gRPC, REST APIs) between your AI services and KDE applications.
    *   Design background AI tasks to be resource-efficient to maintain desktop responsiveness.

5.  **System Scripts:** Review the `UC-1_Core/Optimizations` directory for existing scripts (`03-rocm_ryzenai_setup.sh`, `04-pytorch-setup.sh`, `05-ml-frameworks-setup.sh`, `npu_dev_setup.sh`, etc.) that handle system-level setup and AI framework installations. These provide valuable insights into the platform's configuration.

## Getting Started

*   Explore the `UC-1_Core/docker-compose.yml` to understand the service architecture.
*   Refer to the `UC-1_Core/Optimizations` scripts for details on hardware-specific setup and software installations.
*   Utilize `ollama` for local LLM experimentation and `open-webui` as a primary interface.

This platform provides a robust environment for developing and deploying cutting-edge local AI applications, leveraging the unique capabilities of AMD's integrated hardware.