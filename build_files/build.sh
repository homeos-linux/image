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

# Step 4: Setup OS identity
echo ""
/ctx/04-setup-os-identity.sh

# Step 5: Setup automatic updates
echo ""
/ctx/05-setup-auto-updates.sh

# Step 6: Enable system services
echo ""
/ctx/06-enable-services.sh

# Step 7: Setup Bazaar configuration
echo ""
/ctx/07-setup-bazaar.sh

# Step 8: Setup container support (Distrobox)
echo ""
/ctx/08-setup-containers.sh

# Step 9: Setup Anaconda installer customizations
echo ""
/ctx/09-setup-anaconda.sh

# Step 10: Copy core files
echo ""
/ctx/10-copy-core-files.sh

# Step 11: Install Flatpak applications
echo ""
/ctx/11-flatpaks.sh

# Step 12: Debloat unnecessary packages
echo ""
/ctx/12-debloat.sh

# Setup user session (special script - not numbered)
echo ""
/ctx/setup-user-session.sh

echo ""
echo "=========================================="
echo "✓ Custom image build process complete!"