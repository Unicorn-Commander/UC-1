# Installation Guide - UnicornCommander KDE Themes

## Prerequisites

### System Requirements
- **Operating System**: Ubuntu Server 25.04 or compatible Linux distribution
- **Desktop Environment**: KDE Plasma 6.3.4 or newer
- **Qt Framework**: Qt 6.8.3 or newer
- **Display Server**: Wayland (recommended) or X11
- **Memory**: Minimum 4GB RAM, 8GB recommended
- **Storage**: 200MB free space for complete installation

### Required Packages
Install dependencies before proceeding:

```bash
# Update package lists
sudo apt update

# Install KDE Plasma and development tools
sudo apt install plasma-desktop plasma-workspace kpackagetool6 kbuildsycoca6

# Optional: Additional KDE applications
sudo apt install dolphin konsole kate firefox
```

## Installation Methods

### Method 1: Automated Installation (Recommended)

1. **Navigate to project directory:**
   ```bash
   cd /home/ucadmin/UC-1/KDE-Themes
   ```

2. **Build all theme variants:**
   ```bash
   ./scripts/build-themes.sh
   ```
   
   Expected output:
   ```
   === UnicornCommander KDE Theme Builder ===
   Project directory: /home/ucadmin/UC-1/KDE-Themes
   Creating color schemes...
   Building theme packages...
   Building UC-Mac-Light...
   Building UC-Mac-Dark...
   Building UC-Windows-Light...
   Building UC-Windows-Dark...
   === Build Complete ===
   ```

3. **Install themes to your system:**
   ```bash
   ./scripts/install-themes.sh
   ```
   
   Expected output:
   ```
   === UnicornCommander KDE Theme Installer ===
   Installing color schemes...
   Installing look-and-feel themes...
   Installing UC-Mac-Light...
   Installing UC-Mac-Dark...
   Installing UC-Windows-Light...
   Installing UC-Windows-Dark...
   Installing wallpapers...
   Refreshing KDE cache...
   === Installation Complete ===
   ```

### Method 2: Manual Installation

If you prefer manual control over the installation process:

1. **Build themes manually:**
   ```bash
   cd /home/ucadmin/UC-1/KDE-Themes
   
