#!/usr/bin/env bash
# Setup or remove Docker Engine on Ubuntu
# Usage:
#   ./setup-docker.sh        → Installs Docker
#   ./setup-docker.sh -r     → Removes Docker completely

#====================== LOGGING ==========================
GREEN="\e[32m"; BLUE="\e[34m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"
banner() { echo -e "\n${BLUE}==> $1${RESET}"; }
success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info() { echo -e "${YELLOW}[INFO] $1${RESET}"; }
skip() { echo -e "${BLUE}[SKIP] $1${RESET}"; }
error() { echo -e "${RED}[✗] $1${RESET}"; }

#================== INSTALL DOCKER =======================

install_docker() {
  banner "Uninstalling conflicting Docker packages..."

  # Remove unofficial or conflicting packages
  local conflicts=(docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc)
  for pkg in "${conflicts[@]}"; do
    sudo apt-get remove -y "$pkg" &>/dev/null && success "Removed $pkg" || skip "$pkg not installed"
  done

  banner "Setting up Docker APT repository..."

  # Install required tools
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl

  # Add Docker's GPG key
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add Docker repo to sources
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update

  banner "Installing Docker Engine and plugins..."

  # Install Docker packages
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin && success "Docker Engine installed"

  banner "Verifying Docker installation..."

  # Start Docker and run test container
  sudo systemctl start docker
  sudo docker run hello-world && success "Docker is running correctly"
}

#================== REMOVE DOCKER ========================

remove_docker() {
  banner "Purging Docker Engine and related packages..."

  # Remove all Docker-related packages
  sudo apt-get purge -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    docker-ce-rootless-extras && success "Packages purged"

  banner "Removing Docker data and config..."

  # Delete Docker volumes and config files
  sudo rm -rf /var/lib/docker /var/lib/containerd
  sudo rm -f /etc/apt/sources.list.d/docker.list
  sudo rm -f /etc/apt/keyrings/docker.asc

  success "Docker completely removed from system"
}

#====================== ENTRYPOINT =======================

main() {
  # Keep sudo alive during execution
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done ) 2>/dev/null &

  # Check for -r flag to remove Docker
  if [[ "$1" == "-r" ]]; then
    remove_docker
  else
    install_docker
  fi
}

main "$@"
