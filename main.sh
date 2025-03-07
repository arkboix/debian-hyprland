#!/bin/bash
# Debian-compatible version of Arkboi's Dotfiles Installation Script
# Adapted from https://github.com/arkboix/dotfiles
# https://github.com/arkboix/arch-hyprland

# DO NOT EDIT IF YOU DO NOT KNOW WHAT YOU ARE DOING!!

set -e  # Exit script on any error

sudo -v  # Keep sudo active
sudo apt update
sudo apt install -y figlet ruby
gem install lolcat
figlet "Arkboi's DOTS" | lolcat
echo "Installing Arkboi's DOTFILES for $(whoami)"

# Define stuff - Add any more packages you want to install in EXTRA_PACKAGES
BACKUP_DIR="$HOME/arkboi-dots-backup"

SCRIPT_PACKAGES=(
    "git"
    "stow"
    "curl"
)

# Debian/Ubuntu repositories often lag behind Arch for Wayland packages
# Many packages will need to be installed from source or third-party repositories
APT_PACKAGES=(
    "kitty"
    "emacs"
    "zsh"
    "yad"
    "fonts-font-awesome"
    "fonts-jetbrains-mono"
    "fonts-firacode"
    "fonts-ibm-plex"
    "brightnessctl"
    "zenity"
    "nautilus"
    "pulseaudio-utils" # For pactl
)

EXTRA_PACKAGES=()

FILES=(
    "$HOME/arkscripts"
    "$HOME/.config/hypr"
    "$HOME/.config/waybar"
    "$HOME/.config/doom"
    "$HOME/.config/kitty"
    "$HOME/.config/mako"
    "$HOME/.config/nwg-wrapper"
    "$HOME/.config/rofi"
    "$HOME/wallpapers"
    "$HOME/.config/wlogout"
    "$HOME/.config/starship.toml"
    "$HOME/.zshrc"
    "$HOME/.zshrc-personal"
)

# Install dependent packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y "${SCRIPT_PACKAGES[@]}" "${APT_PACKAGES[@]}" "${EXTRA_PACKAGES[@]}"

figlet "Installing Wayland Components" | lolcat

# Install Hyprland and related components (not available in Debian repos)
install_hyprland() {
    echo "Installing Hyprland and related components..."

    # Build dependencies
    sudo apt install -y cmake meson wget build-essential ninja-build pkg-config \
        libwayland-dev libwlroots-dev libinput-dev libxkbcommon-dev \
        libcairo2-dev libpango1.0-dev libgbm-dev libseat-dev hwdata \
        libdisplay-info-dev libxcb-icccm4-dev libxcb-ewmh-dev

    # Create a directory for building
    mkdir -p "$HOME/hyprbuild"
    cd "$HOME/hyprbuild"

    # Clone and build Hyprland
    git clone --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    make all
    sudo make install

    # Hyprlock
    cd "$HOME/hyprbuild"
    git clone https://github.com/hyprwm/hyprlock
    cd hyprlock
    make all
    sudo make install

    # Hypridle
    cd "$HOME/hyprbuild"
    git clone https://github.com/hyprwm/hypridle
    cd hypridle
    make all
    sudo make install

    # Hyprcursor
    cd "$HOME/hyprbuild"
    git clone https://github.com/hyprwm/hyprcursor
    cd hyprcursor
    make all
    sudo make install
}

# Install waybar (newer version than in Debian repos)
install_waybar() {
    echo "Installing Waybar..."

    sudo apt install -y libgtkmm-3.0-dev libdbusmenu-gtk3-dev libpulse-dev \
        libjsoncpp-dev libmpdclient-dev libspdlog-dev libfmt-dev libwayland-dev \
        libgtk-layer-shell-dev gobject-introspection libgirepository1.0-dev \
        gir1.2-gtk-3.0 libsigc++-2.0-dev libspdlog-dev

    cd "$HOME/hyprbuild"
    git clone https://github.com/Alexays/Waybar.git
    cd Waybar
    meson build
    ninja -C build
    sudo ninja -C build install
}

# Install rofi-wayland
install_rofi_wayland() {
    echo "Installing rofi-wayland..."

    sudo apt install -y libxkbcommon-dev libpango1.0-dev libcairo2-dev \
        libglib2.0-dev libstartup-notification0-dev libxcb-ewmh-dev \
        libxcb-icccm4-dev libxcb-randr0-dev libxcb-xinerama0-dev \
        libxcb-xkb-dev libxcb-util-dev libxcb-cursor-dev flex bison

    cd "$HOME/hyprbuild"
    git clone https://github.com/lbonn/rofi
    cd rofi
    git checkout wayland
    mkdir build
    cd build
    ../configure --disable-check
    make
    sudo make install
}

# Install swww (animated wallpaper)
install_swww() {
    echo "Installing swww..."

    sudo apt install -y cargo rustc
    cargo install swww
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
}

