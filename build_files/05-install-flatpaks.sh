#!/bin/bash
# Step 5: Install Flatpak applications

set -ouex pipefail

echo "=== Installing Flatpak applications ==="

# Read Flatpak list from flatpaks.txt file
FLATPAKS_FILE="/ctx/flatpaks.txt"

if [ -f "$FLATPAKS_FILE" ]; then
    echo "Reading Flatpaks from $FLATPAKS_FILE..."
    # Read non-empty, non-comment lines from the file
    FLATPAKS=($(grep -v '^[[:space:]]*#' "$FLATPAKS_FILE" | grep -v '^[[:space:]]*$' | tr '\n' ' '))
    
    if [ ${#FLATPAKS[@]} -gt 0 ]; then
        echo "Installing ${#FLATPAKS[@]} Flatpaks..."
        for flatpak in "${FLATPAKS[@]}"; do
            echo "Installing: $flatpak"
            flatpak install --system --noninteractive flathub "$flatpak" || echo "Failed to install $flatpak"
        done
        echo "✓ Flatpak applications installation complete"
    else
        echo "No Flatpaks specified for installation in $FLATPAKS_FILE"
    fi
else
    echo "Flatpaks file not found: $FLATPAKS_FILE"
    echo "You can create this file to specify Flatpaks to install"
fi