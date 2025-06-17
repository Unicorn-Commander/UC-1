# Installation Guide - UnicornCommander KDE Themes

## Prerequisites

### System Requirements
- **Operating System**: Ubuntu Server 25.04 or compatible Linux distribution
- **Desktop Environment**: KDE Plasma 6.3.4 or newer
- **Qt Framework**: Qt 6.8.3 or newer
- **Display Server**: Wayland (recommended) or X11
- **Memory**: Minimum 4GB RAM, 8GB recommended
- **Storage**: 200MB free space for complete installation

### Required Packages
Install dependencies before proceeding:

```bash
# Update package lists
sudo apt update

# Install KDE Plasma and development tools
sudo apt install plasma-desktop plasma-workspace kpackagetool6 kbuildsycoca6

# Optional: Additional KDE applications
sudo apt install dolphin konsole kate firefox
```

## Installation Methods

### Method 1: Automated Installation (Recommended)

1. **Navigate to project directory:**
   ```bash
   cd /home/ucadmin/UC-1/KDE-Themes
   ```

2. **Build all theme variants:**
   ```bash
   ./scripts/build-themes.sh
   ```
   
   Expected output:
   ```
   === UnicornCommander KDE Theme Builder ===
   Project directory: /home/ucadmin/UC-1/KDE-Themes
   Creating color schemes...
   Building theme packages...
   Building UC-Mac-Light...
   Building UC-Mac-Dark...
   Building UC-Windows-Light...
   Building UC-Windows-Dark...
   === Build Complete ===
   ```

3. **Install themes to your system:**
   ```bash
   ./scripts/install-themes.sh
   ```
   
   Expected output:
   ```
   === UnicornCommander KDE Theme Installer ===
   Installing color schemes...
   Installing look-and-feel themes...
   Installing UC-Mac-Light...
   Installing UC-Mac-Dark...
   Installing UC-Windows-Light...
   Installing UC-Windows-Dark...
   Installing wallpapers...
   Refreshing KDE cache...
   === Installation Complete ===
   ```

### Method 2: Manual Installation

If you prefer manual control over the installation process:

1. **Build themes manually:**
   ```bash
   cd /home/ucadmin/UC-1/KDE-Themes
   
   # Create build directory
   mkdir -p build/{color-schemes,look-and-feel}
   
   # Copy theme directories
   cp -r themes/* build/look-and-feel/
   
   # Copy color schemes (if you have custom ones)
   cp *.colors build/color-schemes/ 2>/dev/null || true
   ```

2. **Install color schemes:**
   ```bash
   mkdir -p ~/.local/share/color-schemes
   cp build/color-schemes/*.colors ~/.local/share/color-schemes/
   ```

3. **Install global themes:**
   ```bash
   mkdir -p ~/.local/share/plasma/look-and-feel
   cp -r build/look-and-feel/* ~/.local/share/plasma/look-and-feel/
   ```

4. **Install wallpapers:**
   ```bash
   mkdir -p ~/.local/share/wallpapers/UnicornCommander
   cp assets/wallpapers/* ~/.local/share/wallpapers/UnicornCommander/
   ```

5. **Refresh KDE cache:**
   ```bash
   kbuildsycoca6 --noincremental
   ```

## Post-Installation Setup

### Applying Themes

#### Via System Settings (GUI Method)
1. **Open System Settings:**
   ```bash
   systemsettings
   ```

2. **Navigate to Global Theme:**
   - Click **Appearance** in the left sidebar
   - Select **Global Theme**

3. **Choose UnicornCommander Theme:**
   - Look for themes starting with "UnicornCommander"
   - Available options:
     - UnicornCommander Mac Light
     - UnicornCommander Mac Dark
     - UnicornCommander Windows Light
     - UnicornCommander Windows Dark

4. **Apply Theme:**
   - Click on your preferred theme
   - Click **Apply** button
   - Confirm any prompts
   - **For Mac Dark theme**: UCMacDark color scheme will be automatically applied

#### Via Command Line (Advanced Users)
```bash
# Apply Mac Light theme
lookandfeeltool --apply org.unicorncommander.mac.light

# Apply Mac Dark theme  
lookandfeeltool --apply org.unicorncommander.mac.dark

# Apply Windows Light theme
lookandfeeltool --apply org.unicorncommander.windows.light

# Apply Windows Dark theme
lookandfeeltool --apply org.unicorncommander.windows.dark
```

### Complete Theme Activation

1. **Log out and back in:**
   - Click on user menu (top-right corner)
   - Select **Log Out**
   - Log back in with your credentials

2. **Verify installation:**
   - **Mac Layout**: Thin top panel (unicorn + global menu → clock + system tray) + centered floating dock
   - **Windows Layout**: Single bottom taskbar with all controls
   - Verify UnicornCommander wallpaper is applied
   - Confirm unicorn logo appears as application launcher (from `~/UC-1/assets/unicorn.svg`)

## Verification Steps

