#!/usr/bin/env -S bash -e
#
# Dwarf Fortress inspired hyprland setup
# MIT License Copyright (c) 2025 Mateo Correa Franco

#┌──────────────────────────────  ──────────────────────────────┐
#                    Fancy text formating stuff
#└──────────────────────────────  ──────────────────────────────┘
BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
# Reset color
RESET='\033[0m'

info_print () {
    echo -e "${BOLD}${GREEN}[ o ] $1${RESET}"
}

input_print () {
    echo -ne "${BOLD}${YELLOW}[ o ] $1${RESET}"
}

error_print () {
    echo -e "${BOLD}${RED}[ o ] $1${RESET}"
}


#┌──────────────────────────────  ──────────────────────────────┐
#                       Packages installation
#└──────────────────────────────  ──────────────────────────────┘
read_pkglist() {
    local pkgfile="pkglist.txt"
    packages=()

    while IFS= read -r line || [[ -n $line ]]; do
        # Skip empty lines and comment lines starting with #
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        packages+=("$line")
    done < "$pkgfile"

    info_print "Loaded ${#packages[@]} packages from $pkgfile"
}

package_install() {
    read_pkglist
    
}

aur_install() {
    if command -v paru &> /dev/null; then
        info_print "Installing AUR packages with paru..."
        paru -S --noconfirm --needed "${packages[@]}"
    elif command -v yay &> /dev/null; then
        info_print "Installing AUR packages with yay..."
        yay -S --noconfirm --needed "${packages[@]}"
    else
        error_print "No AUR helper found (paru or yay). Please install one and try again."
        exit 1
    fi
}