#!/bin/bash
# Step 1: Setup RPM repositories

set -ouex pipefail

echo "=== Setting up RPM repositories ==="

# Install dnf-plugins-core if needed (for older DNF versions)
dnf install -y dnf-plugins-core 2>/dev/null || true

# Add RPM Fusion repositories
echo "Adding RPM Fusion repositories..."
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable Cisco OpenH264 repository
echo "Enabling Cisco OpenH264 repository..."
dnf config-manager --set-enabled fedora-cisco-openh264 || dnf config-manager setopt fedora-cisco-openh264.enabled=1 || {
    # Fallback for dnf5 - directly edit repo file
    sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/fedora-cisco-openh264.repo 2>/dev/null || true
}

# Enable homeOS repository
echo "Enabling homeOS repository..."
dnf copr enable bubblineyuri/homeOS -y

# Add Docker CE repository
echo "Adding Docker CE repository..."
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || {
    # Fallback for dnf5 - direct download
    curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
}

echo "✓ RPM repositories setup complete"