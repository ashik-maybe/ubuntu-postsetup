#!/usr/bin/env bash
# Setup Brave Browser on Ubuntu

GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error() { echo -e "${RED}[✗] $1${RESET}"; }

main() {
  banner "Installing Brave Browser..."

  if command -v brave-browser &>/dev/null; then
    skip "Brave Browser already installed"
    return
  fi

  info "Installing Brave using official script..."
  curl -fsS https://dl.brave.com/install.sh | sh
  success "Brave Browser installed"
}

main "$@"
