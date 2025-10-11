#!/bin/bash
set -ouex pipefail

echo "=== Downloading GNOME extensions ==="

# Zielordner
EXT_PATH="/usr/share/gnome-shell/extensions"
mkdir -p "$EXT_PATH"

# List of GNOME extension IDs
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

TMP_DIR="/tmp/gnome-ext-download"
mkdir -p "$TMP_DIR"

for EXT_ID in "${EXTENSIONS[@]}"; do
    echo "Processing extension ID: $EXT_ID"

    # Metadata abrufen
    META_JSON=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXT_ID")
    UUID=$(echo "$META_JSON" | grep -Po '"uuid": *"\K[^"]+')
    VERSION=$(echo "$META_JSON" | grep -Po '"latest_version":\K[0-9]+')

    # ZIP runterladen
    ZIP_PATH="$TMP_DIR/${UUID}.zip"
    curl -L -o "$ZIP_PATH" "https://extensions.gnome.org/download-extension/$UUID.shell-extension.zip?version_tag=$VERSION"

    # Entpacken
    EXT_DIR="$EXT_PATH/$UUID"
    mkdir -p "$EXT_DIR"
    unzip -q "$ZIP_PATH" -d "$EXT_DIR"

    # GLib-Schemas kompilieren
    if [ -d "$EXT_DIR/schemas" ]; then
        echo "Compiling schemas for $UUID..."
        glib-compile-schemas "$EXT_DIR/schemas"
    fi
done

# Cleanup
rm -rf "$TMP_DIR"
echo "✓ All extensions downloaded and schemas compiled"
