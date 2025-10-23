#!/usr/bin/env bash
# Setup GitHub Desktop on Ubuntu

GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error() { echo -e "${RED}[✗] $1${RESET}"; }

main() {
  banner "Installing GitHub Desktop..."

  local keyring="/usr/share/keyrings/mwt-desktop.gpg"
  local source_file="/etc/apt/sources.list.d/mwt-desktop.list"

  if command -v github-desktop &>/dev/null; then
    skip "GitHub Desktop already installed"
    return
  fi

  if [ ! -f "$keyring" ]; then
    info "Adding GPG key for GitHub Desktop..."
    wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee "$keyring" > /dev/null
    success "GPG key added"
  else
    skip "GitHub Desktop GPG key"
  fi

  if [ ! -f "$source_file" ]; then
    info "Adding APT repo for GitHub Desktop..."
    echo "deb [arch=amd64 signed-by=$keyring] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" | sudo tee "$source_file" > /dev/null
    success "APT repo added"
  else
    skip "GitHub Desktop repo"
  fi

  sudo apt update -qq
  sudo apt install -y github-desktop && success "GitHub Desktop installed"
}

main "$@"
