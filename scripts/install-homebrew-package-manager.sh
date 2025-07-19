#!/usr/bin/env bash

#========================================
# Install Homebrew Package Manager
#========================================

set -euo pipefail

#==================== COLORS ====================
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

log() {
    echo -e "${CYAN}[INFO]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${RESET} $1"
}

error() {
    echo -e "${RED}[FAIL]${RESET} $1"
}

#==================== FUNCTIONS ====================

install_dependencies() {
    log "Installing required packages: build-essential, curl, git, procps, file"
    sudo apt-get update
    sudo apt-get install -y build-essential curl git procps file
    success "Dependencies installed"
}

install_homebrew() {
    log "Running Homebrew installation script..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    success "Homebrew installation script completed"
}

add_to_path() {
    local brew_prefix="/home/linuxbrew/.linuxbrew"
    local shell_profile

    if [[ -n "${ZSH_VERSION-}" ]]; then
        shell_profile="$HOME/.zprofile"
    elif [[ -n "${BASH_VERSION-}" ]]; then
        shell_profile="$HOME/.bash_profile"
    else
        shell_profile="$HOME/.profile"
    fi

    if ! grep -q 'brew shellenv' "$shell_profile" 2>/dev/null; then
        log "Adding Homebrew to PATH in $shell_profile"
        echo "eval \"\$($brew_prefix/bin/brew shellenv)\"" >> "$shell_profile"
    else
        warn "Homebrew already added to $shell_profile"
    fi

    eval "$($brew_prefix/bin/brew shellenv)"
    success "PATH updated for current session"
}

verify_installation() {
    log "Verifying brew installation..."

    if ! command -v brew &>/dev/null; then
        error "brew command not found. Installation may have failed."
        exit 1
    fi

    brew doctor || true
    brew install hello
    brew list | grep -q hello && success "Homebrew verified with 'hello' installed" || error "'hello' not found"
}

#==================== MAIN ====================

log "==== Starting Homebrew Installation for Linux ===="

if command -v brew &>/dev/null; then
    warn "Homebrew already installed. Skipping installation..."
else
    install_dependencies
    install_homebrew
    add_to_path
    verify_installation
fi

success "Homebrew setup complete!"
echo -e "\n🔧 You may need to restart your terminal for PATH changes to take full effect."

#==================== END ====================
