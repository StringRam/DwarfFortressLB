#!/usr/bin/env -S bash -e
#
# Dwarf Fortress inspired Hyprland setup
# MIT License (c) 2025 Mateo Correa Franco

#┌──────────────────────────────  ──────────────────────────────┐
#                     Fancy text formatting stuff
#└──────────────────────────────  ──────────────────────────────┘
BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

info_print()  { echo -e "${BOLD}${GREEN}[ o ] $1${RESET}"; }
input_print() { echo -ne "${BOLD}${YELLOW}[ o ] $1${RESET}"; }
error_print() { echo -e "${BOLD}${RED}[ x ] $1${RESET}"; }

#┌──────────────────────────────  ──────────────────────────────┐
#                     Basic safety checks
#└──────────────────────────────  ──────────────────────────────┘
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error_print "Do not run this script as root."
        exit 1
    fi
}

check_internet() {
    info_print "Checking internet connectivity..."
    if ! ping -c 1 archlinux.org &>/dev/null; then
        error_print "No internet connection detected!"
        exit 1
    fi
}

check_aur_helper() {
    if command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    elif command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    else
        error_print "No AUR helper (paru/yay) found. Please install one first."
        exit 1
    fi
    info_print "Using AUR helper: $AUR_HELPER"
}

#┌──────────────────────────────  ──────────────────────────────┐
#                      Packages installation
#└──────────────────────────────  ──────────────────────────────┘
read_pkglist() {
    local pkgfile="pkglist.txt"
    packages=()

    while IFS= read -r line || [[ -n $line ]]; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        packages+=("$line")
    done < "$pkgfile"

    info_print "Loaded ${#packages[@]} packages from $pkgfile"
}

install_pacman_packages() {
    read_pkglist
    info_print "Installing official packages..."
    sudo pacman -S --noconfirm --needed "${packages[@]}"
}

install_aur_packages() {
    local aurfile="aur.txt"
    [[ ! -f "$aurfile" ]] && info_print "No aur.txt found, skipping AUR installation." && return

    mapfile -t aurpkgs < <(grep -Ev '^\s*(#|$)' "$aurfile")
    info_print "Installing ${#aurpkgs[@]} AUR packages via $AUR_HELPER..."
    "$AUR_HELPER" -S --needed --noconfirm "${aurpkgs[@]}"
}

#┌──────────────────────────────  ──────────────────────────────┐
#                       NVIDIA driver detection
#└──────────────────────────────  ──────────────────────────────┐
detect_nvidia() {
    if ! lspci | grep -qi "nvidia"; then
        info_print "No NVIDIA GPU detected."
        return 0
    fi

    info_print "NVIDIA GPU detected. Determining driver..."
    local gpu_info
    gpu_info=$(lspci | grep -i "nvidia")

    if echo "$gpu_info" | grep -qE "RTX 40|Ada|Lovelace"; then
        driver_pkg="nvidia-open-dkms"
    elif echo "$gpu_info" | grep -qE "RTX 20|RTX 30|GTX 16|Turing|Ampere"; then
        driver_pkg="nvidia-dkms"
    else
        driver_pkg="nvidia-390xx-dkms"
    fi

    info_print "Installing driver: $driver_pkg"
    sudo pacman -S --noconfirm --needed "$driver_pkg"
}

#┌──────────────────────────────  ──────────────────────────────┐
#                       Post-install configuration
#└──────────────────────────────  ──────────────────────────────┐
configure_regreet() {
    if ! command -v regreet &>/dev/null; then
        info_print "regreet not installed, skipping configuration."
        return
    fi
    info_print "Configuring regreet..."
    sudo mkdir -p /etc/greetd
    sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
command = "Hyprland --config /etc/greetd/hyprland.conf"
user = "greeter"
EOF
    sudo tee /etc/greetd/hyprland.conf >/dev/null <<'EOF'
exec-once = regreet; hyprctl dispatch exit
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    disable_hyprland_qtutils_check = true
}
EOF
    sudo systemctl enable greetd.service
}

apply_stow() {
    if ! command -v stow &>/dev/null; then
        error_print "GNU Stow not installed. Please install it first."
        exit 1
    fi
    info_print "Applying dotfiles with Stow..."
    stow . --target="$HOME"
}

#┌──────────────────────────────  ──────────────────────────────┐
#                       Main execution flow
#└──────────────────────────────  ──────────────────────────────┐
main() {
    check_root
    check_internet
    check_aur_helper
    detect_nvidia
    install_pacman_packages
    install_aur_packages
    configure_regreet
    apply_stow

    info_print "Dotfiles installation complete!"
}

main "$@"
