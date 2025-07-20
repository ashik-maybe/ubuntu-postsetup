#!/usr/bin/env bash
# install-nix-package-manager.sh — Ubuntu-compatible installer for Nix (multi-user)

set -euo pipefail

# ───── Terminal Colors ─────
CYAN="\033[0;36m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error()   { echo -e "${RED}[ERROR]${RESET} $1"; }

# ───── Precheck ─────
info "🔍 Checking if Nix is already installed..."
if command -v nix &>/dev/null; then
    success "Nix is already installed!"
    exit 0
fi

# ───── Install Nix Multi-User (Recommended for Ubuntu) ─────
info "📦 Installing Nix package manager (multi-user)..."
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

success "✅ Nix installation complete!"

echo
cat <<EOF
📌 FINAL STEP:
👉 Run this in your shell or add to ~/.bashrc or ~/.zshrc:

    . /etc/profile.d/nix.sh

EOF
