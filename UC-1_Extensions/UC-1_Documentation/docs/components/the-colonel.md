# The Colonel - AI Automation Agent

The Colonel is UC-1's enhanced fork of Open Interpreter, designed for advanced AI-powered computer automation and seamless integration with Open WebUI.

## Overview

The Colonel serves as your personal AI automation agent, capable of:
- 🖥️ **Computer Control**: Take screenshots, control mouse/keyboard input
- 💻 **Code Execution**: Run Python, shell commands, and scripts safely
- 📁 **File Operations**: Manage files and directories across your system
- 🔧 **Tool Integration**: 12+ specialized tool endpoints for various tasks
- 🌐 **API Server**: OpenAI-compatible streaming API for integrations

## Key Features

### 🔗 Enhanced Integration
- **Open WebUI Compatible**: Native tool server integration
- **Streaming Responses**: Real-time output and progress updates
- **Dynamic Profiles**: Customizable agent personalities and capabilities
- **Enterprise Security**: Authentication and access controls

### 🛠️ Advanced Capabilities
- **System Automation**: Automate complex multi-step workflows
- **Screen Analysis**: Understand and interact with visual interfaces
- **Development Tools**: Code generation, debugging, and deployment
- **Document Processing**: Extract, analyze, and manipulate documents

### 🔒 Security & Safety
- **Sandboxed Execution**: Safe code execution environment
- **Permission Controls**: Granular access permissions
- **Audit Logging**: Complete activity tracking
- **Safe Mode Options**: Configurable safety restrictions

## Installation

The Colonel is automatically installed with UC-1:

```bash
# Installed during UC-1 setup in:
UC-1_Extensions/The_Colonel/

# Global access via:
/opt/open-interpreter/Open-Interpreter/bin/interpreter

# Or activate the environment:
source /opt/open-interpreter/Open-Interpreter/bin/activate
interpreter --help
```

## Configuration

### Environment Variables

```bash
# Edit The Colonel's environment
nano /opt/open-interpreter/.env
```

Common configuration options:
```env
# API Keys (optional - works locally without them)
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key

# Safety Settings
SAFE_MODE=true
AUTO_RUN=false

# Model Configuration
MODEL=gpt-4
LOCAL_MODEL=false

# Server Settings (for API mode)
HOST=localhost
PORT=8000
```

### Profile Configuration

Create custom agent profiles:
```python
# ~/.config/open-interpreter/profiles/the_colonel.py
import os

# Agent personality
profile = {
    \"name\": \"The Colonel\",
    \"description\": \"Military-precision automation agent\",
    \"system_message\": \"You are The Colonel, an elite automation specialist...\",
    \"auto_run\": False,
    \"safe_mode\": True,
    \"model\": \"gpt-4\",
}

# Custom tools
def screenshot_analysis():
    \"\"\"Enhanced screenshot analysis with military precision\"\"\"
    pass

# Export profile
def load_profile():
    return profile
```

## Usage Modes

### 1. Interactive Mode (Terminal)
```bash
# Start interactive session
interpreter

# Use with specific model
interpreter --model gpt-4

# Safe mode (asks before executing)
interpreter --safe_mode

# Local mode (no API keys needed)
interpreter --local
```

### 2. API Server Mode
```bash
# Start as API server
interpreter --server --port 8000

# Server with authentication
interpreter --server --api_key your_secret_key
```

### 3. Open WebUI Integration
The Colonel automatically integrates with Open WebUI as a tool server:

1. **Access Tools**: Click the tools icon in Open WebUI
2. **Select The Colonel**: Choose from available agents
3. **Give Commands**: Natural language automation requests
4. **Monitor Execution**: Real-time feedback and results

## Tool Endpoints

The Colonel provides 12+ specialized tool endpoints:

### Core Tools
- **`/execute_python`**: Run Python code with output capture
- **`/execute_shell`**: Execute shell commands safely
- **`/read_file`**: Read file contents with encoding detection
- **`/write_file`**: Write files with backup and validation
- **`/list_directory`**: Directory listing with metadata

### Computer Control
- **`/take_screenshot`**: Capture screen with annotations
- **`/click_mouse`**: Precise mouse click operations
- **`/type_text`**: Keyboard input simulation
- **`/scroll_screen`**: Scroll operations with targeting

### Advanced Operations
- **`/analyze_image`**: Computer vision analysis
- **`/search_web`**: Web research capabilities
- **`/manage_processes`**: System process management

## Example Workflows

### 1. Document Analysis
```python
# Ask The Colonel to analyze a document
\"Analyze the quarterly report in ~/Documents/Q1-2024.pdf and 
summarize the key financial metrics. Create a comparison chart 
with last quarter's data.\"
```

