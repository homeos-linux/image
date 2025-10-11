#!/bin/bash

set -ouex pipefail

echo "=== Setting up GNOME extensions ==="

# Install helper script
curl -L https://raw.githubusercontent.com/jasonmb626/gnome-shell-extension-installer/master/gnome-shell-extension-installer > /tmp/gnome-shell-extension-installer
chmod +x /tmp/gnome-shell-extension-installer
echo "✓ gnome-shell-extension-installer script installed"

# List of GNOME extensions to install
EXTENSIONS=(
    307
    5895
    517
    4269
    6727
    4805
    6096
    5410
    3193
    5263
    3240
)

EXT_PATH="/usr/share/gnome-shell/extensions"

# Install each extension
for EXT_ID in "${EXTENSIONS[@]}"; do
    echo "Installing GNOME extension ID: $EXT_ID"
    /tmp/gnome-shell-extension-installer "$EXT_ID" --yes || echo "Failed to install extension ID: $EXT_ID"

    # Find the UUID folder created by the installer
    EXT_UUID=$(ls -1 "$EXT_PATH" | grep -i "$EXT_ID" || true)
    if [ -n "$EXT_UUID" ] && [ -d "$EXT_PATH/$EXT_UUID/schemas" ]; then
        echo "Compiling schemas for $EXT_UUID..."
        glib-compile-schemas "$EXT_PATH/$EXT_UUID/schemas"
    fi
done

echo "✓ GNOME extensions installation complete"

# Clean up
rm /tmp/gnome-shell-extension-installer
echo "✓ Cleanup complete"
