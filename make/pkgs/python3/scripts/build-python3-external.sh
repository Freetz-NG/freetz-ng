#!/bin/bash
#
# Build Python 3 standalone external archive
# This script creates a complete standalone .external archive with all dependencies
# that can be tested directly without installation on the device.
#
# Usage: build-python3-external.sh [output-name]
#
# The archive will be created in the images/ directory.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FREETZ_BASE="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

cd "$FREETZ_BASE"

echo "Creating Python 3 standalone external archive..."

# Check if we're in the Freetz-NG root directory
if [ ! -f "Makefile" ] || [ ! -d "make/pkgs/python3" ]; then
    echo "ERROR: Cannot find Freetz-NG root directory"
    echo "Current directory: $(pwd)"
    exit 1
fi

# Find the Python 3 build directory - prefer stable versions over alpha/beta/rc
# First try to find stable versions (no letter suffixes)
PYTHON_BUILD_DIR=$(find packages/target-* -maxdepth 2 -type d -name "python3-3.*" 2>/dev/null | \
    grep -E 'python3-3\.[0-9]+\.[0-9]+$' | head -1)

# If no stable version found, try any Python 3 version
if [ -z "$PYTHON_BUILD_DIR" ]; then
    PYTHON_BUILD_DIR=$(find packages/target-* -maxdepth 2 -type d -name "python3-3.*" 2>/dev/null | head -1)
fi

if [ -z "$PYTHON_BUILD_DIR" ]; then
    echo "ERROR: Python 3 not found in packages/"
    echo "Please build Python 3 first with: make menuconfig && make"
    exit 1
fi

# Extract Python version from build directory
PYTHON_FULL_VERSION=$(echo "$PYTHON_BUILD_DIR" | sed -n 's|.*/python3-\(3\.[0-9.]*[a-z0-9]*\).*|\1|p')

if [ -z "$PYTHON_FULL_VERSION" ]; then
    echo "ERROR: Could not detect Python version from $PYTHON_BUILD_DIR"
    exit 1
fi

# Extract major.minor version
PYTHON_VERSION=$(echo "$PYTHON_FULL_VERSION" | sed -n 's|^\(3\.[0-9]*\).*|\1|p')

if [ -z "$PYTHON_VERSION" ]; then
    echo "ERROR: Could not extract major.minor version from $PYTHON_FULL_VERSION"
    exit 1
fi

# Create version-specific variables
PYTHON_VERSION_SHORT="${PYTHON_VERSION/./}"  # 3.14 -> 314

# Extract target architecture from build directory
TARGET_ARCH=$(echo "$PYTHON_BUILD_DIR" | sed 's|packages/\(target-[^/]*\)/.*|\1|')
ROOT_DIR="packages/$TARGET_ARCH/root"

PYTHON_ROOT="$PYTHON_BUILD_DIR/root"

if [ ! -d "$PYTHON_ROOT/usr/lib/python${PYTHON_VERSION}" ] && [ ! -f "$PYTHON_ROOT/usr/lib/python${PYTHON_VERSION_SHORT}.zip" ]; then
    echo "ERROR: Python ${PYTHON_VERSION} files not found in $PYTHON_ROOT"
    echo "Expected: $PYTHON_ROOT/usr/lib/python${PYTHON_VERSION}/ or $PYTHON_ROOT/usr/lib/python${PYTHON_VERSION_SHORT}.zip"
    echo "Please build Python 3 first with: make"
    exit 1
fi

echo "Found Python ${PYTHON_VERSION} in: $PYTHON_BUILD_DIR"
echo "Using libraries from: $ROOT_DIR"

# Create temporary directory for packaging
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Creating standalone package in: $TEMP_DIR"

# Create directory structure
mkdir -p "$TEMP_DIR/bin"
mkdir -p "$TEMP_DIR/lib/python${PYTHON_VERSION}"

