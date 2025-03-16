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
export PATH="$PATH:/home/derrik/.local/bin"

# Aliases
alias download-distro="cd ~/scripts; and bash ~/scripts/distro_downloader.sh"
alias lsblk="lsblk -e7"

# Functions
function update-packages
    # Update Arch Linux packages
    sudo pacman -Syu
end

function search-packages
    # Search for packages in Arch Linux
    pacman -Ss "$argv"
end

function list-installed-packages
    # List installed packages in Arch Linux
    pacman -Qe
end

function remove-package
    # Remove a package in Arch Linux
    sudo pacman -Rns "$argv"
end

function clean-package-cache
    # Clean package cache in Arch Linux
    sudo pacman -Scc
end

function edit-pacman-config
    # Edit pacman configuration file
    sudo nano /etc/pacman.conf
end
