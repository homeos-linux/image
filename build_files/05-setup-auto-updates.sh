#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Setting up automatic updates ==="

# Enable rpm-ostree automatic updates
echo "Enabling rpm-ostree automatic updates..."
systemctl enable rpm-ostreed-automatic.timer

# Configure automatic updates policy
echo "Configuring automatic update policy..."
mkdir -p /etc/rpm-ostreed.conf.d

# Create automatic updates configuration
cat > /etc/rpm-ostreed.conf.d/10-automatic-updates.conf << 'EOF'
# Automatic updates configuration for homeOS
[Daemon]
# Enable automatic updates
AutomaticUpdatePolicy=stage

# Check for updates daily
IdleExitTimeout=60

[Updates]
# Stage updates automatically but don't reboot
# Users can reboot manually when convenient
AutomaticUpdatePolicy=stage
EOF

# Enable and configure systemd timers for updates
echo "Setting up update timers..."

# Enable the automatic update timer (daily check)
systemctl enable rpm-ostreed-automatic.timer

# Create a custom timer for Flatpak updates
mkdir -p /etc/systemd/system

cat > /etc/systemd/system/flatpak-update.service << 'EOF'
[Unit]
Description=Update Flatpak applications
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update --system --noninteractive
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/lib/flatpak
User=root
EOF

cat > /etc/systemd/system/flatpak-update.timer << 'EOF'
[Unit]
Description=Update Flatpak applications daily
Requires=flatpak-update.service

[Timer]
OnCalendar=daily
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable Flatpak automatic updates
systemctl enable flatpak-update.timer

# Configure systemd-oomd for better memory management during updates
echo "Configuring memory management..."
mkdir -p /etc/systemd/oomd.conf.d

cat > /etc/systemd/oomd.conf.d/10-update-protection.conf << 'EOF'
[OOM]
# Protect system during updates
DefaultMemoryPressureDurationSec=20s
DefaultMemoryPressureLimit=80%
EOF

# Create update notification script (optional)
cp /ctx/core/scripts/update-notification /usr/bin/update-notification

# Set up bootc auto-update (if available)
echo "Configuring bootc automatic updates..."
if command -v bootc &> /dev/null; then
    # Enable bootc auto-update
    mkdir -p /etc/bootc
    cp /ctx/core/bootc/update.toml /etc/bootc/update.toml

    # Enable bootc update service if it exists
    if systemctl list-unit-files | grep -q bootc-update; then
        systemctl enable bootc-update.timer || true
    fi
fi

# Create a simple update status script
cp /ctx/core/scripts/homeos-update-status /usr/bin/homeos-update-status

echo "✓ Automatic updates configuration complete"
echo ""
echo "Update services enabled:"
echo "  - rpm-ostreed-automatic.timer (daily OS updates)"
echo "  - flatpak-update.timer (daily Flatpak updates)"
echo ""
echo "Available commands:"
echo "  - homeos-update-status: Check update status"
echo "  - update-notification: Check for pending updates"

echo "::endgroup::"