# Copy Python library directory
if [ -d "$PYTHON_ROOT/usr/lib/python${PYTHON_VERSION}" ]; then
    echo "Copying python${PYTHON_VERSION} library directory..."
    cp -a "$PYTHON_ROOT/usr/lib/python${PYTHON_VERSION}/"* "$TEMP_DIR/lib/python${PYTHON_VERSION}/"
fi

# Create site-packages directory if it doesn't exist
mkdir -p "$TEMP_DIR/lib/python${PYTHON_VERSION}/site-packages"

# Copy all Python 3 addon packages (3rd-party modules)
echo "Copying Python addon packages..."
ADDON_COUNT=0
for ADDON_DIR in packages/$TARGET_ARCH/python3-*/root/usr/lib/python${PYTHON_VERSION}/site-packages/; do
    if [ -d "$ADDON_DIR" ] && [ "$ADDON_DIR" != "packages/$TARGET_ARCH/python3-${PYTHON_VERSION}*/root/usr/lib/python${PYTHON_VERSION}/site-packages/" ]; then
        ADDON_NAME=$(echo "$ADDON_DIR" | sed 's|.*/python3-\([^/]*\)/.*|\1|')
        echo "  - $ADDON_NAME"
        cp -a "$ADDON_DIR"* "$TEMP_DIR/lib/python${PYTHON_VERSION}/site-packages/" 2>/dev/null || true
        ADDON_COUNT=$((ADDON_COUNT + 1))
    fi
done

if [ $ADDON_COUNT -eq 0 ]; then
    echo "  (no addon packages found)"
else
    echo "  Total: $ADDON_COUNT addon packages copied"
fi

# Copy python zip file
if [ -f "$PYTHON_ROOT/usr/lib/python${PYTHON_VERSION_SHORT}.zip" ]; then
    echo "Copying python${PYTHON_VERSION_SHORT}.zip..."
    cp -a "$PYTHON_ROOT/usr/lib/python${PYTHON_VERSION_SHORT}.zip" "$TEMP_DIR/lib/"
fi

# Copy Python executable
if [ -f "$PYTHON_ROOT/usr/bin/python${PYTHON_VERSION}.bin" ]; then
    echo "Copying python${PYTHON_VERSION} executable..."
    cp -a "$PYTHON_ROOT/usr/bin/python${PYTHON_VERSION}.bin" "$TEMP_DIR/bin/"
fi

# Copy all required shared libraries from /usr/lib/freetz/
echo "Copying shared libraries..."

# Copy libpython and create symlinks
LIBPYTHON=$(find "$ROOT_DIR/usr/lib/freetz/" -name "libpython${PYTHON_VERSION}.so.1.0" 2>/dev/null | head -1)
if [ -n "$LIBPYTHON" ]; then
    cp -a "$LIBPYTHON" "$TEMP_DIR/lib/"
    ln -sf "libpython${PYTHON_VERSION}.so.1.0" "$TEMP_DIR/lib/libpython${PYTHON_VERSION}.so"
    echo "  - libpython${PYTHON_VERSION}.so.1.0"
fi

# Copy libz and create symlinks
LIBZ=$(find "$ROOT_DIR/usr/lib/freetz/" -name "libz.so.1.*" 2>/dev/null | head -1)
if [ -n "$LIBZ" ]; then
    LIBZ_NAME=$(basename "$LIBZ")
    cp -a "$LIBZ" "$TEMP_DIR/lib/"
    ln -sf "$LIBZ_NAME" "$TEMP_DIR/lib/libz.so.1"
    ln -sf "$LIBZ_NAME" "$TEMP_DIR/lib/libz.so"
    echo "  - $LIBZ_NAME"
fi

# Copy libexpat and create symlinks
LIBEXPAT=$(find "$ROOT_DIR/usr/lib/freetz/" -name "libexpat.so.1.*" 2>/dev/null | head -1)
if [ -n "$LIBEXPAT" ]; then
    LIBEXPAT_NAME=$(basename "$LIBEXPAT")
    cp -a "$LIBEXPAT" "$TEMP_DIR/lib/"
    ln -sf "$LIBEXPAT_NAME" "$TEMP_DIR/lib/libexpat.so.1"
    ln -sf "$LIBEXPAT_NAME" "$TEMP_DIR/lib/libexpat.so"
    echo "  - $LIBEXPAT_NAME"
