#!/usr/bin/env bash

#=================== COLOR SETUP ===================
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

#================== INTRO MESSAGE ==================
clear
echo -e "${BLUE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Ubuntu Desktop Setup Script - Auto & Smart"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${RESET}"
echo -e "${YELLOW}This script will do the following:${RESET}"
echo -e "  ${GREEN}✔${RESET} Enable extra repositories (universe, multiverse, restricted)"
echo -e "  ${GREEN}✔${RESET} Add Flatpak + Flathub support"
echo -e "  ${GREEN}✔${RESET} Enable SSD TRIM via fstrim.timer"
echo -e "  ${GREEN}✔${RESET} Install ubuntu-restricted-extras (media codecs & fonts)"
echo -e "  ${GREEN}✔${RESET} Perform a system cleanup (autoremove, autoclean)"
echo ""
echo -e "${YELLOW}🔐 Please enter your password when prompted...${RESET}"

#================== SUDO PERMISSION ==================
# Ask for sudo and keep alive
sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

#================== HELPER FUNCTIONS =================
banner() {
  echo -e "\n${BLUE}==> $1${RESET}"
}
success() {
  echo -e "${GREEN}[✓] $1${RESET}"
}
info() {
  echo -e "${YELLOW}[INFO] $1${RESET}"
}
skip() {
  echo -e "${BLUE}[SKIP] $1 already done.${RESET}"
}

#================== ENABLE REPOS =====================
enable_repos() {
  banner "Checking and enabling Ubuntu repositories..."

  REPO_CHANGED=false

  if ! grep -Rq "^deb .* universe" /etc/apt/sources.list /etc/apt/sources.list.d; then
    sudo add-apt-repository -y universe && REPO_CHANGED=true
  else skip "Universe repo"; fi

  if ! grep -Rq "^deb .* multiverse" /etc/apt/sources.list /etc/apt/sources.list.d; then
    sudo add-apt-repository -y multiverse && REPO_CHANGED=true
  else skip "Multiverse repo"; fi

  if ! grep -Rq "^deb .* restricted" /etc/apt/sources.list /etc/apt/sources.list.d; then
    sudo add-apt-repository -y restricted && REPO_CHANGED=true
  else skip "Restricted repo"; fi

  if $REPO_CHANGED; then
    info "Updating package list..."
    sudo apt update -qq
  else
    skip "No repo changes, skipping apt update"
  fi

  success "Repositories enabled"
}

#================== ENABLE FLATPAK ====================
enable_flatpak() {
  banner "Checking Flatpak installation..."

  if ! command -v flatpak &>/dev/null; then
    info "Installing Flatpak..."
    sudo apt install -y flatpak
    success "Flatpak installed"
  else
    skip "Flatpak already installed"
  fi

  if ! flatpak remote-list | grep -q flathub; then
    info "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub added"
  else
    skip "Flathub already added"
  fi
}

#================== INSTALL EXTRAS =====================
install_extras() {
  banner "Installing ubuntu-restricted-extras..."

  if dpkg -s ubuntu-restricted-extras &>/dev/null; then
    skip "ubuntu-restricted-extras"
  else
    # Install non-interactively (pre-accept EULA)
    echo "ubuntu-restricted-extras ubuntu-restricted-extras/accept-mscorefonts-eula select true" | sudo debconf-set-selections
    sudo apt install -y ubuntu-restricted-extras
    success "ubuntu-restricted-extras installed"
  fi
}

#================== ENABLE FSTRIM ======================
enable_fstrim() {
  banner "Enabling fstrim.timer (for SSDs)..."

  if systemctl is-enabled fstrim.timer &>/dev/null; then
    skip "fstrim.timer already enabled"
  else
    sudo systemctl enable --now fstrim.timer
    success "fstrim.timer enabled and started"
  fi
}

#================== SYSTEM CLEANUP =====================
cleanup_system() {
  banner "Cleaning up system..."
  sudo apt autoremove -y
  sudo apt autoclean -y
  sudo apt clean
  success "System cleanup complete"
}

#================== MAIN EXECUTION =====================
enable_repos
enable_flatpak
install_extras
enable_fstrim
cleanup_system

echo -e "\n${GREEN}🎉 All setup tasks completed successfully!${RESET}"