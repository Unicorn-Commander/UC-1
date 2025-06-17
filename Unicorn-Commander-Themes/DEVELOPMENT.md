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
```

#### ✅ manifest.json Structure (CRITICAL!)
```json
{
    "KPackageStructure": "Plasma/LookAndFeel",
    "KPlugin": {
        "Id": "org.themename.variant",
        "Name": "Theme Display Name",
        "Description": "Theme description",
        "Authors": [{"Name": "Author", "Email": "email@domain.com"}],
        "Version": "1.0",
        "License": "GPL-3.0",
        "Website": "https://website.com"
    },
    "X-Plasma-API": "6.0"
}
```

**IMPORTANT:** Without `manifest.json` containing `"KPackageStructure": "Plasma/LookAndFeel"`, the theme will NOT appear in KDE Settings > Global Theme!

### Theme Installation & Management

#### ✅ Theme Installation
```bash
# Install themes to user directory
cp -r theme-folder ~/.local/share/plasma/look-and-feel/theme-id

# List available themes
lookandfeeltool --list

# Apply theme
lookandfeeltool --apply theme-id
```

#### ✅ Color Scheme Management
```bash
# Install color schemes
cp *.colors ~/.local/share/color-schemes/

# Apply color scheme
plasma-apply-colorscheme SchemeName
```

#### ✅ Wallpaper Management
```bash
# Create wallpaper directories
mkdir -p ~/.local/share/wallpapers/ThemeName

# Apply wallpaper
plasma-apply-wallpaperimage /path/to/wallpaper.jpg
```

### Panel Configuration (The Key to Success!)

#### 🏆 **BREAKTHROUGH: Authentic macOS Dock Configuration**

**THE MOST CHALLENGING ASPECT** - Creating a proper macOS-style dock that actually fits content (like real macOS) instead of spanning the full screen was extremely difficult and required multiple approaches:

##### ✅ **The Complete Solution (All Steps Required!)**

**Step 1: Clean the Dock (Critical!)**
```bash
# Remove all non-app widgets from dock for authentic macOS experience
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    if (panel.location == 'bottom') {
        // Remove everything except icontasks (app icons)
        for (var j = 0; j < panel.widgetIds.length; j++) {
            var widget = panel.widgetById(panel.widgetIds[j]);
            if (widget && widget.type != 'org.kde.plasma.icontasks') {
                widget.remove(); // Remove kickoff, spacers, clock, system tray
            }
        }
        // Add only trash (like real macOS)
        panel.addWidget('org.kde.plasma.trash');
        break;
    }
}
"
```

**Step 2: Configure via Config Files (Essential!)**
```bash
# Get the dock containment ID
PANEL_ID=$(grep -B 5 "location=4" ~/.config/plasma-org.kde.plasma.desktop-appletsrc | grep "Containments" | grep -v "Applets" | head -1 | sed 's/.*\[\([0-9]*\)\].*/\1/')

