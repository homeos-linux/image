#!/bin/bash
set -euo pipefail

echo "Setting up Anaconda installer customizations..."

# Install Anaconda development packages for customization
dnf install -y anaconda-core anaconda-gui python3-kickstart

# Copy homeOS branding
mkdir -p /usr/share/anaconda/pixmaps
mkdir -p /usr/share/anaconda/branding/homeos

# Copy custom addon
mkdir -p /usr/share/anaconda/addons/org_homeos_setup
cp /ctx/core/anaconda_addon/org_homeos_setup.py /usr/share/anaconda/addons/org_homeos_setup/
cp /ctx/core/anaconda_addon/homeos_setup.glade /usr/share/anaconda/addons/org_homeos_setup/

# Copy branding configuration
cp /ctx/core/branding/product.conf /usr/share/anaconda/branding/homeos/

# Create homeOS installer theme
cat > /usr/share/anaconda/branding/homeos/anaconda-gtk.css << 'EOF'
/* homeOS Anaconda Theme */

/* Main window styling */
.anaconda-main-window {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Sidebar styling */
.anaconda-sidebar {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    margin: 20px;
}

/* Button styling */
.anaconda-button {
    background: linear-gradient(45deg, #667eea, #764ba2);
    border: none;
    border-radius: 8px;
    color: white;
    padding: 12px 24px;
    font-weight: 600;
}

.anaconda-button:hover {
    background: linear-gradient(45deg, #5a6fd8, #6a4190);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

/* Progress bar */
.anaconda-progress {
    background: linear-gradient(90deg, #667eea, #764ba2);
    border-radius: 4px;
}

/* Welcome screen */
.anaconda-welcome-title {
    font-size: 2.5em;
    font-weight: 300;
    color: white;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.anaconda-welcome-subtitle {
    font-size: 1.2em;
    color: rgba(255, 255, 255, 0.9);
    margin-top: 10px;
}
EOF

# Create desktop file for homeOS installer customization
cat > /usr/share/applications/homeos-installer.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=homeOS Installer
Comment=Install homeOS - Your Home Operating System
Icon=system-software-install
Exec=liveinst --product=homeOS
Categories=System;Settings;
NoDisplay=false
Terminal=false
EOF

echo "Anaconda installer customization complete!"