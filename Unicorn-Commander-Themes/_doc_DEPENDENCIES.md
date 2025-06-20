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