# Use config file method for reliable fit-to-content (lengthMode="1")
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "lengthMode" "1"
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "alignment" "132" 
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "maxLength" ""
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "minLength" ""
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "panelSize" "0"
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group "Containments" --group "$PANEL_ID" --group "General" --key "floating" "true"
```

**Step 3: Force Full Restart (Required!)**
```bash
# CRITICAL: Full plasmashell restart needed to read config changes
killall plasmashell
sleep 3
plasmashell > /dev/null 2>&1 &
```

**Step 4: Final Touch (macOS Behavior)**
```bash
# Set hiding behavior after restart
sleep 5
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    if (panel.location == 'bottom') {
        panel.hiding = 'windowsgobelow';  // Authentic macOS behavior
        break;
    }
}
"
```

##### 🎯 **Success Indicators**
After applying all steps, verify with:
```bash
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    if (panel.location == 'bottom') {
        print('✅ macOS Dock Status:');
        print('  length: ' + panel.length + ' (should be ~400-600, not 2560!)');
        print('  lengthMode: ' + panel.lengthMode + ' (should be fit)');
        print('  alignment: ' + panel.alignment + ' (should be center)');
        print('  floating: ' + panel.floating + ' (should be true)');
        print('  widgets: ' + panel.widgetIds.length + ' (should be 2: icontasks + trash)');
        break;
    }
}
"
```

##### ⚠️ **Why This Was So Difficult**
1. **Scripting API vs Config Files**: Using only `panel.lengthMode = 'fit'` via scripting wasn't sufficient
2. **Widget Contamination**: System tray/clock/spacers prevent proper fit-to-content behavior  
3. **Restart Requirement**: Config changes only take effect after full plasmashell restart
4. **Multiple Bottom Panels**: System tray was creating separate bottom panel, confusing the layout
5. **Length Override**: Even with correct lengthMode, length was hardcoded to screen width

##### 🍎 **Result: Authentic macOS Dock**
- **Dynamic sizing**: Dock width changes based on number of apps (300-600px, not full screen)
- **Clean appearance**: Only app icons and trash, no system widgets
- **Proper behavior**: Windows slide under dock, exactly like macOS
- **Manual configuration works**: "Fit content" option now responds correctly

## 🏆 **BREAKTHROUGH: Theme-Specific Panel Management**

**THE SECOND MAJOR CHALLENGE** - Creating themes with different panel layouts that persist correctly when switching between themes.

### ⚠️ **The Problem Discovered**
KDE Plasma panels are **global to the desktop session**, not theme-specific. When you switch themes:
- All themes share the same panel configuration
- Layout files in themes don't automatically apply
- Manual panel changes affect all themes
- No built-in way to have different layouts per theme

### ✅ **The Complete Solution**

**Smart Theme Switcher with Panel Management**
```bash
apply_theme() {
    local theme_id="$1"
    
    # Apply Look and Feel theme first
    lookandfeeltool --apply "$theme_id"
    
    # Apply theme-specific panel configurations
    case "$theme_id" in
        *magicunicorn*)
            # Ensure macOS layout: top panel + bottom dock
            qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                var allPanels = panels();
                var hasTop = false;
                
                // Check and create top panel if missing
                for (var i = 0; i < allPanels.length; i++) {
                    if (allPanels[i].location == 'top') hasTop = true;
                }
                
                if (!hasTop) {
                    var topPanel = new Panel;
                    topPanel.location = 'top';
                    topPanel.height = 28;
                    topPanel.addWidget('org.kde.plasma.kickoff');
                    topPanel.addWidget('org.kde.plasma.appmenu');
                    topPanel.addWidget('org.kde.plasma.panelspacer');
                    topPanel.addWidget('org.kde.plasma.systemtray');
                    topPanel.addWidget('org.kde.plasma.digitalclock');
                }
                
                // Configure bottom dock
                for (var i = 0; i < allPanels.length; i++) {
                    var panel = allPanels[i];
                    if (panel.location == 'bottom') {
                        // Clean dock - remove non-app widgets
                        for (var j = 0; j < panel.widgetIds.length; j++) {
                            var widget = panel.widgetById(panel.widgetIds[j]);
                            if (widget && widget.type != 'org.kde.plasma.icontasks') {
                                widget.remove();
                            }
                        }
                        panel.addWidget('org.kde.plasma.trash');
                        
                        // Configure as macOS dock
                        panel.lengthMode = 'fit';
                        panel.alignment = 'center';
                        panel.floating = true;
                        panel.hiding = 'windowsgobelow';
                        panel.height = 60;
                        break;
                    }
                }
            "
            ;;
        *unicorncommander*)
            # Ensure Windows layout: single bottom taskbar
            qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                var allPanels = panels();
                var hasBottom = false;
                
                // Remove top panel (Windows has no top panel)
                for (var i = 0; i < allPanels.length; i++) {
                    var panel = allPanels[i];
                    if (panel.location == 'top') {
                        panel.remove();
                    } else if (panel.location == 'bottom') {
                        hasBottom = true;
                    }
                }
                
                // Create bottom panel if missing
                if (!hasBottom) {
                    var bottomPanel = new Panel;
                    bottomPanel.location = 'bottom';
                    bottomPanel.height = 48;
                    bottomPanel.addWidget('org.kde.plasma.kickoff');
                    bottomPanel.addWidget('org.kde.plasma.icontasks');
                    bottomPanel.addWidget('org.kde.plasma.systemtray');
                    bottomPanel.addWidget('org.kde.plasma.digitalclock');
                }
                
                // Configure as Windows taskbar
                for (var i = 0; i < allPanels.length; i++) {
                    var panel = allPanels[i];
                    if (panel.location == 'bottom') {
                        panel.lengthMode = 'fill';
                        panel.alignment = 'left';
                        panel.floating = false;
                        panel.hiding = 'none';
                        panel.height = 48;
                        break;
                    }
                }
            "
            ;;
    esac
}
```

### 🎯 **Result: True Theme-Specific Layouts**
- **Magic Unicorn**: Always gets macOS layout (top panel + centered dock)
- **UnicornCommander**: Always gets Windows layout (single full taskbar)
- **No cross-contamination**: Each theme maintains its distinct identity
- **Automatic management**: Theme switcher handles all panel logic
- **Persistent layouts**: Switching themes always applies correct panel configuration

#### ✅ Working Panel Creation
```bash
# Create panels using Plasma scripting API
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var topPanel = new Panel;
topPanel.location = 'top';
topPanel.height = 28;
topPanel.addWidget('org.kde.plasma.kickoff');
topPanel.addWidget('org.kde.plasma.appmenu');
topPanel.addWidget('org.kde.plasma.panelspacer');
topPanel.addWidget('org.kde.plasma.systemtray');
topPanel.addWidget('org.kde.plasma.digitalclock');
"
```

#### ✅ Critical Panel Configuration Values

**BREAKTHROUGH: The Magic of lengthMode='fit'**

There are TWO different ways to set the auto-sizing dock, depending on the method:

**Method 1: Configuration Files (kwriteconfig6)**
```bash
# Content-fit dock configuration via config files
kwriteconfig6 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc \
  --group "Containments" --group "PANEL-ID" --group "General" \
  --key "lengthMode" "1"           # 1 = Fit Content (numeric value!)
  --key "alignment" "132"          # 132 = Center alignment
  --key "floating" "true"          # Enable floating appearance
  --key "maxLength" ""             # Remove constraints
  --key "minLength" ""             # Remove constraints
  --key "panelSize" "0"            # Auto-size
