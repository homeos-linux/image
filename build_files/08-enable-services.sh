#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Enabling system daemons ==="

# Essential system services
echo "Enabling essential system services..."

# Display manager
systemctl enable gdm.service
echo "✓ GDM (GNOME Display Manager) enabled"

# Network management
systemctl enable NetworkManager.service
systemctl enable NetworkManager-wait-online.service
echo "✓ NetworkManager services enabled"

# Bluetooth
systemctl enable bluetooth.service
echo "✓ Bluetooth service enabled"

# Audio services
systemctl enable pipewire.service
systemctl enable pipewire-pulse.service
systemctl enable wireplumber.service
echo "✓ Audio services (PipeWire) enabled"

# Power management
systemctl enable power-profiles-daemon.service
echo "✓ Power profiles daemon enabled"

# Firmware updates
systemctl enable fwupd.service
echo "✓ Firmware update daemon enabled"

# Flatpak services
systemctl enable flatpak-system-helper.service
echo "✓ Flatpak system helper enabled"

# Time synchronization
systemctl enable systemd-timesyncd.service
echo "✓ Time synchronization enabled"

# System monitoring and logging
systemctl enable systemd-oomd.service
echo "✓ Out-of-memory daemon enabled"

# Security services
systemctl enable accounts-daemon.service
echo "✓ Accounts daemon enabled"

# Hardware detection and management
systemctl enable udisks2.service
echo "✓ Disk management service enabled"

# Printer support (CUPS)
systemctl enable cups.service
echo "✓ CUPS printing service enabled"

# SSH (disabled by default for security, can be enabled later)
systemctl disable sshd.service
echo "✓ SSH service disabled (can be enabled manually if needed)"

# Disable unnecessary services
echo "Disabling unnecessary services..."

# Disable some services that might not be needed
systemctl disable ModemManager.service || true
echo "✓ ModemManager disabled (can be enabled if needed for mobile broadband)"

# Configure firewall (firewalld)
systemctl enable firewalld.service
echo "✓ Firewall (firewalld) enabled"

# Configure systemd-resolved for better DNS
systemctl enable systemd-resolved.service
echo "✓ DNS resolver enabled"

# Enable systemd-homed for better home directory management
systemctl enable systemd-homed.service || true
echo "✓ systemd-homed enabled (if available)"

# Set default target to graphical
systemctl set-default graphical.target
echo "✓ Default target set to graphical"

echo "✓ System daemons configuration complete"

echo "::endgroup::"