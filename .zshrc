# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#                                                 Load zinit                                                 #
##############################################################################################################

ZI_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config/zsh.d/zi.d/zi_config}
for file in ${ZI_CONFIG}/**/*(.N)
do
    [ -x "$file" ] &&  . "$file"
done

source /etc/profile.d/autojump.zsh

# ZI_CONFIG=${XDG_CONFIG_HOME:-$HOME/my_dotfiles/Config/zsh.d/zi.d/zi_config}
# for file in ${ZI_CONFIG}/**/*(.N)
# do
#     [ -x "$file" ] &&  . "$file"
# done

# set history file location
HISTFILE=${HOME}/.histfile
if [[ -f ${HOME}/.zshhistfile || ! -f $HISTFILE ]]; then
    command touch $HISTFILE
fi
    HISTSIZE=10000
    SAVEHIST=10000

# alias
alias giti="git commit -m 'upload photo'"
alias sudo='doas'
# alias sudoo='sudo'
alias syv='doas systemctl start v2ray v2raya'
alias stv='doas systemctl stop v2ray v2raya'
alias neofetchm='neofetch --config ~/.config/neofetch-config.conf'
alias neofetchml='neofetch --config ~/.config/neofetch-config.conf | lolcat'
# alias vim='nvim'
alias up='doas pacman -Syu'
alias aup='paru -Syu'
alias h='Hyprland'
alias shn='shutdown -h now'
alias npm='doas npm'
alias yay='paru'
alias hs='hexo clean && hexo g && hexo s'
alias hd='hexo clean && hexo g && hexo d'
alias hsd='hexo clean && hexo g && hexo s && hexo d'
alias gc='git clone'
alias gp='git push origin main'
alias gs='git status'
alias cat='bat'
alias ls="eza -a"
alias lnvim='NVIM_APPNAME=lnvim nvim'
alias mnvim='NVIM_APPNAME=mnvim nvim'
alias fastfetchm='fastfetch --config ~/.config/fastfetch/config.jsonc --logo ~/.config/fastfetch/archlinux_logo.png'
alias waybarc='waybar -c ~/.config/hypr/waybar/config.jsonc -s ~/.config/hypr/waybar/style.css'
alias waybars='waybar -s ~/.config/hypr/waybar/style.css'
alias lst='ls --tree'
alias als='~/alist/alist server'

# 该配置无效,已弃用
# alias cdc='cd ~/Code-Workspace'
# alias cdm='cd ~/Desktop/myblog'
# alias lnvim='nvim -u ~/.config/lnvim/init.lua'
# alias mnvim='nvim -u ~/.config/mnvim/init.lua'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
