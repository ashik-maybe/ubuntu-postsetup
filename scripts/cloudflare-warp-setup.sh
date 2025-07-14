#!/usr/bin/env bash

set -euo pipefail

CYAN="\033[0;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Helper: run command with feedback
run_cmd() {
    echo -e "${CYAN}🔧 Running: $1${RESET}"
    eval "$1"
}

#========================= 1. Intro =========================
clear
echo -e "${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Cloudflare WARP Setup Script for Ubuntu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${RESET}"
echo -e "${YELLOW}This script will install and optionally register Cloudflare WARP on Ubuntu.${RESET}"
echo -e "It will:"
echo -e "  ${GREEN}✔${RESET} Add the official Cloudflare GPG key"
echo -e "  ${GREEN}✔${RESET} Add the APT repository"
echo -e "  ${GREEN}✔${RESET} Install the WARP CLI (warp-cli)"
echo -e "  ${GREEN}✔${RESET} Optionally register this device"
echo ""

#========================= 2. Get Sudo ======================
echo -e "${YELLOW}🔐 Requesting sudo access...${RESET}"
sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

#========================= 3. Add GPG Key ===================
if [ ! -f /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg ]; then
  echo -e "${YELLOW}🌐 Adding Cloudflare GPG key...${RESET}"
  run_cmd "curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg"
else
  echo -e "${GREEN}✅ Cloudflare GPG key already present.${RESET}"
fi

#====================== 4. Add APT Repo =====================
REPO_FILE="/etc/apt/sources.list.d/cloudflare-client.list"
if [ ! -f "$REPO_FILE" ]; then
  echo -e "${YELLOW}📦 Adding Cloudflare WARP repository...${RESET}"
  DISTRO=$(lsb_release -cs)
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $DISTRO main" | sudo tee "$REPO_FILE" > /dev/null
  run_cmd "sudo apt-get update -qq"
else
  echo -e "${GREEN}✅ Cloudflare APT repo already added.${RESET}"
fi

#====================== 5. Install warp-cli =================
if ! command -v warp-cli &>/dev/null; then
  echo -e "${YELLOW}📥 Installing WARP CLI...${RESET}"
  run_cmd "sudo apt-get install -y cloudflare-warp"
else
  echo -e "${GREEN}✅ WARP CLI already installed.${RESET}"
fi

#====================== 6. Optional Registration ============
echo -e "${YELLOW}🆕 Is this your first time using WARP?${RESET}"
read -p "👉 Register this device now? (y/n): " reg_ans
if [[ "$reg_ans" =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}🔐 Registering with Cloudflare WARP...${RESET}"
    warp-cli --accept-tos registration new && echo -e "${GREEN}✅ Registration complete.${RESET}"
else
    echo -e "${CYAN}⏭️ Skipping WARP registration.${RESET}"
fi

#====================== 7. CLI Usage Guide ==================
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
