#!/bin/bash
set -e

# Clean up
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

ONEPASSWORD_GPG_KEY="3FEF9748469ADBE15DA7CA80AC2D62742012EA22"
PRODUCT_HISTORY_URL="https://app-updates.agilebits.com/product_history/CLI2"
KEYSERVERS="keyserver.ubuntu.com hkps://keys.openpgp.org"

# Install dependencies
check_packages apt-transport-https curl ca-certificates gnupg2 dirmngr unzip

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64)
        OP_ARCH="amd64"
        ;;
    arm64)
        OP_ARCH="arm64"
        ;;
    armhf)
        OP_ARCH="arm"
        ;;
    i386)
        OP_ARCH="386"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

TMP_DIR=$(mktemp -d -t op-install.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR" || exit 1

if ! PRODUCT_HISTORY_PAGE=$(curl -fsSL --show-error "$PRODUCT_HISTORY_URL"); then
    echo "Unable to fetch 1Password CLI release history from: $PRODUCT_HISTORY_URL"
    exit 1
fi

# The URL format follows the official CLI2 history link pattern, for example:
# https://cache.agilebits.com/dist/1P/op2/pkg/v2.35.0/op_linux_amd64_v2.35.0.zip
DOWNLOAD_URL=$(printf '%s\n' "$PRODUCT_HISTORY_PAGE" \
    | grep -oE "https://cache\\.agilebits\\.com/dist/1P/op2/pkg/v[0-9]+\\.[0-9]+\\.[0-9]+/op_linux_${OP_ARCH}_v[0-9]+\\.[0-9]+\\.[0-9]+\\.zip" \
    | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Unable to determine the latest 1Password CLI release URL for architecture: $OP_ARCH"
    exit 1
fi
case "$DOWNLOAD_URL" in
    https://cache.agilebits.com/*)
        ;;
    *)
        echo "Unexpected 1Password CLI download URL: $DOWNLOAD_URL"
        exit 1
        ;;
esac
DIRECTORY_VERSION=$(printf '%s\n' "$DOWNLOAD_URL" | sed -nE 's#.*/pkg/v([0-9]+\.[0-9]+\.[0-9]+)/op_linux_.*#\1#p')
FILENAME_VERSION=$(printf '%s\n' "$DOWNLOAD_URL" | sed -nE 's#.*/op_linux_[^_]+_v([0-9]+\.[0-9]+\.[0-9]+)\.zip#\1#p')
if [ -z "$DIRECTORY_VERSION" ] || [ "$DIRECTORY_VERSION" != "$FILENAME_VERSION" ]; then
    echo "Invalid 1Password CLI release URL version format: $DOWNLOAD_URL"
    exit 1
fi

if ! curl -fsSL --show-error "$DOWNLOAD_URL" -o op.zip; then
    echo "Failed to download 1Password CLI from: $DOWNLOAD_URL"
    exit 1
fi
if ! unzip -q op.zip op op.sig; then
    echo "Failed to extract 1Password CLI archive"
    exit 1
fi

KEY_RETRIEVED=false
for KEYSERVER in $KEYSERVERS; do
    if gpg --batch --keyserver "$KEYSERVER" --receive-keys "$ONEPASSWORD_GPG_KEY"; then
        KEY_RETRIEVED=true
        break
    fi
done

if [ "$KEY_RETRIEVED" = false ]; then
    echo "Failed to retrieve 1Password GPG key from configured keyservers"
    exit 1
fi

# Signature validity is tied to the official 1Password signing key fingerprint above.
if ! gpg --batch --verify op.sig op; then
    echo "GPG signature verification failed for 1Password CLI binary"
    exit 1
fi

if ! getent group onepassword-cli > /dev/null; then
    groupadd onepassword-cli
fi

# 1Password recommends setgid with onepassword-cli so op can securely access its credential store.
install -m 0755 -g onepassword-cli op /usr/local/bin/op
chmod 2755 /usr/local/bin/op

op --version
