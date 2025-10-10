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
mkdir -p /usr/local/bin

cat > /usr/local/bin/update-notification << 'EOF'
#!/bin/bash
# Simple update notification for homeOS

# Check if updates are staged
if rpm-ostree status | grep -q "staged"; then
    echo "homeOS: Updates are staged and ready for reboot"
    # You can add desktop notification here if needed
    # notify-send "homeOS Updates" "Updates are ready. Reboot when convenient."
fi

# Check if Flatpak updates are available
if flatpak remote-ls --updates flathub 2>/dev/null | grep -q .; then
    echo "homeOS: Flatpak updates available"
    # notify-send "homeOS Updates" "Flatpak updates are available"
fi
EOF

chmod +x /usr/local/bin/update-notification

# Set up bootc auto-update (if available)
echo "Configuring bootc automatic updates..."
if command -v bootc &> /dev/null; then
    # Enable bootc auto-update
    mkdir -p /etc/bootc
    
    cat > /etc/bootc/update.toml << 'EOF'
# bootc automatic update configuration
[updates]
# Check for updates automatically
enabled = true

# Update policy: "staged" stages updates but doesn't reboot
# "auto" would automatically reboot (not recommended for desktop)
policy = "staged"

# Check interval (in seconds) - daily
interval = 86400
EOF

    # Enable bootc update service if it exists
    if systemctl list-unit-files | grep -q bootc-update; then
        systemctl enable bootc-update.timer || true
    fi
fi

# Create a simple update status script
cat > /usr/local/bin/homeos-update-status << 'EOF'
#!/bin/bash
# Show update status for homeOS

echo "homeOS Update Status"
echo "===================="
echo ""

echo "Container Image Updates:"
if command -v bootc &> /dev/null; then
    bootc status || rpm-ostree status
else
    rpm-ostree status
fi

echo ""
echo "Flatpak Updates:"
flatpak remote-ls --updates flathub 2>/dev/null || echo "No Flatpak updates available"

echo ""
echo "Update Services Status:"
echo "- rpm-ostreed-automatic.timer: $(systemctl is-enabled rpm-ostreed-automatic.timer 2>/dev/null || echo 'not available')"
echo "- flatpak-update.timer: $(systemctl is-enabled flatpak-update.timer 2>/dev/null || echo 'not available')"
if systemctl list-unit-files | grep -q bootc-update.timer; then
    echo "- bootc-update.timer: $(systemctl is-enabled bootc-update.timer 2>/dev/null || echo 'not available')"
fi
EOF

chmod +x /usr/local/bin/homeos-update-status

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