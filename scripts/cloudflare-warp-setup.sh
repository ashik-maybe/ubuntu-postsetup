#!/usr/bin/env bash
# Cloudflare WARP Setup Script for Ubuntu (by M Ash)

set -euo pipefail

#====================== LOGGING ==========================
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

banner() { echo -e "\n${CYAN}==> $1${RESET}"; }
info()   { echo -e "${YELLOW}[INFO] $1${RESET}"; }
success(){ echo -e "${GREEN}[✓] $1${RESET}"; }
error()  { echo -e "${RED}[✗] $1${RESET}"; }

#==================== ENSURE DEPENDENCIES ===================
ensure_deps() {
  for cmd in curl gpg; do
    if ! command -v "$cmd" &>/dev/null; then
      info "$cmd not found. Installing..."
      sudo apt update -qq
      sudo apt install -y "$cmd"
      success "$cmd installed"
    else
      info "$cmd already installed"
    fi
  done
}

#==================== ADD REPO & INSTALL ====================
setup_warp() {
  local keyring="/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg"
  local source_list="/etc/apt/sources.list.d/cloudflare-client.list"

  banner "Adding Cloudflare WARP GPG key..."
  if [ ! -f "$keyring" ]; then
    info "Downloading and installing GPG key..."
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output "$keyring"
    success "GPG key added"
  else
    success "Cloudflare WARP GPG key already present"
  fi

  banner "Adding Cloudflare WARP repository..."

  # Force fallback to `jammy` if `noble` is not supported
  local ubuntu_codename
  ubuntu_codename="$(lsb_release -cs)"
  local warp_codename="$ubuntu_codename"

  if [[ "$ubuntu_codename" == "noble" ]]; then
    info "Cloudflare repo does not support 'noble'. Falling back to 'jammy'."
    warp_codename="jammy"
  fi

  if [ ! -f "$source_list" ]; then
    echo "deb [signed-by=$keyring] https://pkg.cloudflareclient.com/ $warp_codename main" | sudo tee "$source_list" > /dev/null
    success "Cloudflare WARP repo added ($warp_codename)"
  else
    success "Cloudflare WARP repo already present"
  fi

  banner "Updating package lists..."
  sudo apt update -qq

  banner "Installing Cloudflare WARP client..."
  if ! command -v warp-cli &>/dev/null; then
    sudo apt install -y cloudflare-warp
    success "Cloudflare WARP installed"
  else
    success "Cloudflare WARP already installed"
  fi
}

#====================== RUN SCRIPT =========================

main() {
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

  ensure_deps
  setup_warp

  echo -e "\n${GREEN}🎉 Cloudflare WARP setup completed! Use 'warp-cli' to manage.${RESET}"
}

main "$@"
