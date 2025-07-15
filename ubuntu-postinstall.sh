#!/usr/bin/env bash
# Ubuntu Post-Install Setup Script by M Ash

set -euo pipefail

#==================== TASK FUNCTIONS ======================

enable_repos() {
  banner "Enabling additional APT repositories..."

  local changed=false

  if ! grep -Rq "^deb .* universe" /etc/apt/sources.list /etc/apt/sources.list.d; then
    sudo add-apt-repository -y universe && changed=true
  else skip "Universe repo"; fi

  if ! grep -Rq "^deb .* multiverse" /etc/apt/sources.list /etc/apt/sources.list.d; then
    sudo add-apt-repository -y multiverse && changed=true
  else skip "Multiverse repo"; fi

  if ! grep -Rq "^deb .* restricted" /etc/apt/sources.list /etc/apt/sources.list.d; then
    sudo add-apt-repository -y restricted && changed=true
  else skip "Restricted repo"; fi

  $changed && info "Updating package list..." && sudo apt update -qq || skip "APT update"
  success "Repositories enabled"
}

install_flatpak() {
  banner "Checking Flatpak and Flathub..."

  if ! command -v flatpak &>/dev/null; then
    info "Installing Flatpak..."
    sudo apt install -y flatpak
    success "Flatpak installed"
  else skip "Flatpak already installed"; fi

  if ! flatpak remote-list | grep -q flathub; then
    info "Adding Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub added"
  else skip "Flathub already present"; fi
}

install_extras() {
  banner "Installing ubuntu-restricted-extras..."

  if dpkg -s ubuntu-restricted-extras &>/dev/null; then
    skip "ubuntu-restricted-extras"
  else
    # Pre-accept both debconf selections needed
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
    echo "ubuntu-restricted-extras ubuntu-restricted-extras/accept-mscorefonts-eula select true" | sudo debconf-set-selections

    sudo apt install -y ubuntu-restricted-extras
    success "Restricted extras installed"
  fi
}

remove_snap_bloat() {
  banner "Removing unnecessary Snap packages..."

  local whitelist=(
    "snapd"
    "core22"
    "bare"
    "gtk-common-themes"
    "snap-store"
    "gnome-.*"
    "snapd-desktop-integration"
    "firmware-updater"
  )

  local snaps
  snaps=$(snap list | awk 'NR>1 {print $1}')

  for snap in $snaps; do
    local keep=false
    for safe in "${whitelist[@]}"; do
      [[ "$snap" =~ ^$safe$ ]] && keep=true && break
    done
    $keep && skip "$snap (kept)" || {
      info "Removing snap: $snap"
      sudo snap remove --purge "$snap"
      success "Removed $snap"
    }
  done
}

cleanup() {
  banner "Cleaning up APT and snap cache..."
  sudo apt autoremove -y
  sudo apt autoclean -y
  sudo apt clean
  success "System cleanup complete"
}

enable_trim() {
  banner "Enabling SSD TRIM (fstrim.timer)..."
  systemctl is-enabled fstrim.timer &>/dev/null && skip "fstrim.timer" || {
    sudo systemctl enable --now fstrim.timer
    success "fstrim.timer enabled and started"
  }
}

#====================== EXECUTION ========================

main() {
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

  enable_repos
  install_flatpak
  install_extras
  remove_snap_bloat
  cleanup
  enable_trim

  echo -e "\n${GREEN}🎉 Post-install setup done!${RESET}"
}

#====================== LOGGING ==========================
GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }

main "$@"
