# Unicorn Commander Themes - Dependencies

## Required Dependencies

### Core KDE Dependencies
These are automatically installed by the installer when run with `sudo`:

- **plasma-widgets-addons** - Required for Application Dashboard widget
- **qml-module-qtquick-layouts** - Required for QML layouts in themes
- **qml-module-qtquick-controls2** - Required for QML controls in themes  
- **qml-module-qtgraphicaleffects** - Required for visual effects
- **qml-module-qt-labs-platform** - Required for platform integration
- **kwin-addons** - Additional KWin effects and features

### Color Schemes
Custom color schemes are installed automatically:
- **UCMacDark.colors** - Dark theme for Magic Unicorn
- **UCMacLight.colors** - Light theme for Magic Unicorn
- **UCWindowsDark.colors** - Dark theme for UnicornCommander
- **UCWindowsLight.colors** - Light theme for UnicornCommander

### Plasma Themes
Custom plasma themes are created automatically:
- **magic-unicorn-dark** - Custom dark plasma theme with purple accents

### Icon Themes
The installer uses standard KDE icon themes:
- **breeze** - Default light icon theme
- **breeze-dark** - Default dark icon theme

## Manual Installation

If you need to install dependencies manually:

### Ubuntu/Debian:
```bash
sudo apt install plasma-widgets-addons \
                 qml-module-qtquick-layouts \
                 qml-module-qtquick-controls2 \
                 qml-module-qtgraphicaleffects \
                 qml-module-qt-labs-platform \
                 kwin-addons
```

### Arch Linux:
```bash
sudo pacman -S plasma-addons qt6-declarative
```

### Fedora:
```bash
sudo dnf install plasma-workspace-addons qt6-qtdeclarative-devel
```

## File Structure After Installation

### System-wide Installation (`sudo ./install.sh`):
```
/usr/share/plasma/look-and-feel/
├── MagicUnicorn-Dark/
│   ├── contents/
│   │   ├── assets/menu-button/          # Self-contained assets
│   │   ├── defaults                     # Fixed paths
│   │   ├── layouts/                     # Fixed paths
│   │   ├── scripts/                     # Fixed paths
│   │   └── previews/
│   └── metadata.json
├── MagicUnicorn-Light/                  # Same structure
└── org.unicorncommander.windows.*      # UnicornCommander themes

/usr/share/color-schemes/
├── UCMacDark.colors
├── UCMacLight.colors
├── UCWindowsDark.colors
└── UCWindowsLight.colors

/usr/share/plasma/desktoptheme/
└── magic-unicorn-dark/                 # Custom plasma theme

/usr/share/wallpapers/
├── MagicUnicorn/
└── UnicornCommander/

/usr/local/bin/
└── uc-theme-switch                     # Unified theme switcher
```

## Self-Containment Features

### Assets Embedded in Themes
Each theme contains its own copy of required assets:
- **Menu button icons** (unicorn.svg, rainbow-grid.svg)
- **Preview images** for System Settings
- **All configuration files** with corrected paths

### No External Dependencies
- ✅ No hardcoded user paths
- ✅ No references to development directories  
- ✅ All assets copied to theme directories
- ✅ Proper system wallpaper paths
- ✅ Standard icon theme references only

### Automatic Path Fixing
The installer automatically:
- Replaces `/home/ucadmin/UC-1/` paths with proper system paths
- Copies assets to theme directories for self-containment
- Creates necessary color schemes and plasma themes
- Installs all dependencies

## Verification

After installation, verify everything is self-contained:

```bash
# Check for any remaining hardcoded paths
sudo grep -r "/home/ucadmin" /usr/share/plasma/look-and-feel/MagicUnicorn* || echo "✅ No hardcoded paths found"

# Check assets are present
ls /usr/share/plasma/look-and-feel/MagicUnicorn-Dark/contents/assets/menu-button/

# Check themes are available
lookandfeeltool --list | grep -i unicorn
```

## What's Portable

✅ **Complete theme package** - All assets included  
✅ **Cross-system compatibility** - No hardcoded paths  
✅ **Dependency management** - Installer handles everything  
✅ **Self-contained** - Works offline after installation  
✅ **Clean uninstall** - All files in standard locations