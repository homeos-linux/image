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
mkdir -p /usr/local/bin

# Create a script to set up common development containers
cat > /usr/local/bin/homeos-setup-containers << 'EOF'
#!/bin/bash
# homeOS Container Setup Script
# Sets up common development environments

set -euo pipefail

show_help() {
    echo "homeOS Container Setup"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  ubuntu      Create Ubuntu development container"
    echo "  arch        Create Arch Linux container"
    echo "  debian      Create Debian stable container"
    echo "  fedora      Create Fedora latest container"
    echo "  docker-test Test Docker installation"
    echo "  list        List available containers"
    echo "  help        Show this help message"
}

setup_ubuntu() {
    echo "Setting up Ubuntu development container..."
    distrobox create --name ubuntu --image ubuntu:latest
    distrobox enter ubuntu -- sudo apt update
    distrobox enter ubuntu -- sudo apt install -y build-essential git curl wget vim nano
    echo "✓ Ubuntu container ready: distrobox enter ubuntu"
}

setup_arch() {
    echo "Setting up Arch Linux container..."
    distrobox create --name arch --image archlinux:latest
    distrobox enter arch -- sudo pacman -Syu --noconfirm
    distrobox enter arch -- sudo pacman -S --noconfirm base-devel git curl wget vim nano
    echo "✓ Arch container ready: distrobox enter arch"
}

setup_debian() {
    echo "Setting up Debian stable container..."
    distrobox create --name debian --image debian:stable
    distrobox enter debian -- sudo apt update
    distrobox enter debian -- sudo apt install -y build-essential git curl wget vim nano
    echo "✓ Debian container ready: distrobox enter debian"
}

setup_fedora() {
    echo "Setting up Fedora development container..."
    distrobox create --name fedora --image fedora:latest
    distrobox enter fedora -- sudo dnf update -y
    distrobox enter fedora -- sudo dnf install -y @development-tools git curl wget vim nano
    echo "✓ Fedora container ready: distrobox enter fedora"
}

list_containers() {
    echo "Available containers:"
    distrobox list
}

test_docker() {
    echo "Testing Docker installation..."
    if docker --version; then
        echo "✓ Docker CLI is working"
        if docker run --rm hello-world; then
            echo "✓ Docker is working correctly"
        else
            echo "✗ Docker test failed - you may need to log out and back in"
        fi
    else
        echo "✗ Docker CLI not found"
    fi
}

case "${1:-help}" in
    ubuntu)
        setup_ubuntu
        ;;
    arch)
        setup_arch
        ;;
    debian)
        setup_debian
        ;;
    fedora)
        setup_fedora
        ;;
    list)
        list_containers
        ;;
    docker-test)
        test_docker
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/homeos-setup-containers

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
Exec=/usr/local/bin/homeos-docker-setup-gui
Icon=docker
Terminal=false
Type=Application
Categories=System;Settings;
Keywords=docker;container;setup;permissions;
StartupNotify=true
NoDisplay=false
EOF

# Create GUI setup script for Docker
cat > /usr/local/bin/homeos-docker-setup-gui << 'EOF'
#!/bin/bash
# GUI Docker setup script using pkexec

# Check if user is already in docker group
if groups | grep -q docker; then
    zenity --info --title="Docker Setup" --text="You already have Docker access!" 2>/dev/null || {
        notify-send "Docker Setup" "You already have Docker access!"
    }
    exit 0
fi

# Ask user if they want to set up Docker
if zenity --question --title="Docker Setup" --text="Would you like to set up Docker access for your user account?\n\nThis will add you to the docker group and requires administrator privileges." 2>/dev/null; then
    # Use pkexec to add user to docker group
    if pkexec usermod -aG docker "$USER"; then
        zenity --info --title="Docker Setup Complete" --text="You have been added to the docker group!\n\nPlease log out and log back in for the changes to take effect." 2>/dev/null || {
            notify-send "Docker Setup Complete" "Please log out and log back in for Docker access."
        }
    else
        zenity --error --title="Docker Setup Failed" --text="Failed to add user to docker group.\n\nPlease run manually: sudo usermod -aG docker $USER" 2>/dev/null || {
            notify-send "Docker Setup Failed" "Run: sudo usermod -aG docker $USER"
        }
    fi
else
    echo "Docker setup cancelled by user"
fi
EOF

chmod +x /usr/local/bin/homeos-docker-setup-gui

# Set up user session integration
echo "Configuring user session integration..."

# Create a script that runs on user login to set up container environment
cat > /usr/local/bin/homeos-container-session-setup << 'EOF'
#!/bin/bash
# Set up container environment for user session

# Enable lingering for the user to allow containers to run without login
loginctl enable-linger "$USER" 2>/dev/null || true

# Set up XDG runtime directory permissions for containers
chmod 755 "$XDG_RUNTIME_DIR" 2>/dev/null || true

# Create containers directory if it doesn't exist
mkdir -p "$HOME/.local/share/containers"

# Set up container shortcuts in applications
mkdir -p "$HOME/.local/share/applications"

# Check if user needs Docker group setup and show notification
if ! groups | grep -q docker; then
    # Show one-time notification about Docker setup
    if [ ! -f "$HOME/.config/homeos-docker-setup-notified" ]; then
        if command -v notify-send &> /dev/null; then
            notify-send "Docker Setup Required" \
                "To use Docker, please run 'Docker Setup' from the applications menu or command: sudo usermod -aG docker $USER" \
                --icon=docker \
                --expire-time=10000
        fi
        mkdir -p "$HOME/.config"
        touch "$HOME/.config/homeos-docker-setup-notified"
    fi
fi
EOF

chmod +x /usr/local/bin/homeos-container-session-setup

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