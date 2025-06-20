# 🦄 Unicorn Commander Themes

**Beautiful, self-contained KDE Plasma themes with macOS and Windows-style layouts, featuring custom unicorn branding and advanced theming features.**

![Unicorn Commander Theme Preview](assets/wallpapers/unicorncommander_1920x1080.jpg)

## ✨ Features

### 🎨 **Four Complete Themes**
- **Magic Unicorn Light** ☀️ - macOS-inspired with top menu bar + bottom dock
- **Magic Unicorn Dark** 🌙 - macOS-inspired with top menu bar + bottom dock  
- **UnicornCommander Light** 🪟 - Windows-inspired with standard bottom taskbar
- **UnicornCommander Dark** 🌚 - Windows-inspired with standard bottom taskbar

### 🦄 **Unique Features**
- **Unicorn logo integration** in start menu buttons
- **Rainbow application dashboard** for quick app access
- **Two distinct layout styles** (macOS vs Windows-inspired)
- **Custom wallpapers** optimized for multiple resolutions
- **Coordinated color schemes** with purple and violet accents
- **Self-contained design** - no missing files or dependencies

### 🖥️ **Layout Styles**

#### Magic Unicorn Themes (macOS-inspired)
- Top menu bar with app menu integration
- Bottom dock with centered app icons and auto-hide
- Floating dock style with magnification effects
- Rainbow application dashboard launcher
- Unicorn logo on dock launcher

#### UnicornCommander Themes (Windows-inspired)  
- Single bottom taskbar using standard KDE panel size
- Start menu with unicorn logo (Kickoff widget)
- Task manager for open applications
- Rainbow application dashboard button
- System tray with notifications, sound, network controls
- Digital clock with date display
- Show desktop button

## 🚀 Quick Start

### **1. Install Desktop Themes**
```bash
cd Unicorn-Commander-Themes
sudo ./install.sh                    # System-wide (recommended)
# OR
./install.sh                         # User-only install
```

### **2. Apply Themes**

**Option 1: Terminal Command (Full Automation)**
```bash
uc-theme-switch                      # Unified theme switcher with complete setup
```

**Option 2: System Settings (Native KDE Integration)**
```
System Settings > Appearance > Global Theme
⚠️ IMPORTANT: Check "Use desktop layout from theme"
```

### **3. Install Login Themes (Optional)**
```bash
sudo ./install-sddm.sh              # Separate SDDM installer with safety features
```

## 📋 What Gets Installed

### Desktop Themes
- ✅ 4 complete Look and Feel themes with preview images
- ✅ Custom color schemes (UCMacDark, UCMacLight, etc.)
- ✅ Custom plasma themes with proper naming
- ✅ High-resolution wallpapers for all screen sizes
- ✅ Unified theme switching command

### System Integration  
- ✅ All required KDE/QML dependencies
- ✅ Self-contained assets (no external file dependencies)
- ✅ Proper system paths (works on any computer)
- ✅ Desktop integration and preview support

## 🎯 Usage

### Theme Switching
```bash
uc-theme-switch                      # Interactive menu with 4 options
```

**Available Options:**
1. **Magic Unicorn Light** - Enables macOS global menu + light theme
2. **Magic Unicorn Dark** - Enables macOS global menu + dark theme  
3. **UnicornCommander Light** - Windows layout + light theme
4. **UnicornCommander Dark** - Windows layout + dark theme

### GUI Method (System Settings)
1. Open **System Settings**
2. Go to **Appearance** > **Global Theme**
3. Select any Unicorn Commander theme
4. **⚠️ IMPORTANT:** Check **"Use desktop layout from theme"**
5. Click **Apply**

> **Note:** The "Use desktop layout from theme" option is crucial for getting:
> - Custom panel layouts (Windows vs macOS-inspired)
> - Unicorn logo on start buttons
> - Rainbow application launcher
> - Proper system tray positioning

### Features Per Theme

| Theme | Layout | Panel Style | Key Features | Colors |
|-------|--------|-------------|-------------|---------|
| Magic Unicorn Light | macOS-inspired | Top menu + floating dock | Global menu, auto-hide dock | Light + Purple |
| Magic Unicorn Dark | macOS-inspired | Top menu + floating dock | Global menu, auto-hide dock | Dark + Purple |
| UnicornCommander Light | Windows-inspired | Standard bottom taskbar | System tray, rainbow launcher | Light + Violet |
| UnicornCommander Dark | Windows-inspired | Standard bottom taskbar | System tray, rainbow launcher | Dark + Violet |

