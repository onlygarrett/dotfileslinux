#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

# Only move files that aren't already symlinked
move_if_exists() {
  local source="$1"
  local dest="$2"

  # Only move if source exists and is NOT already a symlink
  if [ -e "$source" ] && [ ! -L "$source" ]; then
    echo "Moving $source"
    mkdir -p "$(dirname "$dest")"
    mv "$source" "$dest"
  fi
}

# Bash files
move_if_exists "$HOME/.bashrc" "$DOTFILES_DIR/bash/.bashrc"
move_if_exists "$HOME/.bash_aliases" "$DOTFILES_DIR/bash/.bash_aliases"

# Zsh files
move_if_exists "$HOME/.zprofile" "$DOTFILES_DIR/zsh/.zprofile"
move_if_exists "$HOME/.zsh_aliases" "$DOTFILES_DIR/zsh/.zsh_aliases"

# Scripts
if [ -d "$HOME/.local/bin" ] && [ ! -L "$HOME/.local/bin" ]; then
  echo "Moving ~/. local/bin"
  mkdir -p "$DOTFILES_DIR/scripts/.local"
  mv "$HOME/.local/bin" "$DOTFILES_DIR/scripts/.local/bin"
fi

# Other common files
move_if_exists "$HOME/.profile" "$DOTFILES_DIR/bash/.profile"
move_if_exists "$HOME/.inputrc" "$DOTFILES_DIR/readline/.inputrc"
move_if_exists "$HOME/.editorconfig" "$DOTFILES_DIR/editorconfig/.editorconfig"
move_if_exists "$HOME/. tmux.conf" "$DOTFILES_DIR/tmux/.tmux.conf"
move_if_exists "$HOME/.vimrc" "$DOTFILES_DIR/vim/.vimrc"

echo "Done!  Check if any files were moved, then run: cd ~/dotfiles && stow */"
