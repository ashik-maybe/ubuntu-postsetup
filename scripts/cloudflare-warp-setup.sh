#!/usr/bin/env bash
# Cloudflare WARP Setup Script for Ubuntu (by M Ash)

set -euo pipefail

#==================== TASK FUNCTIONS ======================

add_gpg_key() {
  banner "Adding Cloudflare GPG key..."

  local key_path="/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg"
  if [ -f "$key_path" ]; then
    skip "GPG key already present"
  else
    info "Downloading and installing GPG key..."
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor -o "$key_path"
    success "GPG key added"
  fi
}

add_warp_repo() {
  banner "Adding Cloudflare WARP APT repository..."

  local repo_file="/etc/apt/sources.list.d/cloudflare-client.list"
  if [ -f "$repo_file" ]; then
    skip "APT repo already exists"
  else
    local distro
    distro=$(lsb_release -cs)
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $distro main" | sudo tee "$repo_file" > /dev/null
    sudo apt-get update -qq
    success "WARP repository added"
  fi
}

install_warp_cli() {
  banner "Installing Cloudflare WARP CLI..."

  if command -v warp-cli &>/dev/null; then
    skip "warp-cli already installed"
  else
    sudo apt-get install -y cloudflare-warp
    success "warp-cli installed"
  fi
}

register_device() {
  banner "Optional WARP registration"
  read -p "🆕 Register this device with Cloudflare WARP now? (y/n): " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    info "Registering..."
    warp-cli --accept-tos registration new
    success "Device registered with WARP"
  else
    skip "User skipped registration"
  fi
}

show_usage_guide() {
  banner "warp-cli usage quick reference"
  echo -e "${CYAN}
📘 WARP CLI Quick Reference:

  ➤ Connect:    warp-cli connect
  ➤ Status:     warp-cli status
  ➤ Disconnect: warp-cli disconnect

⚙️ Mode switching:
  🔸 DNS only (DoH):     warp-cli mode doh
  🔹 WARP + DoH:         warp-cli mode warp+doh

👨‍👩‍👧‍👦 1.1.1.1 for Families:
  🚫 Off:                warp-cli dns families off
  🛡️ Malware filter:     warp-cli dns families malware
  🔞 Full filter:        warp-cli dns families full

📚 More commands: warp-cli --help
${RESET}"
}

#====================== EXECUTION ========================

main() {
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

  add_gpg_key
  add_warp_repo
  install_warp_cli
  register_device
  show_usage_guide

  echo -e "\n${GREEN}🎉 WARP setup complete!${RESET}"
}

#====================== LOGGING ==========================
GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; CYAN="\e[36m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }

main "$@"
