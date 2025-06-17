# UnicornCommander SDDM Theme

Professional Windows 11 inspired login theme with modern design and Qt6 compatibility for KDE Plasma 6.

## Features

✨ **Windows 11 Visual Experience**
- Stunning cosmic wallpaper background
- Animated particle effects
- Smooth animations and transitions
- Windows 11 inspired color scheme with Microsoft Blue accents

🎨 **Modern Design**
- Clean, minimal Windows 11 style interface
- Subtle shadows and modern borders
- Professional button styling
- Consistent Windows 11 design language

🔧 **Technical Excellence**
- Qt6 compatible QML code
- Proper SDDM integration
- Support for all display resolutions
- Keyboard navigation support
- Session selection
- Power actions (reboot/shutdown)

## Installation

### Automatic Installation (Recommended)
```bash
cd /path/to/sddm-theme/
sudo ./install-sddm-theme.sh
```

### Manual Installation
```bash
# Copy theme files
sudo cp -r UnicornCommander /usr/share/sddm/themes/

# Set permissions
sudo chown -R root:root /usr/share/sddm/themes/UnicornCommander
sudo chmod -R 755 /usr/share/sddm/themes/UnicornCommander

# Configure SDDM
echo "[Theme]" | sudo tee /etc/sddm.conf.d/kde_settings.conf
echo "Current=UnicornCommander" | sudo tee -a /etc/sddm.conf.d/kde_settings.conf

# Restart SDDM
sudo systemctl restart sddm
```

## Testing

Test the theme without logging out:
```bash
sudo sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/UnicornCommander
```

## Customization

### Colors
Edit `theme.conf` to customize the color scheme:
```ini
[Colors]
primaryColor=#0078d4      # Windows 11 blue accent
secondaryColor=#106ebe    # Secondary blue
backgroundColor=#202020   # Dark background
textColor=#ffffff         # Text color
accentColor=#0078d4       # Accent color for focus states
```

### Background
Replace `backgrounds/unicorn-commander-bg.jpg` with your own wallpaper.

### Logo
Replace `assets/unicorn-logo.png` with your custom logo.

## File Structure

```
UnicornCommander/
├── Main.qml                 # Main theme interface
├── metadata.desktop         # Theme metadata
├── theme.conf              # Theme configuration
├── components/             # Reusable QML components
│   ├── Button.qml
│   └── InputField.qml
├── backgrounds/            # Wallpaper images
│   └── unicorn-commander-bg.jpg
└── assets/                 # Icons and logos
    └── unicorn-logo.svg
```

## Compatibility

- **Qt Version**: 6.2+
- **KDE Plasma**: 6.0+
- **SDDM**: 0.19+
- **Display Servers**: Wayland, X11

## Troubleshooting

### Theme not appearing
- Check permissions: `ls -la /usr/share/sddm/themes/UnicornCommander`
- Verify config: `cat /etc/sddm.conf.d/kde_settings.conf`

### Test mode fails
- Install Qt6 QML modules: `sudo apt install qml6-module-*`
- Check SDDM version: `sddm --version`

### Login issues
- Check SDDM logs: `journalctl -u sddm`
- Reset to default: `sudo rm /etc/sddm.conf.d/kde_settings.conf`

## Development

This theme uses modern Qt6 QML with:
- QtQuick 2.15
- QtQuick.Controls 2.15
- Qt5Compat.GraphicalEffects
- SddmComponents 2.0

## License

GPL-3.0 - Same as KDE Plasma

## Credits

Created by the UnicornCommander Team as part of the professional KDE Plasma 6 theme collection.