#!/bin/bash

set -ouex pipefail

echo "Starting custom image build process..."
echo "=========================================="

# Step 1: Setup RPM repositories
echo ""
/ctx/01-setup-repos.sh

# Step 2: Install RPM packages
echo ""
/ctx/02-install-packages.sh

# Step 3: Setup multimedia codecs
echo ""
/ctx/03-setup-multimedia.sh

# Step 4: Setup Flatpak
echo ""
/ctx/04-setup-flatpak.sh

# Step 5: Install Flatpak applications
echo ""
/ctx/05-install-flatpaks.sh

# Step 6: Setup OS identity
echo ""
/ctx/06-setup-os-identity.sh

# Step 7: Setup automatic updates
echo ""
/ctx/07-setup-auto-updates.sh

# Step 8: Enable system services
echo ""
/ctx/08-enable-services.sh

# Step 9: Setup Bazaar configuration
echo ""
/ctx/09-setup-bazaar.sh

# Step 10: Setup container support (Distrobox)
echo ""
/ctx/10-setup-containers.sh

# Setup user session (special script - not numbered)
echo ""
/ctx/setup-user-session.sh

echo ""
echo "=========================================="
echo "✓ Custom image build process complete!"