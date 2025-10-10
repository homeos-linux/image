#!/bin/bash
# Step 3: Setup multimedia codecs

set -ouex pipefail

echo "=== Setting up multimedia codecs ==="

# Swap to full ffmpeg
echo "Swapping to full ffmpeg..."
dnf swap ffmpeg-free ffmpeg --allowerasing -y

# Install multimedia packages directly instead of using @multimedia group
echo "Installing multimedia packages..."
dnf install -y --setopt="install_weak_deps=False" --skip-unavailable \
    gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-freeworld \
    gstreamer1-plugins-ugly \
    gstreamer1-plugin-libav \
    gstreamer1-vaapi \
    libva-utils \
    intel-media-driver \
    mesa-va-drivers \
    mesa-vdpau-drivers

echo "✓ Multimedia codecs setup complete"