```

**Method 2: Plasma Scripting API (qdbus6)**
```bash
# Content-fit dock configuration via Plasma API
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    if (panel.location == 'bottom') {
        panel.lengthMode = 'fit';        # 'fit' = Fit Content (string value!)
        panel.alignment = 'center';      # 'center' = Center alignment
        panel.floating = true;           # Boolean value
        panel.reloadConfig();
        break;
    }
}
"
```

**Panel lengthMode Values:**
- **Config Files**: `"0"` = Custom, `"1"` = FitContent ← **KEY!**, `"2"` = FillAvailable
- **Scripting API**: `"custom"` = Custom, `"fit"` = FitContent ← **KEY!**, `"fill"` = FillAvailable

#### ✅ Plasma Configuration Reload
```bash
# Reload panel configuration without restart
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var panels = panels(); 
for (var i = 0; i < panels.length; i++) { 
    panels[i].reloadConfig(); 
}"

# Restart plasmashell (when needed)
killall plasmashell && sleep 2 && nohup plasmashell > /dev/null 2>&1 &
```

### KWin Configuration

#### ✅ Window Effects
```bash
# Enable compositing and effects
kwriteconfig6 --file kwinrc --group Compositing --key Enabled true
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key slideEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key fadeEnabled true

# Apply changes
qdbus6 org.kde.KWin /KWin reconfigure
```

#### ✅ Window Decorations
```bash
# Set window decoration
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
```

### QML Development for Plasma 6

#### ✅ Correct QML Imports for Plasma 6
```qml
import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Effects                      // Qt 6 effects
import org.kde.plasma.core 2.0 as PlasmaCore  // Still version 2.0!
import org.kde.plasma.plasmoid              // Version-less import
```

#### ✅ Metadata Requirements
```json
{
    "X-Plasma-API-Minimum-Version": "6.0",
    "KPlugin": {
        "Id": "org.themename.variant",
        "Name": "Theme Display Name"
    }
}
```

### Layout Script Development

#### ✅ Working Layout Structure
```javascript
var layout = {
    "desktops": [...],
    "panels": [...]  // Note: UnicornCommander uses "panels" array
};

