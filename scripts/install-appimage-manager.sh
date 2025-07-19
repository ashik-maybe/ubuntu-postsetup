#!/usr/bin/env bash
# Setup Gear Lever (AppImage manager)

set -euo pipefail
GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RED="\e[31m"; RESET="\e[0m"
info()    { echo -e "${YELLOW}[INFO] $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
skip()    { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error()   { echo -e "${RED}[✗] $1${RESET}"; }

install_flatpak_if_missing() {
  if ! command -v flatpak &>/dev/null; then
    info "Flatpak not found. Installing..."
    sudo apt update
    sudo apt install -y flatpak
    success "Flatpak installed"
  else
    skip "Flatpak already installed"
  fi
}

enable_flathub_if_missing() {
  if ! flatpak remote-list | grep -q flathub; then
    info "Flathub not configured. Adding it..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub added"
  else
    skip "Flathub already configured"
  fi
}

install_gearlever() {
  if flatpak list --app | grep -i "Gear Lever" &>/dev/null; then
    skip "Gear Lever already installed"
  else
    info "Installing Gear Lever..."
    flatpak install -y flathub it.mijorus.gearlever
    success "Gear Lever installed"
  fi
}

main() {
  install_flatpak_if_missing
  enable_flathub_if_missing
  install_gearlever
}

main "$@"