### Check Installation Paths
```bash
# Verify global themes are installed
ls ~/.local/share/plasma/look-and-feel/ | grep UC-

# Verify color schemes are installed  
ls ~/.local/share/color-schemes/ | grep UCMac

# Verify wallpapers are installed
ls ~/.local/share/wallpapers/UnicornCommander/
```

Expected output:
```
UC-Mac-Dark
UC-Mac-Light
UC-Windows-Dark
UC-Windows-Light

UCMacDark.colors
UCMacLight.colors

unicorncommander_1080x1920.jpg
unicorncommander_1366x768.jpg
[... additional wallpaper files ...]
```

### Test Theme Switching
1. Open System Settings → Appearance → Global Theme
2. Switch between different UnicornCommander variants
3. Verify each theme applies correctly
4. Check that panel layouts change appropriately

## Troubleshooting Installation Issues

### Theme Not Appearing in System Settings

**Problem**: UnicornCommander themes don't show up in Global Theme list

**Solutions**:
```bash
# Refresh KDE services database
kbuildsycoca6 --noincremental

# Check file permissions
chmod -R 644 ~/.local/share/plasma/look-and-feel/UC-*
find ~/.local/share/plasma/look-and-feel/UC-* -type d -exec chmod 755 {} \;

# Restart system settings
killall systemsettings5 systemsettings
```

### Build Script Fails

**Problem**: `./scripts/build-themes.sh` returns errors

**Solutions**:
```bash
# Check script permissions
chmod +x scripts/*.sh

# Verify you're in correct directory
pwd
# Should output: /home/ucadmin/UC-1/KDE-Themes

# Check for required files
ls themes/ assets/ configs/

# Run with debug output
bash -x scripts/build-themes.sh
```

### Installation Script Fails

**Problem**: `./scripts/install-themes.sh` encounters permission errors

**Solutions**:
```bash
# Ensure user directories exist
mkdir -p ~/.local/share/{plasma/look-and-feel,color-schemes,wallpapers}

# Check disk space
df -h ~/.local/

# Run installation manually (see Method 2 above)
```

### Wallpapers Not Loading

**Problem**: UnicornCommander wallpapers don't appear or load

**Solutions**:
```bash
# Verify wallpaper files exist
ls -la ~/.local/share/wallpapers/UnicornCommander/

# Check file permissions
chmod 644 ~/.local/share/wallpapers/UnicornCommander/*

# Manually set wallpaper
plasma-apply-wallpaperimage ~/.local/share/wallpapers/UnicornCommander/unicorncommander_1920x1080.jpg
```

### Panel Layout Issues

**Problem**: Panels don't match expected layout after theme application

**Solutions**:
```bash
# Reset panel configuration
rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc

# Restart Plasma shell
killall plasmashell && plasmashell &

# Reapply theme via System Settings
```

## Advanced Configuration

### Custom Installation Paths

For system-wide installation (requires root access):
```bash
# Install to system directories (all users)
sudo mkdir -p /usr/share/plasma/look-and-feel
sudo cp -r build/look-and-feel/* /usr/share/plasma/look-and-feel/

sudo mkdir -p /usr/share/color-schemes  
sudo cp build/color-schemes/*.colors /usr/share/color-schemes/

# Refresh system cache
sudo kbuildsycoca6 --noincremental
```

### Selective Installation

Install only specific theme variants:
```bash
# Install only Mac themes
cp -r build/look-and-feel/UC-Mac-* ~/.local/share/plasma/look-and-feel/

# Install only dark themes
cp -r build/look-and-feel/*Dark ~/.local/share/plasma/look-and-feel/
```

## Uninstallation

### Complete Removal
```bash
# Remove all UnicornCommander themes
rm -rf ~/.local/share/plasma/look-and-feel/UC-*

# Remove color schemes
rm ~/.local/share/color-schemes/UCMac*.colors

# Remove wallpapers
rm -rf ~/.local/share/wallpapers/UnicornCommander/

# Refresh cache
kbuildsycoca6 --noincremental

# Reset to default theme
lookandfeeltool --apply org.kde.breeze.desktop
```

### Backup Before Uninstall
```bash
# Create backup
mkdir -p ~/uc-theme-backup
cp -r ~/.local/share/plasma/look-and-feel/UC-* ~/uc-theme-backup/
cp ~/.local/share/color-schemes/UCMac*.colors ~/uc-theme-backup/

# To restore later:
# cp -r ~/uc-theme-backup/* ~/.local/share/plasma/look-and-feel/
```

## Next Steps

After successful installation:

1. **Read the User Guide**: See `USER-GUIDE.md` for usage instructions
2. **Explore Customization**: Check `DEVELOPMENT.md` for advanced configuration
3. **Test Different Layouts**: Try all four theme variants to find your preference
4. **Configure Applications**: Set up your favorite applications to launch from the dock/taskbar

---

**Installation Support**: If you encounter issues not covered here, check the log files mentioned in USER-GUIDE.md or refer to DEVELOPMENT.md for technical details.