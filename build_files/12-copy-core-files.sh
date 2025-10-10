#!/bin/bash

echo "::group:: ===$(basename "$0")==="
set -ouex pipefail

echo "=== Copying core files ==="

# Copy core configuration files to the target system
cp /ctx/core/homeos-update /usr/bin/homeos-update
chmod +x /usr/bin/homeos-update
echo "✓ homeos-update script copied and made executable"