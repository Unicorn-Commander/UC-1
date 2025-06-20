# 🦄 Unicorn Commander Themes - User Guide

## Table of Contents

1. [Overview](#overview)
2. [Theme Descriptions](#theme-descriptions)
3. [Installation](#installation)
4. [Using the Theme Switcher](#using-the-theme-switcher)
5. [GUI Theme Selection](#gui-theme-selection)
6. [Theme Features](#theme-features)
7. [Customization](#customization)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Usage](#advanced-usage)

## Overview

Unicorn Commander Themes provide four distinct desktop experiences for KDE Plasma:

- **Two macOS-inspired themes** (Magic Unicorn) with top menu bar and floating dock
- **Two Windows-inspired themes** (UnicornCommander) with standard bottom taskbar
- **Light and dark variants** of each style
- **Self-contained design** with all assets included
- **Unicorn branding** throughout the interface

## Theme Descriptions

### Magic Unicorn Themes (macOS-style)

#### Magic Unicorn Light ☀️
- **Layout**: Top menu bar + bottom floating dock
- **Colors**: Light theme with purple accents
- **Features**: Global menu, rainbow grid launcher, auto-hide dock
- **Best for**: Users familiar with macOS who want a light, clean interface

#### Magic Unicorn Dark 🌙  
- **Layout**: Top menu bar + bottom floating dock
- **Colors**: Dark theme with purple accents
- **Features**: Global menu, rainbow grid launcher, auto-hide dock
- **Best for**: Users who prefer dark themes with macOS-style workflow

### UnicornCommander Themes (Windows-style)

#### UnicornCommander Light 🪟
- **Layout**: Standard bottom taskbar (default KDE panel size)
- **Colors**: Light theme with violet accents
- **Features**: Unicorn logo start menu, system tray, rainbow app launcher
- **Best for**: Users familiar with Windows who want familiar layout

#### UnicornCommander Dark 🌚
- **Layout**: Standard bottom taskbar (default KDE panel size)
- **Colors**: Dark theme with violet accents  
- **Features**: Unicorn logo start menu, system tray, rainbow app launcher
- **Best for**: Windows users who prefer dark themes

## Installation

### Quick Installation
```bash
# 1. Install desktop themes
cd Unicorn-Commander-Themes
sudo ./install.sh                    # System-wide (recommended)

# 2. Apply a theme
uc-theme-switch                      # Interactive theme selector

# 3. Optional: Install login themes
sudo ./install-sddm.sh              # Separate SDDM installer
```

### Installation Modes

**System-wide** (`sudo ./install.sh`):
- Available for all users
- Installs to `/usr/share/`
- Includes SDDM theme files
- Automatic dependency installation

**User-only** (`./install.sh`):
- Only for current user
- Installs to `~/.local/share/`
- No SDDM themes
- Manual dependency installation may be needed

## Using the Theme Switcher

### Command Line Interface
```bash
uc-theme-switch
```

This opens an interactive menu:

```
🦄 Unicorn Commander Theme Switcher
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Magic Unicorn Light ☀️ (macOS-style with global menu)
  2. Magic Unicorn Dark 🌙 (macOS-style with global menu)
  3. UnicornCommander Light 🪟 (Windows-style)
  4. UnicornCommander Dark 🌚 (Windows-style)
  5. Exit

Select theme (1-5):
```

### What Happens When You Switch

The theme switcher automatically:
1. **Applies the Look and Feel theme**
2. **Configures panel layout** (macOS or Windows style)
3. **Enables global menu** (for Magic Unicorn themes)
4. **Applies unicorn logos** to menu buttons
5. **Sets appropriate wallpaper**
6. **Restarts Plasma** to apply changes
7. **Re-applies custom configurations** after restart

## GUI Theme Selection

### System Settings Method
1. Open **System Settings** (`systemsettings6`)
2. Navigate to **Appearance** > **Global Theme**
3. Look for themes with unicorn icons and names:
   - Magic Unicorn Dark
   - Magic Unicorn Light  
   - UnicornCommander Dark
   - UnicornCommander Light
4. Click on desired theme
5. **⚠️ IMPORTANT:** Check **"Use desktop layout from theme"**
6. Click **Apply**

> **Critical:** The "Use desktop layout from theme" checkbox must be checked to get:
> - Custom panel layouts (macOS vs Windows-inspired)
> - Unicorn logo on start buttons
> - Rainbow application launcher
> - Proper system tray positioning
> 
> Without this option, you'll get the theme colors but default KDE panel layout.

### Preview Images
All themes include preview images showing the wallpaper and general appearance.

## Theme Features

### Magic Unicorn Themes

#### Global Menu Integration
- **Application menus appear in top bar** (like macOS)
- **App name displayed** in menu bar when active
- **Automatic menu hiding** when no app is focused
- **System-wide integration** works with most applications

#### Floating Dock
- **Auto-sizing dock** adjusts to content
- **Centered alignment** with app icons
- **Auto-hide behavior** when windows overlap
- **Rainbow grid launcher** for full-screen app grid

#### Top Menu Bar
- **Always visible** menu bar at top of screen
- **System tray** in top-right corner
- **Digital clock** integrated
- **Application menus** integrated

### UnicornCommander Themes

#### Standard Bottom Taskbar
- **Default KDE panel size** for familiar feel
- **Full-width bottom panel** spanning entire screen
- **Windows-inspired layout** with all controls in one place
- **No top panel** for clean, focused workspace

#### Taskbar Components (Left to Right)
1. **Start menu** with unicorn logo (Kickoff widget)
2. **Task manager** showing open applications
3. **Rainbow application dashboard** button for app grid
4. **Margin separator** for proper spacing
5. **System tray** with notifications, sound, network controls
6. **Digital clock** with date display
7. **Show desktop** button

#### Start Menu Features
- **Unicorn logo** as start button icon
- **Traditional KDE menu layout**
- **Application categories and search**
- **Recently used applications**

### Universal Features

#### Unicorn Branding
- **Unicorn SVG logo** in menu buttons
- **Custom wallpapers** with unicorn themes
- **Purple/blue accent colors** throughout interface
- **Coordinated color schemes**

#### Visual Effects
- **Blur effects** enabled automatically
- **Smooth animations** for panel interactions
- **Professional appearance** with polish

## Customization

### Changing Wallpapers
```bash
# Apply different wallpaper
plasma-apply-wallpaperimage /path/to/your/wallpaper.jpg

# Browse available unicorn wallpapers
ls /usr/share/wallpapers/UnicornCommander/
ls /usr/share/wallpapers/MagicUnicorn/
```

### Panel Customization
Right-click on panels to:
- **Add/remove widgets**
- **Adjust panel height**
- **Change panel behavior**
- **Modify alignment**

### Color Scheme Tweaks
1. Open **System Settings** > **Appearance** > **Colors**
2. Select base color scheme:
   - UCMacDark (for Magic Unicorn Dark)
   - UCMacLight (for Magic Unicorn Light)
   - UCWindowsDark (for UnicornCommander Dark)
   - UCWindowsLight (for UnicornCommander Light)
3. Customize individual colors as desired

### Icon Theme Changes
1. **System Settings** > **Appearance** > **Icons**
2. Select from available themes:
   - `breeze` (light themes)
   - `breeze-dark` (dark themes)
   - Or install additional icon themes

## Troubleshooting

### Themes Don't Appear in System Settings
```bash
# Rebuild KDE cache
kbuildsycoca6

# Restart Plasma if needed
kquitapp6 plasmashell
plasmashell &
```

### Dark Theme Appears Light
```bash
# Re-apply theme with correct configuration
uc-theme-switch
# Select the dark theme option again
```

### Global Menu Not Working
1. **Check dependencies**:
   ```bash
   sudo apt install plasma-widgets-addons
   ```

2. **Re-apply Magic Unicorn theme**:
   ```bash
   uc-theme-switch
   # Choose option 1 or 2
   ```

3. **Restart applications** to see global menu

### Unicorn Logo Missing
```bash
# Re-apply theme to restore logos
uc-theme-switch
```

### Command Not Found
```bash
# For user installations, add to PATH:
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Panel Layout Issues
```bash
# Reset to default theme configuration
uc-theme-switch
# Select desired theme to restore proper layout
```

## Advanced Usage

### Manual Theme Application
```bash
# Apply specific theme directly
lookandfeeltool --apply org.magicunicorn.dark

# List all available themes
lookandfeeltool --list
```

### Custom Wallpaper Integration
```bash
# Copy custom wallpapers to theme directories
sudo cp /path/to/custom-wallpaper.jpg /usr/share/wallpapers/UnicornCommander/
sudo cp /path/to/custom-wallpaper.jpg /usr/share/wallpapers/MagicUnicorn/
```

### Scripting Theme Changes
```bash
#!/bin/bash
# Example script to switch to dark theme
lookandfeeltool --apply org.magicunicorn.dark
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    // Custom panel configuration here
"
```

### SDDM Theme Management
```bash
# Install SDDM themes separately
sudo ./install-sddm.sh

# Check current SDDM theme
grep "Current=" /etc/sddm.conf.d/kde_settings.conf

# Reset SDDM to default if needed
sudo sed -i 's/^Current=/#Current=/' /etc/sddm.conf.d/kde_settings.conf
```

### Backup and Restore
```bash
# Backup current KDE configuration
tar -czf kde-backup.tar.gz ~/.config/plasma* ~/.config/kde*

# Restore if needed
tar -xzf kde-backup.tar.gz -C ~/
```

## Tips and Best Practices

### For macOS Users
- **Start with Magic Unicorn Light** for familiar experience
- **Use global menu** - app menus appear in top bar
- **Try rainbow grid launcher** for Launchpad-like experience
- **Use dock auto-hide** for clean desktop

### For Windows Users  
- **Start with UnicornCommander Light** for familiar taskbar
- **Pin frequently used apps** to taskbar
- **Use start menu search** for quick app launching
- **Keep taskbar always visible** for easy access

### For Dark Theme Enthusiasts
- **Magic Unicorn Dark** for macOS-style dark theme
- **UnicornCommander Dark** for Windows-style dark theme
- **Both use custom dark color schemes** with purple/blue accents
- **Wallpapers are optimized** for dark theme viewing

### Performance Tips
- **Global menu may use slightly more RAM** but provides better screen space
- **Floating dock auto-hide** saves screen space on smaller displays
- **Blur effects** require GPU acceleration for best performance
- **Multiple wallpapers** take minimal storage (pre-optimized)

## Getting Help

### Documentation
- **[README.md](README.md)** - Project overview and quick start
- **[INSTALLER-README.md](INSTALLER-README.md)** - Detailed installation guide  
- **[DEPENDENCIES.md](DEPENDENCIES.md)** - Technical dependency information

### Common Solutions
1. **Restart Plasma** if themes appear broken
2. **Rebuild KDE cache** if new themes don't appear
3. **Re-run theme switcher** to fix configuration issues
4. **Check dependencies** if advanced features don't work
5. **Use recovery scripts** if SDDM breaks (auto-generated during SDDM install)

### File Locations
- **Themes**: `/usr/share/plasma/look-and-feel/` (system) or `~/.local/share/plasma/look-and-feel/` (user)
- **Wallpapers**: `/usr/share/wallpapers/`
- **Color schemes**: `/usr/share/color-schemes/`
- **Commands**: `/usr/local/bin/` or `~/.local/bin/`

---

🦄 **Enjoy your new Unicorn Commander themed desktop!** 🦄