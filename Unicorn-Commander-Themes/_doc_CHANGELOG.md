# Changelog

## [2.0.0] - 2024-06-14

### 🚀 Major Release - Production Ready

### ✅ Fixed Major Issues
- **FIXED**: Themes now properly appear in System Settings > Global Theme
- **FIXED**: macOS dock now centered and width-limited (was spanning full screen)
- **FIXED**: Wallpapers now display correctly from ~/UC-1/assets/wallpapers/
- **FIXED**: All themes use consistent KDE Classic cursor theme

### 🆕 Added Features
- **Advanced Dock Magnification**: Smooth 1.0x to 1.8x scaling for macOS themes
- **Enhanced Blur Effects**: Qt6 MultiEffect with adaptive blur radius
- **Multi-Resolution Support**: Automatic scaling for HD/QHD/4K displays
- **Windows Theme Enhancements**: Proper taskbar layout with magnification
- **Resolution Testing**: Comprehensive test script for different display sizes
- **Distribution Packaging**: Universal, Debian, and RPM package generation

### 🔧 Technical Improvements
- **KDE Plasma 6 Compatibility**: Updated metadata format (KPackageStructure)
- **Qt6 Migration**: All QML files updated to QtQuick 6.2
- **Modern Effects**: Replaced QtGraphicalEffects with QtQuick.Effects
- **Color Scheme Integration**: Proper Windows-specific color schemes
- **Enhanced Animations**: Smooth easing curves for dock magnification

### 📦 New Scripts & Tools
- `test-resolutions.sh`: Multi-resolution testing and validation
- `package-for-distribution.sh`: Comprehensive distribution packaging
- Enhanced build system with proper metadata handling

## [1.1.0] - 2024-06-14

### Added
- macOS-style panel refinements for UC-Mac-Dark theme
- Authentic centered dock configuration  
- Panel spacer for proper macOS-like layout
- Integration with UnicornCommander wallpapers from ~/UC-1/assets/wallpapers/
- PROJECT-STATUS.md for project handover and continuation

### Changed
- Bottom dock now properly centered (20-30% width)
- Increased dock height to 80px with 60px icons
- Top panel configured for 28px height
- System tray and clock positioned on right side of top panel
- Updated documentation with detailed macOS theme implementation
 - UnicornCommander KDE Themes

All notable changes to the UnicornCommander KDE Themes project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-06-14

### 🎉 Initial Release

#### Added
- **Four Complete Theme Variants**:
  - UnicornCommander Mac Light - macOS-style layout with light color scheme
  - UnicornCommander Mac Dark - macOS-style layout with dark color scheme  
  - UnicornCommander Windows Light - Windows-style layout with light color scheme
  - UnicornCommander Windows Dark - Windows-style layout with dark color scheme

- **Layout Systems**:
  - Mac-style: Top global menu bar + centered floating bottom dock
  - Windows-style: Single bottom taskbar with all components
  - Responsive design for multiple screen resolutions
  - Multi-monitor support with independent panel configurations

- **Visual Components**:
  - Custom UnicornCommander unicorn logo as application launcher
  - Complete set of cosmic gradient wallpapers (1366x768 to 7680x4320)
  - Purple and blue accent color scheme matching UnicornCommander branding
  - Light and dark color variants optimized for different lighting conditions

- **Technical Features**:
  - KDE Plasma 6.3.4+ native compatibility
  - Qt 6.8.3+ component usage
