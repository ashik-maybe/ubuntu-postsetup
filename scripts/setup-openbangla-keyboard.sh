#!/usr/bin/env bash

# OpenBangla Keyboard Setup Script for Ubuntu/Debian
# Author: ChatGPT
# Version: 1.1
# Usage:
#   ./setup-openbangla-keyboard.sh           --> install or upgrade
#   ./setup-openbangla-keyboard.sh --remove  --> uninstall

set -e

# Constants
INSTALL_CMD='bash -c "$(wget -q https://raw.githubusercontent.com/OpenBangla/OpenBangla-Keyboard/master/tools/install.sh -O -)"'
PKG_NAME="openbangla-keyboard"

# Ensure script is run with bash
ensure_bash_shell() {
  if [ -z "$BASH_VERSION" ]; then
    echo "[!] Please run this script using bash:"
    echo "    bash ./setup-openbangla-keyboard.sh"
    exit 1
  fi
}

# Check if package is installed
is_installed() {
  dpkg -s "$PKG_NAME" &> /dev/null
}

# Get installed version
get_installed_version() {
  dpkg -s "$PKG_NAME" 2>/dev/null | grep '^Version:' | awk '{print $2}'
}

# Compare versions (returns true if version is <= 1.5.1)
is_legacy_version() {
  local version="$1"
  dpkg --compare-versions "$version" le "1.5.1"
}

# Uninstall logic
uninstall_openbangla() {
  if is_installed; then
    echo "[*] Uninstalling OpenBangla Keyboard..."
    sudo apt remove -y "$PKG_NAME"
    echo "[✓] Uninstalled."
  else
    echo "[i] OpenBangla Keyboard is not installed."
  fi
}

# Install logic
install_openbangla() {
  echo "[*] Installing latest OpenBangla Keyboard..."
  eval "$INSTALL_CMD"
  echo "[✓] Installation complete."
  echo "ℹ️  You may need to configure the input method in your desktop environment."
}

# Main logic
ensure_bash_shell

# Handle --remove
if [[ "$1" == "--remove" ]]; then
  uninstall_openbangla
  exit 0
fi

echo "🔍 Checking for existing OpenBangla Keyboard installation..."

if is_installed; then
  version=$(get_installed_version)
  echo "[i] Detected version: $version"
  if is_legacy_version "$version"; then
    echo "[!] Version $version is older than or equal to 1.5.1. Removing..."
    uninstall_openbangla
    echo "[→] Proceeding to fresh install..."
    install_openbangla
  else
    echo "[✓] OpenBangla Keyboard is already installed and up-to-date."
    exit 0
  fi
else
  install_openbangla
fi
