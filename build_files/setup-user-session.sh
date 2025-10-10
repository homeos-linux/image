#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Setting up user session configuration ==="

# Create user session setup script that runs on first login
echo "Creating first-login setup script..."

mkdir -p /etc/skel/.config/autostart
mkdir -p /etc/skel/.local/share/applications
mkdir -p /usr/local/bin

# Create the first-login setup script
cat > /usr/local/bin/homeos-first-login-setup << 'EOF'
#!/bin/bash
# homeOS first login setup script
# This script runs automatically on first user login and when configuration updates

# Script version - increment when adding new features
SCRIPT_VERSION="1.1.0"
VERSION_FILE="$HOME/.config/homeos-first-login-version"

# Check current version
CURRENT_VERSION=""
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
fi

# Skip if already run with same or newer version
if [ "$CURRENT_VERSION" = "$SCRIPT_VERSION" ]; then
    exit 0
fi

echo "Setting up homeOS user session (version $SCRIPT_VERSION)..."

# Show what's being updated if this is an upgrade
if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$SCRIPT_VERSION" ]; then
    echo "Upgrading homeOS user configuration from $CURRENT_VERSION to $SCRIPT_VERSION"
fi

# Enable GNOME Shell extensions
echo "Enabling GNOME Shell extensions..."

# Enable extensions using gsettings
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true

# Enable user-theme extension
gsettings set org.gnome.shell.extensions.user-theme name ""

# Configure GNOME settings
echo "Configuring GNOME settings..."

# Set up favorite apps in dock
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.mozilla.firefox.desktop', 'io.github.kolunmi.Bazaar.desktop']"

# Configure interface settings
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface enable-hot-corners false
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Configure window management
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'

# Configure file manager
gsettings set org.gnome.nautilus.preferences show-hidden-files false
gsettings set org.gnome.nautilus.preferences show-image-thumbnails 'always'

# Set up wallpaper (if custom wallpaper exists)
if [ -f "/usr/share/backgrounds/homeos-default.jpg" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/homeos-default.jpg"
    gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/homeos-default.jpg"
fi

# Configure power settings
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800

# Set up automatic screen lock
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.screensaver lock-delay 300

# Configure privacy settings
gsettings set org.gnome.desktop.privacy report-technical-problems false
gsettings set org.gnome.desktop.privacy send-software-usage-stats false

echo "✓ GNOME configuration complete"

# Set up demonhide autostart
echo "Setting up demonhide autostart..."
cat > "$HOME/.config/autostart/demonhide.desktop" << 'AUTOSTART_EOF'
[Desktop Entry]
Type=Application
Name=DemonHide
Comment=Hide system tray applications
Exec=demonhide
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
AUTOSTART_EOF

echo "✓ DemonHide autostart configured"

# Create welcome notification
echo "Creating welcome notification..."
cat > "$HOME/.config/autostart/homeos-welcome.desktop" << 'WELCOME_EOF'
[Desktop Entry]
Type=Application
Name=homeOS Welcome
Comment=Show welcome message
Exec=/usr/local/bin/homeos-welcome-notification
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
StartupNotify=false
WELCOME_EOF

# Mark setup as complete with version
mkdir -p "$HOME/.config"
echo "$SCRIPT_VERSION" > "$VERSION_FILE"
echo "✓ homeOS user setup complete (version $SCRIPT_VERSION)"

# Show welcome notification (only on first install, not upgrades)
if [ -z "$CURRENT_VERSION" ] && command -v notify-send &> /dev/null; then
    notify-send "Welcome to homeOS!" "Your desktop has been configured. Enjoy your new system!" --icon=dialog-information
fi
EOF

chmod +x /usr/local/bin/homeos-first-login-setup

# Create welcome notification script
cat > /usr/local/bin/homeos-welcome-notification << 'EOF'
#!/bin/bash
# Welcome notification for homeOS

# Wait a bit for desktop to load
sleep 10

# Check if this is first run
if [ ! -f "$HOME/.config/homeos-welcome-shown" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send "Welcome to homeOS!" \
            "Welcome to homeOS Genesis! Your desktop is ready to use.\n\nTip: Check for updates with 'homeos-update-status'" \
            --icon=dialog-information \
            --expire-time=10000
    fi
    
    touch "$HOME/.config/homeos-welcome-shown"
fi

# Remove the autostart entry after first run
rm -f "$HOME/.config/autostart/homeos-welcome.desktop" 2>/dev/null
EOF

chmod +x /usr/local/bin/homeos-welcome-notification

# Create autostart entry in skeleton for new users
cat > /etc/skel/.config/autostart/homeos-first-login.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=homeOS First Login Setup
Comment=Configure homeOS user session on first login
Exec=/usr/local/bin/homeos-first-login-setup
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
StartupNotify=false
EOF

# Set up default GNOME extensions to be enabled
echo "Configuring default GNOME extensions..."

# Create dconf database for default settings
mkdir -p /etc/dconf/db/homeos.d
mkdir -p /etc/dconf/profile

# Create user profile
cat > /etc/dconf/profile/user << 'EOF'
user-db:user
system-db:homeos
EOF

# Create default settings
cat > /etc/dconf/db/homeos.d/00-homeos-defaults << 'EOF'
[org/gnome/shell]
enabled-extensions=['dash-to-dock@micxgx.gmail.com', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'appindicatorsupport@rgcjonas.gmail.com']

[org/gnome/shell/extensions/dash-to-dock]
dock-position='BOTTOM'
extend-height=false
dock-fixed=false
autohide=true
intellihide=true

[org/gnome/desktop/interface]
clock-show-weekday=true
show-battery-percentage=true
enable-hot-corners=false
color-scheme='prefer-dark'
gtk-theme='Adwaita-dark'

[org/gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'
focus-mode='click'

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-timeout=3600
sleep-inactive-battery-timeout=1800

[org/gnome/desktop/screensaver]
lock-enabled=true
lock-delay=uint32 300

[org/gnome/desktop/privacy]
report-technical-problems=false
send-software-usage-stats=false
EOF

# Update dconf database
dconf update

echo "✓ User session configuration setup complete"
echo ""
echo "User session features:"
echo "  - Automatic GNOME extensions configuration"
echo "  - DemonHide autostart setup"
echo "  - Welcome notification on first login"
echo "  - Optimized GNOME settings"
echo "  - Privacy-focused defaults"

echo "::endgroup::"