#!/bin/bash

echo "::group:: ===$(basename "$0")==="
set -ouex pipefail

echo "=== Installing Flatpak applications ==="

# Read Flatpak list from flatpaks.txt file
FLATPAKS_FILE="/ctx/flatpaks.txt"

# Add Flathub repository for user
echo "Adding Flathub repository..."
flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Flatpaks from the list
if [ -f "$FLATPAKS_FILE" ]; then
    echo "Reading Flatpaks from $FLATPAKS_FILE..."
    # Read non-empty, non-comment lines from the file
    FLATPAKS=($(grep -v '^[[:space:]]*#' "$FLATPAKS_FILE" | grep -v '^[[:space:]]*$' | tr '\n' ' '))
    
    if [ ${#FLATPAKS[@]} -gt 0 ]; then
        echo "Installing ${#FLATPAKS[@]} Flatpaks..."
        for flatpak in "${FLATPAKS[@]}"; do
            echo "Installing: $flatpak"
            flatpak install --system --noninteractive --no-sandbox flathub "$flatpak" || echo "Failed to install $flatpak"
        done
        echo "✓ Flatpak applications installation complete"
    else
        echo "No Flatpaks specified for installation in $FLATPAKS_FILE"
    fi
else
    echo "Flatpaks file not found: $FLATPAKS_FILE"
    echo "You can create this file to specify Flatpaks to install"
fi