#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# homeOS Configuration
IMAGE_PRETTY_NAME="homeOS"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/homeos-linux"
DOCUMENTATION_URL="https://github.com/homeos-linux/image"
SUPPORT_URL="https://github.com/homeos-linux/image/issues/"
BUG_SUPPORT_URL="https://github.com/homeos-linux/image/issues/"
CODE_NAME="Genesis"
VERSION="${VERSION:-1.0.0}"

# Use environment variables if available, otherwise use defaults
IMAGE_NAME="fedora"
IMAGE_VENDOR="${IMAGE_VENDOR:-homeos-linux}"
BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-fedora-bootc}"
FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-42}"
UBLUE_IMAGE_TAG="${UBLUE_IMAGE_TAG:-latest}"
SHA_HEAD_SHORT="${SHA_HEAD_SHORT:-}"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$IMAGE_INFO")"

# Image Flavor (for future variants like nvidia, etc.)
image_flavor="main"
if [[ "${IMAGE_NAME}" =~ nvidia ]]; then
  image_flavor="nvidia"
fi
if [[ "${IMAGE_NAME}" =~ nvidia-open ]]; then
  image_flavor="nvidia-open"
fi

echo "Creating image info file..."
cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-flavor": "$image_flavor",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag":"$UBLUE_IMAGE_TAG",
  "base-image-name": "$BASE_IMAGE_NAME",
  "fedora-version": "$FEDORA_MAJOR_VERSION"
}
EOF

echo "Updating OS release information..."

# OS Release File - Update system identity
sed -i "s|^ID=.*|ID=$IMAGE_NAME|" /usr/lib/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (Version: ${VERSION})\"|" /usr/lib/os-release
sed -i "s|^NAME=.*|NAME=\"$IMAGE_PRETTY_NAME\"|" /usr/lib/os-release
sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" /usr/lib/os-release
sed -i "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:homeos:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
sed -i "s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME=\"${IMAGE_PRETTY_NAME,}\"|" /usr/lib/os-release
sed -i "s|^ID_LIKE=.*|ID_LIKE=\"$IMAGE_LIKE\"|" /usr/lib/os-release

# Remove Red Hat specific entries
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release

# Update version information
sed -i "s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"$CODE_NAME\"|" /usr/lib/os-release
sed -i "s|^VERSION=.*|VERSION=\"${VERSION} (${BASE_IMAGE_NAME^})\"|" /usr/lib/os-release
sed -i "s|^OSTREE_VERSION=.*|OSTREE_VERSION=\'${VERSION}\'|" /usr/lib/os-release

# Add build ID if available
if [[ -n "${SHA_HEAD_SHORT:-}" ]]; then
  echo "BUILD_ID=\"$SHA_HEAD_SHORT\"" >>/usr/lib/os-release
fi

# Added in systemd 249 - Image identification
echo "IMAGE_ID=\"${IMAGE_NAME}\"" >> /usr/lib/os-release
echo "IMAGE_VERSION=\"${VERSION}\"" >> /usr/lib/os-release

# Fix bootloader issues caused by ID no longer being fedora
if [[ -f /usr/sbin/grub2-switch-to-blscfg ]]; then
  sed -i "s|^EFIDIR=.*|EFIDIR=\"fedora\"|" /usr/sbin/grub2-switch-to-blscfg
fi

echo "Installing GRUB theme..."
cd /tmp
git clone https://github.com/homeos-linux/grub-theme.git
mkdir -p /boot/grub2/themes/
cp -r grub-theme /boot/grub2/themes/homeos-theme
sed -i 's|^GRUB_TERMINAL_OUTPUT=.*|GRUB_TERMINAL_OUTPUT="gfxterm"|' /usr/sbin/grub2-switch-to-blscfg
sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub2/themes/homeos-theme/theme.txt"|' /usr/sbin/grub2-switch-to-blscfg
rm -r grub-theme
if grub2-probe / >/dev/null 2>&1; then
  grub2-mkconfig -o /etc/grub2.cfg
else
  echo "Skipping grub2-mkconfig (no block device)"
fi


echo "✓ OS identity setup complete for homeOS"

echo "::endgroup::"