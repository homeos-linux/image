#!/bin/bash
# Step 1: Setup RPM repositories

set -ouex pipefail

echo "=== Setting up RPM repositories ==="

# Install dnf plugins for dnf5 compatibility
echo "Installing DNF plugins..."
dnf install -y dnf5-command\(copr\) dnf5-command\(config-manager\) 2>/dev/null || {
    # Fallback for older DNF versions
    dnf install -y dnf-plugins-core 2>/dev/null || true
}

# Add RPM Fusion repositories
echo "Adding RPM Fusion repositories..."
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable Cisco OpenH264 repository
echo "Enabling Cisco OpenH264 repository..."
sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/fedora-cisco-openh264.repo 2>/dev/null || true

# Enable homeOS repository
echo "Enabling homeOS repository..."
dnf copr enable bubblineyuri/homeOS -y || {
    # Fallback: Add COPR repo manually
    echo "Fallback: Adding homeOS COPR repository manually..."
    curl -fsSL https://copr.fedorainfracloud.org/coprs/bubblineyuri/homeOS/repo/fedora-$(rpm -E %fedora)/bubblineyuri-homeOS-fedora-$(rpm -E %fedora).repo -o /etc/yum.repos.d/bubblineyuri-homeOS.repo
}

echo "✓ RPM repositories setup complete"