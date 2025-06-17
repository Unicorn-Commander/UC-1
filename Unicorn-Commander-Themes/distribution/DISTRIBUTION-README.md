# Magic Unicorn Theme - Distribution Package

## 🦄 Complete KDE Theme Distribution

This distribution contains **production-ready Magic Unicorn themes** that can be installed both via KDE GUI and CLI tools.

## 📦 Package Contents

### `/packages/` - Ready-to-distribute files
- **`MagicUnicorn-Light-2.0.tar.gz`** - GUI-importable Light theme
- **`MagicUnicorn-Dark-2.0.tar.gz`** - GUI-importable Dark theme  
- **`MagicUnicorn-Complete-2.0.tar.gz`** - Complete package with all features
- **`README.md`** - Distribution instructions

### Individual Components
- **`MagicUnicorn-Light/`** - Light theme source
- **`MagicUnicorn-Dark/`** - Dark theme source
- **`scripts/`** - CLI theme switcher tools
- **`sddm-theme/`** - Login screen themes
- **`install-magic-unicorn.sh`** - Complete installer script

## 🚀 Distribution Methods

### Method 1: KDE GUI Import (Basic Themes)
**Best for:** Users who want basic themes through KDE's built-in installer

1. **Download:** `MagicUnicorn-Light-2.0.tar.gz` or `MagicUnicorn-Dark-2.0.tar.gz`
2. **Install via GUI:**
   - Open System Settings > Appearance > Global Theme
   - Click "Get New Global Themes"
   - Click "Install from File"
   - Select the downloaded .tar.gz file
   - Apply the theme

**Features included:** Basic KDE Look and Feel theme only

### Method 2: Complete Installation (Recommended)
**Best for:** Users who want all features including CLI tools, global menu, etc.

1. **Download:** `MagicUnicorn-Complete-2.0.tar.gz`
2. **Extract:** `tar -xzf MagicUnicorn-Complete-2.0.tar.gz`
3. **Install:** `cd MagicUnicorn-Complete-2.0 && sudo ./install-magic-unicorn.sh`
4. **Use:** `uc-theme-switch`

**Features included:** Everything (see feature comparison below)

### Method 3: CLI Installation (for packaged systems)
**Best for:** Package maintainers and system administrators

```bash
# Install individual theme via kpackagetool6
kpackagetool6 --type=Plasma/LookAndFeel --install MagicUnicorn-Light-2.0.tar.gz

# Apply theme via lookandfeeltool
lookandfeeltool --apply org.magicunicorn.light
```

## 🎨 Feature Comparison

| Feature | GUI Import | Complete Install | CLI Only |
|---------|------------|------------------|----------|
| **Basic KDE Theme** | ✅ | ✅ | ✅ |
| **Unicorn Logo in Menu** | ❌ | ✅ | ✅ |
| **Rainbow App Launcher** | ❌ | ✅ | ✅ |
| **macOS Global Menu** | ❌ | ✅ | ✅ |
| **CLI Theme Switcher** | ❌ | ✅ | ✅ |
| **SDDM Login Themes** | ❌ | ✅ | ❌ |
| **Flat-Remix-Violet Icons** | ❌ | ✅ | ❌ |
| **Application Dashboard** | ❌ | ✅ | ✅ |

## 🛠️ Technical Details

### Theme IDs
- **Light:** `org.magicunicorn.light`
- **Dark:** `org.magicunicorn.dark`

### CLI Commands (after complete install)
```bash
# Interactive theme switcher
uc-theme-switch

# Enhanced switcher with global menu
uc-theme-switch-with-global-menu.sh

# Direct theme application
lookandfeeltool --apply org.magicunicorn.light
lookandfeeltool --apply org.magicunicorn.dark
```

### Dependencies
- **KDE Plasma:** 6.0+
- **Qt:** 6.8+
- **plasma-widgets-addons:** For Application Dashboard
- **Flat-Remix icons:** Automatically installed with complete package

### File Locations (after installation)
- **Themes:** `/usr/share/plasma/look-and-feel/MagicUnicorn-{Light,Dark}/`
- **CLI Tools:** `/usr/local/bin/uc-theme-switch*`
- **Icons:** `/usr/share/icons/Flat-Remix-Violet-{Light,Dark}/`
- **SDDM:** `/usr/share/sddm/themes/MagicUnicorn/`

## 🎯 Recommended Distribution Strategy

### For End Users
1. **Primary:** Distribute `MagicUnicorn-Complete-2.0.tar.gz` with installation instructions
2. **Alternative:** Provide individual GUI packages for users who prefer GUI installation

### For Package Maintainers
1. **Create distro packages** using the complete installer as a reference
2. **Split packages:** Separate themes, icons, and CLI tools per distro conventions
3. **Dependencies:** Include plasma-widgets-addons as a requirement

### For Online Distribution
1. **KDE Store:** Upload individual .tar.gz files for GUI import
2. **GitHub Releases:** Provide complete package with installation instructions
3. **Package Repositories:** Create native packages for major distributions

## 📋 Quality Assurance

### ✅ Tested Installation Methods
- [x] KDE GUI import (kpackagetool6)
- [x] Complete installer script
- [x] CLI theme switching
- [x] Theme application via lookandfeeltool
- [x] All features functional after installation

### ✅ Verified Components
- [x] Look and Feel themes (Light/Dark)
- [x] Metadata and KDE compatibility
- [x] Icon theme integration
- [x] CLI tool functionality
- [x] SDDM theme compatibility
- [x] Application Dashboard integration

## 🚀 Ready for Distribution!

The Magic Unicorn theme packages are **production-ready** and can be distributed through:
- KDE Store
- GitHub Releases  
- Package repositories
- Direct download

Choose the distribution method that best fits your target audience!