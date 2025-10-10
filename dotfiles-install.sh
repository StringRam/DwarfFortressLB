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

# AUR packages: list your AUR packages here (replace the placeholders).
# The script will skip AUR installation if this array is empty.
AUR_PACKAGES=(
    "greetd-regreet-git"
    "wlogout"
    "hyprpicker"
    "python-pywal16"
    "python-pywalfox"
    "zsh-theme-powerlevel10k-git"
    "visual-studio-code-bin"
    "vesktop"
)

install_aur_packages() {
    if [[ ${#AUR_PACKAGES[@]} -eq 0 ]]; then
        info_print "No AUR packages defined in AUR_PACKAGES, skipping AUR installation."
        return
    fi

    info_print "Installing ${#AUR_PACKAGES[@]} AUR packages via $AUR_HELPER..."
    # Use the selected AUR helper (paru or yay)
    "$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}"
}

#┌──────────────────────────────  ──────────────────────────────┐
#                       NVIDIA driver detection
#└──────────────────────────────  ──────────────────────────────┘
detect_nvidia() {
    if ! lspci | grep -qi "nvidia"; then
        info_print "No NVIDIA GPU detected."
        return 0
    fi

    info_print "NVIDIA GPU detected. Selecting driver package..."
    local prefer_dkms prefer_open driver_pkg utils_pkg

    # Allow user to override preference via environment variables:
    # NVIDIA_USE_DKMS=1 to prefer DKMS variant, NVIDIA_USE_OPEN=1 to prefer nvidia-open
    prefer_dkms=${NVIDIA_USE_DKMS:-0}
    prefer_open=${NVIDIA_USE_OPEN:-0}

    if [[ "$prefer_open" -eq 1 ]]; then
        driver_pkg="nvidia-open-dkms"
    else
        if [[ "$prefer_dkms" -eq 1 ]]; then
            driver_pkg="nvidia-dkms"
        else
            driver_pkg="nvidia"
        fi
    fi

    utils_pkg="nvidia-utils"

    info_print "Installing driver: $driver_pkg and utils: $utils_pkg"

    if [[ "$driver_pkg" == *-dkms ]]; then
        info_print "DKMS driver selected. Ensure kernel headers are installed (e.g. linux-headers)."
    fi

    sudo pacman -S --noconfirm --needed "$driver_pkg" "$utils_pkg"
}

#┌──────────────────────────────  ──────────────────────────────┐
#                       Post-install configuration
#└──────────────────────────────  ──────────────────────────────┘

install_fonts() {
    info_print "Installing local TTF fonts..."
    # Determine script directory and assets directory
    local script_dir fonts_src fonts_dest ttf_files
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fonts_src="$script_dir/Dwarf-Fortress-Assets"
    fonts_dest="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"

    mkdir -p "$fonts_dest"

    # Find .ttf files inside the assets directory (recursively)
    mapfile -t ttf_files < <(find "$fonts_src" -type f -iname '*.ttf' 2>/dev/null || true)

    if [[ ${#ttf_files[@]} -eq 0 ]]; then
        info_print "No .ttf fonts found in $fonts_src — nothing to install."
        return
    fi

    for f in "${ttf_files[@]}"; do
        local basename_f
        basename_f=$(basename "$f")
        info_print "Installing $basename_f"
        if [[ -e "$fonts_dest/$basename_f" ]]; then
            info_print "Skipping $basename_f (already present)"
            continue
        fi
        cp "$f" "$fonts_dest/"
        chmod 644 "$fonts_dest/$basename_f" || true
    done

    # Refresh font cache for the user
    if command -v fc-cache &>/dev/null; then
        info_print "Refreshing font cache..."
        fc-cache -f "$fonts_dest" >/dev/null 2>&1 || true
    else
        info_print "fc-cache not found; remember to run 'fc-cache -f' manually if needed."
    fi

    info_print "Fonts installation complete."
}

# Make scripts inside the user's config directory executable.
# Criteria: files ending with .sh or files starting with a shebang (#!).
make_config_scripts_executable() {
    info_print "Setting execute permissions on scripts in the config directory..."

    local config_dir
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"

    if [[ ! -d "$config_dir" ]]; then
        info_print "No config directory found at $config_dir, skipping."
        return 0
    fi

    local changed=0
    # Find all regular files and check if they are scripts
    while IFS= read -r -d '' file; do
        # skip if already executable
        if [[ -x "$file" ]]; then
            continue
        fi

        # If filename ends with .sh or file starts with shebang, make it executable
        if [[ "$file" == *.sh ]] || head -n1 "$file" 2>/dev/null | grep -q '^#!'; then
            chmod 755 "$file" 2>/dev/null && {
                info_print "Made executable: ${file#$HOME/}"
                changed=$((changed+1))
            } || error_print "Failed to chmod $file"
        fi
    done < <(find "$config_dir" -type f -print0 2>/dev/null)

    if [[ $changed -eq 0 ]]; then
        info_print "No scripts needed permission changes in $config_dir."
    else
        info_print "Updated $changed script(s) in $config_dir."
    fi
}

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

changeshell_zsh(){
    if ! command -v zsh &>/dev/null; then
        info_print "zsh not installed, skipping configuration."
        return
    fi
    if [[ "$SHELL" != *"zsh"* ]]; then
        info_print "Changing default shell to zsh..."
        chsh -s "$(command -v zsh)"
    else
        info_print "Default shell is already zsh."
    fi
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
#└──────────────────────────────  ──────────────────────────────┘
main() {
    check_root
    check_internet
    check_aur_helper
    detect_nvidia
    install_pacman_packages
    install_aur_packages
    configure_regreet
    install_fonts
    changeshell_zsh
    apply_stow
    make_config_scripts_executable

    info_print "Dotfiles installation complete!"
}

main "$@"
