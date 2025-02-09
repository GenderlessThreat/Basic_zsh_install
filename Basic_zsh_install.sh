#!/bin/bash

# Exit immediately if any command fails
set -e

# Function to install packages on Debian-based systems
install_debian() {
    sudo apt-get update
    sudo apt-get install -y zsh git curl
}

# Function to install packages on macOS
install_mac() {
    brew install zsh git curl
}

# Detect operating system
OS="$(uname -s)"
case "$OS" in
    Linux*)
        if [ -f /etc/debian_version ]; then
            echo "Detected Debian/Ubuntu-based system"
            # Check and install dependencies
            for pkg in zsh git curl; do
                if ! command -v "$pkg" &> /dev/null; then
                    install_debian
                    break
                fi
            done
        else
            echo "Unsupported Linux distribution. Exiting."
            exit 1
        fi
        ;;
    Darwin*)
        echo "Detected macOS"
        # Check for Homebrew
        if ! command -v brew &> /dev/null; then
            echo "Homebrew required. Please install first: https://brew.sh/"
            exit 1
        fi
        # Check and install dependencies
        for pkg in zsh git curl; do
            if ! command -v "$pkg" &> /dev/null; then
                install_mac
                break
            fi
        done
        ;;
    *)
        echo "Unsupported operating system. Exiting."
        exit 1
        ;;
esac

# Install Oh My Zsh (if not already installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh already installed. Skipping."
fi

# Install Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "Powerlevel10k already installed. Skipping."
fi

# Install zsh-autosuggestions plugin
AUTOSUGGEST_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGGEST_DIR" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGEST_DIR"
else
    echo "zsh-autosuggestions already installed. Skipping."
fi

# Install zsh-syntax-highlighting plugin
SYNTAX_HIGHLIGHT_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_HIGHLIGHT_DIR" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$SYNTAX_HIGHLIGHT_DIR"
else
    echo "zsh-syntax-highlighting already installed. Skipping."
fi

# Configure .zshrc
ZSHRC="$HOME/.zshrc"

# Backup existing .zshrc if it exists
if [ -f "$ZSHRC" ]; then
    cp "$ZSHRC" "${ZSHRC}.bak"
    echo "Existing .zshrc backed up to ${ZSHRC}.bak"
fi

# Set theme
echo "Configuring Powerlevel10k theme..."
sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"

# Add plugins
echo "Configuring plugins..."
sed -i.bak 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"

# Final instructions
echo -e "\nInstallation complete!"
echo "To start using Zsh:"
echo "  1. Start a new Zsh session: exec zsh"
echo "  2. Follow the Powerlevel10k configuration wizard"
echo "  3. To make Zsh your default shell: chsh -s \$(which zsh)"
echo -e "\nNote: If you have an existing Powerlevel10k configuration,"
echo "you might want to remove ~/.p10k.zsh to trigger the wizard again."
