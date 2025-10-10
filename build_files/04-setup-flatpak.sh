#!/bin/bash
# Step 4: Setup Flatpak

set -ouex pipefail

echo "=== Setting up Flatpak ==="

# Add Flathub repository system-wide
echo "Adding Flathub repository..."
flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Flatpak runtime (required for Flatpak apps to run)
echo "Installing Flatpak runtimes..."
flatpak install --system --noninteractive flathub org.freedesktop.Platform//23.08
flatpak install --system --noninteractive flathub org.freedesktop.Sdk//23.08

echo "✓ Flatpak setup complete"