fi

# Create firmware-compatible wrapper script
cat > "$TEMP_DIR/bin/python${PYTHON_VERSION}" << EOF
#!/bin/sh
#
# Firmware-compatible Python ${PYTHON_VERSION} wrapper
# This script sets up the environment exactly like the firmware installation
#

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\$0")" && pwd)"
PYTHON_ROOT="\$(cd "\${SCRIPT_DIR}/.." && pwd)"

# Set Python home to our test installation
export PYTHONHOME="\${PYTHON_ROOT}"

# Add our lib directory to library path (mimic firmware setup)
export LD_LIBRARY_PATH="\${PYTHON_ROOT}/lib\${LD_LIBRARY_PATH:+:}\${LD_LIBRARY_PATH}"

# Execute the Python binary with all arguments
exec "\${PYTHON_ROOT}/bin/python${PYTHON_VERSION}.bin" -B "\$@"
EOF
chmod +x "$TEMP_DIR/bin/python${PYTHON_VERSION}"

# Create python3 symlink
ln -sf "python${PYTHON_VERSION}" "$TEMP_DIR/bin/python3"

# Create images directory if it doesn't exist
mkdir -p images

# Generate archive name
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE_NAME="${1:-python${PYTHON_VERSION_SHORT}-standalone_${BRANCH}-${COMMIT}_${TIMESTAMP}.tar.gz}"
ARCHIVE_PATH="images/$ARCHIVE_NAME"

echo "Creating archive: $ARCHIVE_PATH"

# Create the archive
cd "$TEMP_DIR"
tar -czf "$FREETZ_BASE/$ARCHIVE_PATH" .

cd "$FREETZ_BASE"

# Verify archive
if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "ERROR: Failed to create archive"
    exit 1
fi

ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
echo
echo "SUCCESS! Python ${PYTHON_VERSION} standalone archive created:"
echo "  File: $ARCHIVE_PATH"
echo "  Size: $ARCHIVE_SIZE"
echo
#echo "Archive contents:"
#tar -tzf "$ARCHIVE_PATH" | head -20
echo "  ..."
echo
cat << 'USAGE_INSTRUCTIONS'
To test on your device:
NOTE: Requires a Linux filesystem (i.e., ext4) with ~100MB free space.
      FAT32/VFAT filesystems are NOT supported (no symlink/executable permissions).

Example using /var/media/ftp/EXTERNAL (replace with your actual mount point):
  DEVICE_PATH="/var/media/ftp/EXTERNAL"  # Adjust to your ext4 external drive

  1. Copy to device:
USAGE_INSTRUCTIONS
echo "     scp $ARCHIVE_PATH root@192.168.178.1:\$DEVICE_PATH/"
cat << 'USAGE_INSTRUCTIONS'

  2. Extract on device:
     mkdir -p $DEVICE_PATH/python3
USAGE_INSTRUCTIONS
echo "     tar -xzf \$DEVICE_PATH/$(basename "$ARCHIVE_PATH") -C \$DEVICE_PATH/python3/"
cat << 'USAGE_INSTRUCTIONS'

  3. Test Python installation:
     $DEVICE_PATH/python3/bin/python3 << 'PYTEST'

import sys
print('Python version:', sys.version)

import importlib.metadata
print('\nInstalled packages:')
for dist in importlib.metadata.distributions():
    print(f'  {dist.metadata["Name"]} {dist.version}')

import os
print('\nZip import test:')
print('  os module from:', os.__file__)

try:
    import ssl, socket
    ctx = ssl._create_unverified_context()
    s = ctx.wrap_socket(socket.socket(), server_hostname='python.org')
    s.connect(('python.org', 443))
    print('\nSSL test: OK -', s.version())
    s.close()
except Exception as e:
    print('\nSSL test: FAILED -', e)

PYTEST
USAGE_INSTRUCTIONS
echo
