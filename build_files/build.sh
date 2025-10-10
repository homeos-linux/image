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

# Step 5: Setup OS identity
echo ""
/ctx/05-setup-os-identity.sh

# Step 6: Setup automatic updates
echo ""
/ctx/06-setup-auto-updates.sh

# Step 7: Enable system services
echo ""
/ctx/07-enable-services.sh

# Step 8: Setup Bazaar configuration
echo ""
/ctx/08-setup-bazaar.sh

# Step 9: Setup container support (Distrobox)
echo ""
/ctx/09-setup-containers.sh

# Step 10: Setup Anaconda installer customizations
echo ""
/ctx/10-setup-anaconda.sh

# Step 11: Copy core files
echo ""
/ctx/11-copy-core-files.sh

# Setup user session (special script - not numbered)
echo ""
/ctx/setup-user-session.sh

echo ""
echo "=========================================="
echo "✓ Custom image build process complete!"