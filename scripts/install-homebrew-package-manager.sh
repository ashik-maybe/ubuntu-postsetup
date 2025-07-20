#!/usr/bin/env bash
# install-homebrew-package-manager.sh — Install Homebrew on Ubuntu

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
info "🔍 Checking if Homebrew is already installed..."
if command -v brew &>/dev/null; then
    success "Homebrew is already installed!"
    exit 0
fi

# ───── Install Dependencies ─────
info "📦 Installing required dependencies..."
sudo apt update
sudo apt install -y build-essential procps curl file git

# ───── Install Homebrew ─────
info "🚀 Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ───── Post-Install ─────
BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
if [ -f "$BREW_PATH" ]; then
    success "✅ Homebrew installed successfully!"
    echo
    echo "👉 Run this to finish setup (or add to your ~/.bashrc or ~/.zshrc):"
    echo ""
    echo "    eval \"\$($BREW_PATH shellenv)\""
else
    error "❌ Homebrew install failed or not in expected path."
    exit 1
fi
