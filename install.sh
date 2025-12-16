#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Neovim Configuration Installation Script
# =============================================================================

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARN] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

command_exists() {
    command -v "$1" &>/dev/null
}

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# -----------------------------------------------------------------------------
# Package Installation
# -----------------------------------------------------------------------------

install_homebrew() {
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to path for current session
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    fi
}

install_packages_macos() {
    log_info "Installing packages via Homebrew..."
    install_homebrew
    
    local packages=(neovim ripgrep fd lazygit node git)
    for pkg in "${packages[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            log_info "Installing $pkg..."
            brew install "$pkg"
        else
            log_info "$pkg already installed"
        fi
    done
}

install_packages_linux() {
    local distro
    distro=$(detect_linux_distro)
    
    case "$distro" in
        ubuntu|debian|pop)
            install_packages_debian
            ;;
        fedora)
            install_packages_fedora
            ;;
        arch|manjaro)
            install_packages_arch
            ;;
        *)
            log_warn "Unknown distro: $distro. Attempting Homebrew..."
            install_packages_linux_brew
            ;;
    esac
}

install_packages_debian() {
    log_info "Installing packages via apt..."
    sudo apt update
    sudo apt install -y git curl
    
    # Neovim from PPA for latest version
    if ! command_exists nvim; then
        log_info "Installing Neovim from PPA..."
        sudo apt install -y software-properties-common
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        sudo apt update
        sudo apt install -y neovim
    fi
    
    # Other tools
    sudo apt install -y ripgrep fd-find
    
    # Node.js via NodeSource
    if ! command_exists node; then
        log_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
    
    # lazygit
    if ! command_exists lazygit; then
        log_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm -f lazygit lazygit.tar.gz
    fi
}

install_packages_fedora() {
    log_info "Installing packages via dnf..."
    sudo dnf install -y neovim ripgrep fd-find git nodejs lazygit
}

install_packages_arch() {
    log_info "Installing packages via pacman..."
    sudo pacman -Syu --noconfirm neovim ripgrep fd git nodejs npm lazygit
}

install_packages_linux_brew() {
    install_homebrew
    
    local packages=(neovim ripgrep fd lazygit node git)
    for pkg in "${packages[@]}"; do
        if ! brew list "$pkg" &>/dev/null; then
            brew install "$pkg"
        fi
    done
}

# -----------------------------------------------------------------------------
# Symlink Management
# -----------------------------------------------------------------------------

backup_existing() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
        log_warn "Backing up existing $target to $backup"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        log_info "Removing existing symlink: $target"
        rm "$target"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    backup_existing "$target"
    
    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"
    
    log_info "Linking $source -> $target"
    ln -sf "$source" "$target"
}

setup_symlinks() {
    log_info "Setting up symlinks..."
    
    # Neovim
    create_symlink "$REPO_DIR/nvim" "$CONFIG_DIR/nvim"
}

# -----------------------------------------------------------------------------
# Neovim Setup
# -----------------------------------------------------------------------------

setup_neovim() {
    log_info "Setting up Neovim..."
    
    if command_exists nvim; then
        log_info "Running Neovim headless to bootstrap plugins..."
        # This triggers lazy.nvim bootstrap and plugin installation
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
        log_info "Neovim plugins installed"
    else
        log_error "Neovim not found. Please install it first."
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
    local os
    os=$(detect_os)
    
    log_info "Detected OS: $os"
    log_info "Repository: $REPO_DIR"
    log_info "Config directory: $CONFIG_DIR"
    echo ""
    
    # Install packages
    case "$os" in
        macos)
            install_packages_macos
            ;;
        linux)
            install_packages_linux
            ;;
        windows)
            log_warn "Windows detected. Please use WSL2 or install packages manually."
            log_warn "Required: neovim, ripgrep, fd, node, git"
            ;;
        *)
            log_error "Unsupported OS: $os"
            exit 1
            ;;
    esac
    
    echo ""
    
    # Setup symlinks
    setup_symlinks
    
    echo ""
    
    # Setup Neovim
    setup_neovim
    
    echo ""
    log_info "Installation complete!"
    log_info "Open a new terminal and run 'nvim' to start."
}

main "$@"

