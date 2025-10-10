#!/bin/bash
# Step 1: Setup RPM repositories

set -ouex pipefail

echo "=== Setting up RPM repositories ==="

# Add RPM Fusion repositories
echo "Adding RPM Fusion repositories..."
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable Cisco OpenH264 repository
echo "Enabling Cisco OpenH264 repository..."
dnf config-manager setopt fedora-cisco-openh264.enabled=1

# Enable homeOS repository
echo "Enabling homeOS repository..."
dnf copr enable bubblineyuri/homeOS -y

echo "✓ RPM repositories setup complete"