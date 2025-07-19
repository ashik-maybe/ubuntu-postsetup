#!/usr/bin/env bash

#========================================
# Install Nix Package Manager on non-Nix OS
#========================================

set -euo pipefail

#==================== COLORS ====================
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

log()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
warn()   { echo -e "${YELLOW}[WARN]${RESET} $1"; }
success(){ echo -e "${GREEN}[ OK ]${RESET} $1"; }
error()  { echo -e "${RED}[FAIL]${RESET} $1"; }

#==================== CHECK EXISTING ====================
check_existing_install() {
    if command -v nix &>/dev/null; then
        warn "Nix is already installed."
        nix --version
        exit 0
    fi
}

#==================== INSTALL NIX ====================
install_nix_global() {
    log "Attempting global installation (requires sudo)..."
    if sh <(curl -L https://nixos.org/nix/install) --daemon; then
        success "Global installation completed."
    else
        error "Global install failed. You may try local install manually."
        exit 1
    fi
}

install_nix_local() {
    log "Attempting local installation (user-level only)..."
    if sh <(curl -L https://nixos.org/nix/install) --no-daemon; then
        success "Local installation completed."
    else
        error "Local install failed."
        exit 1
    fi
}

#==================== ENV SETUP ====================
setup_environment() {
    log "Setting up environment variables..."
    
    if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
        # Load nix.sh for current session
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
        # Ensure it persists in shell profile
        for profile in "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [[ -f "$profile" && ! $(grep nix.sh "$profile") ]]; then
                echo ". \"$HOME/.nix-profile/etc/profile.d/nix.sh\"" >> "$profile"
                log "Updated $profile"
            fi
        done
        success "Environment setup complete."
    else
        error "nix.sh not found. You may need to reboot or log out/in."
    fi
}

#==================== VERIFY ====================
verify_installation() {
    log "Verifying Nix installation..."
    
    if command -v nix-env &>/dev/null; then
        nix-env --version
        success "Nix is ready to use."

        # Run a test install
        log "Installing 'hello' as a test..."
        nix-env -iA nixpkgs.hello
        if nix-env -q | grep -q hello; then
            success "'hello' installed successfully with nix-env."
        else
            warn "'hello' was not found in installed packages."
        fi
    else
        error "nix-env command not found."
        exit 1
    fi
}

#==================== MAIN ====================
log "==== Starting Nix Package Manager Installation ===="

check_existing_install

# Try global install first
if install_nix_global; then
    setup_environment
    verify_installation
else
    warn "Global install failed or skipped. Trying local install..."
    install_nix_local
    setup_environment
    verify_installation
fi

echo -e "\n🌀 You may need to open a new terminal or log out/in for full access to Nix commands."
success "Nix installation finished!"
