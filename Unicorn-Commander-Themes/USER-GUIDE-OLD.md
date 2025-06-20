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

- **Two macOS-style themes** (Magic Unicorn) with global menu integration
- **Two Windows-style themes** (UnicornCommander) with traditional taskbar
- **Light and dark variants** of each style
- **Self-contained design** with all assets included
- **Unicorn branding** throughout the interface

## Available Themes

### 🍎 Mac-Style Layouts
- **UnicornCommander Mac Light**: Clean, bright interface with authentic macOS layout
- **UnicornCommander Mac Dark**: Sleek dark interface with authentic macOS layout
  - **Top Panel**: Unicorn launcher + global menu → clock + system tray (28px height)
  - **Bottom Dock**: Centered floating dock with app tasks (60px height, auto-centering)
  - **Global Menu**: Changes dynamically based on active application
  - **Dark Colors**: UCMacDark color scheme with cosmic purple accents

### 🪟 Windows-Style Layouts  
- **UnicornCommander Windows Light**: Familiar Windows-style bottom taskbar with light theme
- **UnicornCommander Windows Dark**: Modern Windows-style bottom taskbar with dark theme

## Quick Start

### Installation

1. **Build the themes:**
   ```bash
   cd /home/ucadmin/UC-1/KDE-Themes
   ./scripts/build-themes.sh
   ```

2. **Install to your system:**
   ```bash
   ./scripts/install-themes.sh
   ```

3. **Apply a theme:**
   - Open System Settings (`systemsettings`)
   - Navigate to **Appearance** → **Global Theme**
   - Select your preferred UnicornCommander theme
   - Click **Apply**
   - Log out and back in for complete effect

### Theme Features

#### Mac-Style Layout
```
┌─────────────────────────────────────────────────────────────┐
│ [🦄] [App Menu...]                  [System Tray] [Clock] │ ← Top Panel (28px)
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    Desktop Wallpaper                       │
│                                                             │
│                                                             │
│                 [📁] [⚡] [🔧] [🗑️]                        │ ← Floating Dock (60px)
└─────────────────────────────────────────────────────────────┘
```

**Key Features:**
- **Unicorn launcher** opens application menu at top-left
- **Global menu** shows current app's menus (File, Edit, etc.)
- **Clock positioned** at far right of top panel
- **Centered dock** adapts size to content (20-35% screen width)
- **Floating panels** with modern rounded appearance

#### Windows-Style Layout
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                    Desktop Wallpaper                       │
│                                                             │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│[🦄][📁][⚡][Tasks...][Tray][Clock][Desktop]                │ ← Bottom Taskbar
└─────────────────────────────────────────────────────────────┘
```

## Theme Components

### Visual Elements
- **Logo**: UnicornCommander unicorn logo as application launcher (`~/UC-1/assets/unicorn.svg`)
- **Wallpapers**: High-resolution cosmic gradient wallpapers (1366x768 to 7680x4320)  
- **Colors**: Purple and blue accent colors matching UnicornCommander branding
- **Typography**: Clean, readable fonts optimized for both light and dark variants
- **Floating Panels**: Modern rounded corners with subtle shadows
- **Adaptive Sizing**: Dock automatically adjusts to content while staying centered

### Included Applications
Pre-configured launcher shortcuts:
- **File Manager** (Dolphin)
- **Terminal** (Konsole)  
- **Web Browser** (Firefox)
- **Text Editor** (Kate)

## Customization

### Changing Wallpapers
1. Right-click on desktop → **Configure Desktop and Wallpaper**
2. Choose from UnicornCommander wallpaper collection
3. Or browse to `/home/ucadmin/UC-1/KDE-Themes/assets/wallpapers/`

### Modifying Panel Layout
1. Right-click on panel → **Enter Edit Mode**
2. Add, remove, or rearrange widgets
3. Right-click widgets for configuration options
4. Click **Exit Edit Mode** when finished

### Switching Between Themes
- Use System Settings → **Global Theme** to switch between variants
- Changes apply immediately for most elements
- Log out/in for complete theme switching

## Color Schemes

### Light Theme Colors
- **Background**: Clean whites and light grays
- **Text**: Dark gray (#35,38,39) for readability
- **Accent**: UnicornCommander purple (#8B,5C,F6)
- **Highlight**: Bright blue (#3B,82,F6)

### Dark Theme Colors  
- **Background**: Deep grays and near-black
- **Text**: Light gray (#FC,FC,FC) for contrast
- **Accent**: UnicornCommander purple (#8B,5C,F6)
- **Highlight**: Sky blue (#60,A5,FA)

## Troubleshooting

### Theme Not Appearing in Settings
```bash
# Refresh KDE services database
kbuildsycoca6 --noincremental

