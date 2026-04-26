#!/bin/bash
## Build Echoes of Eleven to standalone executables
## Requires: Godot 4.3 installed and in PATH

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$PROJECT_DIR/dist"
GODOT_CMD="godot"

echo "🎮 Echoes of Eleven - Build Script"
echo "========================================"
echo ""

# Check if Godot is available
if ! command -v $GODOT_CMD &> /dev/null; then
    echo "❌ Godot 4.3 not found in PATH"
    echo "Please install Godot 4.3.0 or set GODOT_CMD environment variable"
    exit 1
fi

# Create export directory
mkdir -p "$EXPORT_DIR"

# Get version from project.godot
VERSION=$(grep 'config/version=' "$PROJECT_DIR/project.godot" | cut -d'"' -f2)
VERSION=${VERSION:-"1.0.0"}

echo "📦 Building Echoes of Eleven v$VERSION"
echo ""

# Export for Linux x86_64
echo "🐧 Exporting for Linux x86_64..."
mkdir -p "$EXPORT_DIR/linux"
$GODOT_CMD --headless --export-release "Linux/X64" "$EXPORT_DIR/linux/echoes_of_eleven" "$PROJECT_DIR/project.godot" \
    2>&1 | grep -v "^OpenGL" || true

if [ -f "$EXPORT_DIR/linux/echoes_of_eleven" ]; then
    chmod +x "$EXPORT_DIR/linux/echoes_of_eleven"
    echo "✅ Linux build complete: $EXPORT_DIR/linux/echoes_of_eleven"
else
    echo "⚠️  Linux build may need manual export from Godot"
fi

# Export for Windows x86_64
echo ""
echo "🪟 Exporting for Windows x86_64..."
mkdir -p "$EXPORT_DIR/windows"
$GODOT_CMD --headless --export-release "Windows Desktop" "$EXPORT_DIR/windows/echoes_of_eleven.exe" "$PROJECT_DIR/project.godot" \
    2>&1 | grep -v "^OpenGL" || true

if [ -f "$EXPORT_DIR/windows/echoes_of_eleven.exe" ]; then
    echo "✅ Windows build complete: $EXPORT_DIR/windows/echoes_of_eleven.exe"
else
    echo "⚠️  Windows build may need manual export from Godot"
fi

# Export for macOS x86_64
echo ""
echo "🍎 Exporting for macOS x86_64..."
mkdir -p "$EXPORT_DIR/macos"
$GODOT_CMD --headless --export-release "macOS" "$EXPORT_DIR/macos/echoes_of_eleven.dmg" "$PROJECT_DIR/project.godot" \
    2>&1 | grep -v "^OpenGL" || true

if [ -f "$EXPORT_DIR/macos/echoes_of_eleven.dmg" ]; then
    echo "✅ macOS build complete: $EXPORT_DIR/macos/echoes_of_eleven.dmg"
else
    echo "⚠️  macOS build may need manual export from Godot"
fi

echo ""
echo "📁 All builds output to: $EXPORT_DIR"
echo ""
echo "🎉 Build process complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Test builds on respective platforms"
echo "  2. Upload to GitHub Releases"
echo "  3. Upload to itch.io"
echo ""
