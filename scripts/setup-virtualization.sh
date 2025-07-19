#!/bin/bash
# install-virt.sh — Set up Virt-Manager, QEMU, and KVM on Ubuntu

set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 🎨 Colors
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# ──────────────────────────────────────────────────────────────
# 🛠️ Helper
run_cmd() {
    echo -e "${CYAN}🔧 Running: $1${RESET}"
    eval "$1"
}

# ──────────────────────────────────────────────────────────────
# 📦 Install virtualization tools
install_virtualization_packages() {
    echo -e "${YELLOW}📦 Installing Virt-Manager, QEMU, and KVM tools...${RESET}"
    run_cmd "sudo apt update"
    run_cmd "sudo apt install -y \
        virt-manager \
        qemu-kvm \
        libvirt-daemon-system \
        libvirt-clients \
        bridge-utils \
        dnsmasq-base \
        virtinst \
        qemu-utils"
    echo -e "${GREEN}✅ Virtualization packages installed.${RESET}"
}

# 🔌 Enable and start libvirtd
enable_libvirtd_service() {
    echo -e "${YELLOW}🔌 Enabling and starting libvirtd...${RESET}"
    run_cmd "sudo systemctl enable --now libvirtd"
    echo -e "${GREEN}✅ libvirtd is active and enabled at boot.${RESET}"
}

# 👤 Add current user to libvirt and kvm groups
add_user_to_groups() {
    echo -e "${YELLOW}👤 Adding user '$USER' to libvirt and kvm groups...${RESET}"
    run_cmd "sudo usermod -aG libvirt $USER"
    run_cmd "sudo usermod -aG kvm $USER"
    echo -e "${GREEN}✅ User '$USER' added to libvirt and kvm groups.${RESET}"
    echo -e "${YELLOW}🔁 Please log out and log back in for group changes to take effect.${RESET}"
}

# 🔐 Configure Polkit for passwordless VM access
setup_polkit_rule() {
    echo -e "${YELLOW}🔐 Setting up Polkit rule for passwordless Virt-Manager access...${RESET}"
    POLKIT_FILE="/etc/polkit-1/rules.d/50-libvirt.rules"
    sudo tee "$POLKIT_FILE" > /dev/null <<EOF
polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" &&
        subject.isInGroup("libvirt")) {
        return polkit.Result.YES;
    }
});
EOF
    echo -e "${GREEN}✅ Polkit rule created at $POLKIT_FILE${RESET}"
}

# ──────────────────────────────────────────────────────────────
# ▶️ Run all
clear
echo -e "${CYAN}🚀 Setting up Virt-Manager and KVM on Ubuntu...${RESET}"
sudo -v || { echo -e "${RED}❌ Sudo required. Exiting.${RESET}"; exit 1; }

install_virtualization_packages
enable_libvirtd_service
add_user_to_groups
# setup_polkit_rule

echo -e "${GREEN}🎉 Virt-Manager & KVM setup complete!${RESET}"
