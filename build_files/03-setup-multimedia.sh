#!/bin/bash
# Step 3: Setup multimedia codecs

set -ouex pipefail

echo "=== Setting up multimedia codecs ==="

# Swap to full ffmpeg
echo "Swapping to full ffmpeg..."
dnf swap ffmpeg-free ffmpeg --allowerasing -y

# Update multimedia packages
echo "Updating multimedia packages..."
dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y

echo "✓ Multimedia codecs setup complete"