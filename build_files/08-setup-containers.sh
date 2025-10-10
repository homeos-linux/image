#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Setting up Distrobox and container support ==="

# Enable and configure systemd services for containers
echo "Configuring container services..."

# Enable Docker service
systemctl enable docker.service
echo "✓ Docker service enabled"

# Enable podman socket for rootless containers
systemctl --global enable podman.socket
echo "✓ Podman socket enabled for rootless containers"

# Create distrobox configuration directory
mkdir -p /etc/distrobox

# Configure Docker group
echo "Configuring Docker group..."
groupadd -f docker
echo "✓ Docker group created"

# Create Docker configuration
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "journald",
  "storage-driver": "overlay2",
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false
}
EOF

echo "✓ Docker daemon configuration created"

# Create default distrobox configuration
cat > /etc/distrobox/distrobox.conf << 'EOF'
# homeOS Distrobox Configuration
# This file contains default settings for Distrobox on homeOS

# Default container manager (podman is preferred on homeOS)
container_manager="podman"

# Default image for new containers
container_image_default="registry.fedoraproject.org/fedora-toolbox:latest"

# Enable X11 forwarding by default
container_init_hook="xhost +si:localuser:\$USER 2>/dev/null || true"

# Default additional packages to install in containers
container_additional_packages="git vim nano curl wget htop"

# Enable home directory integration
container_home_prefix="\$HOME/.local/share/containers/distrobox"
EOF

echo "✓ Distrobox configuration created"

# Create helpful container management scripts
# Create a script to set up common development containers
cp /ctx/core/scripts/homeos-setup-containers /usr/bin/homeos-setup-containers

echo "✓ Container setup script created: homeos-setup-containers"

# Create desktop integration for common tasks
mkdir -p /usr/share/applications

cat > /usr/share/applications/homeos-container-manager.desktop << 'EOF'
[Desktop Entry]
Name=Container Manager
Comment=Manage development containers with Distrobox
GenericName=Container Management
Exec=io.github.dvlv.boxbuddyrs
Icon=io.github.dvlv.boxbuddyrs
Terminal=false
Type=Application
Categories=System;Development;
Keywords=container;distrobox;podman;development;
StartupNotify=true
EOF

# Create desktop application for Docker setup
cat > /usr/share/applications/homeos-docker-setup.desktop << 'EOF'
[Desktop Entry]
Name=Docker Setup
Comment=Set up Docker access for your user account
GenericName=Container Setup
Exec=/usr/bin/homeos-docker-setup-gui
Icon=docker
Terminal=false
Type=Application
Categories=System;Settings;
Keywords=docker;container;setup;permissions;
StartupNotify=true
NoDisplay=false
EOF

# Create GUI setup script for Docker
cp /ctx/core/scripts/homeos-docker-setup-gui /usr/bin/homeos-docker-setup-gui

# Set up user session integration
echo "Configuring user session integration..."

# Create a script that runs on user login to set up container environment
cp /ctx/core/scripts/homeos-container-session-setup /usr/bin/homeos-container-session-setup

echo "✓ Container session setup script created"

# Configure SELinux for containers (if enabled)
if command -v setsebool &> /dev/null; then
    echo "Configuring SELinux for containers..."
    setsebool -P container_manage_cgroup true 2>/dev/null || true
    echo "✓ SELinux configured for containers"
fi

# Set up container image pre-caching (optional)
echo "Setting up container image pre-caching..."
mkdir -p /usr/share/distrobox/images

# Create a service to pre-pull common images
cat > /etc/systemd/system/homeos-container-images.service << 'EOF'
[Unit]
Description=Pre-cache common container images for homeOS
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/bin/bash -c 'podman pull registry.fedoraproject.org/fedora-toolbox:latest || true'
ExecStart=/bin/bash -c 'podman pull ubuntu:latest || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the pre-caching service (but don't start it during build)
systemctl enable homeos-container-images.service

echo "✓ Container image pre-caching configured"

echo ""
echo "Container support setup complete:"
echo "  - Docker CE: Standard containerization with compose support"
echo "  - Distrobox: Command-line container management"
echo "  - BoxBuddy: GUI container management" 
echo "  - Distroshelf: Container application launcher"
echo "  - Podman: Alternative container runtime"
echo "  - Helper script: homeos-setup-containers"
echo ""
echo "Docker commands:"
echo "  docker run hello-world              # Test Docker"
echo "  docker-compose up                   # Run compose file"
echo ""
echo "Distrobox commands:"
echo "  distrobox create --name mycontainer --image ubuntu:latest"
echo "Or use BoxBuddy for a graphical interface"
echo ""
echo "⚠️  Note: Users need to log out and back in for Docker group access"

echo "::endgroup::"