# Install starship prompt
install_starship() {
    echo "Installing starship prompt..."
    curl -sS https://starship.rs/install.sh | sh
}

# Install mako (notification daemon)
install_mako() {
    echo "Installing mako..."

    sudo apt install -y libwayland-dev libdbus-1-dev libpango1.0-dev libcairo2-dev

    cd "$HOME/hyprbuild"
    git clone https://github.com/emersion/mako
    cd mako
    meson build
    ninja -C build
    sudo ninja -C build install
}

# Install wlogout
install_wlogout() {
    echo "Installing wlogout..."

    sudo apt install -y libgtk-3-dev scdoc

    cd "$HOME/hyprbuild"
    git clone https://github.com/ArtsyMacaw/wlogout
    cd wlogout
    meson build
    ninja -C build
    sudo ninja -C build install
}

# Install hyprshot (screenshot tool)
install_hyprshot() {
    echo "Installing hyprshot..."

    sudo apt install -y grim slurp jq libnotify-bin

    cd "$HOME/hyprbuild"
    git clone https://github.com/Gustash/hyprshot
    cd hyprshot
    sudo cp hyprshot /usr/local/bin/
    sudo chmod +x /usr/local/bin/hyprshot
}

# Install pokeget (Terminal Pokémon)
install_pokeget() {
    echo "Installing pokeget..."

    cd "$HOME/hyprbuild"
    git clone https://github.com/talwat/pokeget
    cd pokeget
    chmod +x pokeget
    sudo cp pokeget /usr/local/bin/
}

# Install light (for brightness control)
install_light() {
    echo "Installing light..."

    cd "$HOME/hyprbuild"
    git clone https://github.com/haikarainen/light
    cd light
    ./autogen.sh
    ./configure
    make
    sudo make install
}

# Install waypaper (wallpaper selector)
install_waypaper() {
    echo "Installing waypaper..."

    sudo apt install -y python3-pip
    pip3 install --user waypaper
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
}

# Install nwg-displays
install_nwg_displays() {
    echo "Installing nwg-displays..."

    sudo apt install -y python3-pip
    pip3 install --user nwg-displays
}

# Install nwg-wrapper
install_nwg_wrapper() {
    echo "Installing nwg-wrapper..."

    sudo apt install -y python3-pip python3-cairo
    pip3 install --user nwg-wrapper
}

# Install Nerd Fonts
install_nerd_fonts() {
    echo "Installing Nerd Fonts..."

    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts

    # JetBrains Mono Nerd Font
    wget -c https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
    unzip JetBrainsMono.zip
    rm JetBrainsMono.zip

    # IBM Plex Mono Nerd Font
    wget -c https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/IBMPlexMono.zip
    unzip IBMPlexMono.zip
    rm IBMPlexMono.zip

    fc-cache -fv
}

# Execute installation functions
install_hyprland
install_waybar
install_rofi_wayland
install_swww
install_starship
install_mako
install_wlogout
install_hyprshot
install_pokeget
install_light
install_waypaper
install_nwg_displays
install_nwg_wrapper
install_nerd_fonts

figlet "Backup and Install" | lolcat

# Clone the repository of dotfiles
if [ -d "$HOME/dotfiles" ]; then
    echo "Existing dotfiles found. Moving to ~/.dotfiles_old..."
    mkdir -p "$HOME/.dotfiles_old"
    mv "$HOME/dotfiles" "$HOME/.dotfiles_old"
fi

git clone https://github.com/arkboix/dotfiles.git "$HOME/dotfiles"

# Backup existing configurations
echo "Backing up existing configuration files..."
mkdir -p "$BACKUP_DIR"

for FILE in "${FILES[@]}"; do
    if [ -e "$FILE" ]; then
        mv "$FILE" "$BACKUP_DIR/"
        echo "Moved $FILE to $BACKUP_DIR/"
    fi
done

# Stow dotfiles safely
cd "$HOME/dotfiles"

echo "Applying dotfiles using Stow..."
for DIR in hypr waybar kitty mako wlogout nwg-wrapper doom arkscripts starship rofi wallpapers zsh; do
    if [ -d "$DIR" ] || [ -f "$DIR" ]; then
        stow -v -t ~ "$DIR"
    else
        echo "Skipping $DIR, directory not found."
    fi
done

# Post Installation
echo "Reloading configurations..."
echo "Note: You will need to login to Hyprland session to see changes"

# Set ZSHELL
chsh -s /bin/zsh

figlet "Done!" | lolcat
echo "Installation complete! Most packages had to be built from source as they're not available in Debian repositories."
echo "You should be good to go now! If you experience any errors, open an issue at: https://github.com/arkboix/dotfiles"
echo "If you launch into Hyprland and see no wallpaper, set one by pressing Super + C"
