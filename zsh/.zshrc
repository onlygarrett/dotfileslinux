if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
neofetch --config ~/.config/neofetch/asdf/config3.conf -L
task
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Add wisely, as too many plugins slow down shell startup.
# export FPATH="/home/grumschik/.oh-my-zsh/custom/plugins/eza/completions/zsh:$FPATH"
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting ohmyzsh-full-autoupdate sudo ) 

source $ZSH/oh-my-zsh.sh

DISABLE_AUTO_UPDATE=true
DISABLE_MAGIC_FUNCTIONS=true
# User configuration

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Example aliases
alias c="clear"
alias ..="cd .."
alias syu="sudo dnf upgrade"
alias syi="sudo dnf install"
alias cat="bat"
alias fk="sudo !!"
alias dco="docker compose"
alias dps="docker ps"
# Qwen3-Coder local server (podman container)
alias qcup='qwen-coder-server.sh -d'              # start detached
alias qcdown='podman stop qwen-coder'             # stop (auto-removes; container is --rm)
alias qcps='podman ps --filter name=qwen-coder'   # status
# JupyterLab (for jupyter-mcp-server)
alias jlup='~/.venvs/jupyter/bin/jupyter lab --port 8888 --IdentityProvider.token "$(cat ~/.jupyter_token 2>/dev/null || echo myjupytertoken)" --ServerApp.disable_check_xsrf=True --no-browser'


alias zshconfig="source ~/.zshrc"
alias ls="eza -a --icons --git"
alias l='eza -alg --color=always --group-directories-first --git'
alias ll='eza -alSgh --color=always --group-directories-first --icons --header --long --git'
alias lt='eza -@alT --color=always --git'
alias llt="tree"
alias lr='eza -alg --sort=modified --color=always --group-directories-first --git'
alias ide='bash ~/.config/scripts/__tmux_ide.sh'
alias v='nvim'
alias grep='grep --color=auto'
alias sensors='sensors | bat -l cpuinfo -p'
alias vh="nvim"
alias lg="lazygit"
alias ld="sudo lazydocker"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias python='/usr/bin/python3'
alias wezterm='flatpak run org.wezfurlong.wezterm'
alias wz='flatpak run org.wezfurlong.wezterm'
# alias y='yazi'

# fzf
export FZF_DEFAULT_COMMAND='fd --type file --color=always --follow --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
# tat: tmux attach
function tat {
  name=$(basename `pwd` | sed -e 's/\.//g')

  if tmux ls 2>&1 | grep "$name"; then
    tmux attach -t "$name"
  elif [ -f .envrc ]; then
    direnv exec / tmux new-session -s "$name"
  else
    tmux new-session -s "$name"
  fi
}
# Example aliases
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(zoxide init zsh)"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH=$PATH:$HOME/.cargo/bin:$HOME/go/bin

. "$HOME/.config/local/share/../bin/env"

autoload -U compinit; compinit

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/jee/.lmstudio/bin"
#compdef opencode
###-begin-opencode-completions-###
#
# yargs command completion script
#
# Installation: opencode completion >> ~/.zshrc
#    or opencode completion >> ~/.zprofile on OSX.
#
_opencode_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
  IFS=$si
  if [[ ${#reply} -gt 0 ]]; then
    _describe 'values' reply
  else
    _default
  fi
}
if [[ "'${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
  _opencode_yargs_completions "$@"
else
  compdef _opencode_yargs_completions opencode
fi
###-end-opencode-completions-###


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Android AVD Home (for XDG compliance on Linux)
export ANDROID_AVD_HOME=~/.config/.android/avd

# Qwen Code PATH block begin
export PATH='/home/jee/.local/bin':$PATH
# Qwen Code PATH block end

# Pi
export PATH="/home/jee/.config/local/share/pi-node/node-v22.23.0-linux-x64/bin:$PATH"

# Local secrets (NOT in dotfiles repo) — e.g. TAVILY_API_KEY for opencode
[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets
