#!/bin/bash

# UnicornCommander KDE Theme Distribution Packager
# Creates distribution packages for different Linux distributions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
DIST_DIR="$PROJECT_DIR/dist"

VERSION="1.0.0"
PACKAGE_NAME="unicorncommander-kde-themes"

echo "=== UnicornCommander KDE Theme Distribution Packager ==="
echo "Version: $VERSION"
echo "Package: $PACKAGE_NAME"

# Clean and create distribution directory
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Ensure themes are built
if [ ! -d "$BUILD_DIR/look-and-feel" ]; then
    echo "Building themes first..."
    "$SCRIPT_DIR/build-themes.sh"
fi

# Create universal tarball
create_universal_package() {
    echo "Creating universal package..."
    
    local package_dir="$DIST_DIR/$PACKAGE_NAME-$VERSION"
    mkdir -p "$package_dir"
    
    # Copy theme files
    cp -r "$BUILD_DIR/look-and-feel" "$package_dir/"
    cp -r "$BUILD_DIR/color-schemes" "$package_dir/"
    cp -r "$PROJECT_DIR/assets" "$package_dir/"
    
    # Copy scripts
    mkdir -p "$package_dir/scripts"
    cp "$SCRIPT_DIR/install-themes.sh" "$package_dir/scripts/"
    cp "$SCRIPT_DIR/test-resolutions.sh" "$package_dir/scripts/"
    
    # Create installation script
    cat > "$package_dir/install.sh" << 'EOF'
#!/bin/bash
# UnicornCommander KDE Themes Universal Installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing UnicornCommander KDE Themes..."

# Install color schemes
echo "Installing color schemes..."
mkdir -p "$HOME/.local/share/color-schemes"
cp "$SCRIPT_DIR/color-schemes"/*.colors "$HOME/.local/share/color-schemes/"

# Install look-and-feel themes
echo "Installing look-and-feel themes..."
mkdir -p "$HOME/.local/share/plasma/look-and-feel"

for theme in UC-Mac-Light UC-Mac-Dark UC-Windows-Light UC-Windows-Dark; do
    echo "Installing $theme..."
    cp -r "$SCRIPT_DIR/look-and-feel/$theme" "$HOME/.local/share/plasma/look-and-feel/"
done

# Install wallpapers
echo "Installing wallpapers..."
mkdir -p "$HOME/.local/share/wallpapers/UnicornCommander"
cp "$SCRIPT_DIR/assets/wallpapers"/* "$HOME/.local/share/wallpapers/UnicornCommander/"

# Refresh KDE cache
echo "Refreshing KDE cache..."
if command -v kbuildsycoca6 > /dev/null 2>&1; then
    kbuildsycoca6 --noincremental
elif command -v kbuildsycoca5 > /dev/null 2>&1; then
    kbuildsycoca5 --noincremental
fi

echo "Installation complete!"
echo ""
echo "Available themes:"
echo "- UnicornCommander Mac Light"
echo "- UnicornCommander Mac Dark"
echo "- UnicornCommander Windows Light"
echo "- UnicornCommander Windows Dark"
echo ""
echo "To apply a theme:"
echo "1. Open System Settings"
echo "2. Go to Appearance > Global Theme"
echo "3. Select your preferred UnicornCommander theme"
echo "4. Click 'Apply'"
EOF

    chmod +x "$package_dir/install.sh"
    chmod +x "$package_dir/scripts"/*.sh
    
    # Copy documentation
    cp "$PROJECT_DIR/README.md" "$package_dir/"
    cp "$PROJECT_DIR/CHANGELOG.md" "$package_dir/"
    cp "$PROJECT_DIR/USER-GUIDE.md" "$package_dir/"
    
    # Create package info
    cat > "$package_dir/PACKAGE-INFO.txt" << EOF
UnicornCommander KDE Themes
Version: $VERSION
Package: $PACKAGE_NAME

Contents:
- 4 Global Themes (Mac Light/Dark, Windows Light/Dark)
- Color schemes
- Wallpapers in multiple resolutions
- Installation scripts
- Documentation

System Requirements:
- KDE Plasma 6.0+
- Qt 6.2+
- Linux distribution with KDE

Installation:
Run ./install.sh in this directory

For more information, see README.md and USER-GUIDE.md
EOF
    
    # Create tarball
    echo "Creating tarball..."
    cd "$DIST_DIR"
    tar -czf "$PACKAGE_NAME-$VERSION.tar.gz" "$PACKAGE_NAME-$VERSION"
    
    echo "Universal package created: $DIST_DIR/$PACKAGE_NAME-$VERSION.tar.gz"
}

# Create Debian package
create_debian_package() {
    echo "Creating Debian package..."
    
    local deb_dir="$DIST_DIR/debian"
    local package_root="$deb_dir/$PACKAGE_NAME-$VERSION"
    
    mkdir -p "$package_root/DEBIAN"
    mkdir -p "$package_root/usr/share/plasma/look-and-feel"
    mkdir -p "$package_root/usr/share/color-schemes"
    mkdir -p "$package_root/usr/share/wallpapers/UnicornCommander"
    
    # Copy files
    cp -r "$BUILD_DIR/look-and-feel"/* "$package_root/usr/share/plasma/look-and-feel/"
    cp -r "$BUILD_DIR/color-schemes"/* "$package_root/usr/share/color-schemes/"
    cp -r "$PROJECT_DIR/assets/wallpapers"/* "$package_root/usr/share/wallpapers/UnicornCommander/"
    
    # Create control file
    cat > "$package_root/DEBIAN/control" << EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: kde
Priority: optional
Architecture: all
Depends: plasma-desktop (>= 6.0), qt6-base (>= 6.2)
Maintainer: UnicornCommander Team <support@unicorncommander.org>
Description: UnicornCommander KDE Themes
 A collection of macOS and Windows-style themes for KDE Plasma 6.
 Includes 4 global themes with custom layouts, color schemes, and wallpapers.
 .
 Themes included:
  - UnicornCommander Mac Light
  - UnicornCommander Mac Dark
  - UnicornCommander Windows Light
  - UnicornCommander Windows Dark
EOF
    
    # Create postinst script
    cat > "$package_root/DEBIAN/postinst" << 'EOF'
#!/bin/bash
# Refresh KDE cache after installation
if command -v kbuildsycoca6 > /dev/null 2>&1; then
    kbuildsycoca6 --noincremental
elif command -v kbuildsycoca5 > /dev/null 2>&1; then
    kbuildsycoca5 --noincremental
fi
EOF
    
    chmod +x "$package_root/DEBIAN/postinst"
    
    # Build package
    if command -v dpkg-deb > /dev/null 2>&1; then
        cd "$deb_dir"
        dpkg-deb --build "$PACKAGE_NAME-$VERSION"
        echo "Debian package created: $deb_dir/$PACKAGE_NAME-$VERSION.deb"
    else
        echo "dpkg-deb not available - skipping Debian package creation"
    fi
}

# Create RPM spec file
create_rpm_spec() {
    echo "Creating RPM spec file..."
    
    local rpm_dir="$DIST_DIR/rpm"
    mkdir -p "$rpm_dir"
    
    cat > "$rpm_dir/$PACKAGE_NAME.spec" << EOF
Name: $PACKAGE_NAME
Version: $VERSION
Release: 1
Summary: UnicornCommander KDE Themes
License: GPL-3.0
Group: User Interface/Desktops
URL: https://github.com/unicorncommander/kde-themes
BuildArch: noarch
Requires: plasma-desktop >= 6.0, qt6-qtbase >= 6.2

%description
A collection of macOS and Windows-style themes for KDE Plasma 6.
Includes 4 global themes with custom layouts, color schemes, and wallpapers.

%files
%defattr(-,root,root,-)
/usr/share/plasma/look-and-feel/*
/usr/share/color-schemes/*
/usr/share/wallpapers/UnicornCommander/*

%post
if command -v kbuildsycoca6 > /dev/null 2>&1; then
    kbuildsycoca6 --noincremental
elif command -v kbuildsycoca5 > /dev/null 2>&1; then
    kbuildsycoca5 --noincremental
fi

%changelog
* $(date '+%a %b %d %Y') UnicornCommander Team <support@unicorncommander.org> - $VERSION-1
- Initial release
- 4 global themes: Mac Light/Dark, Windows Light/Dark
- Enhanced blur and transparency effects
- Dock magnification for macOS theme
- Multi-resolution wallpapers
EOF
    
    echo "RPM spec file created: $rpm_dir/$PACKAGE_NAME.spec"
    echo "To build RPM package: rpmbuild -ba $rpm_dir/$PACKAGE_NAME.spec"
}

# Create checksums
create_checksums() {
    echo "Creating checksums..."
    
    cd "$DIST_DIR"
    
    # Create checksums for all packages
    find . -name "*.tar.gz" -o -name "*.deb" -o -name "*.rpm" | while read -r file; do
        if [ -f "$file" ]; then
            md5sum "$file" >> checksums.md5
            sha256sum "$file" >> checksums.sha256
        fi
    done
    
    echo "Checksums created in $DIST_DIR/"
}

# Main execution
echo "Creating distribution packages..."
echo ""

create_universal_package
create_debian_package
create_rpm_spec
create_checksums

echo ""
echo "=== Distribution Packages Created ==="
echo "Output directory: $DIST_DIR"
echo ""
echo "Packages:"
ls -la "$DIST_DIR"/*.tar.gz "$DIST_DIR"/*.deb 2>/dev/null || true
echo ""
echo "Checksums:"
echo "- checksums.md5"
echo "- checksums.sha256"
echo ""
echo "Installation instructions:"
echo "Universal: Extract and run install.sh"
echo "Debian/Ubuntu: sudo dpkg -i $PACKAGE_NAME-$VERSION.deb"
echo "RPM: Use spec file to build with rpmbuild"