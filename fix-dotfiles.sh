#!/bin/bash
# Save this as ~/dotfiles/fix-dotfiles.sh

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "Creating backup directory at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to safely move a file
move_dotfile() {
  local source="$1"
  local dest="$2"

  if [ -f "$source" ] || [ -d "$source" ]; then
    echo "Moving $source to $dest"
    # Create backup
    cp -r "$source" "$BACKUP_DIR/" 2>/dev/null || true
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    # Move the file
    mv "$source" "$dest"
  else
    echo "Skipping $source (doesn't exist)"
  fi
}

echo "Fixing dotfile structure..."

# Bash files - NO SPACES in paths!
move_dotfile "$HOME/.bashrc" "$DOTFILES_DIR/bash/. bashrc"
move_dotfile "$HOME/.bash_aliases" "$DOTFILES_DIR/bash/.bash_aliases"

# Zsh files - NO SPACES!
move_dotfile "$HOME/. zprofile" "$DOTFILES_DIR/zsh/.zprofile"
move_dotfile "$HOME/. zsh_aliases" "$DOTFILES_DIR/zsh/.zsh_aliases"

# Scripts
move_dotfile "$HOME/.local/bin" "$DOTFILES_DIR/scripts/. local/bin"

# Any other dotfiles in home directory
move_dotfile "$HOME/.profile" "$DOTFILES_DIR/bash/.profile"
move_dotfile "$HOME/.inputrc" "$DOTFILES_DIR/readline/.inputrc"
move_dotfile "$HOME/.editorconfig" "$DOTFILES_DIR/editorconfig/.editorconfig"

echo ""
echo "Checking for orphaned config directories..."

# Clean up any empty 'config' directory if it exists
if [ -d "$DOTFILES_DIR/config" ]; then
  echo "Found orphaned 'config' directory, checking contents..."
  if [ -z "$(ls -A $DOTFILES_DIR/config)" ]; then
    echo "  Removing empty config directory"
    rmdir "$DOTFILES_DIR/config"
  else
    echo "  Warning: config directory is not empty, please move contents manually"
    ls -la "$DOTFILES_DIR/config"
  fi
fi

echo ""
echo "Migration complete!"
echo "Backup created at: $BACKUP_DIR"
