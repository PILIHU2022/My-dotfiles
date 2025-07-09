echo Hi! $USER
# Set default editor
export EDITOR=nvim
export VISUAL=$EDITOR
source /etc/environment
source ~/.config/zsh.d/fzf.zsh
# export EDITOR=nvim
#                                                 Load zinit                                                 #
##############################################################################################################

ZI_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config/zsh.d/zi.d/zi_config}
for file in ${ZI_CONFIG}/**/*(.N)
do
    [ -x "$file" ] &&  . "$file"
done

# for f ( ~/.config/zsh.d/zi.d/zi_config/*.zsh ) { source $f }

#                                                 Load plugins && settings                                   #
##############################################################################################################
source /usr/share/autojump/autojump.zsh

# set history file location
HISTFILE=${HOME}/.cache/.histfile
if [[ -f ${HOME}/.cache/.histfile || ! -f $HISTFILE ]]; then
    command touch $HISTFILE
fi
HISTSIZE=5000
SAVEHIST=5000
# Options
# See .config/zsh.d/zi/zi_config/3_zi_opt.zsh

#                                                 Aliases                                                    #
##############################################################################################################
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

# For Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Load starship
eval "$(starship init zsh)"

# Load fzf
eval "$(fzf --zsh)"

# For fontpreview content
export FONTPREVIEW_PREVIEW_TEXT="ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!@$\%(){}[]\n我能吞下玻璃而不伤身体。"

# Ranger auto cd to the directory what your last opened directory before you exit. Written with ChatGPT
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

# Yazi auto cd to the directory what your last opened directory before you exit. Written with ChatGPT
function yc() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
