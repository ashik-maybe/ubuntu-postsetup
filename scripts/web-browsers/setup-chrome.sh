#!/usr/bin/env bash
# Setup Google Chrome on Ubuntu

GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error() { echo -e "${RED}[✗] $1${RESET}"; }

main() {
  banner "Installing Google Chrome..."

  if command -v google-chrome &>/dev/null; then
    skip "Google Chrome already installed"
    return
  fi

  local key_path="/usr/share/keyrings/google-chrome.gpg"
  local source_file="/etc/apt/sources.list.d/google-chrome.list"

  if [ ! -f "$key_path" ]; then
    info "Adding Google Chrome GPG key..."
    curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee "$key_path" > /dev/null
    success "GPG key added"
  else
    skip "Google Chrome GPG key"
  fi

  if [ ! -f "$source_file" ]; then
    info "Adding Chrome APT repository..."
    echo "deb [arch=amd64 signed-by=$key_path] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee "$source_file" > /dev/null
    success "APT repo added"
  else
    skip "Google Chrome repo"
  fi

  sudo apt update -qq
  sudo apt install -y google-chrome-stable
  success "Google Chrome installed"
}

main "$@"
