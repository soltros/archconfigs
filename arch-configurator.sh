#!/bin/bash
set -e

USER_HOME="/home/$USER"
FISH_CONFIG_DIR="$USER_HOME/.config/fish"
FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"

fish_setup() {
    echo "Setting up Fish config..."

    mkdir -p "$FISH_CONFIG_DIR"

    cat <<EOF > "$FISH_CONFIG_FILE"
# No greeting
set -g fish_greeting ""

# Prompt Configuration
function fish_prompt
    set_color white; echo -n (whoami)
    set_color normal; echo -n ':'
    set_color cyan; echo -n (pwd)
    set_color normal; echo -n ' '
end

# Environment Variables
set -x PATH \$PATH $USER_HOME/.local/bin

# Aliases
alias lsblk="lsblk -e7"
EOF

    chsh -s "$(which fish)" "$USER"
    echo "Fish shell set as default for user: $USER"
}

install_packages() {
    echo "Installing system packages..."
    sudo pacman -Syu --noconfirm

    sudo pacman -S --noconfirm \
        gimp tailscale vlc nano thunderbird git papirus-icon-theme \
        geany wine fish util-linux pciutils hwdata usbutils coreutils binutils \
        findutils grep iproute2 bash bash-completion udisks2 base-devel cmake
}

install_flatpaks() {
    echo "Installing Flatpak apps..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    sudo flatpak install -y \
        com.mattjakeman.ExtensionManager \
        com.discordapp.Discord \
        io.kopia.KopiaUI \
        com.spotify.Client \
        com.valvesoftware.Steam \
        org.telegram.desktop \
        tv.plex.PlexDesktop \
        com.nextcloud.desktopclient.nextcloud \
        im.riot.Riot \
        com.github.tchx84.Flatseal
}

install_docker_distrobox() {
    echo "Installing Docker and Distrobox..."

    sudo pacman -S --noconfirm docker
    sudo systemctl enable docker --now

    if ! command -v distrobox >/dev/null 2>&1; then
        echo "Installing Distrobox from AUR with Trizen..."
        trizen -S --noconfirm distrobox
    fi
}

install_virtualbox() {
    echo "Installing VirtualBox from repo..."
    sudo pacman -S --noconfirm virtualbox virtualbox-host-modules-arch linux-headers
    sudo modprobe vboxdrv
    echo "VirtualBox installed and kernel module loaded."
}

install_waterfox() {
    echo "Installing Waterfox from AUR..."
    trizen -S --noconfirm waterfox-bin
}

switch_desktop_environment() {
    echo "Switching desktop environments (KDE <-> GNOME)..."

    echo "1) GNOME"
    echo "2) KDE"
    echo -n "Enter your choice: "
    read -r de_choice

    case "$de_choice" in
        1)
            echo "Installing GNOME and removing KDE..."
            sudo pacman -Rs --noconfirm plasma-meta kde-applications-meta sddm || true
            sudo pacman -S --noconfirm gnome gnome-extra gdm
            sudo systemctl enable gdm
            ;;
        2)
            echo "Installing KDE and removing GNOME..."
            sudo pacman -Rs --noconfirm gnome gnome-extra gdm || true
            sudo pacman -S --noconfirm plasma-meta kde-applications-meta sddm
            sudo systemctl enable sddm
            ;;
        *)
            echo "Invalid choice. Aborting."
            return
            ;;
    esac

    echo "Done. Reboot to complete the desktop switch."
}

main_menu() {
    echo "Arch Linux Setup Menu"
    echo "1) Setup Fish shell and config"
    echo "2) Install system packages"
    echo "3) Install Flatpak apps"
    echo "4) Install Docker and Distrobox"
    echo "5) Install VirtualBox"
    echo "6) Install Waterfox (AUR)"
    echo "7) Switch desktop environments"
    echo "8) Quit"
    echo -n "Choose an option: "
    read -r choice

    case "$choice" in
        1) fish_setup ;;
        2) install_packages ;;
        3) install_flatpaks ;;
        4) install_docker_distrobox ;;
        5) install_virtualbox ;;
        6) install_waterfox ;;
        7) switch_desktop_environment ;;
        8) echo "Bye!"; exit 0 ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
}

main_menu
