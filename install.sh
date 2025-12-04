#!/bin/bash

set -e

echo "======================================"
echo "Dotfiles Installation Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if stow is installed
if ! command -v stow &>/dev/null; then
  echo -e "${RED}Error: GNU Stow is not installed. ${NC}"
  echo ""
  echo "Please install it first:"
  echo "  Debian/Ubuntu: sudo apt install stow"
  echo "  Fedora/RHEL:   sudo dnf install stow"
  echo "  Arch Linux:    sudo pacman -S stow"
  echo "  macOS:         brew install stow"
  exit 1
fi

# Get the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo -e "${GREEN}Dotfiles directory: $DOTFILES_DIR${NC}"
echo ""

# Backup existing dotfiles
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}Creating backup at $BACKUP_DIR${NC}"
mkdir -p "$BACKUP_DIR"

# Function to backup if file exists
backup_if_exists() {
  local file="$1"
  if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
    echo "  Backing up ~/$file"
    mkdir -p "$BACKUP_DIR/$(dirname "$file")"
    cp -r "$HOME/$file" "$BACKUP_DIR/$file"
    rm -rf "$HOME/$file"
  fi
}

# List of common dotfiles to backup
backup_if_exists ".bashrc"
backup_if_exists ".bash_profile"
backup_if_exists ".zshrc"
backup_if_exists ".vimrc"
backup_if_exists ".gitconfig"
backup_if_exists ".tmux.conf"

echo ""
echo -e "${GREEN}Stowing packages...${NC}"

# Stow all packages
for dir in "$DOTFILES_DIR"/*/; do
  if [ -d "$dir" ]; then
    package=$(basename "$dir")
    echo "  Stowing $package..."
    stow -v "$package" 2>&1 | grep -v "BUG in find_stowed_path" || true
  fi
done

echo ""
echo -e "${GREEN}======================================"
echo "Installation complete!"
echo "======================================${NC}"
echo ""
echo "Backup created at: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1.  Restart your terminal or source your shell config"
echo "  2.  Verify everything works correctly"
echo "  3. If everything is good, you can delete the backup"
echo ""
