# Unicorn Commander Themes - Complete Installation Guide

## Quick Start

1. **Download or clone** this repository to any location
2. **Install desktop themes**:
   ```bash
   cd Unicorn-Commander-Themes
   sudo ./install.sh                    # System-wide (recommended)
   # OR
   ./install.sh                         # User-only install
   ```
3. **Apply themes**:
   ```bash
   uc-theme-switch                      # Unified theme switcher
   ```
4. **Install login themes** (optional):
   ```bash
   sudo ./install-sddm.sh              # Separate SDDM installer
   ```

## What Gets Installed

### Themes
- **Magic Unicorn Dark** - macOS-style with dark theme
- **Magic Unicorn Light** - macOS-style with light theme  
- **UnicornCommander Dark** - Windows-style with dark theme
- **UnicornCommander Light** - Windows-style with light theme

### Features
- 🦄 **Unicorn logos** in menu buttons
- 🌈 **Rainbow grid launcher** for app drawer
- 🍎 **macOS-style global menu** (Magic Unicorn themes)
- 🪟 **Windows-style taskbar** (UnicornCommander themes)
- 🖼️ **Custom wallpapers** for each theme
- 🎨 **Custom icon themes**
- 🔐 **SDDM login themes** (system install only)

### Commands Installed
- `uc-theme-switch` - Unified theme switcher with all features
- `uc-theme-install` - Re-run installer from anywhere

## Installation Modes

### User Installation (./install.sh)
- Installs themes only for current user
- No root access required
- Themes go to `~/.local/share/plasma/look-and-feel/`
- Commands go to `~/.local/bin/`
- SDDM themes **not** installed

### System Installation (sudo ./install.sh)  
- Installs themes system-wide
- Available for all users
- Themes go to `/usr/share/plasma/look-and-feel/`
- Commands go to `/usr/local/bin/`
- SDDM themes **included**
- Automatic dependency installation

## Usage After Installation

### GUI Method
1. Open **System Settings**
2. Go to **Appearance** > **Global Theme**
3. Select a Unicorn Commander theme
4. Click **Apply**

### Command Line Method
```bash
# Unified theme switcher with all features
uc-theme-switch
```

**Interactive Menu Options:**
1. Magic Unicorn Light ☀️ (macOS-style with global menu)
2. Magic Unicorn Dark 🌙 (macOS-style with global menu)  
3. UnicornCommander Light 🪟 (Windows-style)
4. UnicornCommander Dark 🌚 (Windows-style)

### Desktop Shortcut