## 🛠️ Technical Details

### Self-Contained Design
- **No hardcoded paths** - works on any system
- **Embedded assets** - all icons and images included in themes
- **Standard system paths** - follows KDE conventions
- **Cross-platform compatibility** - portable between systems

### Dependencies
All dependencies are automatically installed:
- `plasma-widgets-addons` - Application Dashboard support
- `qml-module-qtquick-*` - QML interface components
- `kwin-addons` - Window effects and features

### File Locations (System Install)
```
/usr/share/plasma/look-and-feel/     # Theme definitions
/usr/share/color-schemes/            # Custom color schemes  
/usr/share/wallpapers/               # Wallpaper collections
/usr/share/plasma/desktoptheme/      # Custom plasma themes
/usr/local/bin/uc-theme-switch       # Theme switcher command
```

## 🔧 Advanced Features

### macOS Global Menu
Magic Unicorn themes automatically enable:
- Application menus in top menu bar
- App name display in menu bar
- System-wide menu integration
- Proper menu hiding/showing

### Custom Plasma Theme
- **Magic Unicorn Dark** uses custom plasma theme with purple accents
- Proper theme naming in System Settings
- Coordinated color schemes across all components

### Multi-Resolution Support
Wallpapers included for:
- 1920x1080, 2560x1440, 3840x2160 (4K)
- 3440x1440 (Ultrawide), 5120x2880 (5K)
- 7680x4320 (8K), and many more

## 🔐 SDDM Login Themes

### Separate Installation
```bash
sudo ./install-sddm.sh              # Safe installer with backups
```

### Features
- **UnicornCommander Universal** - Works with any resolution
- **Same wallpaper** as desktop themes
- **Unicorn logo** prominently displayed  
- **Dark theme** with purple accents
- **Automatic backups** of existing config
- **Recovery script** included for safety

### Safety Features
- Backs up existing SDDM configuration
- Creates recovery script automatically
- No automatic restart (manual reboot recommended)
- Works independently from desktop themes

## 📚 Documentation

- **[INSTALLER-README.md](INSTALLER-README.md)** - Detailed installation guide
- **[DEPENDENCIES.md](DEPENDENCIES.md)** - Complete dependency information
- **[USER-GUIDE.md](USER-GUIDE.md)** - Comprehensive usage guide

## 🆘 Troubleshooting

### Themes Not Showing
```bash
kbuildsycoca6                        # Rebuild KDE cache
# OR restart KDE: kquitapp6 plasmashell; plasmashell &
```

### Command Not Found
```bash
# User install - add to PATH:
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Dark Theme Appears Light
```bash
uc-theme-switch                     # Re-apply theme to fix configuration
```

### SDDM Login Issues
```bash
sudo /root/sddm-recovery-*.sh       # Run auto-generated recovery script
# OR manually reset:
sudo sed -i 's/^Current=/#Current=/' /etc/sddm.conf.d/kde_settings.conf
sudo systemctl restart sddm
```

## 🌟 What Makes This Special

- **🎨 Four distinct themes** covering both macOS and Windows workflows
- **🦄 Unique unicorn branding** with custom logos and rainbow elements
- **🔧 Self-contained design** - no missing files or broken references
- **📱 Modern features** like global menu and dynamic layouts
- **🛡️ Safe installation** with backups and recovery options
- **📏 Multi-resolution support** for any screen size
- **⚡ One-command switching** between all themes

## 🚀 Perfect For

- **KDE enthusiasts** wanting unique, polished themes
- **macOS users** transitioning to Linux (Magic Unicorn themes)
- **Windows users** who want familiar layouts (UnicornCommander themes)
- **System administrators** deploying consistent themes across multiple machines
- **Anyone** who wants beautiful, functional themes that "just work"

## 📄 License

GPL-3.0 License - Free to use, modify, and distribute.

---

*Created with ❤️ by the UnicornCommander Team*

🦄 **Ready to transform your desktop? Run `sudo ./install.sh` and `uc-theme-switch` to get started!** 🦄