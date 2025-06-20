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
- **Layout**: Single bottom taskbar
- **Colors**: Light theme with blue accents
- **Features**: Traditional start menu with unicorn logo
- **Best for**: Users familiar with Windows who want familiar layout

#### UnicornCommander Dark 🌚
- **Layout**: Single bottom taskbar  
- **Colors**: Dark theme with blue accents
- **Features**: Traditional start menu with unicorn logo
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
