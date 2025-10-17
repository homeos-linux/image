#!/bin/bash
set -ouex pipefail

echo "=== Downloading GNOME extensions system-wide ==="

dnf install -y https://gitlab.com/smedius/desktop-icons-ng/-/raw/main/Downloads/gnome-shell-extension-adw-desktop-icons-100.8-2.el5.local.noarch.rpm

# Zielordner für systemweite Installation
EXT_PATH="/usr/share/gnome-shell/extensions"
mkdir -p "$EXT_PATH"

# Liste der GNOME Extension IDs
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
    3240
)

TMP_DIR="/tmp/gnome-ext-download"
mkdir -p "$TMP_DIR"

for EXT_ID in "${EXTENSIONS[@]}"; do
    echo "Processing extension ID: $EXT_ID"

    META_JSON=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXT_ID")
    UUID=$(echo $META_JSON | jq -r '.uuid')
    UUID_WITHOUT_AT=$(echo $UUID | tr -d '@')
    VERSION=$(echo $META_JSON | jq -r '.shell_version_map["48"].version')

    ZIP_PATH="$TMP_DIR/${UUID}.zip"

    # Download prüfen
    if ! curl -fL -o "$ZIP_PATH" "https://extensions.gnome.org/extension-data/$UUID_WITHOUT_AT.v$VERSION.shell-extension.zip"; then
        echo "⚠️  Failed to download $UUID v$VERSION, skipping..."
        continue
    fi

    EXT_DIR="$EXT_PATH/$UUID"
    mkdir -p "$EXT_DIR"
    unzip -oq "$ZIP_PATH" -d "$EXT_DIR"

    if [ -d "$EXT_DIR/schemas" ]; then
        glib-compile-schemas "$EXT_DIR/schemas"
    fi

    chown -R root:root "$EXT_DIR"
    find "$EXT_DIR" -type d -exec chmod 755 {} \;
    find "$EXT_DIR" -type f -exec chmod 644 {} \;

    echo "✓ Installed $UUID"
done

rm -rf "$TMP_DIR"

echo "✓ All extensions downloaded and installed system-wide"
