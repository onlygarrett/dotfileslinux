#!/bin/bash
# save this as ~/dotfiles/migrate-dotfiles.sh

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

# Bash files
move_dotfile "$HOME/.bashrc" "$DOTFILES_DIR/bash/.bashrc"
move_dotfile "$HOME/.bash_profile" "$DOTFILES_DIR/bash/.bash_profile"
move_dotfile "$HOME/.bash_logout" "$DOTFILES_DIR/bash/.bash_logout"
move_dotfile "$HOME/.bash_aliases" "$DOTFILES_DIR/bash/.bash_aliases"
move_dotfile "$HOME/.profile" "$DOTFILES_DIR/bash/.profile"

# Zsh files
move_dotfile "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
move_dotfile "$HOME/.zsh_profile" "$DOTFILES_DIR/zsh/.zsh_profile"
move_dotfile "$HOME/.zsh_aliases" "$DOTFILES_DIR/zsh/.zsh_aliases"
move_dotfile "$HOME/.zshenv" "$DOTFILES_DIR/zsh/.zshenv"

# Git files
move_dotfile "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
move_dotfile "$HOME/.gitignore_global" "$DOTFILES_DIR/git/.gitignore_global"
move_dotfile "$HOME/.gitmessage" "$DOTFILES_DIR/git/.gitmessage"

# Vim files
move_dotfile "$HOME/.vimrc" "$DOTFILES_DIR/vim/.vimrc"
move_dotfile "$HOME/.vim" "$DOTFILES_DIR/vim/.vim"

# Neovim files
move_dotfile "$HOME/.config/nvim" "$DOTFILES_DIR/nvim/.config/nvim"

# Tmux files
move_dotfile "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux/.tmux.conf"
move_dotfile "$HOME/.tmux" "$DOTFILES_DIR/tmux/.tmux"

# Alacritty
move_dotfile "$HOME/.config/alacritty" "$DOTFILES_DIR/alacritty/.config/alacritty"

# i3 window manager
move_dotfile "$HOME/.config/i3" "$DOTFILES_DIR/i3/.config/i3"
move_dotfile "$HOME/.config/i3status" "$DOTFILES_DIR/i3/.config/i3status"

# Kitty terminal
move_dotfile "$HOME/.config/kitty" "$DOTFILES_DIR/kitty/.config/kitty"

# SSH config (be careful with this one)
move_dotfile "$HOME/.ssh/config" "$DOTFILES_DIR/ssh/.ssh/config"

# X11 files
move_dotfile "$HOME/.Xresources" "$DOTFILES_DIR/x11/.Xresources"
move_dotfile "$HOME/.xinitrc" "$DOTFILES_DIR/x11/.xinitrc"
move_dotfile "$HOME/.Xmodmap" "$DOTFILES_DIR/x11/.Xmodmap"

# Readline
move_dotfile "$HOME/.inputrc" "$DOTFILES_DIR/readline/.inputrc"

# Scripts
if [ -d "$HOME/.local/bin" ]; then
  move_dotfile "$HOME/.local/bin" "$DOTFILES_DIR/scripts/.local/bin"
fi

# Environment variables
move_dotfile "$HOME/.environment" "$DOTFILES_DIR/environment/.environment"

# Starship prompt
move_dotfile "$HOME/.config/starship.toml" "$DOTFILES_DIR/starship/.config/starship.toml"

# Dunst notification daemon
move_dotfile "$HOME/.config/dunst" "$DOTFILES_DIR/dunst/.config/dunst"

# Rofi launcher
move_dotfile "$HOME/.config/rofi" "$DOTFILES_DIR/rofi/.config/rofi"

# Polybar
move_dotfile "$HOME/.config/polybar" "$DOTFILES_DIR/polybar/.config/polybar"

# Picom compositor
move_dotfile "$HOME/.config/picom" "$DOTFILES_DIR/picom/.config/picom"

# Ranger file manager
move_dotfile "$HOME/.config/ranger" "$DOTFILES_DIR/ranger/.config/ranger"

# Fish shell
move_dotfile "$HOME/.config/fish" "$DOTFILES_DIR/fish/.config/fish"

# Awesome WM
move_dotfile "$HOME/.config/awesome" "$DOTFILES_DIR/awesome/.config/awesome"

# Emacs
move_dotfile "$HOME/.emacs.d" "$DOTFILES_DIR/emacs/.emacs.d"
move_dotfile "$HOME/.emacs" "$DOTFILES_DIR/emacs/.emacs"

# Nano
move_dotfile "$HOME/.nanorc" "$DOTFILES_DIR/nano/.nanorc"

# htop
move_dotfile "$HOME/.config/htop" "$DOTFILES_DIR/htop/.config/htop"

# mpv
move_dotfile "$HOME/.config/mpv" "$DOTFILES_DIR/mpv/.config/mpv"

# VSCode settings (optional, if you want to version control them)
move_dotfile "$HOME/.config/Code/User/settings.json" "$DOTFILES_DIR/vscode/.config/Code/User/settings.json"
move_dotfile "$HOME/.config/Code/User/keybindings.json" "$DOTFILES_DIR/vscode/.config/Code/User/keybindings. json"

echo ""
echo "Migration complete!"
echo "Backup created at: $BACKUP_DIR"
echo "Dotfiles moved to: $DOTFILES_DIR"
echo ""
echo "Next steps:"
echo "1. Review the moved files in $DOTFILES_DIR"
echo "2.  Run 'cd ~/dotfiles && stow *' to create symlinks"
echo "3.  Test your configuration"
echo "4. If everything works, you can delete $BACKUP_DIR"
