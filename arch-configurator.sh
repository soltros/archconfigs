#!/bin/bash
# Arch Linux equivalent of the NixOS flake setup

# System package list (Equivalent to environment.systemPackages)
PACKAGES=(
  base-devel
  git
  nano
  vscode
  htop
  btop
  ripgrep
  fd
  bitwarden
  python312
  btrfs-progs
  appimage-run
  papirus-icon-theme
  gnome-dconf-editor
  libreoffice-qt
  gnome-tweaks
  spotify
  tailscale
  vlc
  gimp
  wget
  zettlr
  winetricks
  wine-staging
  pavucontrol
  fluffychat
  distrobox
  geany
  thunderbird
  ntfs-3g
  firefox
  flatpak
  discord
  kopia
  telegram-desktop
  screen
  nodejs
  pipx
  ncdu
  python-pip
  caffeine-ng
  php
  adapta-gtk-theme
  mlocate
  yt-dlp
  pamixer
  gthumb
  unzip
  file-roller
  lxrandr
  pinta
  okular
  plex-media-player
  virt-manager
  virtualbox
  virtualbox-host-modules-arch
  pacman-contrib
  libvirt
)

# AUR packages (using Trizen)
AUR_PACKAGES=(
  # Add more AUR packages as needed
)

# Ensure Architecture is defined in pacman.conf
if ! grep -q "^Architecture" /etc/pacman.conf; then
  echo "Architecture = x86_64" | sudo tee -a /etc/pacman.conf
fi

# Enable multilib repository if not enabled
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
fi

# Enable parallel downloads
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# Install system packages
sudo pacman -Syu --needed "${PACKAGES[@]}"

# Install AUR packages
trizen -S --noconfirm "${AUR_PACKAGES[@]}"

# Enable Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Ensure vboxusers group exists
if ! grep -q "^vboxusers:" /etc/group; then
  sudo groupadd vboxusers
fi

# Enable VirtualBox support
sudo gpasswd -a derrik vboxusers
sudo modprobe vboxdrv vboxnetadp vboxnetflt vboxpci

# Enable libvirt virtualization
sudo systemctl enable --now virtqemud.service

# User-specific configuration
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/alacritty"

# Git configuration
cat <<EOF > "$HOME/.gitconfig"
[user]
  name = Derrik Diener
  email = soltros@proton.me
[init]
  defaultBranch = main
[pull]
  rebase = true
[core]
  editor = nano
EOF

# Fish shell configuration
cat <<EOF > "$HOME/.config/fish/config.fish"
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
set -gx PATH \$PATH:/home/derrik/.local/bin

# Aliases
alias download-distro="cd ~/scripts; and bash ~/scripts/distro_downloader.sh"
alias nixpkger="bash ~/scripts/nixpkger"
alias lsblk="lsblk -e7"
EOF

# XDG directories setup
mkdir -p "$HOME/Documents" "$HOME/Downloads" "$HOME/Music" "$HOME/Pictures" "$HOME/Videos"

# GTK theme settings
mkdir -p "$HOME/.config/gtk-3.0"
cat <<EOF > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
EOF

# Alacritty configuration
cat <<EOF > "$HOME/.config/alacritty/alacritty.yml"
window:
  opacity: 0.95
  padding:
    x: 10
    y: 10
font:
  normal:
    family: "DejaVu Sans Mono"
    style: "Regular"
  size: 12.0
colors:
  primary:
    background: "#1d1f21"
    foreground: "#c5c8c6"
EOF

# Environment variables
cat <<EOF > "$HOME/.config/environment"
export EDITOR=nano
export VISUAL=nano
export TERMINAL=alacritty
export BROWSER=firefox
EOF

# Nix garbage collection equivalent
sudo paccache -r
