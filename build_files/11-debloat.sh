#!/bin/bash

set -ouex pipefail

echo "=== Debloating unnecessary packages ==="
# List of packages to remove
PACKAGES_TO_REMOVE=(
    "gnome-calculator"
    "gnome-calendar"
    "gnome-characters"
    "gnome-clocks"
    "gnome-console"
    "gnome-contacts"
    "gnome-disk-utility"
    "gnome-disk-usage-analyzer"
    "gnome-documents"
    "gnome-font-viewer"
    "gnome-logs"
    "gnome-maps"
    "gnome-music"
    "gnome-photos"
    "gnome-software"
    "gnome-system-monitor"
    "gnome-text-editor"
    "gnome-weather"
    "gnome-web"
    "gnome-console"
    "eog"
    "evince"
    "totem"
    "rhythmbox"
    "cheese"
    "yelp"
    "transmission-gtk"
    "libreoffice"
    "firefox"
)

# Remove the packages
if [ ${#PACKAGES_TO_REMOVE[@]} -gt 0 ]; then
    echo "Removing ${#PACKAGES_TO_REMOVE[@]} unnecessary packages..."
    dnf remove -y "${PACKAGES_TO_REMOVE[@]}"
    echo "✓ Unnecessary packages removal complete"
else
    echo "No packages specified for removal"
fi