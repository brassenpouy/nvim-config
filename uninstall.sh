#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Dotfiles Uninstallation Script
# =============================================================================

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

log_info() {
    echo "[INFO] $1"
}

remove_symlink() {
    local target="$1"
    
    if [ -L "$target" ]; then
        log_info "Removing symlink: $target"
        rm "$target"
    elif [ -e "$target" ]; then
        log_info "Skipping (not a symlink): $target"
    else
        log_info "Does not exist: $target"
    fi
}

main() {
    log_info "Removing dotfile symlinks..."
    
    remove_symlink "$CONFIG_DIR/nvim"
    # Add more as needed:
    # remove_symlink "$HOME/.zshrc"
    # remove_symlink "$HOME/.gitconfig"
    
    log_info "Uninstallation complete."
    log_info "Note: Installed packages were not removed."
}

main "$@"