// Magic Unicorn dock configuration in layout
"/General": {
    "alignment": "132",
    "floating": "true", 
    "lengthMode": "1",
    "maxLength": "",
    "minLength": "",
    "panelSize": "0"
}
```

## Commands That DON'T Work (Avoid These!)

### ❌ Deprecated Qt5/KDE5 Commands
```bash
# DON'T USE - Qt5 versions
kquitapp5 plasmashell     # Use: kquitapp6 plasmashell
kstart5 plasmashell       # Use: kstart6 plasmashell  
qdbus                     # Use: qdbus6

# DON'T USE - Old KDE5 tools
plasma-apply-colorscheme --kde4-config  # Obsolete flag
```

### ❌ X11-Specific Commands (We Use Wayland)
```bash
# DON'T USE - X11 tools don't work on Wayland
xrandr                    # Use: kscreen-doctor
setxkbmap                 # Use: KDE's keyboard settings
xset                      # Use: KDE power management
```

### ❌ Ineffective Panel Methods
```bash
# DON'T USE - Layout files alone don't create panels reliably
# Theme layout files work for configuration but not panel creation

# DON'T USE - Direct config file editing without reload
# Always use kwriteconfig6 + reloadConfig() or restart plasmashell
```

### ❌ Problematic Scripting Patterns
```javascript
// DON'T USE - These Panel enum values don't work in scripts
panel.lengthMode = Panel.FitContent;     // Causes errors
panel.alignment = Panel.Center;          // Use string values instead

// DON'T USE - Wrong string values in scripting API
panel.lengthMode = "1";                  // Doesn't work in scripting API!
panel.writeConfig('lengthMode', '1');    // Config file method only

// USE INSTEAD - Correct values for each method
// For Plasma Scripting API:
panel.lengthMode = "fit";                // ← CORRECT for API!
panel.alignment = "center";              // Works reliably

// For Configuration Files:
kwriteconfig6 --key "lengthMode" "1"     // ← CORRECT for config files!
```

**CRITICAL LESSON:** The lengthMode values are different between scripting API and config files:
- **Scripting API**: Use `"fit"` for auto-sizing
- **Config Files**: Use `"1"` for auto-sizing

## Development Workflow

### 1. Theme Development Process
1. **Create theme structure** in `~/UC-1/KDE-Themes/themes/`
2. **Test locally** by copying to `~/.local/share/plasma/look-and-feel/`
3. **Verify with** `lookandfeeltool --list`
4. **Apply and test** with `lookandfeeltool --apply theme-id`
5. **Debug panels** using `qdbus6` scripting
6. **Update theme-switcher** script accordingly

### 2. Panel Debugging
```bash
# Check current panels
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    print('Panel ' + i + ': location=' + panel.location + 
          ', floating=' + panel.floating + 
          ', lengthMode=' + panel.lengthMode);
}"

# Find panel containment IDs
grep -n "location=4" ~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

### 3. Asset Management
```bash
# Proper asset installation
mkdir -p ~/.local/share/wallpapers/ThemeName
mkdir -p ~/.local/share/icons/ThemeName
cp assets/* ~/.local/share/wallpapers/ThemeName/
```

## Key Lessons Learned

### Critical Success Factors
1. **SDDM Theme Requirements**: Must include `QtVersion=6` in metadata.desktop and use Qt6-compatible QML imports.
2. **manifest.json Required**: Global themes MUST have manifest.json with "KPackageStructure": "Plasma/LookAndFeel" to appear in KDE Settings.
3. **Panel Creation**: Layout files configure panels but don't reliably create them. Use Plasma scripting API.
4. **lengthMode Values**: Different values for different methods:
   - **Scripting API**: `panel.lengthMode = 'fit'` for auto-sizing dock
   - **Config Files**: `kwriteconfig6 --key "lengthMode" "1"` for auto-sizing dock
