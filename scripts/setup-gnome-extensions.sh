#!/usr/bin/env bash
# Setup Gnome Extension Manager via Flathub

set -euo pipefail

#==================== TASK FUNCTIONS ======================

check_gnome() {
  banner "Checking for GNOME desktop..."

  if pgrep -x "gnome-shell" > /dev/null || gnome-shell --version &>/dev/null; then
    success "GNOME detected"
  else
    echo -e "${RED}❌ GNOME Shell not detected. This script is intended for GNOME environments only.${RESET}"
    exit 1
  fi
}

install_flatpak() {
  banner "Installing Flatpak..."

  if ! command -v flatpak &>/dev/null; then
    info "Installing Flatpak..."
    sudo apt install -y flatpak
    success "Flatpak installed"
  else
    skip "Flatpak already installed"
  fi
}

add_flathub() {
  banner "Checking Flathub remote..."

  if ! flatpak remote-list | grep -q flathub; then
    info "Adding Flathub remote..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub remote added"
  else
    skip "Flathub already present"
  fi
}

install_extension_manager() {
  banner "Installing GNOME Extension Manager..."

  if ! flatpak list | grep -q com.mattjakeman.ExtensionManager; then
    info "Installing Extension Manager via Flatpak..."
    flatpak install -y flathub com.mattjakeman.ExtensionManager
    success "Extension Manager installed"
  else
    skip "Extension Manager already installed"
  fi
}

#====================== EXECUTION ========================

main() {
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

  check_gnome
  install_flatpak
  add_flathub
  install_extension_manager

  echo -e "\n${GREEN}🎉 GNOME setup complete! Extension Manager is ready to use.${RESET}"
}

#====================== LOGGING ==========================
GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }

main "$@"
