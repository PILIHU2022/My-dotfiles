# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

# History file
HISTFILE=${HOME}/.cache/.histfile
if [[ -f ${HOME}/.cache/.histfile || ! -f $HISTFILE ]]; then
    command touch $HISTFILE
fi
HISTSIZE=5000
SAVEHIST=5000

## History file options
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups   # remove older duplicate entries from the history
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_reduce_blanks     # remove superfluous blanks from history items
setopt hist_save_no_dups      # do not write a duplicate event to the history file
setopt inc_append_history     # allow multiple terminal sessions to append to one history
setopt inc_append_history     # write to the history file immediately, not when the shell exits.
setopt share_history          # share command history data

# Options
## 警告显示为红色
zstyle ':completion:*:warnings' format $'\e[91m -- No Matches Found --\e[0m'
## 描述显示为淡色
zstyle ':completion:*:descriptions' format $'\e[2m -- %d --\e[0m'
zstyle ':completion:*:corrections' format $'\e[93m -- %d (errors: %e) --\e[0m'
## cd 补全顺序
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'

# Alias
alias pvenv='source bin/activate'
alias syc='doas systemctl start clash-meta'
alias stc='doas systemctl stop clash-meta'
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

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.config/zsh/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

# Theme
## Load starship
eval "$(starship init zsh)"

# Add `fzf` support to search file or command history(comman history you should use it under `vi` mode)
eval "$(fzf --zsh)"

# Plugins settings
# NOTE: !!!Specail configurations for `fzf-tab`
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

## For `zsh-vi-mode`
ZVM_CURSOR_STYLE_ENABLED=true     # 光标样式开关
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk   # 回退到 Normal 模式快捷键
ZVM_VI_SURROUND_BINDKEY=s-prefix  # 环绕模式 (classic / s-prefix)
ZVM_KEYTIMEOUT=0.5                # 按键等待时间

# User snippet
## Yazi auto cd to the directory what your last opened directory before you exit. Written with ChatGPT
function yc() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Source plugins which are installed by `pacman`
source /usr/share/autojump/autojump.zsh

# Variables
## Set default editor
export EDITOR=nvim
export VISUAL=$EDITOR
source /etc/environment
# source ~/.env
