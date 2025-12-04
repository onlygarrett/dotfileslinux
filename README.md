# My Dotfiles

Personal configuration files managed with GNU Stow.

## Prerequisites

- Git
- GNU Stow

### Installing GNU Stow

```bash
# Debian/Ubuntu
sudo apt install stow

# Fedora/RHEL
sudo dnf install stow

# Arch Linux
sudo pacman -S stow

# macOS
brew install stow

# Clone this repository
git clone https://github. com/onlygarrett/dotfiles.git ~/dotfiles

# Navigate to the directory
cd ~/dotfiles

# Stow all configurations
stow */

# Or stow individual packages
stow bash
stow vim
stow git

# Create package directory if it doesn't exist
mkdir -p ~/dotfiles/newapp

# Move your config file, preserving directory structure
# For files in home directory:
mv ~/.newapprc ~/dotfiles/newapp/. newapprc

# For files in . config:
mkdir -p ~/dotfiles/newapp/.config/newapp
mv ~/.config/newapp/config ~/dotfiles/newapp/.config/newapp/config

# Stow the package
cd ~/dotfiles
stow newapp

# removing a package
cd ~/dotfiles
stow -D packagename

# restowing afte updates
cd ~/dotfiles
stow -R packagename

# Fresh System setup
# Install stow
# ...  (see prerequisites above)

# Clone dotfiles
git clone https://github.com/onlygarrett/dotfiles.git ~/dotfiles

# Stow everything
cd ~/dotfiles
stow */

# Source your shell config
source ~/.bashrc  # or ~/.zshrc

## Adding new dotfiles
# 1. Create package directory
mkdir -p ~/dotfiles/newapp

# 2. Move config (preserving path structure)
# For home directory files:
mv ~/.newapprc ~/dotfiles/newapp/. newapprc

# For .config files:
mkdir -p ~/dotfiles/newapp/.config/newapp
mv ~/.config/newapp/config ~/dotfiles/newapp/.config/newapp/config

# 3. Stow the package
cd ~/dotfiles
stow newapp

# 4. Commit to git
git add newapp
git commit -m "Add newapp configuration"
git push
