echo 'Hi!' $USER
# source /etc/environment
export SUDO_EDITOR=/bin/nvim

# Configuration of zsh
## Other
### 警告显示为红色
zstyle ':completion:*:warnings' format $'\e[91m -- No Matches Found --\e[0m'
### 描述显示为淡色
zstyle ':completion:*:descriptions' format $'\e[2m -- %d --\e[0m'
zstyle ':completion:*:corrections' format $'\e[93m -- %d (errors: %e) --\e[0m'
### cd 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

## Set history file location
HISTFILE=${HOME}/.cache/.histfile
if [[ ! -f $HISTFILE ]]; then
    command mkdir -p ${HISTFILE:h} && command touch $HISTFILE
fi
HISTSIZE=5000
SAVEHIST=5000
### Options
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups   # remove older duplicate entries from the history
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_reduce_blanks     # remove superfluous blanks from history items
setopt hist_save_no_dups      # do not write a duplicate event to the history file
setopt inc_append_history     # allow multiple terminal sessions to append to one history
setopt share_history          # share command history data

# Alias
## Path
alias -g dsh='./Projects/deepseek-harness/'
alias -g paper267='./Projects/Papers-Coding/2026~2027/'
## Others
alias pvenv='source bin/activate'
alias upvenv='source .venv/bin/activate'
alias syc='doas systemctl start mihomo'
alias stc='doas systemctl stop mihomo'
alias neofetchm='neofetch --config ~/.config/neofetch-config.conf'
alias neofetchml='neofetch --config ~/.config/neofetch-config.conf | lolcat'
alias up='doas pacman -Syyu'
alias aup='paru -Syyu'
alias h='Hyprland'
alias shn='shutdown -h now'
alias gc='git clone'
alias gp='git push origin main'
alias gs='git status'
alias cat='bat'
alias ls="eza -a"
alias fastfetchm='fastfetch --config ~/.config/fastfetch/config.jsonc --logo ~/.config/fastfetch/Arch-Linux-Logo.png'
alias waybarc='waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style/style-dark.css'
alias waybars='waybar -s ~/.config/hypr/waybar/style.css'
alias lst="ls --tree --ignore-glob='.git'"
alias fontpreview="fontpreview --preview-text 'ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!@$\%(){}[]\n我能吞下玻璃而不伤身体。'"
alias mountex="doas mount -t exfat -o uid=$(id -u),gid=$(id -g),dmask=000,fmask=000"

# For Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# ZI Download
typeset -A ZI
  ZI[HOME_DIR]="${HOME}/.config/zsh/zi"
  ZI[BIN_DIR]="${ZI[HOME_DIR]}/bin"

if [[ ! -f ${ZI[BIN_DIR]}/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "${ZI[BIN_DIR]}" && command chmod go-rwX "${ZI[BIN_DIR]}"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "${ZI[BIN_DIR]}" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

# Load ZI
source "${ZI[BIN_DIR]}/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi
# Plugins install and setting
## Plugin installation and loading
### 1. Completions (must be before compinit)
zi light zsh-users/zsh-completions

### Run compinit
zicompinit

### 2. Load fzf before fzf-tab (fzf-tab must be last to bind ^I)
eval "$(fzf --zsh)"

### 3. fzf-tab (after compinit and fzf, before widget-wrapping plugins)
zi light Aloxaf/fzf-tab

### 4. zsh-vi-mode (config must be set before loading)
ZVM_CURSOR_STYLE_ENABLED=true
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_VI_SURROUND_BINDKEY=s-prefix
ZVM_KEYTIMEOUT=0.5
function zvm_after_init() {
    zvm_bindkey viins '^R' fzf-history-widget
}
zi light jeffreytse/zsh-vi-mode

### 5. zsh-autosuggestions
zi light zsh-users/zsh-autosuggestions

### 6. fast-syntax-highlighting (MUST be last)
zi light zdharma-continuum/fast-syntax-highlighting

#### Choose highlighting theme.
#### Use command: fast-theme {theme-name}.("-l" to list all)

## Configuration of plugins
### Set completion match character
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

### fzf-Tab
# enable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort true
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=enter:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
# zstyle ':fzf-tab:*' switch-group '<' '>'

# Load plugins which are installed by `pacman`
# source /usr/share/autojump/autojump.zsh

# Load zoxide for quick `cd`
eval "$(zoxide init zsh)"

## Options
export _ZO_EXCLUDE_DIRS="/tmp:/var:/proc:/sys:/node_modules" # exclude huge folders
export _ZO_DATA_DIR="$HOME/.local/share/zoxide" # set database location
export _ZO_EXCLUDE_PATHS=".git" # exclude .git folder

# Load snippet
## Load starship
eval "$(starship init zsh)"

## Ranger auto cd to the directory what your last opened directory before you exit. Written with ChatGPT
function rc() {
    tempfile="$(mktemp -t tmp.XXXXXX)"
    ranger --choosedir="$tempfile" "$@"
    if [ -f "$tempfile" ]; then
        dir="$(cat "$tempfile")"
        if [ -n "$dir" ] && [ -d "$dir" ]; then
            cd "$dir"
        fi
    fi
    rm -f "$tempfile"
}

## Yazi auto cd to the directory what your last opened directory before you exit. Written with ChatGPT
function yc() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Variables
# Set default editor
export EDITOR=nvim
export VISUAL=$EDITOR

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
