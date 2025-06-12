#!/usr/bin/env bash
set -e

ARCH="$(dpkg --print-architecture)"

if [ "$ARCH" = "amd64" ]; then
    # On amd64, do nothing and exit successfully
    exit 0
fi

echo "Non-amd64 detected: $ARCH. Enabling amd64 multiarch and sources..."

# Enable amd64 architecture
dpkg --add-architecture amd64

# Add amd64 source to ubuntu.sources if not already present
UBUNTU_SOURCES="/etc/apt/sources.list.d/ubuntu.sources"
if ! grep -q "Architectures: amd64" /etc/apt/sources.list.d/*.sources 2>/dev/null; then
    cat <<EOF > "$UBUNTU_SOURCES"
Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports
Suites: noble noble-updates noble-backports noble-security
Components: main restricted universe multiverse
Architectures: arm64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://archive.ubuntu.com/ubuntu
Suites: noble noble-updates noble-backports noble-security
Components: main restricted universe multiverse
Architectures: amd64
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    echo "Overwrote $UBUNTU_SOURCES for amd64 packages."
else
    echo "amd64 source already present."
fi

apt-get update

# Install the amd64 libraries
apt-get install -y libc6:amd64 libstdc++6:amd64

# Clean up
rm -rf /var/lib/apt/lists/*
