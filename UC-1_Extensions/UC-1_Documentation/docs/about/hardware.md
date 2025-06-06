# UC-1 Hardware Specifications

## Complete Hardware Profile

The UC-1 Founders Edition is purpose-built for AI workloads, combining powerful processing with efficient design and silent operation.

### 🖥️ Processor & Graphics

| Component | Specification | Details |
|-----------|---------------|---------|
| **CPU** | AMD Ryzen 9 8945HS | Zen 4 architecture, 8 cores, 16 threads |
| **Base Clock** | 4.0 GHz | Up to 5.2 GHz boost |
| **Cache** | 24MB Total | 8MB L3 + 16MB L2 cache |
| **TDP** | 35-54W | Configurable thermal design power |
| **iGPU** | AMD Radeon 780M | RDNA3 architecture with 12 compute units |
| **GPU Clock** | Up to 2.8 GHz | Dynamic frequency scaling |
| **GPU Memory** | Shared system RAM | Up to 8GB dedicated from system memory |

### 🧠 Memory & Storage

| Component | Specification | Performance |
|-----------|---------------|-------------|
| **RAM** | 96GB DDR5-5600 | Dual-channel configuration |
| **Memory Bandwidth** | 89.6 GB/s | Optimized for AI workloads |
| **Primary Storage** | 2TB NVMe SSD | PCIe 4.0 for maximum throughput |
| **Read Speed** | Up to 7,000 MB/s | Sequential read performance |
| **Write Speed** | Up to 6,500 MB/s | Sequential write performance |
| **Additional Storage** | Expansion ready | M.2 slots for additional drives |

### 🔌 Connectivity & Ports

| Port Type | Quantity | Specification |
|-----------|----------|---------------|
| **USB-C** | 2x | USB 3.2 Gen 2 (10 Gbps) with DisplayPort Alt Mode |
| **USB-A** | 4x | USB 3.2 Gen 1 (5 Gbps) |
| **HDMI** | 1x | HDMI 2.1 supporting 4K@120Hz |
| **Ethernet** | 1x | Gigabit Ethernet (RJ45) |
| **WiFi** | WiFi 6E | 802.11ax with 6GHz support |
| **Bluetooth** | 5.3 | Low energy support |
| **Audio** | 3.5mm | Combined headphone/microphone jack |

### ⚡ Power & Thermal

| Aspect | Specification | Notes |
|--------|---------------|-------|
| **Power Supply** | 120W External | Efficient GaN charger |
| **Power Consumption** | 35-90W | Varies by workload |
| **Cooling** | Dual-fan active | Near-silent operation (<30dB) |
| **Operating Temp** | 0-35°C | Extended range: -10 to 50°C |
| **Storage Temp** | -20-60°C | Safe storage conditions |
| **Humidity** | 10-90% RH | Non-condensing |

### 📦 Physical Specifications

| Dimension | Measurement | Notes |
|-----------|-------------|-------|
| **Form Factor** | Compact Desktop | Office and lab optimized |
| **Dimensions** | 196 × 196 × 38 mm | Approximately 7.7" × 7.7" × 1.5" |
| **Weight** | 1.2 kg | Approximately 2.6 lbs |
| **Mounting** | VESA compatible | 75mm × 75mm mounting pattern |
| **Color** | Space Gray | Premium anodized aluminum finish |

## 🎮 GPU Acceleration Details

### AMD Radeon 780M Capabilities

The integrated 780M GPU provides substantial AI acceleration:

- **Architecture**: RDNA3 with 12 compute units (768 stream processors)
- **Vulkan Support**: Full Vulkan 1.3 API support for compute workloads
- **ROCm Support**: AMD's ROCm platform for GPU computing
- **Memory Access**: Direct access to system memory with high bandwidth

### AI Performance Characteristics

| Workload Type | Performance | Notes |
|---------------|-------------|-------|
| **Embedding Generation** | ~500 tokens/sec | 768-dimensional vectors |
| **LLM Inference** | 15-30 tokens/sec | Varies by model size |
| **Vector Search** | <100ms | 1M+ vector database |
| **Document Processing** | 50+ pages/sec | OCR and text extraction |

## 🖥️ Operating System

### Magic Unicorn Distro

**Based on**: Ubuntu 25.04 LTS with KDE Plasma 6

#### Pre-installed Optimizations:
- **GPU Drivers**: Latest AMDGPU drivers with ROCm support
- **Vulkan Runtime**: Complete Vulkan development and runtime environment
- **Docker Engine**: Pre-configured with GPU access
- **Python Environment**: Python 3.11+ with AI/ML libraries
- **Development Tools**: Complete toolchain for AI development

#### Custom Configurations:
- **Memory Management**: Optimized for large model loading
- **Process Scheduling**: Priority scheduling for AI workloads
- **Network Security**: Hardened networking with privacy focus
- **Service Management**: Auto-start for UC-1 services

## 🔧 Expansion & Upgrade Options

### Supported Upgrades
- **RAM**: User-replaceable SO-DIMM slots
- **Storage**: Additional M.2 NVMe slots
- **WiFi**: M.2 WiFi module upgrade path
- **External GPU**: USB4/Thunderbolt eGPU support *(planned)*

### Not User-Serviceable
- **CPU**: Soldered BGA package
- **iGPU**: Integrated with CPU
- **Main Board**: Compact design for reliability

## 🌡️ Performance Benchmarks

### CPU Performance
- **Cinebench R23**: ~15,000 (multi-core), ~1,650 (single-core)
- **Geekbench 6**: ~2,400 (single-core), ~11,500 (multi-core)
- **AI Inference**: Optimized for sustained workloads

### GPU Performance
- **3DMark**: ~4,500 Time Spy score
- **Vulkan Compute**: ~2.2 TFLOPS (FP32)
- **Memory Bandwidth**: ~89 GB/s to system memory

### Thermal Performance
- **Idle**: ~35°C CPU, <30dB noise
- **Load**: ~75°C CPU, <40dB noise
- **Sustained**: Maintains performance indefinitely

## 🔒 Security Features

### Hardware Security
- **Secure Boot**: UEFI Secure Boot enabled by default
- **TPM**: Trusted Platform Module 2.0
- **Memory Encryption**: AMD Memory Guard support
- **Secure Storage**: Encrypted storage by default

### Physical Security
- **Tamper Detection**: Chassis intrusion detection
- **Kensington Lock**: Physical security slot
- **Secure Mounting**: VESA mount with security screws

## 🌍 Compliance & Certifications

| Standard | Status | Notes |
|----------|--------|-------|
| **FCC Part 15** | ✅ Certified | Class B digital device |
| **CE Marking** | ✅ Certified | European conformity |
| **RoHS** | ✅ Compliant | Restriction of hazardous substances |
| **Energy Star** | ✅ Qualified | Energy efficiency certification |
| **EPEAT** | ✅ Gold | Environmental performance rating |

## 📚 References & Resources

- [AMD Ryzen 9 8945HS Specifications](https://www.amd.com/en/products/processors/laptop/ryzen/8000-series/amd-ryzen-9-8945hs.html)
- [AMD Radeon 780M Technical Details](https://www.amd.com/en/products/graphics/amd-radeon-780m)
- [ROCm Platform Documentation](https://docs.amd.com/)
- [Vulkan API Specification](https://vulkan.lunarg.com/)

---

!!! note "Performance Variability"
    Actual performance may vary based on configuration, software version, and environmental conditions. Benchmarks represent typical performance under optimal conditions.