5. **Wayland Compatibility**: Ensure all commands work with Wayland (use qdbus6, not qdbus).
6. **Asset Paths**: Use `~/.local/share/` paths, not project directories.
7. **Configuration Reload**: Always reload config or restart plasmashell after changes.
8. **🏆 MOST CRITICAL**: **Authentic macOS Dock Creation** - Widget contamination, config file + scripting hybrid approach, and full restart requirements.
9. **🏆 SECOND MOST CRITICAL**: **Theme-Specific Panel Management** - KDE panels are global, requiring intelligent theme switcher to manage different layouts per theme.

### Critical Breakthroughs
1. **🏆 Authentic macOS Dock**: The most challenging breakthrough - creating a dock that actually fits content like real macOS (documented in detail above)
2. **🏆 Theme-Specific Panel Management**: Second most challenging - solving KDE's global panel limitation to enable distinct layouts per theme
3. **SDDM Qt6 Compatibility**: Created professional login theme using Qt6-compatible QML with cosmic branding.
4. **manifest.json Discovery**: Without this file, themes don't appear in Global Theme settings.
5. **lengthMode='fit' vs '1'**: The GUI sets lengthMode to 'fit', but config files use '1'.
6. **Widget Contamination Prevention**: Discovered that system widgets prevent proper dock sizing.
7. **Panel Global Nature Discovery**: Realized KDE panels are session-global, not theme-specific.
8. **Intelligent Theme Switcher**: Enhanced script that actively manages panel creation/removal per theme type.

### Updated Theme Switcher Implementation
The `uc-theme-switch` script now incorporates the macOS dock breakthrough:

```bash
# The script now uses the complete solution for Magic Unicorn themes:
# 1. Detects panel containment ID dynamically
# 2. Uses config file method for reliable fit-to-content
# 3. Cleans dock widgets to only app icons + trash
# 4. Forces proper restart sequence
# 5. Distinguishes between macOS (2 panels) and Windows (1 panel) layouts
```

This ensures every theme switch results in authentic desktop experiences.

### Common Pitfalls
1. **SDDM Qt Version**: Missing `QtVersion=6` in metadata.desktop breaks compatibility.
2. **Missing manifest.json**: Desktop themes won't appear in KDE Settings without this file.
3. **Wrong lengthMode Values**: Using '1' in scripting API or 'fit' in config files won't work.
4. **Layout Files**: Don't rely solely on layout files for panel creation.
5. **Old Qt5 Tools**: Many online tutorials reference Qt5/KDE5 commands that don't work.
6. **X11 Dependencies**: Avoid X11-specific tools when targeting Wayland.
7. **Hardcoded Paths**: Use relative paths and proper asset installation.
8. **Panel Enums**: Use string/numeric values in scripts, not enum constants.

## Testing Commands

### Comprehensive Theme Test
```bash
# Test complete experience
uc-theme-switch                       # All-in-one theme manager

# Test SDDM theme
sudo sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/UnicornCommander

# Verify panel configuration  
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var panels = panels();
print('Found ' + panels.length + ' panels');
for (var i = 0; i < panels.length; i++) {
    print('Panel ' + i + ': ' + panels[i].location);
}"

# Check wallpaper
grep "Image=" ~/.config/plasma-org.kde.plasma.desktop-appletsrc

# Verify color scheme
plasma-apply-colorscheme --list-schemes | grep UC
```

## Future Development Notes

- **SDDM Evolution**: Monitor SDDM updates for new theming capabilities
- **Plasma 6.x**: Continue using Qt 6.2+ imports for all components
- **Wayland Focus**: Ensure all new features work with Wayland
- **Panel API**: Monitor KDE development for panel configuration improvements
- **Complete Experience**: Maintain integration between login and desktop themes
- **Asset Management**: Consider packaging assets with themes for distribution

## Useful Resources

- [KDE Plasma 6 Porting Guide](https://develop.kde.org/docs/plasma/theme/theme-porting-to-plasma6/)
- [Plasma Scripting API](https://develop.kde.org/docs/plasma/scripting/)
- [Qt 6 QML Documentation](https://doc.qt.io/qt-6/qmlapplications.html)