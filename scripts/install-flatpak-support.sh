#!/usr/bin/env bash
# Setup Flatpak, Flathub, and Flatseal for managing permissions for flatpaks

set -euo pipefail
GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }

install_flatpak() {
  if ! command -v flatpak &>/dev/null; then
    info "Installing Flatpak..."
    sudo apt install -y flatpak
    success "Flatpak installed"
  else skip "Flatpak already installed"; fi
}

enable_flathub() {
  if ! flatpak remote-list | grep -q flathub; then
    info "Adding Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub added"
  else skip "Flathub already exists"; fi
}

install_flatseal() {
  if flatpak list --app | grep -i "Flatseal" &>/dev/null; then
    skip "Flatseal already installed"
  else
    flatpak install -y flathub com.github.tchx84.Flatseal
    success "Flatseal installed"
  fi
}

main() {
  install_flatpak
  enable_flathub
  install_flatseal
}

main "$@"
