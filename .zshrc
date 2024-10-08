# Set default editor
export EDITOR=nvim
export VISUAL=$EDITOR
source /etc/environment
# export EDITOR=nvim

#                                                 About zinit                                                #
##############################################################################################################
# 
# if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
#   print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
#   command mkdir -p "$HOME/.zi" && command chmod go-rwX "$HOME/.zi"
#   command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
#     print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
#     print -P "%F{160}▓▒░ The clone has failed.%f%b"
# fi
# source "$HOME/.zi/bin/zi.zsh"
# autoload -Uz _zi
# (( ${+_comps} )) && _comps[zi]=_zi
# # examples here -> https://wiki.zshell.dev/ecosystem/category/-annexes
# zicompinit # <- https://wiki.zshell.dev/docs/guides/commands

#                                                 Load zinit                                                 #
##############################################################################################################

for f ( ~/.config/zsh.d/zi.d/zi_config/*.zsh ) { source $f }

# source ~/.config/zsh.d/zsh.d/motd/motd.zsh

# ZI_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config/zsh.d/zi.d/zi_config}
# for file in ${ZI_CONFIG}/**/*(.N)
# do
#     [ -x "$file" ] &&  . "$file"
# done

# ZI_CONFIG=${XDG_CONFIG_HOME:-$HOME/my_dotfiles/Config/zsh.d/zi.d/zi_config}
# for file in ${ZI_CONFIG}/**/*(.N)
# do
#     [ -x "$file" ] &&  . "$file"
# done

#                                                 Load plugins && settings                                   #
##############################################################################################################
source /etc/profile.d/autojump.zsh

# set history file location
HISTFILE=${HOME}/.cache/.histfile
if [[ -f ${HOME}/.zshhistfile || ! -f $HISTFILE ]]; then
    command touch $HISTFILE
fi
    HISTSIZE=10000
    SAVEHIST=10000

#                                                 Aliases                                                    #
##############################################################################################################
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

# 该配置无效,已弃用
# alias gcd='git checkout dev'
# alias giti="git commit -m 'upload photo'"
# alias c.='cd ..'
# alias gcm='git checkout main'
# alias als='~/alist/alist server'
# alias gplm='git push GitHub main && git push GitLab main' #在一个有Git版本控制的文件夹中使用，这是同时将更改上传到GitHub和GitLab的仓库中，前提是添加了这两个远程仓库，命名可更改
# alias gpld='git push GitHub dev && git push GitLab dev'
# alias sudo='doas'
# alias yay='paru'
# alias hs='hexo clean && hexo g && hexo s'
# alias hd='hexo clean && hexo g && hexo d'
# alias hsd='hexo clean && hexo g && hexo s && hexo d'
# alias cdc='cd ~/Code-Workspace'
# alias cdm='cd ~/Desktop/myblog'
# alias lnvim='nvim -u ~/.config/lnvim/init.lua'
# alias mnvim='nvim -u ~/.config/mnvim/init.lua'
# alias sudoo='sudo'
# alias vim='nvim'

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

# For fontpreview content
export FONTPREVIEW_PREVIEW_TEXT="ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!@$\%(){}[]\n我能吞下玻璃而不伤身体。"

# Ranger auto cd to the directory what your last opened directory before you exit. Written with ChatGPT
ranger_cd() {
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