### 2. Development Automation
```python
# Automate development tasks
\"Check the git status of my project, run the test suite, 
and if all tests pass, create a pull request with the 
current changes.\"
```

### 3. System Administration
```python
# System maintenance tasks
\"Check disk usage across all drives, clean up temporary files 
older than 30 days, and generate a system health report.\"
```

### 4. Web Automation
```python
# Web scraping and automation
\"Take a screenshot of the login page, fill in the credentials 
from my password manager, and download the monthly reports 
from the dashboard.\"
```

## API Reference

### Authentication
```bash
# API key authentication
curl -H \"Authorization: Bearer your_api_key\" \\
     http://localhost:8000/v1/chat/completions
```

### Chat Completions
```json
POST /v1/chat/completions
{
  \"model\": \"the-colonel\",
  \"messages\": [
    {\"role\": \"user\", \"content\": \"Take a screenshot and analyze it\"}
  ],
  \"stream\": true
}
```

### Tool Execution
```json
POST /tools/execute_python
{
  \"code\": \"import os; print(os.getcwd())\",
  \"timeout\": 30
}
```

## Security Considerations

### Safe Mode Options
- **`safe_mode=true`**: Requires approval before execution
- **Sandboxed execution**: Isolated environment for code running
- **Permission controls**: Granular file and system access
- **Audit logging**: Complete activity tracking

### Production Deployment
```yaml
# Docker deployment with security
version: '3.8'
services:
  the-colonel:
    build: ./UC-1_Extensions/The_Colonel
    environment:
      - SAFE_MODE=true
      - AUTO_RUN=false
      - API_KEY=${COLONEL_API_KEY}
    volumes:
      - ./data:/app/data:ro  # Read-only data access
    security_opt:
      - no-new-privileges:true
    user: \"1000:1000\"
```

## Troubleshooting

### Common Issues

#### 1. Permission Denied
```bash
# Check user permissions
ls -la /opt/open-interpreter/

# Fix ownership if needed
sudo chown -R $USER:$USER /opt/open-interpreter/
```

#### 2. Module Import Errors
```bash
# Reinstall in development mode
cd UC-1_Extensions/The_Colonel
pip install -e .

# Check virtual environment
source /opt/open-interpreter/Open-Interpreter/bin/activate
python -c \"import interpreter; print('OK')\"
```

#### 3. API Server Won't Start
```bash
# Check port availability
netstat -tlnp | grep :8000

# Start with different port
interpreter --server --port 8001
```

#### 4. Screenshot Issues
```bash
# Install display dependencies
sudo apt install xvfb x11vnc

# Test screenshot capability
interpreter -c \"computer.screenshot()\"
```

### Performance Optimization

#### Memory Usage
```python
# Optimize for large files
import os
os.environ['OMP_NUM_THREADS'] = '4'  # Limit thread usage
```

#### GPU Acceleration
```bash
# Enable GPU for compatible operations
export CUDA_VISIBLE_DEVICES=0
interpreter --local --model local-gpu-model
```

## Advanced Configuration

### Custom Tools
Create custom tool endpoints:

```python
# ~/.config/open-interpreter/tools/custom_tool.py
def custom_automation_tool(task_description):
    \"\"\"Custom automation tool for specific workflows\"\"\"
    # Implementation here
    return result

# Register tool
interpreter.tools.append(custom_automation_tool)
```

### Integration Hooks
```python
# Pre-execution hooks
def security_check(code):
    \"\"\"Security validation before code execution\"\"\"
    if 'rm -rf' in code:
        raise SecurityError(\"Destructive command detected\")
    return True

interpreter.pre_execution_hooks.append(security_check)
```

## Monitoring & Logging

### Activity Logging
```bash
# View execution logs
tail -f ~/.config/open-interpreter/logs/activity.log

# Structured logging
cat ~/.config/open-interpreter/logs/commands.json | jq
```

### Performance Metrics
```python
# Monitor performance
import time
start_time = time.time()
result = interpreter.run(\"complex task\")
execution_time = time.time() - start_time
print(f\"Execution time: {execution_time:.2f}s\")
```

## Future Roadmap

### Planned Features
- **Visual Workflow Builder**: Drag-and-drop automation design
- **Multi-Agent Coordination**: Orchestrate multiple AI agents
- **Plugin Marketplace**: Community-contributed tools and integrations
- **Voice Interface**: Voice-activated automation commands

### Contributing
The Colonel is open source and welcomes contributions:
1. Fork the repository
2. Create feature branches
3. Submit pull requests
4. Join community discussions

---

**The Colonel represents the cutting edge of AI automation - precise, powerful, and completely under your control.** 🎖️