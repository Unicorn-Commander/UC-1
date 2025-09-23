# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive KDE Plasma 6 theme repository containing four complete desktop themes with custom branding, layouts, and assets. The project creates both macOS-style and Windows-style desktop experiences with unicorn branding and advanced theming features.

## Key Commands

### Theme Installation and Management
```bash
# Main installation (system-wide)
sudo ./install.sh

# User installation only
./install.sh

# Theme switching (unified command)
uc-theme-switch-unified.sh

# SDDM login theme installation
sudo ./install-sddm.sh

# Theme building and packaging
./scripts/build-themes.sh
./scripts/install-themes.sh
```

### KDE6 Global Theme Commands
```bash
# Install theme manually using kpackagetool6
kpackagetool6 --type "Plasma/LookAndFeel" --install /path/to/theme

# List installed themes
kpackagetool6 --type "Plasma/LookAndFeel" --list

# Remove theme
kpackagetool6 --type "Plasma/LookAndFeel" --remove theme-id

# Apply theme via command line
lookandfeeltool --apply theme-id

# Refresh KDE cache after changes
kbuildsycoca6
```

### Panel Configuration Commands (Critical for macOS Dock)
```bash
# Get panel containment ID
PANEL_ID=$(grep -B 5 "location=4" ~/.config/plasma-org.kde.plasma.desktop-appletsrc | grep "Containments" | grep -v "Applets" | head -1 | sed 's/.*\[\([0-9]*\)\].*/\1/')

# Configure authentic macOS dock (fit-to-content)
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "lengthMode" "1"
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "alignment" "132"
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "floating" "true"

# Restart plasmashell to apply config changes
killall plasmashell && sleep 3 && plasmashell > /dev/null 2>&1 &
```

### Debugging and Testing
```bash
# Test SDDM theme
sudo sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/UnicornCommander

# Debug panel configuration
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    print('Panel ' + i + ': location=' + panel.location + ', lengthMode=' + panel.lengthMode);
}"

# Check theme availability
lookandfeeltool --list | grep -i unicorn
```

## Architecture Overview

### Theme Structure
The repository contains four main themes:
- **MagicUnicorn-Light/Dark**: macOS-style with top menu bar + floating dock
- **UnicornCommander-Light/Dark**: Windows-style with single bottom taskbar

Each theme includes:
- `metadata.json` - KDE6-compatible theme metadata
- `manifest.json` - Required for KDE6 global theme recognition
- `contents/` directory with layouts, splash screens, color schemes, and UI components

### Critical KDE6 Requirements
1. **manifest.json** must contain `"KPackageStructure": "Plasma/LookAndFeel"`
2. **metadata.json** must follow KDE6 format with KPlugin structure
3. **X-Plasma-API**: "5.0" (compatibility mode for Plasma 6)

### Panel Management System
The most complex aspect of this codebase is the panel management system that creates theme-specific layouts:

#### macOS-Style (Magic Unicorn themes)
- Top panel: app menu, spacer, system tray, clock
- Bottom dock: only app icons + trash, fit-to-content sizing, floating, centered

#### Windows-Style (UnicornCommander themes)  
- Single bottom panel: start menu, tasks, system tray, clock, full-width

### Key Technical Challenges Solved

#### 1. Authentic macOS Dock Creation
The most difficult challenge was creating a dock that actually fits content (like real macOS) instead of spanning full screen:
- **lengthMode values differ**: Config files use "1" for fit-content, Plasma API uses "fit"
- **Widget contamination**: System widgets prevent proper sizing, must be removed
- **Restart requirement**: Config changes only apply after plasmashell restart
- **Hybrid approach**: Uses both kwriteconfig6 AND Plasma scripting API

#### 2. Theme-Specific Panel Management
KDE panels are global to the session, not theme-specific. The theme switcher actively manages panel creation/removal to maintain distinct layouts per theme.

### Asset Management
- **Wallpapers**: Multi-resolution support in `assets/wallpapers/`
- **Icons**: Custom unicorn branding in `assets/menu-button/` and icon themes
- **Color Schemes**: Four custom schemes (.colors files) with purple/violet accents

### Build System
- `scripts/build-themes.sh`: Creates color schemes and packages themes
- `scripts/install-themes.sh`: Installs to appropriate KDE directories
- Automatic dependency detection and installation

## Development Notes

### When working with panels:
- Always use `qdbus6` (not `qdbus`) for Plasma 6 compatibility
- Panel configuration requires understanding both config file and API methods
- Test panel changes by checking lengthMode value after applying
- Full plasmashell restart often required for layout changes

### When working with themes:
- All themes must have both metadata.json AND manifest.json
- Use `kpackagetool6` for theme installation testing
- Theme IDs should be consistent across metadata files
- Preview images should be added to contents/previews/

### When working with color schemes:
- Install to `~/.local/share/color-schemes/` for testing
- Use `plasma-apply-colorscheme SchemeName` to test application
- Color schemes are referenced by name in theme defaults

### Critical KDE6 Plasma Scripting Values:
- **lengthMode**: "fit" (API) vs "1" (config files) for auto-sizing dock
- **alignment**: "center" (API) vs "132" (config files) for center alignment
- **location**: "bottom" = 4, "top" = 3 in config files

## Testing Workflow

1. **Build themes**: `./scripts/build-themes.sh`
2. **Install themes**: `./scripts/install-themes.sh`
3. **Test switching**: `./uc-theme-switch-unified.sh`
4. **Verify panels**: Use debugging commands to check panel configuration
5. **Test SDDM**: Use sddm-greeter-qt6 test mode

## Important File Locations

### Development
- `themes/*/`: Source theme directories
- `scripts/`: Build and installation scripts
- `assets/`: Wallpapers, icons, and branding assets
- `configs/`: Layout configuration files

### Installed (User)
- `~/.local/share/plasma/look-and-feel/`: Global themes
- `~/.local/share/color-schemes/`: Color schemes
- `~/.local/share/wallpapers/`: Wallpapers
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc`: Panel configuration

### Installed (System)
- `/usr/share/plasma/look-and-feel/`: System-wide themes
- `/usr/share/sddm/themes/UnicornCommander/`: Login theme
- `/usr/local/bin/uc-theme-switch`: Theme switcher command