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

    META_JSON=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXT_ID")
    UUID=$(echo $META_JSON | jq -r '.uuid')
    UUID_WITHOUT_AT=$(echo $UUID | tr -d '@')
    VERSION=$(echo $META_JSON | jq -r '.shell_version_map["48"].version')

    ZIP_PATH="$TMP_DIR/${UUID}.zip"
    curl -L -o "$ZIP_PATH" "https://extensions.gnome.org/extension-data/$UUID_WITHOUT_AT.v$VERSION.shell-extension.zip"

    gnome-extensions install -fq "$ZIP_PATH"
done

# Cleanup
rm -rf "$TMP_DIR"
echo "✓ All extensions downloaded and schemas compiled"
