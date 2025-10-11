#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Setting up Distrobox and container support ==="

# Enable and configure systemd services for containers
echo "Configuring container services..."

# Enable podman socket for rootless containers
systemctl --global enable podman.socket
echo "✓ Podman socket enabled for rootless containers"

# Symlink podman to docker for compatibility
if ! command -v docker &> /dev/null; then
    ln -s /usr/bin/podman /usr/bin/docker
    echo "✓ Symlinked podman to docker"
fi

# Create helpful container management scripts
# Create a script to set up common development containers
cp /ctx/core/scripts/homeos-setup-containers /usr/bin/homeos-setup-containers

echo "✓ Container setup script created: homeos-setup-containers"

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