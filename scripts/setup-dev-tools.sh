#!/usr/bin/env bash
# Install GitHub Desktop and Visual Studio Code on Ubuntu

#====================== LOGGING ==========================
GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error() { echo -e "${RED}[✗] $1${RESET}"; }

#==================== TASK FUNCTIONS ======================

install_github_desktop() {
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
  sudo apt install -y github-desktop
  success "GitHub Desktop installed"
}

install_vscode() {
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
  sudo apt install -y code
  success "VS Code installed"
}

#====================== EXECUTION ========================

main() {
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

  install_github_desktop || error "GitHub Desktop installation failed"
  install_vscode || error "VS Code installation failed"

  echo -e "\n${GREEN}🎉 GitHub Desktop and VS Code setup complete! Happy coding!${RESET}"
}

main "$@"
