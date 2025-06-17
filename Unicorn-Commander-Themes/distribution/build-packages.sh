#!/bin/bash

# Build distributable Magic Unicorn theme packages

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/packages"

echo -e "${PURPLE}🦄 Building Magic Unicorn Theme Packages${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 1. Create individual KDE theme packages for GUI import
echo -e "${BLUE}📦 Creating KDE theme packages for GUI import...${NC}"

# Magic Unicorn Light package
echo -e "${YELLOW}   Building Magic Unicorn Light...${NC}"
cd "$SCRIPT_DIR"
tar -czf "$BUILD_DIR/MagicUnicorn-Light-2.0.tar.gz" MagicUnicorn-Light/
echo -e "${GREEN}   ✅ MagicUnicorn-Light-2.0.tar.gz created${NC}"

# Magic Unicorn Dark package  
echo -e "${YELLOW}   Building Magic Unicorn Dark...${NC}"
tar -czf "$BUILD_DIR/MagicUnicorn-Dark-2.0.tar.gz" MagicUnicorn-Dark/
echo -e "${GREEN}   ✅ MagicUnicorn-Dark-2.0.tar.gz created${NC}"

# 2. Create complete installer package
echo -e "${BLUE}📦 Creating complete installer package...${NC}"
echo -e "${YELLOW}   Building Magic Unicorn Complete...${NC}"

# Create temporary directory for complete package
TEMP_DIR=$(mktemp -d)
COMPLETE_DIR="$TEMP_DIR/MagicUnicorn-Complete-2.0"
mkdir -p "$COMPLETE_DIR"

# Copy all components
cp -r MagicUnicorn-Light "$COMPLETE_DIR/"
cp -r MagicUnicorn-Dark "$COMPLETE_DIR/"
cp -r scripts "$COMPLETE_DIR/"
cp -r sddm-theme "$COMPLETE_DIR/"
cp install-magic-unicorn.sh "$COMPLETE_DIR/"

# Create README for complete package
cat > "$COMPLETE_DIR/README.md" << 'EOF'
# Magic Unicorn Theme - Complete Package

## What's Included

- **Magic Unicorn Light & Dark** - KDE Look and Feel themes
- **Flat-Remix-Violet icons** - Light and dark icon themes  
- **CLI Theme Switcher** - `uc-theme-switch` command
- **SDDM Login Themes** - Magic Unicorn login screens
- **Application Dashboard** - Rainbow grid app launcher
- **Global Menu Support** - macOS-style menu integration
- **Unicorn Logo Assets** - SVG icons and branding

## Installation

### Complete Installation (Recommended)
```bash
sudo ./install-magic-unicorn.sh
```

### GUI Installation (Individual Themes)
1. Open System Settings > Appearance > Global Theme
2. Click "Get New Global Themes"
3. Install from File: `MagicUnicorn-Light-2.0.tar.gz` or `MagicUnicorn-Dark-2.0.tar.gz`

### CLI Usage
After installation:
```bash
uc-theme-switch
```

## Features

- 🦄 **Unicorn Logo** in menu button
- 🌈 **Rainbow Grid Launcher** - Full-screen app grid
- 🍎 **macOS Global Menu** - App titles in menu bar  
- 🎨 **Flat-Remix-Violet Icons** - Beautiful violet theme
- 💻 **SDDM Login Themes** - Branded login screens
- ⚡ **CLI Theme Switching** - Quick theme changes

## Requirements

- KDE Plasma 6.0+
- Qt 6.8+
- plasma-widgets-addons (for Application Dashboard)

## License

GPL-3.0 - See individual component licenses for details.
EOF

# Create the complete package
cd "$TEMP_DIR"
tar -czf "$BUILD_DIR/MagicUnicorn-Complete-2.0.tar.gz" MagicUnicorn-Complete-2.0/
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}   ✅ MagicUnicorn-Complete-2.0.tar.gz created${NC}"

# 3. Create installation summary
echo -e "${BLUE}📋 Creating package manifest...${NC}"
cat > "$BUILD_DIR/README.md" << 'EOF'
# Magic Unicorn Theme Packages

## Available Packages

### Individual KDE Themes (GUI Import)
- **MagicUnicorn-Light-2.0.tar.gz** - Light theme for KDE GUI import
- **MagicUnicorn-Dark-2.0.tar.gz** - Dark theme for KDE GUI import

### Complete Package (CLI Install)  
- **MagicUnicorn-Complete-2.0.tar.gz** - Everything included with installer

## Installation Methods

### Method 1: GUI Installation (Individual Themes)
1. Download `MagicUnicorn-Light-2.0.tar.gz` or `MagicUnicorn-Dark-2.0.tar.gz`
2. Open KDE System Settings > Appearance > Global Theme
3. Click "Get New Global Themes" 
4. Click "Install from File"
5. Select the downloaded .tar.gz file
6. Apply the theme

**Note:** GUI installation only installs the basic theme. For full features (CLI switcher, SDDM themes, etc.), use the complete package.

### Method 2: Complete Installation (Recommended)
1. Download `MagicUnicorn-Complete-2.0.tar.gz`
2. Extract: `tar -xzf MagicUnicorn-Complete-2.0.tar.gz`
3. Install: `cd MagicUnicorn-Complete-2.0 && sudo ./install-magic-unicorn.sh`
4. Use: `uc-theme-switch`

## Features by Installation Method

| Feature | GUI Install | Complete Install |
|---------|-------------|------------------|
| Basic Theme | ✅ | ✅ |
| Unicorn Logo | ❌ | ✅ |
| Rainbow App Launcher | ❌ | ✅ |
| Global Menu | ❌ | ✅ |
| CLI Switcher | ❌ | ✅ |
| SDDM Themes | ❌ | ✅ |
| Icon Themes | ❌ | ✅ |

Choose the installation method that best fits your needs!
EOF

echo -e "${GREEN}   ✅ Package manifest created${NC}"

echo ""
echo -e "${GREEN}🎉 Package build complete!${NC}"
echo ""
echo -e "${PURPLE}📦 Generated packages in $BUILD_DIR:${NC}"
ls -la "$BUILD_DIR"
echo ""
echo -e "${BLUE}🚀 Distribution ready:${NC}"
echo -e "   • GUI Import: Individual .tar.gz files"
echo -e "   • Complete Install: MagicUnicorn-Complete-2.0.tar.gz"
echo -e "   • CLI Command: uc-theme-switch (after complete install)"