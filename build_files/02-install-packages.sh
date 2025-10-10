#!/bin/bash
# Step 2: Install RPM packages

set -ouex pipefail

echo "=== Installing RPM packages ==="

# Read packages from packages.txt file
PACKAGES_FILE="/ctx/packages.txt"

if [ -f "$PACKAGES_FILE" ]; then
    echo "Reading packages from $PACKAGES_FILE..."
    # Read non-empty, non-comment lines from the file
    PACKAGES=($(grep -v '^[[:space:]]*#' "$PACKAGES_FILE" | grep -v '^[[:space:]]*$' | tr '\n' ' '))
    
    if [ ${#PACKAGES[@]} -gt 0 ]; then
        echo "Installing ${#PACKAGES[@]} packages..."
        dnf install -y "${PACKAGES[@]}"
        echo "✓ RPM packages installation complete"
    else
        echo "No packages specified for installation in $PACKAGES_FILE"
    fi
else
    echo "Packages file not found: $PACKAGES_FILE"
    echo "Skipping RPM package installation"
fi