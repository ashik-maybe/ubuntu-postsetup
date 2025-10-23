#!/usr/bin/env bash
# Setup Visual Studio Code on Ubuntu

GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error() { echo -e "${RED}[✗] $1${RESET}"; }

main() {
  banner "Installing Visual Studio Code..."

  if command -v code &>/dev/null; then
    skip "VS Code already installed"
    return
  fi

  sudo apt-get install -y wget gpg apt-transport-https

  info "Fetching Microsoft GPG key..."
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  rm -f packages.microsoft.gpg
  success "Microsoft key installed"

  local source_file="/etc/apt/sources.list.d/vscode.list"
  if [ ! -f "$source_file" ]; then
    info "Adding APT repo for VS Code..."
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee "$source_file" > /dev/null
    success "VS Code repo added"
  else
    skip "VS Code repo"
  fi

  sudo apt update -qq
  sudo apt install -y code && success "VS Code installed"
}

main "$@"
