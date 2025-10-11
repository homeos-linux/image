#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Setting up user session configuration ==="

# Create user session setup script that runs on first login
echo "Creating first-login setup script..."

mkdir -p /etc/skel/.config/autostart
mkdir -p /etc/skel/.local/share/applications

# Create the first-login setup script
cp /ctx/core/scripts/homeos-first-login-setup /usr/bin/homeos-first-login-setup

# Create autostart entry in skeleton for new users
cat > /etc/skel/.config/autostart/homeos-first-login.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=homeOS First Login Setup
Comment=Configure homeOS user session on first login
Exec=/usr/bin/homeos-first-login-setup
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

[org/gnome/desktop/app-folders]
folder-children=['Utilities', 'YaST', 'LibreOffice']

[org/gnome/desktop/app-folders/folders/LibreOffice]
name='LibreOffice'
categories=['Office']
apps=['org.libreoffice.LibreOffice.desktop', 'org.libreoffice.LibreOffice-writer.desktop', 'org.libreoffice.LibreOffice-calc.desktop', 'org.libreoffice.LibreOffice-impress.desktop', 'org.libreoffice.LibreOffice-draw.desktop', 'org.libreoffice.LibreOffice-base.desktop', 'org.libreoffice.LibreOffice-math.desktop', 'org.libreoffice.LibreOffice-startcenter.desktop']
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