#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

echo "=== Setting up Bazaar configuration ==="

# Create Bazaar configuration directories
mkdir -p /etc/bazaar
mkdir -p /usr/share/bazaar

# Copy Bazaar configuration files
echo "Installing Bazaar configuration files..."

# Copy curated applications configuration
cp /ctx/core/bazaar/curated.yaml /etc/bazaar/curated.yaml
echo "✓ Curated applications configuration installed"

# Copy main configuration with hooks
cp /ctx/core/bazaar/main.yaml /etc/bazaar/main.yaml
echo "✓ Main configuration with hooks installed"

# Copy blocklist
cp /ctx/core/bazaar/blocklist.txt /etc/bazaar/blocklist.txt
echo "✓ Application blocklist installed"

# Set appropriate permissions
chmod 644 /etc/bazaar/*.yaml
chmod 644 /etc/bazaar/blocklist.txt
echo "✓ Permissions set for Bazaar configuration files"

# Create a symbolic link for the curated config in a standard location
ln -sf /etc/bazaar/curated.yaml /usr/share/bazaar/curated.yaml || true

# Log the configuration for debugging
echo ""
echo "Bazaar configuration summary:"
echo "  - Curated apps: /etc/bazaar/curated.yaml"
echo "  - Main config: /etc/bazaar/main.yaml"
echo "  - Blocklist: /etc/bazaar/blocklist.txt"

echo "✓ Bazaar configuration complete"

echo "::endgroup::"