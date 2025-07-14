# 🚀 Ubuntu Fresh Installation Scripts

A clean, modular collection of post-install scripts to set up a fresh Ubuntu desktop the way you want — quickly, safely, and automatically.

> ⚠️ **Important:** Before running these scripts, please **change the APT mirror** to the nearest server to you for faster downloads.
> You can do this via:  
> **Software & Updates → Ubuntu Software → Download from → Select Best Server**

---

## 📁 What's Included

Each script does one specific task — easy to run, safe to re-run, and built for GNOME-based Ubuntu systems.

### 🔧 `ubuntu-postinstall.sh`
> Enables important repositories, installs Flatpak, restricted codecs, sets up SSD TRIM, removes snap bloat, and cleans up your system.

### 🌐 `scripts/browser-install.sh`
> Installs Brave Browser and Google Chrome using official repositories.

### 🛡️ `scripts/cloudflare-warp-setup.sh`
> Adds the Cloudflare WARP APT repo, installs `warp-cli`, and optionally registers your device.

### 🧑‍💻 `scripts/dev-tools-setup.sh`
> Installs GitHub Desktop and Visual Studio Code with official signing keys and APT sources.

### 🎨 `scripts/gnome-setup.sh`
> Checks if you're using GNOME, then installs Flatpak, Flathub, and the GNOME Extension Manager.

---