#!/usr/bin/env bash
# Install ov from a GitHub Release binary.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/vivarcus/vivarcus-cli/main/scripts/install-ov.sh | bash
#   VERSION=v26R3.3-13304 bash install-ov.sh
set -euo pipefail

VERSION="${VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
REPO="vivarcus/vivarcus-cli"

mkdir -p "$INSTALL_DIR"

if [ "$VERSION" = "latest" ]; then
  URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -o 'https://[^"]*ov-linux-amd64[^"]*' | head -1 || true)
else
  URL="https://github.com/${REPO}/releases/download/${VERSION}/ov-linux-amd64"
fi

if [ -z "${URL:-}" ]; then
  cat <<'EOF'
No ov CLI release found for this repository yet.

Download ov from your Vivarcus Vault release notes, or contact Vivarcus support
for the CLI build matching your Vault version.

See README.md
EOF
  exit 1
fi

TMP=$(mktemp)
curl -fsSL "$URL" -o "$TMP"
chmod +x "$TMP"
mv "$TMP" "$INSTALL_DIR/ov"
echo "installed ov to $INSTALL_DIR/ov"
