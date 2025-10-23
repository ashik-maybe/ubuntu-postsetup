#!/usr/bin/env bash
# Setup Firefox via Flatpak from Flathub

GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error() { echo -e "${RED}[✗] $1${RESET}"; }

main() {
  banner "Installing Firefox via Flatpak..."

  # Check if Flatpak is installed
  if ! command -v flatpak &>/dev/null; then
    info "Flatpak not found. Installing Flatpak..."
    sudo apt update -qq
    sudo apt install -y flatpak && success "Flatpak installed"
  else
    skip "Flatpak already installed"
  fi

  # Add Flathub if not already added
  if ! flatpak remotes | grep -q flathub; then
    info "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub added"
  else
    skip "Flathub already exists"
  fi

  # Install Firefox
  if flatpak list | grep -q org.mozilla.firefox; then
    skip "Firefox already installed via Flatpak"
  else
    info "Installing Firefox..."
    flatpak install -y flathub org.mozilla.firefox && success "Firefox installed"
  fi
}

main "$@"
