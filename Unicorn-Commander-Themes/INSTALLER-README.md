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
Desktop shortcuts are optional and only created if requested during installation.

## Troubleshooting

### "Command not found" Error
If `uc-theme-switch` command is not found after user installation:
```bash
# Add ~/.local/bin to your PATH
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Themes Not Showing
1. **Verify installation location**:
   ```bash
   ls ~/.local/share/plasma/look-and-feel/  # User install
   ls /usr/share/plasma/look-and-feel/      # System install
   ```

2. **Update KDE caches**:
   ```bash
   kbuildsycoca6  # KDE 6
   kbuildsycoca5  # KDE 5
   ```

3. **Restart Plasma**:
   ```bash
   kquitapp6 plasmashell; plasmashell &
   ```

### Magic Unicorn Dark Appears Light
This happens when the theme components aren't properly configured. Run:
```bash
uc-theme-switch
```
Select option 2 (Magic Unicorn Dark) to properly configure all components with the correct dark theme.

### Global Menu Not Working
1. **Ensure dependencies are installed**:
   ```bash
   sudo apt install plasma-widgets-addons qml-module-qtquick-controls2
   ```

2. **Re-apply Magic Unicorn theme**:
   ```bash
   uc-theme-switch
   ```
   Select option 1 or 2 (Magic Unicorn themes automatically enable global menu)

3. **Restart applications** to see global menu effects

### SDDM Theme Not Applied
SDDM themes require separate installation:
```bash
sudo ./install-sddm.sh
```

The installer creates backups and doesn't auto-restart SDDM for safety. To see changes:
```bash
sudo systemctl restart sddm    # OR reboot system
```

## Dependencies

### Automatic (with sudo installation)
- `plasma-widgets-addons` - For Application Dashboard
- `qml-module-qtquick-layouts` - For QML layouts
- `qml-module-qtquick-controls2` - For QML controls

### Manual Installation
If not using sudo, install these packages manually:
```bash
# Ubuntu/Debian
sudo apt install plasma-widgets-addons qml-module-qtquick-layouts qml-module-qtquick-controls2

# Arch Linux  
sudo pacman -S plasma-addons qt6-declarative

# Fedora
sudo dnf install plasma-workspace-addons qt6-qtdeclarative-devel
```

## File Structure After Installation

### User Installation
```
~/.local/share/
├── plasma/look-and-feel/
│   ├── MagicUnicorn-Dark/
│   ├── MagicUnicorn-Light/
│   └── UC-*/
├── icons/
│   ├── UnicornCommander-Icons/
│   └── Papirus-Unicorn/
└── wallpapers/
    ├── MagicUnicorn/
    └── UnicornCommander/

~/.local/bin/
├── uc-theme-switch
├── uc-theme-switch-global
└── uc-theme-install
```

### System Installation
```
/usr/share/
├── plasma/look-and-feel/
├── icons/
├── wallpapers/
└── sddm/themes/

/usr/local/bin/
├── uc-theme-switch
├── uc-theme-switch-global
└── uc-theme-install
```

## Advanced Configuration

### Custom Wallpapers
Place custom wallpapers in:
- User: `~/.local/share/wallpapers/MagicUnicorn/` or `~/.local/share/wallpapers/UnicornCommander/`  
- System: `/usr/share/wallpapers/MagicUnicorn/` or `/usr/share/wallpapers/UnicornCommander/`

### Custom Icons
The installer includes custom unicorn-themed icons. Additional icons can be added to:
- User: `~/.local/share/icons/UnicornCommander-Icons/`
- System: `/usr/share/icons/UnicornCommander-Icons/`

### Manual Theme Switching
```bash
# Apply theme directly (replace with actual theme ID)
lookandfeeltool --apply org.magicunicorn.dark

# Set wallpaper
plasma-apply-wallpaperimage /path/to/wallpaper.jpg

# Configure icons
kwriteconfig6 --file kdeglobals --group Icons --key Theme "Flat-Remix-Violet-Dark"
```

## Uninstallation

To remove Unicorn Commander themes:

### User Installation
```bash
rm -rf ~/.local/share/plasma/look-and-feel/MagicUnicorn-*
rm -rf ~/.local/share/plasma/look-and-feel/UC-*
rm -rf ~/.local/share/icons/UnicornCommander-Icons
rm -rf ~/.local/share/icons/Papirus-Unicorn
rm -rf ~/.local/share/wallpapers/MagicUnicorn
rm -rf ~/.local/share/wallpapers/UnicornCommander
rm ~/.local/bin/uc-theme-*
```

### System Installation
```bash
sudo rm -rf /usr/share/plasma/look-and-feel/MagicUnicorn-*
sudo rm -rf /usr/share/plasma/look-and-feel/UC-*
sudo rm -rf /usr/share/icons/UnicornCommander-Icons
sudo rm -rf /usr/share/icons/Papirus-Unicorn  
sudo rm -rf /usr/share/wallpapers/MagicUnicorn
sudo rm -rf /usr/share/wallpapers/UnicornCommander
sudo rm /usr/local/bin/uc-theme-*
sudo rm -rf /usr/share/sddm/themes/MagicUnicorn
sudo rm -rf /usr/share/sddm/themes/UnicornCommander
```

## Support

If you encounter issues:

1. **Check this README** for troubleshooting steps
2. **Verify all dependencies** are installed
3. **Try both installation modes** (user vs system)
4. **Test with a fresh user account** to isolate configuration issues
5. **Check KDE version compatibility** (themes work best with KDE 5.24+ or KDE 6.0+)

The installer is designed to be **idempotent** - you can run it multiple times safely to fix any issues.