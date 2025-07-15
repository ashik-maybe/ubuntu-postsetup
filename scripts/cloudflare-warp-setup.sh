#!/usr/bin/env bash
# Cloudflare WARP Setup Script for Ubuntu (by M Ash, 2025+)

set -euo pipefail

#====================== LOGGING ==========================
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

banner()  { echo -e "\n${CYAN}==> $1${RESET}"; }
info()    { echo -e "${YELLOW}[INFO] $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
error()   { echo -e "${RED}[✗] $1${RESET}"; }
skip()    { echo -e "${CYAN}[SKIP] $1${RESET}"; }

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
  local repo_file="/etc/apt/sources.list.d/cloudflare-client.list"
  local codename
  codename="$(lsb_release -cs)"

  banner "Adding Cloudflare WARP GPG key..."
  if [ ! -f "$keyring" ]; then
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output "$keyring"
    success "GPG key added to $keyring"
  else
    success "GPG key already exists"
  fi

  banner "Adding Cloudflare WARP repository for $codename..."
  if [ ! -f "$repo_file" ]; then
    echo "deb [signed-by=$keyring] https://pkg.cloudflareclient.com/ $codename main" | sudo tee "$repo_file" > /dev/null
    success "Repository added to $repo_file"
  else
    success "Repository already exists"
  fi

  banner "Updating package list..."
  sudo apt-get update -qq

  banner "Installing Cloudflare WARP..."
  if ! command -v warp-cli &>/dev/null; then
    sudo apt-get install -y cloudflare-warp
    success "Cloudflare WARP installed"
  else
    success "WARP CLI already installed"
  fi
}

#==================== OPTIONAL REGISTRATION ====================
register_prompt() {
  banner "WARP Registration"

  # Check if already registered
  if warp-cli account | grep -q 'Account'; then
    skip "Device already registered"
    return
  fi

  echo -e "${YELLOW}🆕 This device is not registered with Cloudflare WARP.${RESET}"
  read -rp "👉 Run WARP registration now? (y/n): " reg_ans

  if [[ "$reg_ans" =~ ^[Yy]$ ]]; then
    info "Running: warp-cli registration new"
    warp-cli registration new
  else
    info "Skipping WARP registration"
  fi
}

#====================== RUN SCRIPT =========================
main() {
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

  ensure_deps
  setup_warp
  register_prompt

  echo -e "\n${GREEN}🎉 Cloudflare WARP setup completed!${RESET}"
  echo -e "${CYAN}
🧭 Quick Start:
  ➤ Connect WARP:         warp-cli connect
  ➤ Check status:         warp-cli status
  ➤ Disconnect WARP:      warp-cli disconnect
  ➤ Enable DNS-only:      warp-cli mode doh
  ➤ Enable full mode:     warp-cli mode warp+doh

👨‍👩‍👧‍👦 Family filter (1.1.1.1 for Families):
  🚫 Off:                warp-cli dns families off
  🛡️ Malware filter:     warp-cli dns families malware
  🔞 Full filter:        warp-cli dns families full

📚 More: warp-cli --help
${RESET}"
}

main "$@"
