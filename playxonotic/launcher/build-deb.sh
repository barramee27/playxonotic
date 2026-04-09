#!/bin/bash
set -e

XONOTIC_URL="https://dl.xonotic.org/xonotic-0.8.6.zip"
CACHE_DIR=".build-cache"
ZIP_FILE="$CACHE_DIR/xonotic-0.8.6.zip"

# Build release binary
echo "Building launcher..."
cargo build --release

# Create package directory
PKG_DIR="playxonotic-launcher_1.0.0_amd64"
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/playxonotic"
mkdir -p "$PKG_DIR/DEBIAN"

# Download game data (cached)
mkdir -p "$CACHE_DIR"
if [ ! -f "$ZIP_FILE" ]; then
    echo "Downloading Xonotic (1.2 GB)..."
    wget -q --show-progress -O "$ZIP_FILE" "$XONOTIC_URL" || \
        curl -L -o "$ZIP_FILE" "$XONOTIC_URL"
fi

# Extract game into package
echo "Extracting game data..."
unzip -q -o "$ZIP_FILE" -d "$PKG_DIR/usr/share/playxonotic"
# Zip has top-level folder (Xonotic or xonotic-0.8.6) - normalize to Xonotic
for sub in xonotic-0.8.6 Xonotic; do
    if [ -d "$PKG_DIR/usr/share/playxonotic/$sub" ]; then
        if [ "$sub" != "Xonotic" ]; then
            rm -rf "$PKG_DIR/usr/share/playxonotic/Xonotic" 2>/dev/null
            mv "$PKG_DIR/usr/share/playxonotic/$sub" "$PKG_DIR/usr/share/playxonotic/Xonotic"
        fi
        break
    fi
done

# Inject custom logic mod
echo "Injecting custom QuakeC mod..."
cp /home/barramee27/antigravity/xonotic-data-trimmed/zz_playxonotic_mod.pk3 "$PKG_DIR/usr/share/playxonotic/Xonotic/data/"

chmod -R a+rX "$PKG_DIR/usr/share/playxonotic"
chmod +x "$PKG_DIR/usr/share/playxonotic/Xonotic/"*.sh 2>/dev/null || true

if [ ! -f "$PKG_DIR/usr/share/playxonotic/Xonotic/xonotic-linux-sdl.sh" ] && [ ! -f "$PKG_DIR/usr/share/playxonotic/Xonotic/xonotic-linux-glx.sh" ]; then
    echo "Error: Game extraction failed - expected Xonotic/xonotic-linux-*.sh"
    exit 1
fi

# Copy binary
cp target/release/playxonotic-launcher "$PKG_DIR/usr/bin/playxonotic-launcher"
chmod 755 "$PKG_DIR/usr/bin/playxonotic-launcher"

# Desktop entry
cat > "$PKG_DIR/usr/share/applications/playxonotic-launcher.desktop" << 'EOF'
[Desktop Entry]
Name=PlayXonotic
Comment=Play Xonotic with your PlayXonotic account
Exec=playxonotic-launcher
Icon=playxonotic
Terminal=false
Type=Application
Categories=Game;ActionGame;
Keywords=xonotic;game;shooter;
EOF

# Control file (minimal - no build-deps for simple dpkg-deb)
cat > "$PKG_DIR/DEBIAN/control" << 'EOF'
Package: playxonotic-launcher
Version: 1.0.0
Section: games
Priority: optional
Architecture: amd64
Depends: libgtk-4-1 (>= 4.0)
Maintainer: Barramee Kottanawadee <barramee25038@gmail.com>
Description: Native PlayXonotic launcher with login
 PlayXonotic launcher - sign in and play Xonotic with your account.
 Includes full game data. Connects to playxonotic.com servers.
EOF

# Build .deb
echo "Building .deb package..."
if dpkg-deb --help 2>&1 | grep -q root-owner-group; then
  dpkg-deb -Znone --build --root-owner-group "$PKG_DIR"
else
  dpkg-deb -Znone --build "$PKG_DIR"
fi

# Cleanup
rm -rf "$PKG_DIR"

DEB_NAME="${PKG_DIR}.deb"
echo "Done: $DEB_NAME"
ls -la "$DEB_NAME"
