#!/bin/bash

echo "::group:: ===$(basename "$0")==="
set -ouex pipefail

echo "=== Copying core files ==="

# Copy core files to the target system
cp /ctx/core/scripts/homeos-update /usr/bin/homeos-update
chmod +x /usr/bin/homeos-update
echo "✓ homeos-update script copied and made executable"

cp /ctx/core/scripts/homeos-update-gui /usr/bin/homeos-update-gui
chmod +x /usr/bin/homeos-update-gui
echo "✓ homeos-update-gui script copied and made executable"

cat > /usr/share/applications/homeos-update-gui.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=homeOS Update
Name[de]=homeOS Aktualisierung
Name[es]=Actualización de homeOS
Name[fr]=Mise à jour de homeOS
Name[it]=Aggiornamento di homeOS
Name[ja]=homeOS アップデート
Name[ko]=homeOS 업데이트
Name[pt]=Atualização do homeOS
Name[ru]=Обновление homeOS
Name[zh_CN]=homeOS 更新
Comment=Check for and install system updates
Exec=/usr/bin/homeos-update-gui
Icon=system-software-update
Terminal=false
Categories=System;Settings;
StartupNotify=true
EOF
echo "✓ homeos-update-gui desktop entry created"

# Copy Flatpak list to the target system
mkdir -p /etc/homeos
cp /ctx/flatpaks.txt /etc/homeos/flatpaks.txt
echo "✓ Flatpak list copied to /etc/homeos/flatpaks.txt"

# Set up gtk.css
echo "Setting up GTK theme..."
cp /ctx/core/branding/gtk.css /usr/share/gtk-4.0/gtk.css
cp /ctx/core/branding/gtk.css /etc/skel/.config/gtk-4.0/gtk.css
echo "✓ GTK theme configured"

# Set up gnome-shell.css
echo "Setting up GNOME Shell theme..."
mkdir -p /usr/share/gnome-shell/theme/
cp /ctx/core/branding/gnome-shell.css /usr/share/gnome-shell/theme/gnome-shell.css
echo "✓ GNOME Shell theme configured"