# Verify installation
ls ~/.local/share/plasma/look-and-feel/ | grep UC-
```

### Panel Layout Issues
1. **Reset panel to defaults:**
   - Right-click panel → **Add Panel** → **Default Panel**
   - Remove old panel after configuring new one

2. **Restore from backup:**
   ```bash
   cp ~/.config/plasma-org.kde.plasma.desktop-appletsrc.backup ~/.config/plasma-org.kde.plasma.desktop-appletsrc
   killall plasmashell && plasmashell &
   ```

### Wallpaper Not Loading
1. Check wallpaper path in desktop settings
2. Verify wallpaper files exist:
   ```bash
   ls ~/.local/share/wallpapers/UnicornCommander/
   ```

### Colors Not Applied
1. **Manual color scheme application:**
   - System Settings → **Colors**
   - Select appropriate UC color scheme
   - Apply changes

2. **Clear color cache:**
   ```bash
   rm -rf ~/.cache/ksycoca6*
   kbuildsycoca6 --noincremental
   ```

## Advanced Usage

### Creating Custom Variants
1. Copy existing theme directory:
   ```bash
   cp -r themes/UC-Mac-Light themes/UC-Custom
   ```

2. Edit `metadata.json` with unique ID and name

3. Modify `contents/defaults` for custom settings

4. Rebuild and install themes

### Multi-Monitor Setup
- Each monitor can have independent panel configurations
- Right-click panel → **Configure Panel** → **More Settings**
- Set **Visibility** to specific screen

### Keyboard Shortcuts
Default shortcuts work with all theme variants:
- **Meta+Space**: Application launcher
- **Meta+Tab**: Task switcher  
- **Meta+D**: Show desktop
- **Alt+F2**: Run command dialog

## System Requirements

### Minimum Requirements
- **OS**: Ubuntu Server 25.04 or compatible
- **Desktop**: KDE Plasma 6.3.4+
- **Qt**: 6.8.3+
- **Display**: Wayland (recommended) or X11
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 200MB for complete theme package

### Recommended Hardware
- **GPU**: Hardware acceleration for smooth effects
- **Display**: 1920x1080 or higher resolution
- **Multi-monitor**: Supported with independent configurations

## Support

### Log Files
Check these locations for troubleshooting:
- **Plasma Shell**: `journalctl --user -u plasma-plasmashell`
- **KDE Services**: `journalctl --user -u plasma-kded`
- **Session**: `~/.xsession-errors`

### Reset to Defaults
```bash
# Backup current settings
cp -r ~/.config/plasma-org.kde.plasma.desktop-appletsrc ~/.config/plasma-backup

# Reset to KDE defaults
rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc
killall plasmashell && plasmashell &
```

### Getting Help
1. Check `DEVELOPMENT.md` for technical details
2. Verify system compatibility requirements
3. Review installation logs for error messages
4. Test with default KDE theme first to isolate issues

## Uninstallation

### Remove Themes
```bash
# Remove global themes
rm -rf ~/.local/share/plasma/look-and-feel/UC-*

# Remove color schemes  
rm ~/.local/share/color-schemes/UCMac*.colors

# Remove wallpapers
rm -rf ~/.local/share/wallpapers/UnicornCommander/

# Refresh cache
kbuildsycoca6 --noincremental
```

### Reset to System Defaults
1. Apply default KDE theme in System Settings
2. Reset panels to default configuration
3. Change wallpaper to system default
4. Log out and back in

---

**Version**: 1.0  
**Compatible with**: KDE Plasma 6.3.4+, Qt 6.8.3+  
**Last Updated**: June 14, 2025