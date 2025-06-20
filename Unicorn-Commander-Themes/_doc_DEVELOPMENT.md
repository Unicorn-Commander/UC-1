# KDE Plasma 6 Theme Development Guide

## Overview

This guide documents the development process, working commands, and lessons learned from creating a complete KDE Plasma 6 theme experience. Our themes target **KDE Plasma 6.x** with **Qt 6.x** and **Wayland**, including both **SDDM login themes** and **desktop themes**.

## Theme Structure

### SDDM Login Theme
- `UnicornCommander` - Professional cosmic login interface with Qt6 compatibility

### Magic Unicorn Themes (macOS-style)
- `org.magicunicorn.dark` - Dark macOS-style with floating centered dock
- `org.magicunicorn.light` - Light macOS-style with floating centered dock

### UnicornCommander Themes (Windows-style)  
- `org.unicorncommander.dark` - Dark Windows-style with full-width taskbar
- `org.unicorncommander.light` - Light Windows-style with full-width taskbar

## Working Commands & Techniques

### SDDM Theme Development

#### ✅ SDDM Theme Structure (Qt6 Compatible)
```bash
# SDDM theme location
/usr/share/sddm/themes/UnicornCommander/
├── Main.qml                 # Main theme interface (Qt6 compatible)
├── metadata.desktop         # Theme metadata with QtVersion=6
├── theme.conf              # Theme configuration
├── components/             # Reusable QML components
├── backgrounds/            # Wallpaper images  
└── assets/                 # Icons and logos
```

#### ✅ Critical SDDM Files
```desktop
# metadata.desktop - MUST include QtVersion=6 for Plasma 6
[SDDM]
QtVersion=6
```

```qml
# Main.qml - Qt6 compatible imports
import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import Qt5Compat.GraphicalEffects      // Qt6 replacement for QtGraphicalEffects
import SddmComponents 2.0
```

#### ✅ SDDM Installation Commands
```bash
# Install SDDM theme
sudo cp -r UnicornCommander /usr/share/sddm/themes/
sudo chown -R root:root /usr/share/sddm/themes/UnicornCommander
sudo chmod -R 755 /usr/share/sddm/themes/UnicornCommander

# Configure SDDM
echo "[Theme]" | sudo tee /etc/sddm.conf.d/kde_settings.conf
echo "Current=UnicornCommander" | sudo tee -a /etc/sddm.conf.d/kde_settings.conf

# Test theme
sudo sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/UnicornCommander
```

### KDE Plasma 6 Global Theme Requirements

#### ✅ Required Files for Global Themes
```bash
# Essential files for KDE Plasma 6 global themes
~/.local/share/plasma/look-and-feel/theme-id/
├── manifest.json          # ← REQUIRED for Plasma 6!
├── metadata.json          # Theme metadata
└── contents/
    ├── defaults           # Default settings
    ├── layouts/
    │   └── org.kde.plasma.desktop-layout.js
    ├── lockscreen/
    ├── splash/
    └── ui/
